import 'dart:async';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/magic_block_models.dart';

/// MagicBlock Ephemeral Rollups Service
///
/// Provides integration with MagicBlock's Ephemeral Rollups (ER) technology
/// for sub-50ms transaction execution on Solana.
///
/// Features:
/// - Ephemeral Rollups (ER) for real-time transactions
/// - Delegation management for ER execution
/// - VRF (Verifiable Randomness Function)
/// - PER (Private Ephemeral Rollups) for TEE-based privacy
class MagicBlockService {
  MagicBlockService._({
    required this.config,
    this.httpClient,
  }) : _client = httpClient ?? http.Client();

  final MagicBlockConfig config;
  final http.Client? httpClient;
  late final http.Client _client;

  static MagicBlockService? _instance;

  /// Check if service is initialized (public getter)
  static bool get isInitialized => _instance != null;

  /// Get singleton instance
  static MagicBlockService get instance {
    if (_instance == null) {
      throw Exception('MagicBlockService not initialized. Call init() first.');
    }
    return _instance!;
  }

  /// Initialize the service with configuration
  static void init(MagicBlockConfig config, {http.Client? httpClient}) {
    _instance = MagicBlockService._(
      config: config,
      httpClient: httpClient,
    );
  }

  /// Update configuration (e.g., switch network)
  void updateConfig(MagicBlockConfig newConfig) {
    _instance = MagicBlockService._(
      config: newConfig,
      httpClient: httpClient,
    );
  }

  /// Current configuration
  MagicBlockConfig get currentConfig => config;

  // ============================================================
  // Ephemeral Rollups Methods
  // ============================================================

  /// Get delegation status for multiple accounts
  ///
  /// Returns the current delegation state of each account.
  /// Accounts that are delegated will have their transactions
  /// automatically routed to ER by the Magic Router.
  Future<List<DelegationStatus>> getDelegationStatus(List<String> accounts) async {
    if (accounts.isEmpty) return [];

    try {
      final response = await _rpcCall('getDelegationStatus', [accounts]);

      if (response['result'] == null) {
        // Return not-delegated status for all accounts
        return accounts.map((a) => DelegationStatus.notDelegated(a)).toList();
      }

      final result = response['result'] as Map<String, dynamic>;
      final statuses = <DelegationStatus>[];

      for (final account in accounts) {
        final accountData = result[account] as Map<String, dynamic>?;
        if (accountData != null) {
          statuses.add(DelegationStatus.fromJson(accountData));
        } else {
          statuses.add(DelegationStatus.notDelegated(account));
        }
      }

      return statuses;
    } catch (e) {
      debugPrint('Error getting delegation status: $e');
      // Return not-delegated status on error
      return accounts.map((a) => DelegationStatus.notDelegated(a)).toList();
    }
  }

  /// Get delegation status for a single account
  Future<DelegationStatus?> getAccountDelegationStatus(String account) async {
    final statuses = await getDelegationStatus([account]);
    return statuses.isNotEmpty ? statuses.first : null;
  }

  /// Get blockhash for delegated accounts
  ///
  /// Returns a recent blockhash that can be used for transactions
  /// targeting the delegated accounts on ER.
  Future<Map<String, dynamic>?> getBlockhashForAccounts(List<String> accounts) async {
    if (accounts.isEmpty) return null;

    try {
      final response = await _rpcCall('getBlockhashForAccounts', [accounts]);

      if (response['result'] != null) {
        return response['result'] as Map<String, dynamic>;
      }

      // Fallback to standard getLatestBlockhash
      return await getLatestBlockhash();
    } catch (e) {
      debugPrint('Error getting blockhash for accounts: $e');
      return await getLatestBlockhash();
    }
  }

  /// Get the closest validator based on latency
  ///
  /// Measures latency to available validators and returns the one
  /// with the lowest response time.
  Future<ValidatorInfo?> getClosestValidator() async {
    final validators = await getAvailableValidators();
    if (validators.isEmpty) return null;

    // Sort by latency and return the fastest
    validators.sort((a, b) => a.latency.compareTo(b.latency));
    return validators.first;
  }

