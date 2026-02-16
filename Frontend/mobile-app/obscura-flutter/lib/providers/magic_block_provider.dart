import 'dart:async';
import 'package:flutter/foundation.dart';
import '../config/env.dart';
import '../models/magic_block_models.dart';
import '../services/magic_block_service.dart';

/// MagicBlock Provider
///
/// Manages state for MagicBlock Ephemeral Rollups integration including:
/// - Network configuration (devnet/mainnet)
/// - Account delegation status
/// - Validator selection
/// - Operation loading states
class MagicBlockProvider with ChangeNotifier {
  late final MagicBlockService _service;

  // ============================================================
  // Network State
  // ============================================================

  MagicBlockNetwork _network = MagicBlockNetwork.devnet;
  MagicBlockNetwork get network => _network;

  // ============================================================
  // Delegation State
  // ============================================================

  /// Map of account addresses to their delegation status
  final Map<String, DelegationStatus> _delegatedAccounts = {};
  Map<String, DelegationStatus> get delegatedAccounts => Map.unmodifiable(_delegatedAccounts);

  /// Check if a specific account is delegated
  bool isAccountDelegated(String account) {
    final status = _delegatedAccounts[account];
    return status?.state.isDelegated ?? false;
  }

  /// Get delegation status for a specific account
  DelegationStatus? getDelegationStatus(String account) {
    return _delegatedAccounts[account];
  }

  /// Get all delegated accounts
  List<String> get delegatedAccountList {
    return _delegatedAccounts.entries
        .where((e) => e.value.state.isDelegated)
        .map((e) => e.key)
        .toList();
  }

  /// Count of delegated accounts
  int get delegatedAccountCount => delegatedAccountList.length;

  // ============================================================
  // Validator State
  // ============================================================

  ValidatorInfo? _selectedValidator;
  ValidatorInfo? get selectedValidator => _selectedValidator;

  List<ValidatorInfo> _availableValidators = [];
  List<ValidatorInfo> get availableValidators => List.unmodifiable(_availableValidators);

  // ============================================================
  // Loading States
  // ============================================================

  bool _delegating = false;
  bool get isDelegating => _delegating;

  bool _committing = false;
  bool get isCommitting => _committing;

  bool _undelegating = false;
  bool get isUndelegating => _undelegating;

  bool _refreshingStatus = false;
  bool get isRefreshingStatus => _refreshingStatus;

  // ============================================================
  // Connection/Health State
  // ============================================================

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  String? _connectionError;
  String? get connectionError => _connectionError;

  int _currentSlot = 0;
  int get currentSlot => _currentSlot;

  // ============================================================
  // VRF State
  // ============================================================

  VrfResult? _lastVrfResult;
  VrfResult? get lastVrfResult => _lastVrfResult;

  bool _requestingVrf = false;
  bool get isRequestingVrf => _requestingVrf;

  // ============================================================
  // Transaction History
  // ============================================================

  final List<MagicTransactionResult> _transactionHistory = [];
  List<MagicTransactionResult> get transactionHistory => List.unmodifiable(_transactionHistory);

  // ============================================================
  // Streams
  // ============================================================

  StreamSubscription? _slotSubscription;

  // ============================================================
  // Initialization
  // ============================================================

  /// Initialize the provider with a network
  Future<void> init({MagicBlockNetwork? initialNetwork, String? programId}) async {
    _network = initialNetwork ?? MagicBlockNetwork.devnet;

    // Create config
    final config = _network == MagicBlockNetwork.devnet
        ? MagicBlockConfig.devnet(programId: programId ?? Env.obscuraProgramId)
        : MagicBlockConfig.mainnet(programId: programId ?? Env.obscuraProgramId);

    // Initialize service
    MagicBlockService.init(config);
    _service = MagicBlockService.instance;

    // Check connection
    await _checkConnection();

    // Load validators
    await _loadValidators();

    // Start slot monitoring
    _startSlotMonitoring();
  }

  /// Check connection to MagicBlock
  Future<void> _checkConnection() async {
    try {
      _isConnected = await _service.getHealth();
      _connectionError = null;
    } catch (e) {
      _isConnected = false;
      _connectionError = e.toString();
    }
    notifyListeners();
  }

