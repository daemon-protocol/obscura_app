import 'dart:convert';
import 'package:http/http.dart' as http;

/// Helius RPC Service for Solana
///
/// Provides:
/// - Standard Solana JSON-RPC methods with devnet/mainnet support
/// - Helius-enhanced APIs (assets, webhooks, transactions)
/// - Priority Fee estimation
/// - Mandel (Smart Transaction) support
///
/// Documentation: https://www.helius.dev/docs/rpc/overview
class HeliusService {
  HeliusService._({
    required this.apiKey,
    this.isDevnet = false,
  }) {
    _updateUrls();
  }

  final String apiKey;
  bool isDevnet;

  late String _rpcUrl;
  late String _apiBaseUrl;

  static HeliusService? _instance;

  /// Check if service is initialized
  static bool get isInitialized => _instance != null;

  static HeliusService get instance {
    if (_instance == null) {
      throw Exception('HeliusService not initialized. Call init() first.');
    }
    return _instance!;
  }

  static void init(String apiKey, {bool isDevnet = false}) {
    _instance = HeliusService._(
      apiKey: apiKey,
      isDevnet: isDevnet,
    );
  }

  /// Update URLs based on current network
  void _updateUrls() {
    _rpcUrl = isDevnet
        ? 'https://rpc-devnet.helius.xyz'
        : 'https://rpc.helius.xyz';
    _apiBaseUrl = _rpcUrl;
  }

  /// Switch network (devnet/mainnet)
  void setNetwork(bool devnet) {
    isDevnet = devnet;
    _updateUrls();
  }

  /// Get current RPC URL
  String get rpcUrl => _rpcUrl;

  /// Get current API base URL
  String get apiBaseUrl => _apiBaseUrl;

  // ============================================================
  // Standard Solana RPC Methods
  // ============================================================

  /// Get account balance in SOL
  Future<double> getBalance(String address) async {
    final response = await _rpcCall('getBalance', [address, 'confirmed']);

    if (response['result'] == null) {
      throw HeliusError('Failed to get balance');
    }

    final lamports = response['result']['value'] as int;
    return lamports / 1e9; // Convert to SOL
  }

  /// Get account info
  Future<Map<String, dynamic>?> getAccountInfo(
    String address, {
    String encoding = 'base64',
  }) async {
    final response = await _rpcCall('getAccountInfo', [
      address,
      {'encoding': encoding}
    ]);

    return response['result'] as Map<String, dynamic>?;
  }

