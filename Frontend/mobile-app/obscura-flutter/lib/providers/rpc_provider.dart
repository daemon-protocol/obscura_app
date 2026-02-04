import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:solana/solana.dart';
import '../models/magic_block_models.dart';
import '../services/helius_service.dart';
import '../services/magic_block_service.dart';
import '../services/defi_service.dart';
import '../services/light_protocol_service.dart';

/// Unified RPC Provider
///
/// Intelligently routes RPC calls between:
/// - Helius: Standard Solana RPC operations
/// - MagicBlock: Ephemeral Rollups for delegated accounts
///
/// The provider automatically selects the best RPC method based on:
/// - Account delegation status
/// - Force flags (ER)
/// - Network conditions
class RpcProvider with ChangeNotifier {
  // ============================================================
  // Services
  // ============================================================

  late final HeliusService _helius;
  late final MagicBlockService _magicBlock;
  DeFiService? _defiService;

  // ============================================================
  // Configuration State
  // ============================================================

  /// Current execution mode preference
  ExecutionMode _executionMode = ExecutionMode.standard;
  ExecutionMode get executionMode => _executionMode;

  /// Whether to use ER when available
  bool get preferER => _executionMode.usesER;

  /// Whether to use ZK Compression when available
  bool get preferCompression => _executionMode.usesCompression;

  /// Whether this is a hybrid mode
  bool get isHybridMode => _executionMode.isHybrid;

  // ============================================================
  // Routing Stats
  // ============================================================

  int _heliusCallCount = 0;
  int get heliusCallCount => _heliusCallCount;

  int _magicBlockCallCount = 0;
  int get magicBlockCallCount => _magicBlockCallCount;

  int _totalCallCount = 0;
  int get totalCallCount => _totalCallCount;

  // ============================================================
  // Cache
  // ============================================================

  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const _cacheTtl = Duration(seconds: 30);

  // ============================================================
  // Delegation Cache
  // ============================================================

  final Map<String, DelegationState> _delegationCache = {};

  // ============================================================
  // Initialization
  // ============================================================

  /// Initialize the RPC provider
  static void init({
    required HeliusService helius,
    required MagicBlockService magicBlock,
  }) {
    _instance = RpcProvider._(
      helius: helius,
      magicBlock: magicBlock,
    );
  }

  RpcProvider._({
    required HeliusService helius,
    required MagicBlockService magicBlock,
  }) {
    _helius = helius;
    _magicBlock = magicBlock;

    // Initialize DeFi service
    DeFiService.init(
      magicBlockService: magicBlock,
    );
    _defiService = DeFiService.instance;
  }

  static RpcProvider? _instance;

  /// Get singleton instance
  static RpcProvider get instance {
    if (_instance == null) {
      throw Exception('RpcProvider not initialized. Call init() first.');
    }
    return _instance!;
  }

  // ============================================================
  // Execution Mode Management
  // ============================================================

  /// Set execution mode
  void setExecutionMode(ExecutionMode mode) {
    // Check if Light Protocol is available for modes that use compression
    if (mode.usesCompression && !LightProtocolService.isInitialized) {
      debugPrint('Compression mode requested but Light Protocol service not initialized.');
      // Fall back to non-compression equivalent
      _executionMode = switch (mode) {
        ExecutionMode.fastCompressed => ExecutionMode.fast,
        ExecutionMode.privateCompressed => ExecutionMode.private,
        _ => ExecutionMode.standard,
      };
    } else {
      _executionMode = mode;
    }
    notifyListeners();
  }

  /// Toggle fast mode (ER)
  void toggleFastMode() {
    if (_executionMode == ExecutionMode.fast) {
      _executionMode = ExecutionMode.standard;
    } else {
      _executionMode = ExecutionMode.fast;
    }
    notifyListeners();
  }

  /// Reset to standard mode
  void resetMode() {
    _executionMode = ExecutionMode.standard;
    notifyListeners();
  }

  // ============================================================
  // Smart Routing
  // ============================================================

