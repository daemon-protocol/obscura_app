import 'package:flutter/foundation.dart';
import 'package:light_sdk/light_sdk.dart' as light_sdk;
import 'package:solana/solana.dart';

/// Light Protocol ZK Compression Service
///
/// Uses the official light_sdk package for:
/// - Compressing SOL into compressed accounts
/// - Transferring compressed SOL/tokens
/// - Decompressing back to regular SOL
///
/// See: https://www.zkcompression.com
/// Package: https://pub.dev/packages/light_sdk
class LightProtocolService {
  LightProtocolService._({
    required this.rpcUrl,
  });

  final String rpcUrl;
  late final light_sdk.Rpc _rpc;

  static LightProtocolService? _instance;

  static LightProtocolService get instance {
    if (_instance == null) {
      throw Exception('LightProtocolService not initialized. Call init() first.');
    }
    return _instance!;
  }

  /// Initialize the service
  static void init(String rpcUrl) {
    _instance = LightProtocolService._(rpcUrl: rpcUrl);
    _instance!._rpc = light_sdk.Rpc.create(rpcUrl);
  }

  /// Get RPC instance
  light_sdk.Rpc get rpc => _rpc;

  /// Check if service is initialized
  static bool get isInitialized => _instance != null;

  // ============================================================
  // SOL Compression
  // ============================================================

  /// Compress SOL into compressed accounts
  ///
  /// Converts regular SOL into compressed SOL accounts which are
  /// significantly cheaper to store and transfer (~1000x cheaper).
  Future<String> compressSol({
    required Ed25519HDKeyPair payer,
    required BigInt lamports,
    required Ed25519HDPublicKey toAddress,
  }) async {
    try {
      debugPrint('Compressing $lamports lamports to ${toAddress.toBase58()}');
      return await light_sdk.compress(
        rpc: _rpc,
        payer: payer,
        lamports: lamports,
        toAddress: toAddress,
      );
    } catch (e) {
      debugPrint('Error compressing SOL: $e');
      rethrow;
    }
  }

  /// Get compressed SOL balance
  ///
  /// Returns the total compressed SOL balance for the given owner.
  Future<BigInt> getCompressedBalance(Ed25519HDPublicKey owner) async {
    try {
      return await _rpc.getCompressedBalanceByOwner(owner);
    } catch (e) {
      debugPrint('Error getting compressed balance: $e');
      return BigInt.zero;
    }
  }

  /// Get total balance (regular + compressed)
  ///
  /// Returns the sum of regular SOL balance and compressed SOL balance.
  Future<BigInt> getTotalBalance(Ed25519HDPublicKey owner) async {
    try {
      // Get compressed balance
      final compressedBalance = await getCompressedBalance(owner);

      // For regular balance, we'd need to call a standard RPC
      // This is a placeholder - in production, you'd get this from Helius
      return compressedBalance;
    } catch (e) {
      debugPrint('Error getting total balance: $e');
      return BigInt.zero;
    }
  }

  /// Transfer compressed SOL
  ///
  /// Transfers compressed SOL from one account to another.
  /// Significantly cheaper than regular SOL transfers.
  Future<String> transferCompressedSol({
    required Ed25519HDKeyPair payer,
    required Ed25519HDKeyPair owner,
    required BigInt lamports,
    required Ed25519HDPublicKey toAddress,
  }) async {
    try {
      debugPrint('Transferring $lamports compressed lamports to ${toAddress.toBase58()}');
      return await light_sdk.transfer(
        rpc: _rpc,
        payer: payer,
        owner: owner,
        lamports: lamports,
        toAddress: toAddress,
      );
    } catch (e) {
      debugPrint('Error transferring compressed SOL: $e');
      rethrow;
    }
  }

  /// Decompress SOL back to regular accounts
  ///
  /// Converts compressed SOL back to regular SOL accounts.
  Future<String> decompressSol({
    required Ed25519HDKeyPair payer,
    required BigInt lamports,
    required Ed25519HDPublicKey recipient,
  }) async {
    try {
      debugPrint('Decompressing $lamports lamports to ${recipient.toBase58()}');
      return await light_sdk.decompress(
        rpc: _rpc,
        payer: payer,
        lamports: lamports,
        recipient: recipient,
      );
    } catch (e) {
      debugPrint('Error decompressing SOL: $e');
      rethrow;
    }
  }

  // ============================================================
  // Compressed Token Operations
  // ============================================================

