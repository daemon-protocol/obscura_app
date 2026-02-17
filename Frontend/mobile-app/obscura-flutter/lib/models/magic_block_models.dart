/// MagicBlock Ephemeral Rollups Models
///
/// This file contains all models for interacting with MagicBlock's
/// Ephemeral Rollups (ER), Delegation, VRF, and PER features.
library;

/// Delegation state for an account on MagicBlock ER
enum DelegationState {
  /// Account is not delegated to any validator
  notDelegated,

  /// Account is currently delegated and executing on ER
  delegated,

  /// Account has pending changes to be committed to base layer
  pendingCommit,

  /// Account is pending undelegation back to base layer
  pendingUndelegation,
}

/// Extension for DelegationState helpers
extension DelegationStateExtension on DelegationState {
  String get displayName {
    switch (this) {
      case DelegationState.notDelegated:
        return 'Not Delegated';
      case DelegationState.delegated:
        return 'Delegated';
      case DelegationState.pendingCommit:
        return 'Pending Commit';
      case DelegationState.pendingUndelegation:
        return 'Pending Undelegation';
    }
  }

  String get emoji {
    switch (this) {
      case DelegationState.notDelegated:
        return '⚪';
      case DelegationState.delegated:
        return '🟢';
      case DelegationState.pendingCommit:
        return '🟡';
      case DelegationState.pendingUndelegation:
        return '🟠';
    }
  }

  bool get isDelegated =>
      this == DelegationState.delegated ||
      this == DelegationState.pendingCommit ||
      this == DelegationState.pendingUndelegation;

  bool get canExecuteTransactions => this == DelegationState.delegated;
}

/// Delegation status for an account
class DelegationStatus {
  /// The account address
  final String account;

  /// Current delegation state
  final DelegationState state;

  /// Validator pubkey if delegated
  final String? validator;

  /// Region of the validator (asia, eu, us)
  final String? validatorRegion;

  /// When the account was delegated
  final DateTime? delegatedAt;

  /// Auto-commit frequency in milliseconds
  final int? commitFrequency;

  /// Last commit slot
  final int? lastCommitSlot;

  /// Estimated latency to this validator in ms
  final int? estimatedLatency;

  const DelegationStatus({
    required this.account,
    required this.state,
    this.validator,
    this.validatorRegion,
    this.delegatedAt,
    this.commitFrequency,
    this.lastCommitSlot,
    this.estimatedLatency,
  });

  /// Create from JSON response
  factory DelegationStatus.fromJson(Map<String, dynamic> json) {
    return DelegationStatus(
      account: json['account'] as String,
      state: _parseDelegationState(json['state'] as String?),
      validator: json['validator'] as String?,
      validatorRegion: json['validatorRegion'] as String?,
      delegatedAt: json['delegatedAt'] != null
          ? DateTime.parse(json['delegatedAt'] as String)
          : null,
      commitFrequency: json['commitFrequency'] as int?,
      lastCommitSlot: json['lastCommitSlot'] as int?,
      estimatedLatency: json['estimatedLatency'] as int?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'account': account,
      'state': state.name,
      'validator': validator,
      'validatorRegion': validatorRegion,
      'delegatedAt': delegatedAt?.toIso8601String(),
      'commitFrequency': commitFrequency,
      'lastCommitSlot': lastCommitSlot,
      'estimatedLatency': estimatedLatency,
    };
  }

  /// Create a not-delegated status for an account
  factory DelegationStatus.notDelegated(String account) {
    return DelegationStatus(
      account: account,
      state: DelegationState.notDelegated,
    );
  }