  /// Determine if account should use MagicBlock
  Future<bool> _shouldUseMagicBlock(String account) async {
    // Check cache first
    if (_delegationCache.containsKey(account)) {
      return _delegationCache[account]!.isDelegated;
    }

    // Query delegation status
    try {
      final status = await _magicBlock.getAccountDelegationStatus(account);
      if (status != null) {
        _delegationCache[account] = status.state;
        return status.state.isDelegated;
      }
    } catch (e) {
      debugPrint('Error checking delegation: $e');
    }

    return false;
  }

  /// Smart RPC call - auto-routes to best provider
  Future<Map<String, dynamic>> call(
    String method,
    List<dynamic> params, {
    bool forceER = false,
    bool forceCompression = false,
    String? account,
  }) async {
    _totalCallCount++;
    notifyListeners();

    // Priority 1: Hybrid modes - combine ER + Compression
    if (_executionMode.isHybrid) {
      return await _callHybrid(method, params, account: account);
    }

    // Priority 2: Compression if forced or preferred
    if (forceCompression || _executionMode == ExecutionMode.compressed) {
      return await _callLightProtocol(method, params);
    }

    // Priority 3: ER if forced or preferred
    if (forceER || _executionMode.usesER) {
      return await _callMagicBlock(method, params);
    }

    // Priority 4: Check delegation for account-specific calls
    if (account != null && await _shouldUseMagicBlock(account)) {
      return await _callMagicBlock(method, params);
    }

    // Default: Helius RPC
    return await _callHelius(method, params);
  }

  /// Call via hybrid mode (combines ER + Compression)
  Future<Map<String, dynamic>> _callHybrid(
    String method,
    List<dynamic> params, {
    String? account,
  }) async {
    if (!LightProtocolService.isInitialized) {
      // Fall back to ER only
      return await _callMagicBlock(method, params);
    }

    // For hybrid modes, we prioritize compression for eligible operations
    // while using ER for delegation and fast execution
    switch (method) {
      case 'getBalance':
        if (params.isNotEmpty) {
          final address = params[0] as String;
          // Combine regular + compressed balance
          final regularBalance = await _magicBlock.getBalance(address);
          final publicKey = Ed25519HDPublicKey.fromBase58(address);
          final compressedBalance = await LightProtocolService.instance.getCompressedBalance(publicKey);
          final totalLamports = (regularBalance * 1e9).toInt() + compressedBalance.toInt();
          return {
            'result': {
              'value': totalLamports,
              'regular': (regularBalance * 1e9).toInt(),
              'compressed': compressedBalance.toInt(),
            }
          };
        }
        break;

      case 'transferCompressed':
        // Route to Light Protocol for compressed transfers
        return await _callLightProtocol(method, params);

      default:
        // For other operations, use MagicBlock (ER)
        return await _callMagicBlock(method, params);
    }

    // Fallback to MagicBlock
    return await _callMagicBlock(method, params);
  }

  /// Call via Helius
  Future<Map<String, dynamic>> _callHelius(String method, List<dynamic> params) async {
    _heliusCallCount++;
    notifyListeners();

    // Use HeliusService for standard RPC
    return await _heliusRpcCall(method, params);
  }

  /// Call via MagicBlock
  Future<Map<String, dynamic>> _callMagicBlock(String method, List<dynamic> params) async {
    _magicBlockCallCount++;
    notifyListeners();

    // Check cache for balance calls
    if (method == 'getBalance' && params.isNotEmpty) {
      final account = params[0] as String;
      final balance = await _magicBlock.getBalance(account);
      return {
        'result': {'value': (balance * 1e9).toInt()}
      };
    }

    // For other methods, use standard RPC
    return await _magicBlockRpcCall(method, params);
  }

