class OrderItem {
  final String name;
  final int quantity;

  OrderItem({required this.name, required this.quantity});
}

class DriverOrder {
  final String id;
  final String customerName;
  final double customerRating;
  final String? customerAvatar;
  final String pickupName;
  final String pickupAddress;
  final String dropoffAddress;
  final String? deliveryNotes;
  final String distance;
  final String estTime;
  final double estPayout;
  final List<OrderItem> items;
  final String? readyIn;
  final String status; // 'available', 'active', 'completed', 'rejected'
  final String? deliveryStep; // 'accepted', 'pickedup', 'on-the-way', 'delivered'

  DriverOrder({
    required this.id,
    required this.customerName,
    required this.customerRating,
    this.customerAvatar,
    required this.pickupName,
    required this.pickupAddress,
    required this.dropoffAddress,
    this.deliveryNotes,
    required this.distance,
    required this.estTime,
    required this.estPayout,
    required this.items,
    this.readyIn,
    required this.status,
    this.deliveryStep,
  });

  DriverOrder copyWith({
    String? id,
    String? customerName,
    double? customerRating,
    String? customerAvatar,
    String? pickupName,
    String? pickupAddress,
    String? dropoffAddress,
    String? deliveryNotes,
    String? distance,
    String? estTime,
    double? estPayout,
    List<OrderItem>? items,
    String? readyIn,
    String? status,
    String? deliveryStep,
  }) {
    return DriverOrder(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerRating: customerRating ?? this.customerRating,
      customerAvatar: customerAvatar ?? this.customerAvatar,
      pickupName: pickupName ?? this.pickupName,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      deliveryNotes: deliveryNotes ?? this.deliveryNotes,
      distance: distance ?? this.distance,
      estTime: estTime ?? this.estTime,
      estPayout: estPayout ?? this.estPayout,
      items: items ?? this.items,
      readyIn: readyIn ?? this.readyIn,
      status: status ?? this.status,
      deliveryStep: deliveryStep ?? this.deliveryStep,
    );
  }
}
