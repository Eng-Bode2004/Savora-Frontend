import 'package:flutter/material.dart';
import 'package:savora_app/core/theme/app_colors.dart';
import 'package:savora_app/core/theme/app_spacing.dart';
import 'package:savora_app/core/theme/app_text_styles.dart';

import '../../widgets/chef_ui_kit.dart';
import '../models/earnings_model.dart';
import '../widgets/earnings_widgets.dart';

/// Earnings tab home: weekly balance, activity chart, payout breakdown,
/// and performance stats.
class EarningsInsightsScreen extends StatelessWidget {
  const EarningsInsightsScreen({super.key});

  static const _days = [
    DailyActivity(dayLabel: 'M', percent: 40),
    DailyActivity(dayLabel: 'T', percent: 60),
    DailyActivity(dayLabel: 'W', percent: 55),
    DailyActivity(dayLabel: 'T', percent: 85, highlighted: true),
    DailyActivity(dayLabel: 'F', percent: 70),
    DailyActivity(dayLabel: 'S', percent: 45),
    DailyActivity(dayLabel: 'S', percent: 30),
  ];

  static const _breakdown = [
    EarningsBreakdownItem(
        icon: Icons.payments_outlined, label: 'Base Pay', amount: 2105.00),
    EarningsBreakdownItem(
        icon: Icons.volunteer_activism_outlined, label: 'Tips', amount: 735.50),
    EarningsBreakdownItem(
        icon: Icons.info_outline,
        label: 'Processing Fees',
        amount: 24.10,
        isNegative: true),
  ];

  static const _recent = [
    RecentEarningEntry(
        orderId: '8821',
        icon: Icons.local_pizza_outlined,
        timeLabel: 'Today, 2:45 PM',
        amount: 42.50),
    RecentEarningEntry(
        orderId: '8819',
        icon: Icons.outdoor_grill_outlined,
        timeLabel: 'Today, 1:12 PM',
        amount: 31.20),
  ];

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding, vertical: AppSpacing.md),
        children: [
          Text('Weekly Earnings',
              style: AppTextStyles.headlineLg
                  .copyWith(color: AppColors.textOf(brightness))),
          const SizedBox(height: 2),
          Text('Oct 23 - Oct 29, 2023',
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.textMutedOf(brightness))),
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL BALANCE',
                      style: AppTextStyles.overline
                          .copyWith(color: AppColors.textMutedOf(brightness)),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.trending_up_rounded,
                            size: 16, color: AppColors.success),
                        Text('+12.4%',
                            style: AppTextStyles.labelLg
                                .copyWith(color: AppColors.success)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('\$2,840.50',
                    style: AppTextStyles.displayLg
                        .copyWith(color: AppColors.amber)),
                const SizedBox(height: AppSpacing.sm),
                ChefPrimaryButton(label: 'Transfer Funds', onPressed: () {}),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Activity',
                    style: AppTextStyles.titleLg
                        .copyWith(color: AppColors.textOf(brightness))),
                const SizedBox(height: AppSpacing.sm),
                const WeeklyActivityChart(days: _days),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Breakdown',
                    style: AppTextStyles.titleLg
                        .copyWith(color: AppColors.textOf(brightness))),
                const SizedBox(height: AppSpacing.xs),
                for (int i = 0; i < _breakdown.length; i++)
                  BreakdownRow(
                      item: _breakdown[i],
                      showDivider: i != _breakdown.length - 1),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: const [
              Expanded(
                child: EarningsStatCard(
                  icon: Icons.timer_outlined,
                  value: '12.4m',
                  label: 'Avg Prep Time',
                  badgeLabel: 'Excellent',
                  badgeTone: PillTone.success,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: EarningsStatCard(
                  icon: Icons.verified_outlined,
                  value: '99.2%',
                  label: 'Accuracy Rate',
                  badgeLabel: 'Top 5%',
                  badgeTone: PillTone.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Earnings',
                  style: AppTextStyles.titleLg
                      .copyWith(color: AppColors.textOf(brightness))),
              Text('View All',
                  style:
                      AppTextStyles.labelLg.copyWith(color: AppColors.amber)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          SectionCard(
            child: Column(
              children: [
                for (final entry in _recent) RecentEarningTile(entry: entry),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