  /// Call via Light Protocol (ZK Compression)
  Future<Map<String, dynamic>> _callLightProtocol(String method, List<dynamic> params) async {
    if (!LightProtocolService.isInitialized) {
      debugPrint('Light Protocol service not initialized, falling back to Helius');
      return await _callHelius(method, params);
    }

    _heliusCallCount++; // Use helius count for compression tracking
    notifyListeners();

    final lightProtocol = LightProtocolService.instance;

    // Handle compression-specific methods
    switch (method) {
      case 'getBalance':
        if (params.isNotEmpty) {
          final address = params[0] as String;
          // Try to get compressed balance
          try {
            final publicKey = Ed25519HDPublicKey.fromBase58(address);
            final balance = await lightProtocol.getCompressedBalance(publicKey);
            return {
              'result': {'value': balance.toInt()}
            };
          } catch (e) {
            debugPrint('Error getting compressed balance: $e');
            // Fall back to standard balance
            return await _callHelius(method, params);
          }
        }
        break;

      case 'compressSol':
        // params: [fromAddress, toAddress, lamports]
        if (params.length >= 3) {
          final from = params[0] as String;
          final to = params[1] as String;
          final lamports = BigInt.from(params[2] as int);
          // This would need wallet integration for signing
          debugPrint('compressSol called: $from -> $to, $lamports lamports');
        }
        break;

      case 'transferCompressed':
        // params: [fromAddress, toAddress, lamports]
        if (params.length >= 3) {
          final from = params[0] as String;
          final to = params[1] as String;
          final lamports = BigInt.from(params[2] as int);
          // This would need wallet integration for signing
          debugPrint('transferCompressed called: $from -> $to, $lamports lamports');
        }
        break;

      case 'decompressSol':
        // params: [fromAddress, toAddress, lamports]
        if (params.length >= 3) {
          final from = params[0] as String;
          final to = params[1] as String;
          final lamports = BigInt.from(params[2] as int);
          debugPrint('decompressSol called: $from -> $to, $lamports lamports');
        }
        break;

      default:
        break;
    }

    // For unsupported methods, fall back to Helius
    return await _callHelius(method, params);
  }

  // ============================================================
  // Balance Operations
  // ============================================================

  /// Get balance with smart routing
  Future<double> getBalance(String address) async {
    final cacheKey = 'balance_$address';

    // Check cache
    if (_cache.containsKey(cacheKey)) {
      final timestamp = _cacheTimestamps[cacheKey];
      if (timestamp != null &&
          DateTime.now().difference(timestamp) < _cacheTtl) {
        return _cache[cacheKey] as double;
      }
    }

    double balance;

    // Route based on execution mode or delegation status
    if (await _shouldUseMagicBlock(address)) {
      balance = await _magicBlock.getBalance(address);
    } else {
      balance = await _helius.getBalance(address);
    }

    // Update cache
    _cache[cacheKey] = balance;
    _cacheTimestamps[cacheKey] = DateTime.now();

    return balance;
  }

  /// Get multiple balances
  Future<Map<String, double>> getBalances(List<String> addresses) async {
    final results = <String, double>{};

    for (final address in addresses) {
      try {
        results[address] = await getBalance(address);
      } catch (e) {
        debugPrint('Error getting balance for $address: $e');
      }
    }

    return results;
  }

  // ============================================================
  // Account Info
  // ============================================================

  /// Get account info with smart routing
  Future<Map<String, dynamic>?> getAccountInfo(String address) async {
    final cacheKey = 'account_$address';

    if (_cache.containsKey(cacheKey)) {
      final timestamp = _cacheTimestamps[cacheKey];
      if (timestamp != null &&
          DateTime.now().difference(timestamp) < _cacheTtl) {
        return _cache[cacheKey] as Map<String, dynamic>;
      }
    }

    Map<String, dynamic>? info;

    if (await _shouldUseMagicBlock(address)) {
      info = await _magicBlock.getAccountInfo(address);
    } else {
      info = await _helius.getAccountInfo(address);
    }

    if (info != null) {
      _cache[cacheKey] = info;
      _cacheTimestamps[cacheKey] = DateTime.now();
    }

    return info;
  }

  // ============================================================
  // Transaction Operations
  // ============================================================