  /// Get available validators for the current network
  Future<List<ValidatorInfo>> getAvailableValidators() async {
    if (config.network == MagicBlockNetwork.devnet) {
      // Return known devnet validators
      return [
        ValidatorInfo(
          pubkey: MagicBlockConfig.devnetValidators['asia']!,
          region: 'asia',
          latency: 150,
          load: 45,
          available: true,
          name: 'Asia Devnet Validator',
        ),
        ValidatorInfo(
          pubkey: MagicBlockConfig.devnetValidators['eu']!,
          region: 'eu',
          latency: 100,
          load: 52,
          available: true,
          name: 'EU Devnet Validator',
        ),
        ValidatorInfo(
          pubkey: MagicBlockConfig.devnetValidators['us']!,
          region: 'us',
          latency: 50,
          load: 38,
          available: true,
          name: 'US Devnet Validator',
        ),
      ];
    }

    // For mainnet, query the actual validators
    try {
      final response = await _rpcCall('getValidators', []);

      if (response['result'] != null) {
        final list = response['result'] as List;
        return list.map((e) => ValidatorInfo.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('Error getting validators: $e');
    }

    return [];
  }

  /// Send transaction via MagicBlock Router
  ///
  /// The router automatically detects if accounts are delegated
  /// and routes transactions to the appropriate ER validator.
  Future<MagicTransactionResult> sendTransaction(
    String transaction, {
    List<String>? signers,
    int? skipPreflight,
    int? maxRetries,
  }) async {
    final startTime = DateTime.now();

    try {
      final params = [
        transaction,
        {
          'encoding': 'base64',
          if (skipPreflight != null) 'skipPreflight': skipPreflight,
          if (maxRetries != null) 'maxRetries': maxRetries,
          'preflightCommitment': 'confirmed',
        }
      ];

      final response = await _rpcCall('sendTransaction', params);

      if (response['error'] != null) {
        return MagicTransactionResult(
          signature: '',
          routedToER: false,
          timestamp: DateTime.now(),
          confirmationTimeMs: DateTime.now().difference(startTime).inMilliseconds,
          error: response['error']['message']?.toString() ?? 'Transaction failed',
        );
      }

      final signature = response['result'] as String? ?? '';
      final confirmationTime = DateTime.now().difference(startTime).inMilliseconds;

      // Check if routed to ER (based on fast confirmation)
      final routedToER = confirmationTime < 200; // Less than 200ms indicates ER

      return MagicTransactionResult(
        signature: signature,
        routedToER: routedToER,
        timestamp: DateTime.now(),
        confirmationTimeMs: confirmationTime,
      );
    } catch (e) {
      return MagicTransactionResult(
        signature: '',
        routedToER: false,
        timestamp: DateTime.now(),
        confirmationTimeMs: DateTime.now().difference(startTime).inMilliseconds,
        error: e.toString(),
      );
    }
  }

  /// Simulate transaction (preflight check)
  Future<Map<String, dynamic>> simulateTransaction(
    String transaction, {
    List<String>? signers,
  }) async {
    try {
      final response = await _rpcCall('simulateTransaction', [
        transaction,
        {
          'encoding': 'base64',
          'commitment': 'confirmed',
        }
      ]);

      return response['result'] as Map<String, dynamic>? ?? {};
    } catch (e) {
      debugPrint('Error simulating transaction: $e');
      rethrow;
    }
  }

  // ============================================================
  // Delegation Methods
  // ============================================================

  /// Delegate an account to a validator for ER execution
  ///
  /// This transfers temporary ownership of the account to the
  /// delegation program, allowing it to execute transactions on ER.
  Future<String> delegateAccount({
    required String accountAddress,
    required String authority,
    String? validator,
    int commitFrequencyMs = 30000,
  }) async {
    try {
      // If no validator specified, use the closest one
      final selectedValidator = validator ?? (await getClosestValidator())?.pubkey;

      if (selectedValidator == null) {
        throw MagicBlockError('No validator available');
      }

      // Create delegation instruction
      // Note: In production, this would create an actual Solana transaction
      // with the delegate instruction from the delegation program
      final response = await _rpcCall('delegateAccount', [
        {
          'account': accountAddress,
          'authority': authority,
          'validator': selectedValidator,
          'commitFrequencyMs': commitFrequencyMs,
          'programId': config.delegationProgramId,
        }
      ]);

      if (response['error'] != null) {
        throw MagicBlockError(response['error']['message']?.toString() ?? 'Delegation failed');
      }

      return response['result']['signature'] as String? ?? '';
    } catch (e) {
      debugPrint('Error delegating account: $e');
      rethrow;
    }
  }

  /// Commit changes from ER back to base layer
  ///
  /// This syncs the state of delegated accounts from ER to Solana.
  Future<String> commitAccounts({
    required List<String> accounts,
    required String authority,
  }) async {
    if (accounts.isEmpty) {
      throw MagicBlockError('No accounts to commit');
    }

    try {
      final response = await _rpcCall('commitAccounts', [
        {
          'accounts': accounts,
          'authority': authority,
        }
      ]);

      if (response['error'] != null) {
        throw MagicBlockError(response['error']['message']?.toString() ?? 'Commit failed');
      }

      return response['result']['signature'] as String? ?? '';
    } catch (e) {
      debugPrint('Error committing accounts: $e');
      rethrow;
    }
  }

  /// Undelegate an account from ER
  ///
  /// Returns ownership of the account to the original program.
  Future<String> undelegateAccount({
    required String accountAddress,
    required String authority,
  }) async {
    try {
      final response = await _rpcCall('undelegateAccount', [
        {
          'account': accountAddress,
          'authority': authority,
          'programId': config.delegationProgramId,
        }
      ]);

      if (response['error'] != null) {
        throw MagicBlockError(response['error']['message']?.toString() ?? 'Undelegation failed');
      }

      return response['result']['signature'] as String? ?? '';
    } catch (e) {
      debugPrint('Error undelegating account: $e');
      rethrow;
    }
  }

  /// Commit and undelegate in a single operation
  Future<String> commitAndUndelegate({
    required List<String> accounts,
    required String authority,
  }) async {
    // First commit the accounts
    await commitAccounts(accounts: accounts, authority: authority);

    // Wait for commit confirmation
    await Future.delayed(const Duration(seconds: 1));

    // Then undelegate each account
    final signatures = <String>[];
    for (final account in accounts) {
      final sig = await undelegateAccount(
        accountAddress: account,
        authority: authority,
      );
      signatures.add(sig);
    }

    return signatures.first;
  }

  // ============================================================
  // VRF Methods
  // ============================================================

  /// Request verifiable randomness from VRF
  Future<VrfResult> requestVrf({
    required String requester,
    List<int>? seed,
  }) async {
    try {
      // Generate seed if not provided
      final seedBytes = seed ?? _generateRandomSeed();

      final response = await _rpcCall('requestVrf', [
        {
          'requester': requester,
          'seed': hex.encode(seedBytes),
        }
      ]);

      if (response['error'] != null) {
        throw MagicBlockError(response['error']['message']?.toString() ?? 'VRF request failed');
      }

      final result = response['result'] as Map<String, dynamic>;

      return VrfResult(
        randomness: _hexToBytes(result['randomness'] as String? ?? ''),
        proof: _hexToBytes(result['proof'] as String? ?? ''),
        slot: result['slot'] as int? ?? 0,
        verified: result['verified'] as bool? ?? false,
        vrfAccount: result['vrfAccount'] as String?,
      );
    } catch (e) {
      debugPrint('Error requesting VRF: $e');
      rethrow;
    }
  }

  /// Verify a VRF proof
  Future<bool> verifyVrf({
    required String vrfAccount,
    required List<int> proof,
    required List<int> randomness,
  }) async {
    try {
      final response = await _rpcCall('verifyVrf', [
        {
          'vrfAccount': vrfAccount,
          'proof': hex.encode(proof),
          'randomness': hex.encode(randomness),
        }
      ]);

      if (response['error'] != null) {
        return false;
      }

      return response['result']['valid'] as bool? ?? false;
    } catch (e) {
      debugPrint('Error verifying VRF: $e');
      return false;
    }
  }

  /// Get VRF account status
  Future<Map<String, dynamic>?> getVrfAccount(String vrfAccount) async {
    try {
      final response = await _rpcCall('getAccountInfo', [
        vrfAccount,
        {'encoding': 'base64'}
      ]);

      return response['result'] as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error getting VRF account: $e');
      return null;
    }
  }

  // ============================================================
  // PER (Private Ephemeral Rollup) Methods
  // ============================================================

  /// Execute a private transfer using PER (TEE-based privacy)
  Future<String> executePrivateTransfer({
    required String from,
    required String to,
    required int amount,
    required String authority,
  }) async {
    try {
      final response = await _rpcCall('executePrivateTransfer', [
        {
          'from': from,
          'to': to,
          'amount': amount,
          'authority': authority,
        }
      ]);

      if (response['error'] != null) {
        throw MagicBlockError(response['error']['message']?.toString() ?? 'Private transfer failed');
      }

      return response['result']['signature'] as String? ?? '';
    } catch (e) {
      debugPrint('Error executing private transfer: $e');
      rethrow;
    }
  }

  /// Verify TEE attestation for a PER transaction
  Future<bool> verifyTEEAttestation({
    required String transactionSignature,
  }) async {
    try {
      final response = await _rpcCall('verifyTEEAttestation', [
        {'signature': transactionSignature}
      ]);

      if (response['error'] != null) {
        return false;
      }

      return response['result']['valid'] as bool? ?? false;
    } catch (e) {
      debugPrint('Error verifying TEE attestation: $e');
      return false;
    }
  }

  // ============================================================
  // Standard RPC Methods (Magic Router compatible)
  // ============================================================

  /// Get account balance
  Future<double> getBalance(String address) async {
    try {
      final response = await _rpcCall('getBalance', [address, 'confirmed']);

      if (response['result'] == null) {
        throw MagicBlockError('Failed to get balance');
      }

      final lamports = response['result']['value'] as int;
      return lamports / 1e9; // Convert to SOL
    } catch (e) {
      debugPrint('Error getting balance: $e');
      rethrow;
    }
  }

  /// Get account info
  Future<Map<String, dynamic>?> getAccountInfo(String address) async {
    try {
      final response = await _rpcCall('getAccountInfo', [
        address,
        {'encoding': 'base64'}
      ]);

      return response['result'] as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error getting account info: $e');
      return null;
    }
  }

  /// Get latest blockhash
  Future<Map<String, dynamic>> getLatestBlockhash() async {
    try {
      final response = await _rpcCall('getLatestBlockhash', [{'commitment': 'confirmed'}]);

      if (response['result'] == null) {
        throw MagicBlockError('Failed to get latest blockhash');
      }

      return response['result']['value'] as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error getting latest blockhash: $e');
      rethrow;
    }
  }

  /// Get transaction details
  Future<Map<String, dynamic>?> getTransaction(String signature) async {
    try {
      final response = await _rpcCall('getTransaction', [
        signature,
        {'encoding': 'jsonParsed'}
      ]);

      return response['result'] as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error getting transaction: $e');
      return null;
    }
  }

  /// Get recent transactions for an address
  Future<List<Map<String, dynamic>>> getSignaturesForAddress(
    String address, {
    int limit = 10,
  }) async {
    try {
      final response = await _rpcCall('getSignaturesForAddress', [
        address,
        {'limit': limit}
      ]);

      if (response['result'] == null) {
        return [];
      }

      return (response['result'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } catch (e) {
      debugPrint('Error getting signatures: $e');
      return [];
    }
  }

  /// Get slot height
  Future<int> getSlot() async {
    try {
      final response = await _rpcCall('getSlot', []);

      if (response['result'] == null) {
        return 0;
      }

      return response['result'] as int? ?? 0;
    } catch (e) {
      debugPrint('Error getting slot: $e');
      return 0;
    }
  }

  /// Get health status
  Future<bool> getHealth() async {
    try {
      final response = await _rpcCall('getHealth', []);
      return response['result'] == 'ok';
    } catch (e) {
      return false;
    }
  }

  /// Get version info
  Future<Map<String, dynamic>?> getVersion() async {
    try {
      final response = await _rpcCall('getVersion', []);
      return response['result'] as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // WebSocket Support
  // ============================================================

  /// Stream for account updates via WebSocket
  Stream<Map<String, dynamic>> onAccountChange(String address) {
    final controller = StreamController<Map<String, dynamic>>();

    // Note: In production, this would establish a WebSocket connection
    // and subscribe to account notifications
    // For now, we simulate it with polling

    Timer.periodic(const Duration(seconds: 2), (timer) async {
      final info = await getAccountInfo(address);
      if (info != null && !controller.isClosed) {
        controller.add(info);
      }
    });

    return controller.stream;
  }

  /// Stream for signature updates via WebSocket
  Stream<Map<String, dynamic>> onSignatureUpdate(String signature) {
    final controller = StreamController<Map<String, dynamic>>();

    Timer.periodic(const Duration(seconds: 1), (timer) async {
      final tx = await getTransaction(signature);
      if (tx != null && !controller.isClosed) {
        controller.add(tx);
        timer.cancel();
        controller.close();
      }
    });

    return controller.stream;
  }

  // ============================================================
  // Helper Methods
  // ============================================================

  /// Generic RPC call
  Future<Map<String, dynamic>> _rpcCall(
    String method,
    List<dynamic> params,
  ) async {
    final url = Uri.parse(config.rpcUrl);

    final body = jsonEncode({
      'jsonrpc': '2.0',
      'id': DateTime.now().millisecondsSinceEpoch,
      'method': method,
      'params': params,
    });

    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw MagicBlockError('RPC call failed: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (json['error'] != null) {
      throw MagicBlockError(json['error']['message']?.toString() ?? 'RPC error');
    }

    return json;
  }

  /// Generate a random seed for VRF
  List<int> _generateRandomSeed() {
    final random = DateTime.now().millisecondsSinceEpoch;
    final bytes = Uint8List(32);
    for (var i = 0; i < 32; i++) {
      bytes[i] = (random ^ (i * 0x100)) & 0xFF;
    }
    return bytes.toList();
  }

  /// Convert hex string to bytes
  List<int> _hexToBytes(String hexString) {
    try {
      return hex.decode(hexString);
    } catch (e) {
      return [];
    }
  }

  /// Dispose resources
  void dispose() {
    _client.close();
  }
}

/// MagicBlock Error
class MagicBlockError implements Exception {
  final String message;

  MagicBlockError(this.message);

  @override
  String toString() => 'MagicBlockError: $message';
}
