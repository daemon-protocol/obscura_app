/// RFQ (Request for Quote) status
enum RFQStatus {
  pending,
  quoted,
  accepted,
  expired,
  cancelled;

  String get displayName => name[0].toUpperCase() + name.substring(1);
}

/// Quote status
enum QuoteStatus {
  active,
  accepted,
  rejected,
  expired;

  String get displayName => name[0].toUpperCase() + name.substring(1);
}

/// RFQ model
class RFQ {
  final String id;
  final String pair;
  final double amount;
  final String side; // 'buy' or 'sell'
  final DateTime expiryTime;
  final RFQStatus status;
  final DateTime createdAt;
  final String requester;
  final bool isPrivate;

  const RFQ({
    required this.id,
    required this.pair,
    required this.amount,
    required this.side,
    required this.expiryTime,
    this.status = RFQStatus.pending,
    required this.createdAt,
    required this.requester,
    this.isPrivate = false,
  });

  RFQ copyWith({
    String? id,
    String? pair,
    double? amount,
    String? side,
    DateTime? expiryTime,
    RFQStatus? status,
    DateTime? createdAt,
    String? requester,
    bool? isPrivate,
  }) {
    return RFQ(
      id: id ?? this.id,
      pair: pair ?? this.pair,
      amount: amount ?? this.amount,
      side: side ?? this.side,
      expiryTime: expiryTime ?? this.expiryTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      requester: requester ?? this.requester,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiryTime);
}

/// Quote model
class Quote {
  final String id;
  final String rfqId;
  final double price;
  final String maker;
  final QuoteStatus status;
  final DateTime createdAt;
  final DateTime expiryTime;
  final bool teeVerified;

  const Quote({
    required this.id,
    required this.rfqId,
    required this.price,
    required this.maker,
    this.status = QuoteStatus.active,
    required this.createdAt,
    required this.expiryTime,
    this.teeVerified = false,
  });

  Quote copyWith({
    String? id,
    String? rfqId,
    double? price,
    String? maker,
    QuoteStatus? status,
    DateTime? createdAt,
    DateTime? expiryTime,
    bool? teeVerified,
  }) {
    return Quote(
      id: id ?? this.id,
      rfqId: rfqId ?? this.rfqId,
      price: price ?? this.price,
      maker: maker ?? this.maker,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiryTime: expiryTime ?? this.expiryTime,
      teeVerified: teeVerified ?? this.teeVerified,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiryTime);
  String get formattedMaker => '${maker.substring(0, 6)}...${maker.substring(maker.length - 4)}';
}
