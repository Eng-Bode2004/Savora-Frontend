import 'package:flutter/material.dart';

/// One day's bar in the weekly "Activity" chart.
class DailyActivity {
  const DailyActivity({required this.dayLabel, required this.percent, this.highlighted = false});

  final String dayLabel;

  /// 0–100 bar height, relative to the week's busiest day.
  final double percent;
  final bool highlighted;
}

/// A single row in the earnings "Breakdown" card (Base Pay, Tips, Fees).
class EarningsBreakdownItem {
  const EarningsBreakdownItem({
    required this.icon,
    required this.label,
    required this.amount,
    this.isNegative = false,
  });

  final IconData icon;
  final String label;
  final double amount;
  final bool isNegative;
}

/// A row in the "Recent Earnings" list.
class RecentEarningEntry {
  const RecentEarningEntry({
    required this.orderId,
    required this.icon,
    required this.timeLabel,
    required this.amount,
  });

  final String orderId;
  final IconData icon;
  final String timeLabel;
  final double amount;
}
