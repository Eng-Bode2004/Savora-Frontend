class DriverNotification {
  final String id;
  final String icon;
  final String title;
  final String body;
  final String time;
  final bool read;
  final String type; // 'order', 'earnings', 'alert', 'older'
  final String? orderRef;

  DriverNotification({
    required this.id,
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    this.read = false,
    required this.type,
    this.orderRef,
  });

  DriverNotification copyWith({
    String? id,
    String? icon,
    String? title,
    String? body,
    String? time,
    bool? read,
    String? type,
    String? orderRef,
  }) {
    return DriverNotification(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      title: title ?? this.title,
      body: body ?? this.body,
      time: time ?? this.time,
      read: read ?? this.read,
      type: type ?? this.type,
      orderRef: orderRef ?? this.orderRef,
    );
  }
}