  /// Get compressed token accounts by owner
  ///
  /// Returns all compressed token accounts for the given owner.
  /// Optionally filter by mint address.
  Future<List<CompressedTokenAccount>> getCompressedTokenAccounts(
    Ed25519HDPublicKey owner, {
    Ed25519HDPublicKey? mint,
  }) async {
    try {
      final result = await _rpc.getCompressedTokenBalancesByOwner(owner, mint: mint);

      // Handle WithCursor response - access items directly
      final items = result.items;

      final compressedAccounts = items.map((tokenBalance) {
        return CompressedTokenAccount(
          mint: tokenBalance.mint,
          amount: tokenBalance.balance,
          accountHash: tokenBalance.mint.bytes,
        );
      }).toList();

      return compressedAccounts;
    } catch (e) {
      debugPrint('Error getting compressed token accounts: $e');
      return [];
    }
  }

  /// Get compressed token balance for specific mint
  ///
  /// Returns the total compressed token balance for the given owner and mint.
  Future<BigInt> getCompressedTokenBalance(
    Ed25519HDPublicKey owner,
    Ed25519HDPublicKey mint,
  ) async {
    try {
      final accounts = await getCompressedTokenAccounts(owner, mint: mint);

      // Use a simple for loop to sum BigInt values
      var total = BigInt.zero;
      for (final account in accounts) {
        total += account.amount;
      }
      return total;
    } catch (e) {
      debugPrint('Error getting compressed token balance: $e');
      return BigInt.zero;
    }
  }

  // ============================================================
  // Proof Operations
  // ============================================================

  /// Get validity proof for compressed accounts
  ///
  /// Returns a validity proof that can be used to verify the
  /// state of compressed accounts.
  Future<ValidityProof> getValidityProof(List<light_sdk.BN254> hashes) async {
    try {
      final proofWithContext = await _rpc.getValidityProof(hashes: hashes);

      // Extract the compressed proof data
      final compressedProof = proofWithContext.compressedProof;
      if (compressedProof == null) {
        throw Exception('No compressed proof in response');
      }

      // CompressedProof has a, b, c components (G1 points)
      // Encode them together for storage
      final proofData = [
        ...compressedProof.a,
        ...compressedProof.b,
        ...compressedProof.c,
      ];

      return ValidityProof(
        compressedProof: proofData,
        rootIndices: proofWithContext.rootIndices,
      );
    } catch (e) {
      debugPrint('Error getting validity proof: $e');
      rethrow;
    }
  }

  // ============================================================
  // Network
  // ============================================================

  /// Set network (devnet/mainnet)
  ///
  /// Updates the RPC endpoint for the service.
  void setNetwork(String rpcUrl) {
    _instance = LightProtocolService._(rpcUrl: rpcUrl);
    _instance!._rpc = light_sdk.Rpc.create(rpcUrl);
    debugPrint('Light Protocol network updated to: $rpcUrl');
  }

  /// Get current RPC URL
  String get currentRpcUrl => rpcUrl;

  // ============================================================
  // Utility Methods
  // ============================================================

  /// Check if an account has compressed SOL
  Future<bool> hasCompressedSol(Ed25519HDPublicKey owner) async {
    final balance = await getCompressedBalance(owner);
    return balance > BigInt.zero;
  }

  /// Format lamports to SOL
  double lamportsToSol(BigInt lamports) {
    return lamports.toDouble() / 1e9;
  }

  /// Format SOL to lamports
  BigInt solToLamports(double sol) {
    return BigInt.from((sol * 1e9).floor());
  }
}

/// Compressed token account model
class CompressedTokenAccount {
  final Ed25519HDPublicKey mint;
  final BigInt amount;
  final List<int> accountHash;

  CompressedTokenAccount({
    required this.mint,
    required this.amount,
    required this.accountHash,
  });

  @override
  String toString() {
    return 'CompressedTokenAccount(mint: ${mint.toBase58()}, amount: $amount)';
  }
}

/// Validity proof model
class ValidityProof {
  final List<int> compressedProof;
  final List<int> rootIndices;

  ValidityProof({
    required this.compressedProof,
    required this.rootIndices,
  });

  @override
  String toString() {
    return 'ValidityProof(proofLength: ${compressedProof.length}, indices: $rootIndices)';
  }
}

/// Compression result model
class CompressionResult {
  final String signature;
  final bool success;
  final String? error;
  final int latencyMs;
  final BigInt compressedAmount;

  CompressionResult({
    required this.signature,
    required this.success,
    this.error,
    required this.latencyMs,
    required this.compressedAmount,
  });

  factory CompressionResult.success({
    required String signature,
    required int latencyMs,
    required BigInt amount,
  }) {
    return CompressionResult(
      signature: signature,
      success: true,
      latencyMs: latencyMs,
      compressedAmount: amount,
    );
  }

  factory CompressionResult.failure({
    required String error,
    required int latencyMs,
  }) {
    return CompressionResult(
      signature: '',
      success: false,
      error: error,
      latencyMs: latencyMs,
      compressedAmount: BigInt.zero,
    );
  }
}
