import 'package:flutter/material.dart';
import 'package:savora_app/core/theme/app_colors.dart';
import 'package:savora_app/core/theme/app_spacing.dart';
import 'package:savora_app/core/theme/app_text_styles.dart';

import '../../widgets/chef_ui_kit.dart';
import '../models/earnings_model.dart';

/// 7-day bar chart used in the "Activity" card on the Earnings screen.
class WeeklyActivityChart extends StatelessWidget {
  const WeeklyActivityChart({super.key, required this.days});

  final List<DailyActivity> days;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final day in days)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: (day.percent / 100).clamp(0.04, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: day.highlighted
                                  ? AppColors.gold
                                  : AppColors.borderOf(brightness),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      day.dayLabel,
                      style: AppTextStyles.labelSm.copyWith(
                        color: day.highlighted
                            ? AppColors.amber
                            : AppColors.textMutedOf(brightness),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A single "Breakdown" row (Base Pay, Tips, Processing Fees).
class BreakdownRow extends StatelessWidget {
  const BreakdownRow(
      {super.key, required this.item, required this.showDivider});

  final EarningsBreakdownItem item;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final amountColor =
        item.isNegative ? AppColors.ember : AppColors.textOf(brightness);
    final amountText =
        '${item.isNegative ? '-' : ''}\$${item.amount.abs().toStringAsFixed(2)}';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(item.icon,
                      size: 18, color: AppColors.textMutedOf(brightness)),
                  const SizedBox(width: AppSpacing.sm),
                  Text(item.label,
                      style: AppTextStyles.bodyMd
                          .copyWith(color: AppColors.textOf(brightness))),
                ],
              ),
              Text(amountText,
                  style: AppTextStyles.titleMd.copyWith(color: amountColor)),
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 1, color: AppColors.borderOf(brightness)),
      ],
    );
  }
}

/// A row in the "Recent Earnings" list.
class RecentEarningTile extends StatelessWidget {
  const RecentEarningTile({super.key, required this.entry});

  final RecentEarningEntry entry;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceSunkenOf(brightness),
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Icon(entry.icon, size: 18, color: AppColors.amber),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order #${entry.orderId}',
                    style: AppTextStyles.titleMd
                        .copyWith(color: AppColors.textOf(brightness))),
                Text(entry.timeLabel,
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.textMutedOf(brightness))),
              ],
            ),
          ),
          Text('+\$${entry.amount.toStringAsFixed(2)}',
              style: AppTextStyles.titleMd.copyWith(color: AppColors.success)),
        ],
      ),
    );
  }
}

/// Compact stat tile with a centered icon, value, and status pill —
/// "Avg Prep Time · Excellent", "Accuracy Rate · Top 5%".
class EarningsStatCard extends StatelessWidget {
  const EarningsStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.badgeLabel,
    required this.badgeTone,
  });

  final IconData icon;
  final String value;
  final String label;
  final String badgeLabel;
  final PillTone badgeTone;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return SectionCard(
      child: Column(
        children: [
          Icon(icon, color: AppColors.amber, size: 22),
          const SizedBox(height: AppSpacing.xs),
          Text(value,
              style: AppTextStyles.headlineMd
                  .copyWith(color: AppColors.textOf(brightness))),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: AppTextStyles.overline
                .copyWith(color: AppColors.textMutedOf(brightness)),
          ),
          const SizedBox(height: AppSpacing.xs),
          StatusPill(label: badgeLabel, tone: badgeTone),
        ],
      ),
    );
  }
}