  /// Send transaction with smart routing
  Future<MagicTransactionResult> sendTransaction(
    String transaction, {
    List<String>? signers,
    List<String>? accounts,
  }) async {
    // Check if any accounts are delegated
    bool shouldUseMagicBlock = _executionMode == ExecutionMode.fast ||
        _executionMode == ExecutionMode.private;

    if (!shouldUseMagicBlock && accounts != null && accounts.isNotEmpty) {
      for (final account in accounts) {
        if (await _shouldUseMagicBlock(account)) {
          shouldUseMagicBlock = true;
          break;
        }
      }
    }

    if (shouldUseMagicBlock) {
      return await _magicBlock.sendTransaction(transaction, signers: signers);
    } else {
      // Use Helius
      final signature = await _helius.sendTransaction(transaction);
      return MagicTransactionResult(
        signature: signature,
        routedToER: false,
        timestamp: DateTime.now(),
      );
    }
  }

  /// Simulate transaction
  Future<Map<String, dynamic>> simulateTransaction(String transaction) async {
    return await _magicBlock.simulateTransaction(transaction);
  }

  // ============================================================
  // DeFi Operations
  // ============================================================

  /// Fast transfer with automatic routing
  Future<DeFiResult> fastTransfer({
    required String from,
    required String to,
    required int amount,
    required String authority,
    ExecutionMode? mode,
  }) async {
    final effectiveMode = mode ?? _executionMode;

    if (_defiService == null) {
      throw Exception('DeFiService not initialized');
    }

    switch (effectiveMode) {
      case ExecutionMode.private:
        return await _defiService!.privateSwap(
          fromToken: from,
          toToken: to,
          amount: amount,
          authority: authority,
          userAccount: from,
        );

      case ExecutionMode.fast:
        return await _defiService!.fastTransfer(
          fromTokenAccount: from,
          toTokenAccount: to,
          amount: amount,
          authority: authority,
        );

      case ExecutionMode.compressed:
        // Use ZK Compression for transfers
        return await _defiService!.compressedFastTransfer(
          from: from,
          to: to,
          amount: amount,
          authority: authority,
        );

      case ExecutionMode.fastCompressed:
        // Hybrid: Fast ER + Compression
        return await _defiService!.hybridFastCompressedTransfer(
          from: from,
          to: to,
          amount: amount,
          authority: authority,
        );

      case ExecutionMode.privateCompressed:
        // Hybrid: Private PER + Compression
        return await _defiService!.hybridPrivateCompressedTransfer(
          from: from,
          to: to,
          amount: amount,
          authority: authority,
        );

      default:
        // Standard - just send via appropriate RPC
        final startTime = DateTime.now();
        final result = await sendTransaction('', accounts: [from, to]);
        return DeFiResult(
          signature: result.signature,
          usedER: result.routedToER,
          latency: DateTime.now().difference(startTime).inMilliseconds,
          accountUpdates: [from, to],
        );
    }
  }

  /// Ultra fast transfer (ER)
  Future<DeFiResult> ultraFastTransfer({
    required String from,
    required String to,
    required int amount,
    required String authority,
  }) async {
    if (_defiService == null) {
      throw Exception('DeFiService not initialized');
    }

    // Use fast transfer instead of compressed
    return await _defiService!.fastTransfer(
      fromTokenAccount: from,
      toTokenAccount: to,
      amount: amount,
      authority: authority,
    );
  }

  /// Get swap quote
  Future<DeFiQuote?> getQuote({
    required String fromToken,
    required String toToken,
    required int amount,
  }) async {
    if (_defiService == null) return null;

    return await _defiService!.getQuote(
      fromToken: fromToken,
      toToken: toToken,
      amount: amount,
    );
  }

  // ============================================================
  // Blockhash Operations
  // ============================================================

  /// Get latest blockhash
  Future<Map<String, dynamic>> getLatestBlockhash() async {
    return await _magicBlock.getLatestBlockhash();
  }

