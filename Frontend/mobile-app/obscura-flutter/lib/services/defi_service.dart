import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/magic_block_models.dart';
import 'magic_block_service.dart';
import 'light_protocol_service.dart';
import 'package:solana/solana.dart';

/// DeFi Service for fast transactions using MagicBlock ER and Light Protocol
///
/// Provides optimized DeFi operations including:
/// - Fast transfers with ER delegation
/// - Fast swaps with ER execution
/// - Batch operations
/// - Private operations using PER
/// - ZK Compression for cheaper transactions
class DeFiService {
  DeFiService._({
    required this.magicBlockService,
  });

  final MagicBlockService magicBlockService;

  static DeFiService? _instance;

  /// Get singleton instance
  static DeFiService get instance {
    if (_instance == null) {
      throw Exception('DeFiService not initialized. Call init() first.');
    }
    return _instance!;
  }

  /// Initialize the service
  static void init({
    required MagicBlockService magicBlockService,
  }) {
    _instance = DeFiService._(
      magicBlockService: magicBlockService,
    );
  }

  // ============================================================
  // Fast Transfer
  // ============================================================

  /// Execute a fast transfer using Ephemeral Rollups
  ///
  /// Automatically delegates the account if needed and executes
  /// the transfer on ER for sub-50ms confirmation.
  Future<DeFiResult> fastTransfer({
    required String fromTokenAccount,
    required String toTokenAccount,
    required int amount,
    required String authority,
    bool autoDelegate = true,
    bool autoCommit = true,
  }) async {
    final startTime = DateTime.now();

    try {
      // Check if account is delegated
      final delegationStatus =
          await magicBlockService.getAccountDelegationStatus(fromTokenAccount);

      bool needsDelegation = delegationStatus == null ||
          !delegationStatus.state.isDelegated;

      String? delegateSignature;

      // Auto-delegate if needed
      if (needsDelegation && autoDelegate) {
        delegateSignature = await magicBlockService.delegateAccount(
          accountAddress: fromTokenAccount,
          authority: authority,
          commitFrequencyMs: 30000,
        );

        // Wait for delegation to be processed
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Create and send transfer transaction
      // Note: In production, this would create an actual Solana
      // transfer instruction and send it via Magic Router
      final transferSignature = await _executeTransferInstruction(
        fromTokenAccount: fromTokenAccount,
        toTokenAccount: toTokenAccount,
        amount: amount,
        authority: authority,
      );

      // Auto-commit if requested
      String? commitSignature;
      if (autoCommit && (needsDelegation || delegationStatus?.state.isDelegated == true)) {
        commitSignature = await magicBlockService.commitAccounts(
          accounts: [fromTokenAccount, toTokenAccount],
          authority: authority,
        );
      }

      final latency = DateTime.now().difference(startTime).inMilliseconds;

      return DeFiResult(
        signature: transferSignature,
        usedER: true,
        latency: latency,
        validator: delegationStatus?.validator,
        accountUpdates: [fromTokenAccount, toTokenAccount],
        delegateSignature: delegateSignature,
        commitSignature: commitSignature,
      );
    } catch (e) {
      final latency = DateTime.now().difference(startTime).inMilliseconds;

      return DeFiResult(
        signature: '',
        usedER: false,
        latency: latency,
        error: e.toString(),
        accountUpdates: [],
      );
    }
  }

  /// Execute transfer instruction
  Future<String> _executeTransferInstruction({
    required String fromTokenAccount,
    required String toTokenAccount,
    required int amount,
    required String authority,
  }) async {
    // In production, this would:
    // 1. Create a Solana transfer instruction
    // 2. Build a transaction with the instruction
    // 3. Sign it with the authority
    // 4. Send it via Magic Router
    //
    // For now, we simulate it with a mock signature
    await Future.delayed(const Duration(milliseconds: 50));

    // Generate mock signature
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'ER${timestamp.toString().padLeft(60, '0')}';
  }

  // ============================================================
  // Compressed Fast Transfer (ZK Compression)
  // ============================================================

  /// Compressed fast transfer using ZK Compression
  ///
  /// Uses Light Protocol's ZK Compression for significantly cheaper
  /// transactions (~1000x cheaper storage costs).
  Future<DeFiResult> compressedFastTransfer({
    required String from,
    required String to,
    required int amount,
    required String authority,
  }) async {
    final startTime = DateTime.now();

    try {
      // Check if Light Protocol is initialized
      if (!LightProtocolService.isInitialized) {
        debugPrint('Light Protocol not initialized, falling back to fast transfer');
        return await fastTransfer(
          fromTokenAccount: from,
          toTokenAccount: to,
          amount: amount,
          authority: authority,
        );
      }

      final lightProtocol = LightProtocolService.instance;
      final wallet = await _getWalletKeyPair(authority);

      // Try to transfer compressed SOL
      try {
        final signature = await lightProtocol.transferCompressedSol(
          payer: wallet,
          owner: wallet,
          lamports: BigInt.from(amount),
          toAddress: Ed25519HDPublicKey.fromBase58(to),
        );

        final latency = DateTime.now().difference(startTime).inMilliseconds;

        return DeFiResult(
          signature: signature,
          usedER: false,
          latency: latency,
          isCompressed: true,
          accountUpdates: [from, to],
        );
      } catch (e) {
        // If no compressed balance, compress first then transfer
        debugPrint('No compressed balance, compressing first: $e');

        // Step 1: Compress SOL
        final compressSignature = await lightProtocol.compressSol(
          payer: wallet,
          lamports: BigInt.from(amount),
          toAddress: wallet.publicKey,
        );

        // Wait for compression to be processed
        await Future.delayed(const Duration(milliseconds: 500));

        // Step 2: Transfer compressed SOL
        final signature = await lightProtocol.transferCompressedSol(
          payer: wallet,
          owner: wallet,
          lamports: BigInt.from(amount),
          toAddress: Ed25519HDPublicKey.fromBase58(to),
        );

        final latency = DateTime.now().difference(startTime).inMilliseconds;

        return DeFiResult(
          signature: signature,
          usedER: false,
          latency: latency,
          isCompressed: true,
          accountUpdates: [from, to],
          delegateSignature: compressSignature, // Store compress signature
        );
      }
    } catch (e) {
      debugPrint('Compressed transfer failed: $e');
      final latency = DateTime.now().difference(startTime).inMilliseconds;

      // Fallback to regular transfer
      return DeFiResult(
        signature: '',
        usedER: false,
        latency: latency,
        error: e.toString(),
        accountUpdates: [],
      );
    }
  }

  /// Get wallet keypair from authority string
  ///
  /// In production, this would retrieve the actual keypair from
  /// secure storage or the wallet provider.
  Future<Ed25519HDKeyPair> _getWalletKeyPair(String authority) async {
    // For demo purposes, create a new keypair
    // In production, retrieve from wallet provider
    final mnemonic = authority.isNotEmpty
        ? authority
        : 'result comes here when test twelve was fabric branch elastic garlic curious';

    return await Ed25519HDKeyPair.fromMnemonic(mnemonic);
  }

  /// Check if account has compressed balance
  Future<bool> hasCompressedBalance(String address) async {
    if (!LightProtocolService.isInitialized) return false;

    try {
      final lightProtocol = LightProtocolService.instance;
      final publicKey = Ed25519HDPublicKey.fromBase58(address);
      final balance = await lightProtocol.getCompressedBalance(publicKey);
      return balance > BigInt.zero;
    } catch (e) {
      debugPrint('Error checking compressed balance: $e');
      return false;
    }
  }

  /// Get compressed balance for address
  Future<double> getCompressedBalance(String address) async {
    if (!LightProtocolService.isInitialized) return 0.0;

    try {
      final lightProtocol = LightProtocolService.instance;
      final publicKey = Ed25519HDPublicKey.fromBase58(address);
      final balance = await lightProtocol.getCompressedBalance(publicKey);
      return lightProtocol.lamportsToSol(balance);
    } catch (e) {
      debugPrint('Error getting compressed balance: $e');
      return 0.0;
    }
  }

  // ============================================================
  // Fast Swap
  // ============================================================

  /// Execute a fast swap using Ephemeral Rollups
  ///
  /// Routes through the specified DEX with ER execution.
  Future<DeFiResult> fastSwap({
    required String fromToken,
    required String toToken,
    required int amount,
    required String authority,
    required String dexProgram,
    String? userTokenAccount,
    bool useER = true,
  }) async {
    final startTime = DateTime.now();

    try {
      String? delegateSignature;

      // Check delegation if using ER
      if (useER && userTokenAccount != null) {
        final delegationStatus =
            await magicBlockService.getAccountDelegationStatus(userTokenAccount);

        if (delegationStatus == null || !delegationStatus.state.isDelegated) {
          delegateSignature = await magicBlockService.delegateAccount(
            accountAddress: userTokenAccount,
            authority: authority,
          );
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      // Execute swap on DEX
      final swapSignature = await _executeSwapInstruction(
        fromToken: fromToken,
        toToken: toToken,
        amount: amount,
        authority: authority,
        dexProgram: dexProgram,
      );

      // Commit if ER was used
      String? commitSignature;
      if (useER && userTokenAccount != null) {
        commitSignature = await magicBlockService.commitAccounts(
          accounts: [userTokenAccount],
          authority: authority,
        );
      }

      final latency = DateTime.now().difference(startTime).inMilliseconds;

      return DeFiResult(
        signature: swapSignature,
        usedER: useER,
        latency: latency,
        accountUpdates: userTokenAccount != null ? [userTokenAccount] : [],
        delegateSignature: delegateSignature,
        commitSignature: commitSignature,
      );
    } catch (e) {
      final latency = DateTime.now().difference(startTime).inMilliseconds;

      return DeFiResult(
        signature: '',
        usedER: false,
        latency: latency,
        error: e.toString(),
        accountUpdates: [],
      );
    }
  }

  /// Execute swap instruction
  Future<String> _executeSwapInstruction({
    required String fromToken,
    required String toToken,
    required int amount,
    required String authority,
    required String dexProgram,
  }) async {
    // In production, this would:
    // 1. Create swap instruction for the DEX (Jupiter, Orca, etc.)
    // 2. Build transaction with swap + any necessary instructions
    // 3. Sign and send via Magic Router
    await Future.delayed(const Duration(milliseconds: 75));

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'SWAP${timestamp.toString().padLeft(58, '0')}';
  }

  // ============================================================
  // Batch Transfers
  // ============================================================

  /// Execute multiple transfers in a single ER session
  ///
  /// More efficient than individual transfers as all operations
  /// happen on ER before a single commit.
  Future<DeFiResult> batchTransfers({
    required List<TransferInstruction> transfers,
    required String authority,
    bool autoCommit = true,
  }) async {
    final startTime = DateTime.now();

    try {
      if (transfers.isEmpty) {
        throw ArgumentError('At least one transfer required');
      }

      // Get unique accounts
      final accounts = transfers
          .expand((t) => [t.from, t.to])
          .toSet()
          .toList();

      // Check delegation status
      final delegationStatuses = await magicBlockService.getDelegationStatus(accounts);

      // Delegate any non-delegated accounts
      final delegateSignatures = <String>[];
      for (final account in accounts) {
        final status = delegationStatuses
            .firstWhere((s) => s.account == account, orElse: () => DelegationStatus.notDelegated(account));

        if (!status.state.isDelegated) {
          final sig = await magicBlockService.delegateAccount(
            accountAddress: account,
            authority: authority,
          );
          delegateSignatures.add(sig);
        }
      }

      // Wait for delegations
      if (delegateSignatures.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Execute all transfers
      final transferSignatures = <String>[];
      for (final transfer in transfers) {
        final sig = await _executeTransferInstruction(
          fromTokenAccount: transfer.from,
          toTokenAccount: transfer.to,
          amount: transfer.amount,
          authority: authority,
        );
        transferSignatures.add(sig);
      }

      // Commit all changes
      String? commitSignature;
      if (autoCommit) {
        commitSignature = await magicBlockService.commitAccounts(
          accounts: accounts,
          authority: authority,
        );
      }

      final latency = DateTime.now().difference(startTime).inMilliseconds;

      return DeFiResult(
        signature: transferSignatures.first,
        usedER: true,
        latency: latency,
        accountUpdates: accounts,
        delegateSignature: delegateSignatures.isNotEmpty ? delegateSignatures.first : null,
        commitSignature: commitSignature,
        batchCount: transfers.length,
      );
    } catch (e) {
      final latency = DateTime.now().difference(startTime).inMilliseconds;

      return DeFiResult(
        signature: '',
        usedER: false,
        latency: latency,
        error: e.toString(),
        accountUpdates: [],
      );
    }
  }

  // ============================================================
  // Private Swap (PER)
  // ============================================================

  /// Execute a private swap using PER (TEE-based privacy)
  Future<DeFiResult> privateSwap({
    required String fromToken,
    required String toToken,
    required int amount,
    required String authority,
    String? userAccount,
  }) async {
    final startTime = DateTime.now();

    try {
      final signature = await magicBlockService.executePrivateTransfer(
        from: fromToken,
        to: toToken,
        amount: amount,
        authority: authority,
      );

      final latency = DateTime.now().difference(startTime).inMilliseconds;

      return DeFiResult(
        signature: signature,
        usedER: true,
        latency: latency,
        isPrivate: true,
        accountUpdates: userAccount != null ? [userAccount] : [],
      );
    } catch (e) {
      final latency = DateTime.now().difference(startTime).inMilliseconds;

      return DeFiResult(
        signature: '',
        usedER: false,
        latency: latency,
        error: e.toString(),
        accountUpdates: [],
      );
    }
  }

  // ============================================================
  // Get Quote
  // ============================================================

  /// Get swap quote from DEX
  Future<DeFiQuote?> getQuote({
    required String fromToken,
    required String toToken,
    required int amount,
    String? dexProgram,
  }) async {
    try {
      // In production, this would query Jupiter, Orca, or other DEXs
      // for actual quotes
      await Future.delayed(const Duration(milliseconds: 100));

      // Mock quote (1% slippage)
      final outputAmount = (amount * 0.99).toInt();

      return DeFiQuote(
        fromToken: fromToken,
        toToken: toToken,
        inputAmount: amount,
        outputAmount: outputAmount,
        priceImpact: 0.01,
        dex: dexProgram ?? 'Jupiter',
        estimatedLatencyMs: 50,
      );
    } catch (e) {
      debugPrint('Error getting quote: $e');
      return null;
    }
  }

  // ============================================================
  // Get Balance
  // ============================================================

  /// Get balance with automatic routing
  Future<double> getBalance(String address) async {
    try {
      // Try MagicBlock first (for delegated accounts)
      return await magicBlockService.getBalance(address);
    } catch (e) {
      debugPrint('Error getting balance: $e');
      return 0.0;
    }
  }

  // ============================================================
  // Hybrid Transfer Methods
  // ============================================================

  /// Hybrid Fast + Compressed Transfer
  ///
  /// Combines ER speed with ZK Compression cost savings:
  /// 1. Checks compressed balance availability
  /// 2. Delegates account to ER if not already delegated
  /// 3. Compresses SOL if needed
  /// 4. Executes compressed transfer via ER
  /// 5. Commits changes and returns result
  Future<DeFiResult> hybridFastCompressedTransfer({
    required String from,
    required String to,
    required int amount,
    required String authority,
  }) async {
    final startTime = DateTime.now();

    try {
      // Check if Light Protocol is available
      if (!LightProtocolService.isInitialized) {
        debugPrint('Light Protocol not initialized, falling back to fast transfer');
        return await fastTransfer(
          fromTokenAccount: from,
          toTokenAccount: to,
          amount: amount,
          authority: authority,
        );
      }

      final lightProtocol = LightProtocolService.instance;
      final wallet = await _getWalletKeyPair(authority);

      // Step 1: Check if account has compressed balance
      final hasCompressedBalance = await this.hasCompressedBalance(from);

      String? compressSignature;
      String? delegateSignature;

      // Step 2: Compress SOL if no compressed balance
      if (!hasCompressedBalance) {
        compressSignature = await lightProtocol.compressSol(
          payer: wallet,
          lamports: BigInt.from(amount),
          toAddress: wallet.publicKey,
        );
        await Future.delayed(const Duration(milliseconds: 200));
      }

      // Step 3: Check delegation status and delegate if needed
      final delegationStatus =
          await magicBlockService.getAccountDelegationStatus(from);

      if (delegationStatus == null || !delegationStatus.state.isDelegated) {
        delegateSignature = await magicBlockService.delegateAccount(
          accountAddress: from,
          authority: authority,
          commitFrequencyMs: 30000,
        );
        await Future.delayed(const Duration(milliseconds: 300));
      }

      // Step 4: Execute compressed transfer (will route through ER)
      final signature = await lightProtocol.transferCompressedSol(
        payer: wallet,
        owner: wallet,
        lamports: BigInt.from(amount),
        toAddress: Ed25519HDPublicKey.fromBase58(to),
      );

      // Step 5: Commit ER changes if delegated
      String? commitSignature;
      if (delegateSignature != null || delegationStatus?.state.isDelegated == true) {
        commitSignature = await magicBlockService.commitAccounts(
          accounts: [from, to],
          authority: authority,
        );
      }

      final latency = DateTime.now().difference(startTime).inMilliseconds;

      return DeFiResult(
        signature: signature,
        usedER: true,
        latency: latency,
        isCompressed: true,
        isPrivate: false,
        isHybrid: true,
        validator: delegationStatus?.validator,
        accountUpdates: [from, to],
        delegateSignature: delegateSignature,
        commitSignature: commitSignature,
        compressSignature: compressSignature,
      );
    } catch (e) {
      debugPrint('Hybrid fast compressed transfer failed: $e');
      final latency = DateTime.now().difference(startTime).inMilliseconds;

      return DeFiResult(
        signature: '',
        usedER: false,
        latency: latency,
        error: e.toString(),
        accountUpdates: [],
      );
    }
  }

  /// Hybrid Private + Compressed Transfer
  ///
  /// Combines PER privacy with ZK Compression cost savings:
  /// 1. Compresses SOL if needed
  /// 2. Routes to PER for private execution
  /// 3. Returns result with all flags (private, compressed, ER)
  Future<DeFiResult> hybridPrivateCompressedTransfer({
    required String from,
    required String to,
    required int amount,
    required String authority,
  }) async {
    final startTime = DateTime.now();

    try {
      // Check if Light Protocol is available
      if (!LightProtocolService.isInitialized) {
        debugPrint('Light Protocol not initialized, falling back to private swap');
        return await privateSwap(
          fromToken: from,
          toToken: to,
          amount: amount,
          authority: authority,
          userAccount: from,
        );
      }

      final lightProtocol = LightProtocolService.instance;
      final wallet = await _getWalletKeyPair(authority);

      // Step 1: Check and compress if needed
      String? compressSignature;
      final hasCompressedBalance = await this.hasCompressedBalance(from);

      if (!hasCompressedBalance) {
        compressSignature = await lightProtocol.compressSol(
          payer: wallet,
          lamports: BigInt.from(amount),
          toAddress: wallet.publicKey,
        );
        await Future.delayed(const Duration(milliseconds: 200));
      }

      // Step 2: Execute private transfer via PER with compressed data
      final signature = await magicBlockService.executePrivateTransfer(
        from: from,
        to: to,
        amount: amount,
        authority: authority,
      );

      final latency = DateTime.now().difference(startTime).inMilliseconds;

      return DeFiResult(
        signature: signature,
        usedER: true,
        latency: latency,
        isCompressed: true,
        isPrivate: true,
        isHybrid: true,
        accountUpdates: [from, to],
        compressSignature: compressSignature,
      );
    } catch (e) {
      debugPrint('Hybrid private compressed transfer failed: $e');
      final latency = DateTime.now().difference(startTime).inMilliseconds;

      return DeFiResult(
        signature: '',
        usedER: false,
        latency: latency,
        error: e.toString(),
        accountUpdates: [],
      );
    }
  }
}

/// Transfer instruction for batch operations
class TransferInstruction {
  final String from;
  final String to;
  final int amount;

  TransferInstruction({
    required this.from,
    required this.to,
    required this.amount,
  });
}

/// DeFi operation result
class DeFiResult {
  /// Transaction signature
  final String signature;

  /// Whether ER was used
  final bool usedER;

  /// Execution time in milliseconds
  final int latency;

  /// Validator that processed (if ER)
  final String? validator;

  /// Accounts that were updated
  final List<String> accountUpdates;

  /// Delegation transaction signature (if any)
  final String? delegateSignature;

  /// Commit transaction signature (if any)
  final String? commitSignature;

  /// Number of operations in batch
  final int? batchCount;

  /// Whether operation was private (PER)
  final bool isPrivate;

  /// Whether operation used ZK Compression
  final bool isCompressed;

  /// Whether operation was hybrid (combined multiple technologies)
  final bool isHybrid;

  /// Compression transaction signature (if any)
  final String? compressSignature;

  /// Error message if failed
  final String? error;

  DeFiResult({
    required this.signature,
    required this.usedER,
    required this.latency,
    this.validator,
    this.accountUpdates = const [],
    this.delegateSignature,
    this.commitSignature,
    this.batchCount,
    this.isPrivate = false,
    this.isCompressed = false,
    this.isHybrid = false,
    this.compressSignature,
    this.error,
  });

  /// Whether the operation was successful
  bool get isSuccess => error == null && signature.isNotEmpty;

  /// Get formatted latency string
  String get latencyString {
    if (latency < 100) return '${latency}ms ⚡';
    if (latency < 500) return '${latency}ms';
    return '${(latency / 1000).toStringAsFixed(1)}s';
  }

  /// Get mode description based on flags
  String get modeDescription {
    if (isHybrid) {
      if (isPrivate && isCompressed) return 'Private + Compressed';
      if (isCompressed) return 'Fast + Compressed';
      return 'Hybrid';
    }
    if (isPrivate) return 'Private (PER)';
    if (isCompressed) return 'Compressed';
    if (usedER) return 'Fast (ER)';
    return 'Standard';
  }

  /// Get mode emoji
  String get modeEmoji {
    if (isHybrid) {
      if (isPrivate && isCompressed) return '🔒🗜️';
      if (isCompressed) return '⚡🗜️';
      return '🔀';
    }
    if (isPrivate) return '🔒';
    if (isCompressed) return '🗜️';
    if (usedER) return '⚡';
    return '⏱️';
  }

  /// Whether this is a hybrid mode
  bool get isHybridMode => isHybrid;

  @override
  String toString() {
    return 'DeFiResult(signature: $signature, usedER: $usedER, isCompressed: $isCompressed, isHybrid: $isHybrid, latency: ${latency}ms, success: $isSuccess)';
  }
}

/// DeFi swap quote
class DeFiQuote {
  final String fromToken;
  final String toToken;
  final int inputAmount;
  final int outputAmount;
  final double priceImpact;
  final String dex;
  final int estimatedLatencyMs;

  DeFiQuote({
    required this.fromToken,
    required this.toToken,
    required this.inputAmount,
    required this.outputAmount,
    required this.priceImpact,
    required this.dex,
    required this.estimatedLatencyMs,
  });

  /// Get exchange rate
  double get rate => inputAmount > 0 ? outputAmount / inputAmount : 0;

  /// Get minimum output with slippage tolerance
  int get minOutputAmount => (outputAmount * (1 - 0.01)).toInt();

  @override
  String toString() {
    return 'DeFiQuote($inputAmount $fromToken -> $outputAmount $toToken via $dex)';
  }
}