  /// Load available validators
  Future<void> _loadValidators() async {
    try {
      _availableValidators = await _service.getAvailableValidators();

      // Auto-select closest validator if none selected
      if (_selectedValidator == null && _availableValidators.isNotEmpty) {
        _selectedValidator = await _service.getClosestValidator();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading validators: $e');
    }
  }

  /// Start monitoring slot height
  void _startSlotMonitoring() {
    _slotSubscription?.cancel();
    _slotSubscription = Stream.periodic(const Duration(seconds: 5), (_) async {
      _currentSlot = await _service.getSlot();
      notifyListeners();
    }).listen((_) {});
  }

  // ============================================================
  // Network Management
  // ============================================================

  /// Switch network (devnet <-> mainnet)
  Future<void> switchNetwork(MagicBlockNetwork newNetwork, {String? programId}) async {
    if (newNetwork == _network) return;

    _network = newNetwork;

    // Clear delegation state when switching networks
    _delegatedAccounts.clear();

    // Create new config
    final config = newNetwork == MagicBlockNetwork.devnet
        ? MagicBlockConfig.devnet(programId: programId ?? Env.obscuraProgramId)
        : MagicBlockConfig.mainnet(programId: programId ?? Env.obscuraProgramId);

    // Update service
    _service.updateConfig(config);

    // Reconnect
    await _checkConnection();
    await _loadValidators();

    notifyListeners();
  }

  // ============================================================
  // Delegation Methods
  // ============================================================

  /// Delegate an account to a validator
  Future<String?> delegateAccount(
    String account, {
    String? authority,
    String? validator,
    int commitFrequencyMs = 30000,
  }) async {
    if (authority == null) {
      _showError('Authority (signer) required for delegation');
      return null;
    }

    _delegating = true;
    notifyListeners();

    try {
      final signature = await _service.delegateAccount(
        accountAddress: account,
        authority: authority,
        validator: validator ?? _selectedValidator?.pubkey,
        commitFrequencyMs: commitFrequencyMs,
      );

      // Update local status
      _delegatedAccounts[account] = DelegationStatus(
        account: account,
        state: DelegationState.delegated,
        validator: validator ?? _selectedValidator?.pubkey,
        validatorRegion: validator != null
            ? _availableValidators
                .firstWhere((v) => v.pubkey == validator,
                    orElse: () => _availableValidators.first)
                .region
            : _selectedValidator?.region,
        delegatedAt: DateTime.now(),
        commitFrequency: commitFrequencyMs,
      );

      _delegating = false;
      notifyListeners();

      return signature;
    } catch (e) {
      _delegating = false;
      _showError('Delegation failed: $e');
      notifyListeners();
      return null;
    }
  }

  /// Commit changes from ER back to base layer
  Future<String?> commitAccounts(
    List<String> accounts, {
    String? authority,
  }) async {
    if (authority == null) {
      _showError('Authority (signer) required for commit');
      return null;
    }

    _committing = true;
    notifyListeners();

    try {
      final signature = await _service.commitAccounts(
        accounts: accounts,
        authority: authority,
      );

      // Update local status
      for (final account in accounts) {
        final status = _delegatedAccounts[account];
        if (status != null) {
          _delegatedAccounts[account] = DelegationStatus(
            account: account,
            state: DelegationState.delegated,
            validator: status.validator,
            validatorRegion: status.validatorRegion,
            delegatedAt: status.delegatedAt,
            commitFrequency: status.commitFrequency,
            lastCommitSlot: _currentSlot,
          );
        }
      }

      _committing = false;
      notifyListeners();

      return signature;
    } catch (e) {
      _committing = false;
      _showError('Commit failed: $e');
      notifyListeners();
      return null;
    }
  }

  /// Undelegate an account from ER
  Future<String?> undelegateAccount(
    String account, {
    String? authority,
  }) async {
    if (authority == null) {
      _showError('Authority (signer) required for undelegation');
      return null;
    }

    _undelegating = true;
    notifyListeners();

    try {
      final signature = await _service.undelegateAccount(
        accountAddress: account,
        authority: authority,
      );

      // Update local status
      _delegatedAccounts.remove(account);

      _undelegating = false;
      notifyListeners();

      return signature;
    } catch (e) {
      _undelegating = false;
      _showError('Undelegation failed: $e');
      notifyListeners();
      return null;
    }
  }

  /// Commit and undelegate in one operation
  Future<String?> commitAndUndelegate(
    List<String> accounts, {
    String? authority,
  }) async {
    if (authority == null) {
      _showError('Authority (signer) required');
      return null;
    }

    _committing = true;
    _undelegating = true;
    notifyListeners();

    try {
      final signature = await _service.commitAndUndelegate(
        accounts: accounts,
        authority: authority,
      );

      // Remove from local status
      for (final account in accounts) {
        _delegatedAccounts.remove(account);
      }

      _committing = false;
      _undelegating = false;
      notifyListeners();

      return signature;
    } catch (e) {
      _committing = false;
      _undelegating = false;
      _showError('Commit and undelegate failed: $e');
      notifyListeners();
      return null;
    }
  }

  // ============================================================
  // Delegation Status
  // ============================================================

  /// Check delegation status for an account
  Future<DelegationStatus?> checkDelegation(String account) async {
    _refreshingStatus = true;
    notifyListeners();

    try {
      final status = await _service.getAccountDelegationStatus(account);

      if (status != null) {
        _delegatedAccounts[account] = status;
        notifyListeners();
      }

      _refreshingStatus = false;
      return status;
    } catch (e) {
      _refreshingStatus = false;
      debugPrint('Error checking delegation: $e');
      notifyListeners();
      return null;
    }
  }

  /// Check delegation status for multiple accounts
  Future<void> checkDelegationBatch(List<String> accounts) async {
    _refreshingStatus = true;
    notifyListeners();

    try {
      final statuses = await _service.getDelegationStatus(accounts);

      for (final status in statuses) {
        _delegatedAccounts[status.account] = status;
      }

      _refreshingStatus = false;
      notifyListeners();
    } catch (e) {
      _refreshingStatus = false;
      debugPrint('Error checking batch delegation: $e');
      notifyListeners();
    }
  }

  /// Refresh all delegation statuses
  Future<void> refreshAllDelegations() async {
    if (_delegatedAccounts.isEmpty) return;

    await checkDelegationBatch(_delegatedAccounts.keys.toList());
  }

  // ============================================================
  // Validator Methods
  // ============================================================

  /// Select a validator
  void selectValidator(ValidatorInfo? validator) {
    _selectedValidator = validator;
    notifyListeners();
  }

  /// Get optimal (closest) validator
  Future<ValidatorInfo?> getOptimalValidator() async {
    return await _service.getClosestValidator();
  }

  /// Refresh available validators
  Future<void> refreshValidators() async {
    await _loadValidators();
  }

  // ============================================================
  // VRF Methods
  // ============================================================

  /// Request verifiable randomness
  Future<VrfResult?> requestRandomness({
    required String requester,
    List<int>? seed,
  }) async {
    _requestingVrf = true;
    notifyListeners();

    try {
      final result = await _service.requestVrf(
        requester: requester,
        seed: seed,
      );

      _lastVrfResult = result;
      _requestingVrf = false;
      notifyListeners();

      return result;
    } catch (e) {
      _requestingVrf = false;
      _showError('VRF request failed: $e');
      notifyListeners();
      return null;
    }
  }

  /// Verify VRF proof
  Future<bool> verifyVrf({
    required String vrfAccount,
    required List<int> proof,
    required List<int> randomness,
  }) async {
    try {
      return await _service.verifyVrf(
        vrfAccount: vrfAccount,
        proof: proof,
        randomness: randomness,
      );
    } catch (e) {
      debugPrint('Error verifying VRF: $e');
      return false;
    }
  }

  // ============================================================
  // PER Methods
  // ============================================================

  /// Execute private transfer using PER
  Future<String?> executePrivateTransfer({
    required String from,
    required String to,
    required int amount,
    required String authority,
  }) async {
    try {
      return await _service.executePrivateTransfer(
        from: from,
        to: to,
        amount: amount,
        authority: authority,
      );
    } catch (e) {
      _showError('Private transfer failed: $e');
      return null;
    }
  }

  /// Verify TEE attestation
  Future<bool> verifyTEEAttestation(String transactionSignature) async {
    try {
      return await _service.verifyTEEAttestation(
        transactionSignature: transactionSignature,
      );
    } catch (e) {
      debugPrint('Error verifying TEE attestation: $e');
      return false;
    }
  }

  // ============================================================
  // Transaction Management
  // ============================================================

  /// Add transaction to history
  void addToHistory(MagicTransactionResult result) {
    _transactionHistory.insert(0, result);

    // Keep only last 50 transactions
    if (_transactionHistory.length > 50) {
      _transactionHistory.removeLast();
    }

    notifyListeners();
  }

  /// Clear transaction history
  void clearHistory() {
    _transactionHistory.clear();
    notifyListeners();
  }

  // ============================================================
  // State Management
  // ============================================================

  /// Clear all delegation state
  void clearDelegations() {
    _delegatedAccounts.clear();
    notifyListeners();
  }

  /// Reset provider state
  void reset() {
    _delegatedAccounts.clear();
    _selectedValidator = null;
    _transactionHistory.clear();
    _lastVrfResult = null;
    _connectionError = null;
    notifyListeners();
  }

  /// Refresh all state
  Future<void> refresh() async {
    await _checkConnection();
    await _loadValidators();
    await refreshAllDelegations();
  }

  // ============================================================
  // Error Handling
  // ============================================================

  String? _lastError;

  String? get lastError => _lastError;

  void _showError(String message) {
    _lastError = message;
    debugPrint('MagicBlockProvider Error: $message');
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  // ============================================================
  // Dispose
  // ============================================================

  @override
  void dispose() {
    _slotSubscription?.cancel();
    super.dispose();
  }
}