  static DelegationState _parseDelegationState(String? state) {
    switch (state) {
      case 'delegated':
        return DelegationState.delegated;
      case 'pendingCommit':
        return DelegationState.pendingCommit;
      case 'pendingUndelegation':
        return DelegationState.pendingUndelegation;
      default:
        return DelegationState.notDelegated;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DelegationStatus &&
          runtimeType == other.runtimeType &&
          account == other.account &&
          state == other.state;

  @override
  int get hashCode => account.hashCode ^ state.hashCode;
}

/// Validator information
class ValidatorInfo {
  /// Validator public key
  final String pubkey;

  /// Region (asia, eu, us)
  final String region;

  /// Estimated latency in milliseconds
  final int latency;

  /// Current load percentage (0-100)
  final int load;

  /// Whether the validator is available
  final bool available;

  /// Validator name/identifier
  final String? name;

  const ValidatorInfo({
    required this.pubkey,
    required this.region,
    required this.latency,
    required this.load,
    required this.available,
    this.name,
  });

  /// Create from JSON
  factory ValidatorInfo.fromJson(Map<String, dynamic> json) {
    return ValidatorInfo(
      pubkey: json['pubkey'] as String,
      region: json['region'] as String,
      latency: json['latency'] as int? ?? 0,
      load: json['load'] as int? ?? 0,
      available: json['available'] as bool? ?? true,
      name: json['name'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'pubkey': pubkey,
      'region': region,
      'latency': latency,
      'load': load,
      'available': available,
      'name': name,
    };
  }

  /// Get display name
  String get displayName {
    return '${name ?? region.toUpperCase()} Validator';
  }

  /// Get region flag emoji
  String get regionFlag {
    switch (region.toLowerCase()) {
      case 'asia':
        return '🌏';
      case 'eu':
      case 'europe':
        return '🇪🇺';
      case 'us':
      case 'usa':
        return '🇺🇸';
      default:
        return '🌐';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidatorInfo &&
          runtimeType == other.runtimeType &&
          pubkey == other.pubkey;

  @override
  int get hashCode => pubkey.hashCode;
}

/// Transaction result from MagicBlock Router
class MagicTransactionResult {
  /// Transaction signature
  final String signature;

  /// Whether the transaction was routed to ER
  final bool routedToER;

  /// Validator that processed the transaction (if routed to ER)
  final String? validator;

  /// Slot the transaction was processed in
  final int? slot;

  /// When the transaction was confirmed
  final DateTime timestamp;

  /// Time from submission to confirmation in milliseconds
  final int? confirmationTimeMs;

  /// Error message if transaction failed
  final String? error;

  const MagicTransactionResult({
    required this.signature,
    required this.routedToER,
    this.validator,
    this.slot,
    required this.timestamp,
    this.confirmationTimeMs,
    this.error,
  });

  /// Create from JSON
  factory MagicTransactionResult.fromJson(Map<String, dynamic> json) {
    return MagicTransactionResult(
      signature: json['signature'] as String,
      routedToER: json['routedToER'] as bool? ?? false,
      validator: json['validator'] as String?,
      slot: json['slot'] as int?,
      timestamp: DateTime.parse(
        json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      ),
      confirmationTimeMs: json['confirmationTimeMs'] as int?,
      error: json['error'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'signature': signature,
      'routedToER': routedToER,
      'validator': validator,
      'slot': slot,
      'timestamp': timestamp.toIso8601String(),
      'confirmationTimeMs': confirmationTimeMs,
      'error': error,
    };
  }

  /// Whether the transaction was successful
  bool get isSuccess => error == null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MagicTransactionResult &&
          runtimeType == other.runtimeType &&
          signature == other.signature;

  @override
  int get hashCode => signature.hashCode;
}

/// VRF (Verifiable Randomness Function) result
class VrfResult {
  /// Random bytes generated
  final List<int> randomness;

  /// Proof of randomness
  final List<int> proof;

  /// Slot the VRF was requested in
  final int slot;

  /// Whether the proof has been verified
  final bool verified;

  /// VRF account address
  final String? vrfAccount;

  const VrfResult({
    required this.randomness,
    required this.proof,
    required this.slot,
    this.verified = false,
    this.vrfAccount,
  });

  /// Create from JSON
  factory VrfResult.fromJson(Map<String, dynamic> json) {
    return VrfResult(
      randomness: (json['randomness'] as List)
          .map((e) => e as int)
          .toList(),
      proof: (json['proof'] as List).map((e) => e as int).toList(),
      slot: json['slot'] as int,
      verified: json['verified'] as bool? ?? false,
      vrfAccount: json['vrfAccount'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'randomness': randomness,
      'proof': proof,
      'slot': slot,
      'verified': verified,
      'vrfAccount': vrfAccount,
    };
  }

  /// Get randomness as hex string
  String get randomnessHex {
    return randomness.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VrfResult &&
          runtimeType == other.runtimeType &&
          vrfAccount == other.vrfAccount &&
          slot == other.slot;

  @override
  int get hashCode => (vrfAccount?.hashCode ?? 0) ^ slot.hashCode;
}

/// Network selection for MagicBlock
enum MagicBlockNetwork {
  /// Solana Devnet
  devnet,

  /// Solana Mainnet
  mainnet,
}

/// Extension for MagicBlockNetwork helpers
extension MagicBlockNetworkExtension on MagicBlockNetwork {
  String get displayName {
    switch (this) {
      case MagicBlockNetwork.devnet:
        return 'Devnet';
      case MagicBlockNetwork.mainnet:
        return 'Mainnet';
    }
  }

  String get emoji {
    switch (this) {
      case MagicBlockNetwork.devnet:
        return '🧪';
      case MagicBlockNetwork.mainnet:
        return '🚀';
    }
  }

  bool get isDevnet => this == MagicBlockNetwork.devnet;
  bool get isMainnet => this == MagicBlockNetwork.mainnet;
}

/// MagicBlock configuration
class MagicBlockConfig {
  /// Selected network
  final MagicBlockNetwork network;

  /// RPC URL for the network
  final String rpcUrl;

  /// WebSocket URL for the network
  final String wsUrl;

  /// Obscura program ID
  final String programId;

  /// MagicBlock Delegation program ID
  final String delegationProgramId;

  /// VRF program ID (if available)
  final String? vrfProgramId;

  const MagicBlockConfig({
    required this.network,
    required this.rpcUrl,
    required this.wsUrl,
    required this.programId,
    required this.delegationProgramId,
    this.vrfProgramId,
  });

  /// Create config for devnet
  factory MagicBlockConfig.devnet({
    required String programId,
    String? vrfProgramId,
  }) {
    return MagicBlockConfig(
      network: MagicBlockNetwork.devnet,
      rpcUrl: 'https://devnet-rpc.magicblock.app',
      wsUrl: 'wss://devnet-rpc.magicblock.app',
      programId: programId,
      delegationProgramId: 'DELeGGvXpWV2fqJUhqcF5ZSYMS4JTLjteaAMARRSaeSh',
      vrfProgramId: vrfProgramId,
    );
  }

  /// Create config for mainnet
  factory MagicBlockConfig.mainnet({
    required String programId,
    String? vrfProgramId,
  }) {
    return MagicBlockConfig(
      network: MagicBlockNetwork.mainnet,
      rpcUrl: 'https://rpc.magicblock.app',
      wsUrl: 'wss://rpc.magicblock.app',
      programId: programId,
      delegationProgramId: 'DELeGGvXpWV2fqJUhqcF5ZSYMS4JTLjteaAMARRSaeSh',
      vrfProgramId: vrfProgramId,
    );
  }

  /// Devnet validators
  static const Map<String, String> devnetValidators = {
    'asia': 'MAS1Dt9qreoRMQ14YQuhg8UTZMMzDdKhmkZMECCzk57',
    'eu': 'MEUEuQfpPYQFvpZYMmwvbJeYpNUYDVbqLNcGJPc5ZwK',
    'us': 'MFVa7oPEvPZxmVeLgyqhYQJt2PkjfVdvZ3hNKVRWP3Z',
  };

  /// Get validator for region on devnet
  static String? getDevnetValidator(String region) {
    return devnetValidators[region.toLowerCase()];
  }

  /// Copy with different network
  MagicBlockConfig copyWithNetwork(MagicBlockNetwork newNetwork, {String? programId}) {
    final effectiveProgramId = programId ?? this.programId;
    return newNetwork == MagicBlockNetwork.devnet
        ? MagicBlockConfig.devnet(programId: effectiveProgramId, vrfProgramId: vrfProgramId)
        : MagicBlockConfig.mainnet(programId: effectiveProgramId, vrfProgramId: vrfProgramId);
  }
}

/// Execution mode for transactions
enum ExecutionMode {
  /// Standard Solana base layer execution
  standard,

  /// Fast execution on Ephemeral Rollup
  fast,

  /// Private execution on PER (TEE)
  private,

  /// Compressed execution using Light Protocol
  compressed,

  /// Fast execution + ZK Compression (Hybrid)
  fastCompressed,

  /// Private execution + ZK Compression (Hybrid)
  privateCompressed,
}

/// Extension for ExecutionMode helpers
extension ExecutionModeExtension on ExecutionMode {
  String get displayName {
    switch (this) {
      case ExecutionMode.standard:
        return 'Standard';
      case ExecutionMode.fast:
        return 'Fast (ER)';
      case ExecutionMode.private:
        return 'Private (PER)';
      case ExecutionMode.compressed:
        return 'Compressed';
      case ExecutionMode.fastCompressed:
        return 'Fast + Compressed';
      case ExecutionMode.privateCompressed:
        return 'Private + Compressed';
    }
  }

  String get shortName {
    switch (this) {
      case ExecutionMode.standard:
        return 'Standard';
      case ExecutionMode.fast:
        return 'Fast';
      case ExecutionMode.private:
        return 'Private';
      case ExecutionMode.compressed:
        return 'Compressed';
      case ExecutionMode.fastCompressed:
        return 'Fast+Comp';
      case ExecutionMode.privateCompressed:
        return 'Priv+Comp';
    }
  }

  String get description {
    switch (this) {
      case ExecutionMode.standard:
        return 'Normal Solana execution (~400ms)';
      case ExecutionMode.fast:
        return 'Ephemeral Rollup (~50ms)';
      case ExecutionMode.private:
        return 'Private execution with TEE';
      case ExecutionMode.compressed:
        return 'ZK compressed (~1000x cheaper)';
      case ExecutionMode.fastCompressed:
        return 'ER speed + Compression savings (~50ms, ~1000x cheaper)';
      case ExecutionMode.privateCompressed:
        return 'PER privacy + Compression savings (TEE, ~1000x cheaper)';
    }
  }

  String get emoji {
    switch (this) {
      case ExecutionMode.standard:
        return '⏱️';
      case ExecutionMode.fast:
        return '⚡';
      case ExecutionMode.private:
        return '🔒';
      case ExecutionMode.compressed:
        return '🗜️';
      case ExecutionMode.fastCompressed:
        return '⚡🗜️';
      case ExecutionMode.privateCompressed:
        return '🔒🗜️';
    }
  }

  /// Whether this mode uses Ephemeral Rollups
  bool get usesER =>
      this == ExecutionMode.fast ||
      this == ExecutionMode.private ||
      this == ExecutionMode.fastCompressed ||
      this == ExecutionMode.privateCompressed;

  /// Whether this mode uses ZK Compression
  bool get usesCompression =>
      this == ExecutionMode.compressed ||
      this == ExecutionMode.fastCompressed ||
      this == ExecutionMode.privateCompressed;

  /// Whether this mode is a hybrid mode (combines multiple technologies)
  bool get isHybrid =>
      this == ExecutionMode.fastCompressed ||
      this == ExecutionMode.privateCompressed;

  /// Whether this mode provides privacy
  bool get isPrivate =>
      this == ExecutionMode.private ||
      this == ExecutionMode.privateCompressed;

  /// Whether delegation is required for this mode
  bool get requiresDelegation => usesER;

  /// Estimated latency in milliseconds
  int get estimatedLatencyMs {
    switch (this) {
      case ExecutionMode.standard:
        return 400;
      case ExecutionMode.fast:
        return 50;
      case ExecutionMode.private:
        return 75;
      case ExecutionMode.compressed:
        return 100;
      case ExecutionMode.fastCompressed:
        return 60;
      case ExecutionMode.privateCompressed:
        return 85;
    }
  }

  /// Cost multiplier relative to standard (1.0 = same cost)
  double get costMultiplier {
    switch (this) {
      case ExecutionMode.standard:
        return 1.0;
      case ExecutionMode.fast:
        return 1.0; // ER doesn't change cost significantly
      case ExecutionMode.private:
        return 1.2; // PER has slight overhead
      case ExecutionMode.compressed:
        return 0.001; // ~1000x cheaper
      case ExecutionMode.fastCompressed:
        return 0.001; // Dominated by compression savings
      case ExecutionMode.privateCompressed:
        return 0.0012; // Slight overhead over pure compression
    }
  }
}
