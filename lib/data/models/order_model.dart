/// Lightweight order model used by the Chef dashboard, order queue,
/// and preparation screens.

enum OrderStatus { incoming, preparing, readyForPickup, completed }

enum FulfillmentType { delivery, pickup, scheduled }

class OrderItem {
  const OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    this.note,
  });

  final String id;
  final String name;
  final int quantity;
  final String? note;

  /// e.g. "2× Margherita Pizza"
  String get quantityLabel => '$quantity× $name';
}

class OrderModel {
  const OrderModel({
    required this.id,
    required this.customerName,
    required this.items,
    required this.total,
    required this.status,
    required this.fulfillmentType,
    this.distanceKm,
    this.remainingSeconds,
    this.totalPrepSeconds,
    this.customerNote,
    this.targetPrepTime,
    this.pickedUpBy,
  });

  final String id;
  final String customerName;
  final List<OrderItem> items;
  final double total;
  final OrderStatus status;
  final FulfillmentType fulfillmentType;
  final double? distanceKm;
  final int? remainingSeconds;
  final int? totalPrepSeconds;
  final String? customerNote;
  final String? targetPrepTime;
  final String? pickedUpBy;

  /// Total quantity of items in the order.
  int get itemCount => items.fold<int>(0, (sum, i) => sum + i.quantity);

  /// Progress from 0.0 → 1.0 based on remaining / total prep time.
  double get prepProgress {
    if (totalPrepSeconds == null || totalPrepSeconds == 0) return 0;
    final elapsed = totalPrepSeconds! - (remainingSeconds ?? 0);
    return (elapsed / totalPrepSeconds!).clamp(0.0, 1.0);
  }

  /// Human-friendly remaining time string, e.g. "8:38".
  String get formattedRemaining {
    final secs = remainingSeconds ?? 0;
    if (secs <= 0) return '0:00';
    final m = secs ~/ 60;
    final s = secs % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  /// Shallow copy with optional overrides.
  OrderModel copyWith({
    String? id,
    String? customerName,
    List<OrderItem>? items,
    double? total,
    OrderStatus? status,
    FulfillmentType? fulfillmentType,
    double? distanceKm,
    int? remainingSeconds,
    int? totalPrepSeconds,
    String? customerNote,
    String? targetPrepTime,
    String? pickedUpBy,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      total: total ?? this.total,
      status: status ?? this.status,
      fulfillmentType: fulfillmentType ?? this.fulfillmentType,
      distanceKm: distanceKm ?? this.distanceKm,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalPrepSeconds: totalPrepSeconds ?? this.totalPrepSeconds,
      customerNote: customerNote ?? this.customerNote,
      targetPrepTime: targetPrepTime ?? this.targetPrepTime,
      pickedUpBy: pickedUpBy ?? this.pickedUpBy,
    );
  }
}

/// Wrapper passed through Navigator arguments to the OrderPreparationScreen.
class OrderPreparationArgs {
  const OrderPreparationArgs(this.order);
  final OrderModel order;
}
