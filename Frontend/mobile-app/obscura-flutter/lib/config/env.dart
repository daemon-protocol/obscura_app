import 'package:flutter/foundation.dart';

/// Environment configuration for Obscura Vault
///
/// # Configuration Guide
///
/// Before running the app, you need to configure the following API keys:
///
/// ## Required API Keys
///
/// 1. **Helius API Key** - Get from https://www.helius.dev
///    - Required for Solana RPC operations and compression support
///    - Sign up at https://www.helius.dev and create a new project
///    - Copy your API key and replace 'YOUR_HELIUS_API_KEY' below
///
/// 2. **WalletConnect Project ID** - Get from https://cloud.walletconnect.com
///    - Required for EVM wallet connections
///    - Sign up at https://cloud.walletconnect.com
///    - Create a new project and copy the Project ID
///
/// ## Optional API Keys
///
/// 3. **Obscura Program ID** - Your deployed program ID
///    - Replace with your actual deployed Solana program ID
///    - This is used for on-chain program interactions
///
/// 4. **MagicBlock API Key** - For advanced features
///    - Get from MagicBlock if using their API services
///    - Currently unused (ephemeral rollups use RPC directly)
///
/// ## Environment Setup
///
/// For development, set `isDevnet = true` to use devnet.
/// For production, set `isDevnet = false` to use mainnet.
class Env {
  // ============================================================
  // Obscura Backend API
  // ============================================================

  static const String obscuraApiUrl =
      'https://obscurabackend-production.up.railway.app';

  // ============================================================
  // Helius (Solana RPC)
  // ============================================================
  //
  // Get your API key from: https://www.helius.dev
  // 1. Sign up at https://www.helius.dev
  // 2. Create a new project
  // 3. Copy your API key below

  static const String heliusApiKey = String.fromEnvironment(
    'HELIUS_API_KEY',
    defaultValue: 'YOUR_HELIUS_API_KEY', // Replace with your actual key
  );

  /// Check if Helius API key is configured
  static bool get isHeliusConfigured =>
      heliusApiKey.isNotEmpty && heliusApiKey != 'YOUR_HELIUS_API_KEY';

  // Helius RPC endpoints
  static const String heliusDevnetRpc = 'https://rpc-devnet.helius.xyz';
  static const String heliusMainnetRpc = 'https://rpc.helius.xyz';

  // Helius RPC endpoints with compression API support (Photon + Light Protocol)
  static const String heliusCompressionRpc = 'https://devnet.helius-rpc.com';
  static const String heliusMainnetCompressionRpc = 'https://mainnet.helius-rpc.com';

  // Legacy Solana RPC endpoints (for reference)
  static const String solanaDevnetRpc = 'https://api.devnet.solana.com';
  static const String solanaMainnetRpc = 'https://api.mainnet-beta.solana.com';

  // ============================================================
  // MagicBlock (Ephemeral Rollups)
  // ============================================================

  // MagicBlock Router endpoints
  static const String magicblockDevnetRpc = 'https://devnet-rpc.magicblock.app';
  static const String magicblockDevnetWs = 'wss://devnet-rpc.magicblock.app';
  static const String magicblockMainnetRpc = 'https://rpc.magicblock.app';
  static const String magicblockMainnetWs = 'wss://rpc.magicblock.app';

  // MagicBlock Programs
  static const String magicblockDelegationProgram =
      'DELeGGvXpWV2fqJUhqcF5ZSYMS4JTLjteaAMARRSaeSh';

  // Obscura Program ID (update after deployment)
  // Get your program ID after deploying your Solana program
  static const String obscuraProgramId = String.fromEnvironment(
    'OBSCURA_PROGRAM_ID',
    defaultValue: 'YOUR_PROGRAM_ID', // Replace with your deployed program ID
  );

  /// Check if Obscura Program ID is configured
  static bool get isObscuraProgramConfigured =>
      obscuraProgramId.isNotEmpty && obscuraProgramId != 'YOUR_PROGRAM_ID';

  // VRF Program ID (if available)
  static const String? vrfProgramId = null;

  // Devnet validators
  static const Map<String, String> magicblockDevnetValidators = {
    'asia': 'MAS1Dt9qreoRMQ14YQuhg8UTZMMzDdKhmkZMECCzk57',
    'eu': 'MEUEuQfpPYQFvpZYMmwvbJeYpNUYDVbqLNcGJPc5ZwK',
    'us': 'MFVa7oPEvPZxmVeLgyqhYQJt2PkjfVdvZ3hNKVRWP3Z',
  };

  // ============================================================
  // Magic Block / Arcium (Confidential Computing) - Legacy
  // ============================================================
  //
  // Note: This API key is currently unused. Ephemeral rollups use the
  // RPC endpoints directly without requiring an API key.

  static const String magicBlockApiKey = String.fromEnvironment(
    'MAGIC_BLOCK_API_KEY',
    defaultValue: '', // Currently unused
  );
  static const String magicBlockUrl = 'https://api.magicblock.xyz';

  // ============================================================
  // WalletConnect (for EVM wallets)
  // ============================================================
  //
  // Get your Project ID from: https://cloud.walletconnect.com
  // 1. Sign up at https://cloud.walletconnect.com
  // 2. Create a new project
  // 3. Copy the Project ID below

  static const String walletConnectProjectId = String.fromEnvironment(
    'WALLETCONNECT_PROJECT_ID',
    defaultValue: 'YOUR_WALLETCONNECT_PROJECT_ID', // Replace with your actual Project ID
  );