  /// Get recent transaction signatures for an address
  Future<List<Map<String, dynamic>>> getSignaturesForAddress(
    String address, {
    int limit = 10,
    String? before,
    String? until,
  }) async {
    final params = [
      address,
      {
        'limit': limit,
        if (before != null) 'before': before,
        if (until != null) 'until': until,
      }
    ];

    final response = await _rpcCall('getSignaturesForAddress', params);

    if (response['result'] == null) {
      return [];
    }

    return (response['result'] as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  /// Get transaction details
  Future<Map<String, dynamic>?> getTransaction(
    String signature, {
    String encoding = 'jsonParsed',
  }) async {
    final response = await _rpcCall('getTransaction', [
      signature,
      {'encoding': encoding}
    ]);

    return response['result'] as Map<String, dynamic>?;
  }

  /// Send transaction
  Future<String> sendTransaction(
    String transaction, {
    bool skipPreflight = false,
    String? encoding,
  }) async {
    final params = [
      transaction,
      {
        'skipPreflight': skipPreflight,
        if (encoding != null) 'encoding': encoding,
      }
    ];

    final response = await _rpcCall('sendTransaction', params);

    if (response['result'] == null) {
      throw HeliusError('Failed to send transaction');
    }

    return response['result'] as String;
  }

  /// Get latest blockhash
  Future<Map<String, dynamic>> getLatestBlockhash({
    String commitment = 'confirmed',
  }) async {
    final response = await _rpcCall('getLatestBlockhash', [
      {'commitment': commitment}
    ]);

    if (response['result'] == null) {
      throw HeliusError('Failed to get latest blockhash');
    }

    return response['result']['value'] as Map<String, dynamic>;
  }

  /// Get token accounts by owner
  Future<List<Map<String, dynamic>>> getTokenAccounts(
    String address, {
    String? mint,
    String encoding = 'jsonParsed',
  }) async {
    final params = [
      address,
      {
        'mint': mint ?? 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',
        'encoding': encoding,
      }
    ];

    final response = await _rpcCall('getTokenAccountsByOwner', params);

    if (response['result'] == null) {
      return [];
    }

    return (response['result']['value'] as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  /// Get slot height
  Future<int> getSlot() async {
    final response = await _rpcCall('getSlot', []);

    if (response['result'] == null) {
      throw HeliusError('Failed to get slot');
    }

    return response['result'] as int;
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
  Future<Map<String, dynamic>> getVersion() async {
    final response = await _rpcCall('getVersion', []);

    if (response['result'] == null) {
      throw HeliusError('Failed to get version');
    }

    return response['result'] as Map<String, dynamic>;
  }

  /// Simulate transaction
  Future<Map<String, dynamic>> simulateTransaction(
    String transaction, {
    bool replaceRecentBlockhash = true,
    String commitment = 'confirmed',
  }) async {
    final response = await _rpcCall('simulateTransaction', [
      transaction,
      {
        'replaceRecentBlockhash': replaceRecentBlockhash,
        'commitment': commitment,
      }
    ]);

    if (response['result'] == null) {
      throw HeliusError('Failed to simulate transaction');
    }

    return response['result'] as Map<String, dynamic>;
  }

  // ============================================================
  // Helius-Specific APIs
  // ============================================================

  /// Get assets by owner (includes NFTs, compressed NFTs, tokens)
  ///
  /// Helius REST API endpoint
  Future<List<Map<String, dynamic>>> getAssetsByOwner(
    String address, {
    int page = 1,
    int limit = 1000,
    String? displayOption,
  }) async {
    var url = Uri.parse('$_apiBaseUrl/v0/addresses/$address/assets')
        .replace(queryParameters: {
      'api-key': apiKey,
      'page': page.toString(),
      'limit': limit.toString(),
      if (displayOption != null) 'display-option': displayOption,
    });

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw HeliusError('Failed to get assets: ${response.body}');
    }

    final json = jsonDecode(response.body);

    return (json['items'] as List? ?? [])
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  /// Get asset proof (for compressed NFTs)
  ///
  /// Helius REST API endpoint
  Future<Map<String, dynamic>> getAssetProof(String assetId) async {
    final url = Uri.parse('$_apiBaseUrl/v0/asset/$assetId/proof')
        .replace(queryParameters: {'api-key': apiKey});

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw HeliusError('Failed to get asset proof: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Get asset details
  ///
  /// Helius REST API endpoint
  Future<Map<String, dynamic>> getAsset(String assetId) async {
    final url = Uri.parse('$_apiBaseUrl/v0/asset/$assetId')
        .replace(queryParameters: {'api-key': apiKey});

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw HeliusError('Failed to get asset: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Get transactions for an address (Helius-enhanced API)
  ///
  /// This is a Helius-specific method that provides more comprehensive
  /// transaction history than getSignaturesForAddress.
  Future<List<Map<String, dynamic>>> getTransactionsForAddress(
    String address, {
    int limit = 10,
    String? before,
    String? after,
    List<String>? types,
  }) async {
    var url = Uri.parse('$_apiBaseUrl/v0/addresses/$address/transactions')
        .replace(queryParameters: {
      'api-key': apiKey,
      'limit': limit.toString(),
      if (before != null) 'before': before,
      if (after != null) 'after': after,
      if (types != null) 'type': types.join(','),
    });

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw HeliusError('Failed to get transactions: ${response.body}');
    }

    final json = jsonDecode(response.body);

    return (json as List? ?? [])
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  /// Create webhook for transaction monitoring
  ///
  /// Helius REST API endpoint
  Future<Map<String, dynamic>> createWebhook({
    required String webhookUrl,
    required List<WebhookEventType> eventTypes,
    String? accountAddress,
    List<String>? accountAddresses,
    String? webhookType,
    int? txnStatus,
  }) async {
    final url = Uri.parse('$_apiBaseUrl/v0/webhooks')
        .replace(queryParameters: {'api-key': apiKey});

    final body = jsonEncode({
      'webhookURL': webhookUrl,
      'transactionTypes': eventTypes.map((e) => e.apiName).toList(),
      if (accountAddress != null)
        'accountAddresses': [accountAddress]
      else if (accountAddresses != null)
        'accountAddresses': accountAddresses,
      if (webhookType != null) 'webhookType': webhookType,
      if (txnStatus != null) 'txnStatus': txnStatus,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw HeliusError('Failed to create webhook: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Get all webhooks
  ///
  /// Helius REST API endpoint
  Future<List<Map<String, dynamic>>> getWebhooks() async {
    final url = Uri.parse('$_apiBaseUrl/v0/webhooks')
        .replace(queryParameters: {'api-key': apiKey});

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw HeliusError('Failed to get webhooks: ${response.body}');
    }

    final json = jsonDecode(response.body);

    return (json as List? ?? [])
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  /// Delete a webhook
  ///
  /// Helius REST API endpoint
  Future<void> deleteWebhook(String webhookId) async {
    final url = Uri.parse('$_apiBaseUrl/v0/webhooks/$webhookId')
        .replace(queryParameters: {'api-key': apiKey});

    final response = await http.delete(url);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw HeliusError('Failed to delete webhook: ${response.body}');
    }
  }

  // ============================================================
  // Priority Fee API
  // ============================================================

  /// Get priority fee estimate
  ///
  /// Helius Priority Fee API for estimating fees to get transactions
  /// prioritized by validators.
  Future<PriorityFeeEstimate> getPriorityFeeEstimate({
    required String transaction,
    bool recommended = true,
  }) async {
    final url = Uri.parse('$_apiBaseUrl/v0/transactions/priority-fee')
        .replace(queryParameters: {'api-key': apiKey});

    final body = jsonEncode({
      'transaction': transaction,
      if (recommended) 'recommended': true,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw HeliusError('Failed to get priority fee estimate: ${response.body}');
    }

    final json = jsonDecode(response.body);
    return PriorityFeeEstimate.fromJson(json);
  }

  /// Get current priority fee levels (low, medium, high)
  ///
  /// Returns a map of priority fee levels in microlamports
  Future<Map<String, int>> getPriorityFeeLevels() async {
    final url = Uri.parse('$_apiBaseUrl/v0/priority-fees')
        .replace(queryParameters: {'api-key': apiKey});

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw HeliusError('Failed to get priority fee levels: ${response.body}');
    }

    final json = jsonDecode(response.body);

    return {
      'low': json['low'] as int? ?? 1000,
      'medium': json['medium'] as int? ?? 10000,
      'high': json['high'] as int? ?? 100000,
    };
  }

  // ============================================================
  // Mandel (Smart Transaction) Support
  // ============================================================

  /// Create a smart transaction using Helius Mandel
  ///
  /// Mandel is Helius's smart transaction service that handles
  /// transaction bundling, retry logic, and fee optimization.
  Future<Map<String, dynamic>> createSmartTransaction({
    required List<Map<String, dynamic>> instructions,
    required String feePayer,
    List<String>? additionalSigners,
    int? priorityFeeLimit,
    String? commitment,
  }) async {
    final url = Uri.parse('$_apiBaseUrl/v0/transactions')
        .replace(queryParameters: {'api-key': apiKey});

    final body = jsonEncode({
      'instructions': instructions,
      'feePayer': feePayer,
      if (additionalSigners != null) 'additionalSigners': additionalSigners,
      if (priorityFeeLimit != null) 'priorityFeeLimit': priorityFeeLimit,
      if (commitment != null) 'commitment': commitment,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw HeliusError('Failed to create smart transaction: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ============================================================
  // Generic RPC Call
  // ============================================================

  /// Generic JSON-RPC call
  Future<Map<String, dynamic>> _rpcCall(
    String method,
    List<dynamic> params,
  ) async {
    final url = Uri.parse('$_rpcUrl/?api-key=$apiKey');

    final body = jsonEncode({
      'jsonrpc': '2.0',
      'id': DateTime.now().millisecondsSinceEpoch,
      'method': method,
      'params': params,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw HeliusError('RPC call failed: ${response.statusCode}');
    }

    final json = jsonDecode(response.body);

    if (json['error'] != null) {
      throw HeliusError(json['error']['message'] ?? 'Unknown RPC error');
    }

    return json as Map<String, dynamic>;
  }
}

// ============================================================
  // Types & Enums
  // ============================================================

/// Webhook event types for Helius webhooks
enum WebhookEventType {
  // ignore: constant_identifier_names
  transaction,
  // ignore: constant_identifier_names
  nativeTransfer,
  // ignore: constant_identifier_names
  tokenTransfer,
  // ignore: constant_identifier_names
  compressedNftTransfer,
  // ignore: constant_identifier_names
  compressedNftSale,
  // ignore: constant_identifier_names
  any,
  // ignore: constant_identifier_names
  nftSale,
  // ignore: constant_identifier_names
  nftListing,
  // ignore: constant_identifier_names
  nftDelisting,
  // ignore: constant_identifier_names
  nftBid,
  // ignore: constant_identifier_names
  nftCancelBid;

  /// Get the API string representation (SCREAMING_CASE)
  String get apiName {
    switch (this) {
      case WebhookEventType.transaction: return 'TRANSACTION';
      case WebhookEventType.nativeTransfer: return 'NATIVE_TRANSFER';
      case WebhookEventType.tokenTransfer: return 'TOKEN_TRANSFER';
      case WebhookEventType.compressedNftTransfer: return 'COMPRESSED_NFT_TRANSFER';
      case WebhookEventType.compressedNftSale: return 'COMPRESSED_NFT_SALE';
      case WebhookEventType.any: return 'ANY';
      case WebhookEventType.nftSale: return 'NFT_SALE';
      case WebhookEventType.nftListing: return 'NFT_LISTING';
      case WebhookEventType.nftDelisting: return 'NFT_DELISTING';
      case WebhookEventType.nftBid: return 'NFT_BID';
      case WebhookEventType.nftCancelBid: return 'NFT_CANCEL_BID';
    }
  }
}

/// Priority fee estimate from Helius
class PriorityFeeEstimate {
  final int priorityFeeEstimate;
  final int? priorityFeeLevel;
  final String? confidenceLevel;

  PriorityFeeEstimate({
    required this.priorityFeeEstimate,
    this.priorityFeeLevel,
    this.confidenceLevel,
  });

  factory PriorityFeeEstimate.fromJson(Map<String, dynamic> json) {
    return PriorityFeeEstimate(
      priorityFeeEstimate: json['priorityFeeEstimate'] as int? ?? 0,
      priorityFeeLevel: json['priorityFeeLevel'] as int?,
      confidenceLevel: json['confidenceLevel'] as String?,
    );
  }

  /// Get priority fee in SOL
  double get inSol => priorityFeeEstimate / 1e9;
}

/// Helius error class
class HeliusError implements Exception {
  final String message;

  HeliusError(this.message);

  @override
  String toString() => 'HeliusError: $message';
}
