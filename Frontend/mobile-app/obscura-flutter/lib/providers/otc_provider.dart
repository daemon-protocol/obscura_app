import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/dark_otc_models.dart';
import '../services/magic_block_service.dart';
import '../services/light_protocol_service.dart';

/// OTC Provider for managing RFQs and quotes
class OTCProvider with ChangeNotifier {
  List<RFQ> _myRFQs = [];
  Map<String, List<Quote>> _quotesByRFQ = {};
  bool _loading = false;
  String? _error;

  List<RFQ> get myRFQs => _myRFQs;
  List<Quote> getQuotesForRFQ(String rfqId) => _quotesByRFQ[rfqId] ?? [];
  bool get loading => _loading;
  String? get error => _error;

  /// Create a new RFQ
  Future<RFQ?> createRFQ({
    required String pair,
    required double amount,
    required String side,
    required Duration expiryDuration,
    required String requesterAddress,
    bool usePrivateMode = false,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final rfqId = DateTime.now().millisecondsSinceEpoch.toString();
      final expiryTime = DateTime.now().add(expiryDuration);

      final rfq = RFQ(
        id: rfqId,
        pair: pair,
        amount: amount,
        side: side,
        expiryTime: expiryTime,
        createdAt: DateTime.now(),
        requester: requesterAddress,
        isPrivate: usePrivateMode,
      );

      // Store RFQ in compressed account (cheap storage)
      if (LightProtocolService.isInitialized) {
        debugPrint('Storing RFQ in compressed account: $rfqId');
      }

      _myRFQs.insert(0, rfq);
      _loading = false;
      notifyListeners();

      // Simulate receiving quotes after a delay
      _simulateQuotes(rfqId, usePrivateMode);

      return rfq;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return null;
    }
  }

  /// Simulate receiving quotes (in production, these come from market makers)
  Future<void> _simulateQuotes(String rfqId, bool isPrivate) async {
    await Future.delayed(const Duration(seconds: 2));

    final quotes = [
      Quote(
        id: '${rfqId}_1',
        rfqId: rfqId,
        price: 100.5,
        maker: 'MarketMaker1111111111111111111111111111',
        createdAt: DateTime.now(),
        expiryTime: DateTime.now().add(const Duration(minutes: 5)),
        teeVerified: isPrivate,
      ),
      Quote(
        id: '${rfqId}_2',
        rfqId: rfqId,
        price: 100.2,
        maker: 'MarketMaker2222222222222222222222222222',
        createdAt: DateTime.now(),
        expiryTime: DateTime.now().add(const Duration(minutes: 5)),
        teeVerified: isPrivate,
      ),
    ];

    _quotesByRFQ[rfqId] = quotes;

    // Update RFQ status
    final rfqIndex = _myRFQs.indexWhere((r) => r.id == rfqId);
    if (rfqIndex != -1) {
      _myRFQs[rfqIndex] = _myRFQs[rfqIndex].copyWith(status: RFQStatus.quoted);
    }

    notifyListeners();
  }

  /// Accept a quote
  Future<bool> acceptQuote({
    required String quoteId,
    required String rfqId,
    required String userAddress,
    bool usePrivateMode = false,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // Find the quote
      final quotes = _quotesByRFQ[rfqId];
      if (quotes == null) {
        throw Exception('Quotes not found');
      }

      final quoteIndex = quotes.indexWhere((q) => q.id == quoteId);
      if (quoteIndex == -1) {
        throw Exception('Quote not found');
      }

      final quote = quotes[quoteIndex];

      // Execute settlement via PER if private mode
      if (usePrivateMode && MagicBlockService.isInitialized) {
        final magicBlock = MagicBlockService.instance;

        final signature = await magicBlock.executePrivateTransfer(
          from: userAddress,
          to: quote.maker,
          amount: (quote.price * 1e9).toInt(),
          authority: userAddress,
        );

        if (signature.isNotEmpty) {
          await magicBlock.verifyTEEAttestation(transactionSignature: signature);
        }
      }

      // Update quote status
      _quotesByRFQ[rfqId]![quoteIndex] = quote.copyWith(status: QuoteStatus.accepted);

      // Update RFQ status
      final rfqIndex = _myRFQs.indexWhere((r) => r.id == rfqId);
      if (rfqIndex != -1) {
        _myRFQs[rfqIndex] = _myRFQs[rfqIndex].copyWith(status: RFQStatus.accepted);
      }

      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  /// Fetch user's RFQs
  Future<void> fetchMyRFQs(String userAddress) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // In production, fetch from Helius
      await Future.delayed(const Duration(milliseconds: 300));

      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
