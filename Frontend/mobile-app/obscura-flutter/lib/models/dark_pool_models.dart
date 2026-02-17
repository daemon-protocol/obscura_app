/// Order side (buy or sell)
enum OrderSide {
  buy,
  sell;

  String get displayName => name.toUpperCase();
}

/// Order type
enum OrderType {
  market,
  limit;

  String get displayName => name[0].toUpperCase() + name.substring(1);
}

/// Order status
enum OrderStatus {
  open,
  partiallyFilled,
  filled,
  cancelled,
  expired;

  String get displayName {
    switch (this) {
      case OrderStatus.partiallyFilled:
        return 'Partially Filled';
      default:
        return name[0].toUpperCase() + name.substring(1);
    }
  }
}

/// Trading pair
class TradingPair {
  final String base;
  final String quote;

  const TradingPair(this.base, this.quote);

  // Pre-defined constant pairs
  static const solUsdc = TradingPair('SOL', 'USDC');
  static const solUsdt = TradingPair('SOL', 'USDT');

  String get symbol => '$base/$quote';

  @override
  String toString() => symbol;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TradingPair && base == other.base && quote == other.quote;

  @override
  int get hashCode => base.hashCode ^ quote.hashCode;
}

/// Order model
class Order {
  final String id;
  final TradingPair pair;
  final OrderSide side;
  final OrderType type;
  final double amount;
  final double? price;
  final double filled;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? signature;
  final bool isPrivate;
  final bool teeVerified;

  const Order({
    required this.id,
    required this.pair,
    required this.side,
    required this.type,
    required this.amount,
    this.price,
    this.filled = 0,
    this.status = OrderStatus.open,
    required this.createdAt,
    this.updatedAt,
    this.signature,
    this.isPrivate = false,
    this.teeVerified = false,
  });

  Order copyWith({
    String? id,
    TradingPair? pair,
    OrderSide? side,
    OrderType? type,
    double? amount,
    double? price,
    double? filled,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? signature,
    bool? isPrivate,
    bool? teeVerified,
  }) {
    return Order(
      id: id ?? this.id,
      pair: pair ?? this.pair,
      side: side ?? this.side,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      price: price ?? this.price,
      filled: filled ?? this.filled,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      signature: signature ?? this.signature,
      isPrivate: isPrivate ?? this.isPrivate,
      teeVerified: teeVerified ?? this.teeVerified,
    );
  }

  double get remainingAmount => amount - filled;
  double get filledPercentage => (filled / amount) * 100;
}

/// Price level in order book
class PriceLevel {
  final double price;
  final double amount;
  final int orderCount;

  const PriceLevel({
    required this.price,
    required this.amount,
    required this.orderCount,
  });
}

/// Order book model
class OrderBook {
  final TradingPair pair;
  final List<PriceLevel> bids;
  final List<PriceLevel> asks;
  final DateTime timestamp;

  const OrderBook({
    required this.pair,
    required this.bids,
    required this.asks,
    required this.timestamp,
  });

  double? get bestBid => bids.isNotEmpty ? bids.first.price : null;
  double? get bestAsk => asks.isNotEmpty ? asks.first.price : null;
  double? get spread => (bestAsk != null && bestBid != null) ? bestAsk! - bestBid! : null;
}

/// Trade model
class Trade {
  final String id;
  final TradingPair pair;
  final OrderSide side;
  final double price;
  final double amount;
  final DateTime timestamp;
  final String? signature;
  final bool isPrivate;

  const Trade({
    required this.id,
    required this.pair,
    required this.side,
    required this.price,
    required this.amount,
    required this.timestamp,
    this.signature,
    this.isPrivate = false,
  });

  double get total => price * amount;
}