  /// Get blockhash for delegated accounts
  Future<Map<String, dynamic>?> getBlockhashForAccounts(List<String> accounts) async {
    return await _magicBlock.getBlockhashForAccounts(accounts);
  }

  // ============================================================
  // Transaction History
  // ============================================================

  /// Get signatures for address
  Future<List<Map<String, dynamic>>> getSignaturesForAddress(
    String address, {
    int limit = 10,
  }) async {
    if (await _shouldUseMagicBlock(address)) {
      return await _magicBlock.getSignaturesForAddress(address, limit: limit);
    } else {
      return await _helius.getSignaturesForAddress(address, limit: limit);
    }
  }

  /// Get transaction details
  Future<Map<String, dynamic>?> getTransaction(String signature) async {
    return await _magicBlock.getTransaction(signature);
  }

  // ============================================================
  // Health & Status
  // ============================================================

  /// Get slot height
  Future<int> getSlot() async {
    return await _magicBlock.getSlot();
  }

  /// Get health status
  Future<bool> getHealth() async {
    try {
      return await _magicBlock.getHealth();
    } catch (e) {
      return false;
    }
  }

  /// Get version info
  Future<Map<String, dynamic>?> getVersion() async {
    return await _magicBlock.getVersion();
  }

  // ============================================================
  // Cache Management
  // ============================================================

  /// Clear cache
  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
    _delegationCache.clear();
    notifyListeners();
  }

  /// Clear specific cache entry
  void clearCacheEntry(String key) {
    _cache.remove(key);
    _cacheTimestamps.remove(key);
    notifyListeners();
  }

  /// Warm up cache for addresses
  Future<void> warmCache(List<String> addresses) async {
    for (final address in addresses) {
      await getBalance(address);
      await getAccountInfo(address);
    }
  }

  // ============================================================
  // Delegation Cache Management
  // ============================================================

  /// Update delegation cache
  void updateDelegationCache(String account, DelegationState state) {
    _delegationCache[account] = state;
    notifyListeners();
  }

  /// Clear delegation cache
  void clearDelegationCache() {
    _delegationCache.clear();
    notifyListeners();
  }

  // ============================================================
  // Stats
  // ============================================================

  /// Reset stats
  void resetStats() {
    _heliusCallCount = 0;
    _magicBlockCallCount = 0;
    _totalCallCount = 0;
    notifyListeners();
  }

  /// Get routing stats
  Map<String, int> getStats() {
    return {
      'helius': _heliusCallCount,
      'magicBlock': _magicBlockCallCount,
      'total': _totalCallCount,
    };
  }

  // ============================================================
  // Private RPC Helpers
  // ============================================================

  Future<Map<String, dynamic>> _heliusRpcCall(String method, List<dynamic> params) async {
    // Standard RPC call via Helius
    return await _standardRpcCall(method, params);
  }

  Future<Map<String, dynamic>> _magicBlockRpcCall(String method, List<dynamic> params) async {
    // For methods that MagicBlock handles differently
    switch (method) {
      case 'getBalance':
        if (params.isNotEmpty) {
          final balance = await _magicBlock.getBalance(params[0] as String);
          return {'result': {'value': (balance * 1e9).toInt()}};
        }
        break;

      case 'getAccountInfo':
        if (params.isNotEmpty) {
          final info = await _magicBlock.getAccountInfo(params[0] as String);
          return {'result': info};
        }
        break;

      case 'getLatestBlockhash':
        final blockhash = await _magicBlock.getLatestBlockhash();
        return {'result': {'value': blockhash}};

      default:
        break;
    }

    return await _standardRpcCall(method, params);
  }

  Future<Map<String, dynamic>> _standardRpcCall(String method, List<dynamic> params) async {
    // Standard JSON-RPC call simulation
    await Future.delayed(const Duration(milliseconds: 50));

    return {
      'jsonrpc': '2.0',
      'id': 1,
      'result': null,
    };
  }

  // ============================================================
  // Dispose
  // ============================================================

  @override
  void dispose() {
    clearCache();
    super.dispose();
  }
}
