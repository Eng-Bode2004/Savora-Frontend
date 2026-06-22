class DriverTransaction {
  final String id;
  final String type; // 'delivery', 'payout', 'bonus'
  final String title;
  final String subtitle;
  final double amount;
  final bool completed;

  DriverTransaction({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.completed = false,
  });
}
