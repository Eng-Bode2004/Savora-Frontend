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
  final String status;
  final String? deliveryStep;

  // Enriched chef details
  final String chefName;
  final String chefPhone;
  final String chefAddress;
  final String chefImage;

  // Enriched customer details
  final String customerPhone;
  final String customerEmail;
  final String dropoffCity;
  final String dropoffLabel;

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
    this.chefName = '',
    this.chefPhone = '',
    this.chefAddress = '',
    this.chefImage = '',
    this.customerPhone = '',
    this.customerEmail = '',
    this.dropoffCity = '',
    this.dropoffLabel = '',
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
    String? chefName,
    String? chefPhone,
    String? chefAddress,
    String? chefImage,
    String? customerPhone,
    String? customerEmail,
    String? dropoffCity,
    String? dropoffLabel,
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
      chefName: chefName ?? this.chefName,
      chefPhone: chefPhone ?? this.chefPhone,
      chefAddress: chefAddress ?? this.chefAddress,
      chefImage: chefImage ?? this.chefImage,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      dropoffCity: dropoffCity ?? this.dropoffCity,
      dropoffLabel: dropoffLabel ?? this.dropoffLabel,
    );
  }

  factory DriverOrder.fromJson(Map<String, dynamic> json) {
    final deliveryAddr = json['delivery_address'] as Map<String, dynamic>?;
    return DriverOrder(
      id: json['_id'] ?? '',
      customerName: json['customer_name'] ?? json['customerName'] ?? 'Unknown',
      customerRating: (json['customer_rating'] ?? 5.0).toDouble(),
      customerAvatar: json['customer_avatar'] ?? json['customerAvatar'],
      pickupName: json['chef_name'] ?? 'Chef Kitchen',
      pickupAddress: json['chef_address'] ?? json['pickupAddress'] ?? 'Savora Hub',
      dropoffAddress: deliveryAddr?['street'] ?? json['dropoffAddress'] ?? 'Unknown Address',
      dropoffCity: deliveryAddr?['city'] ?? '',
      dropoffLabel: deliveryAddr?['label'] ?? '',
      deliveryNotes: json['delivery_notes'] ?? json['deliveryNotes'],
      distance: json['distance'] ?? '2.5 km',
      estTime: json['est_time'] ?? json['estTime'] ?? '15 mins',
      estPayout: (json['est_payout'] ?? json['estPayout'] ?? 15.0).toDouble(),
      chefName: json['chef_name'] ?? '',
      chefPhone: json['chef_phone'] ?? '',
      chefAddress: json['chef_address'] ?? '',
      chefImage: json['chef_image'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      customerEmail: json['customer_email'] ?? '',
      items: (json['items'] as List<dynamic>? ?? []).map((item) => OrderItem(
        name: item['name'] ?? '',
        quantity: item['qty'] ?? 1,
      )).toList(),
      status: json['order_status'] == 'ready' ? 'available' : json['order_status'] == 'out_for_delivery' ? 'active' : json['order_status'] ?? 'unknown',
    );
  }
}