  /// Check if WalletConnect is configured
  static bool get isWalletConnectConfigured =>
      walletConnectProjectId.isNotEmpty &&
      walletConnectProjectId != 'YOUR_WALLETCONNECT_PROJECT_ID';

  // ============================================================
  // Network Selection
  // ============================================================

  /// Whether to use devnet (true) or mainnet (false)
  static bool isDevnet = true;

  /// Get appropriate Helius RPC URL based on network
  static String get heliusRpc =>
      isDevnet ? heliusDevnetRpc : heliusMainnetRpc;

  /// Get Helius compression RPC URL (with Light Protocol support)
  static String get heliusCompressionRpcUrl =>
      isDevnet
          ? '$heliusCompressionRpc?api-key=$heliusApiKey'
          : '$heliusMainnetCompressionRpc?api-key=$heliusApiKey';

  /// Get appropriate MagicBlock RPC URL based on network
  static String get magicblockRpc =>
      isDevnet ? magicblockDevnetRpc : magicblockMainnetRpc;

  /// Get appropriate MagicBlock WebSocket URL based on network
  static String get magicblockWs =>
      isDevnet ? magicblockDevnetWs : magicblockMainnetWs;

  /// Get validators for current network
  static Map<String, String> get magicblockValidators =>
      isDevnet ? magicblockDevnetValidators : const {};

  /// Get Solana RPC URL based on network (for reference)
  static String get solanaRpc =>
      isDevnet ? solanaDevnetRpc : solanaMainnetRpc;

  // ============================================================
  // App Configuration
  // ============================================================

  static const String appName = 'Obscura Vault';
  static const String appUrl = 'https://obscura.app';
  static int commitmentTimeout = 60; // seconds

  // ============================================================
  // Feature Flags
  // ============================================================

  /// Enable Ephemeral Rollups
  static const bool enableER = true;

  /// Enable VRF
  static const bool enableVRF = true;

  /// Enable PER (Private ER)
  static const bool enablePER = true;

  /// Enable ZK Compression (Light Protocol)
  /// Requires light_sdk package and Helius RPC with compression support
  static const bool enableCompression = true;

  // ============================================================
  // Timeout Settings
  // ============================================================

  static const int rpcTimeout = 30; // seconds
  static const int transactionTimeout = 120; // seconds
  static const int delegationTimeout = 60; // seconds

  // ============================================================
  // Gas/Fee Configuration
  // ============================================================

  static const int defaultPriorityFee = 1000; // microlamports
  static const int fastPriorityFee = 10000; // microlamports
  static const int turboPriorityFee = 100000; // microlamports

  // ============================================================
  // DEX Configuration
  // ============================================================

  // Jupiter aggregator
  static const String jupiterProgram = 'JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4';
  static const String jupiterApi = 'https://quote-api.jup.ag';

  // Orca Whirlpools
  static const String orcaWhirlpoolProgram = 'whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc';

  // ============================================================
  // Token Mints (Common)
  // ============================================================

  static const String solMint = 'So11111111111111111111111111111111111111112';
  static const String usdcMint = 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v';
  static const String usdtMint = 'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB';
  static const String rayMint = '4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R';

  // ============================================================
  // Helper Methods
  // ============================================================

  /// Switch between devnet and mainnet
  static void setNetwork(bool devnet) {
    isDevnet = devnet;
  }

  /// Get current network name
  static String get networkName => isDevnet ? 'devnet' : 'mainnet';

  /// Check if running on devnet
  static bool get isDevnetMode => isDevnet;

  /// Check if running on mainnet
  static bool get isMainnetMode => !isDevnet;

  // ============================================================
  // Configuration Validation
  // ============================================================

  /// Check if all required configuration is set
  static ConfigStatus getConfigStatus() {
    return ConfigStatus(
      isHeliusConfigured: isHeliusConfigured,
      isWalletConnectConfigured: isWalletConnectConfigured,
      isObscuraProgramConfigured: isObscuraProgramConfigured,
      isFullyConfigured: isHeliusConfigured && isWalletConnectConfigured,
      networkName: networkName,
    );
  }

  /// Print configuration status (for debugging)
  static void printConfigStatus() {
    final status = getConfigStatus();
    debugPrint('========================================');
    debugPrint('Obscura Vault Configuration Status');
    debugPrint('========================================');
    debugPrint('Network: ${status.networkName}');
    debugPrint('Helius API Key: ${status.isHeliusConfigured ? "✓ Configured" : "✗ Not configured"}');
    debugPrint('WalletConnect: ${status.isWalletConnectConfigured ? "✓ Configured" : "✗ Not configured"}');
    debugPrint('Obscura Program ID: ${status.isObscuraProgramConfigured ? "✓ Configured" : "✗ Not configured"}');
    debugPrint('Status: ${status.isFullyConfigured ? "✓ Ready" : "✗ Configuration needed"}');
    debugPrint('========================================');
  }
}

/// Configuration status model
class ConfigStatus {
  final bool isHeliusConfigured;
  final bool isWalletConnectConfigured;
  final bool isObscuraProgramConfigured;
  final bool isFullyConfigured;
  final String networkName;

  ConfigStatus({
    required this.isHeliusConfigured,
    required this.isWalletConnectConfigured,
    required this.isObscuraProgramConfigured,
    required this.isFullyConfigured,
    required this.networkName,
  });

  @override
  String toString() {
    return 'ConfigStatus(network: $networkName, helius: $isHeliusConfigured, '
        'walletConnect: $isWalletConnectConfigured, '
        'obscuraProgram: $isObscuraProgramConfigured, '
        'fullyConfigured: $isFullyConfigured)';
  }
}
