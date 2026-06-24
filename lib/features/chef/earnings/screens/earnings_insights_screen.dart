import 'package:flutter/material.dart';
import 'package:savora_app/core/network/savora_api.dart';
import 'package:savora_app/core/theme/app_colors.dart';
import 'package:savora_app/core/theme/app_spacing.dart';
import 'package:savora_app/core/theme/app_text_styles.dart';
import 'package:savora_app/state/providers/auth_provider.dart';

import '../../widgets/chef_ui_kit.dart';
import '../models/earnings_model.dart';
import '../widgets/earnings_widgets.dart';

class EarningsInsightsScreen extends StatefulWidget {
  const EarningsInsightsScreen({super.key});

  @override
  State<EarningsInsightsScreen> createState() => _EarningsInsightsScreenState();
}

class _EarningsInsightsScreenState extends State<EarningsInsightsScreen> {
  bool _loading = true;
  String? _error;

  double _netEarnings = 0;
  double _changePercent = 0;
  int _orderCount = 0;
  double _totalRevenue = 0;
  double _appFee = 0;
  List<DailyActivity> _days = [];
  List<RecentEarningEntry> _recent = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final chefId = authState.profileId;
    if (chefId == null) {
      if (mounted) setState(() { _error = 'Please log in first'; _loading = false; });
      return;
    }
    setState(() => _loading = true);
    try {
      final data = await SavoraApi.getChefEarnings(chefId);
      final e = data['earnings'] as Map<String, dynamic>? ?? {};
      final daysRaw = e['days'] as List? ?? [];
      final recentRaw = e['recent'] as List? ?? [];

      final iconMap = {
        'receipt': Icons.receipt_long_outlined,
        'local_pizza': Icons.local_pizza_outlined,
        'outdoor_grill': Icons.outdoor_grill_outlined,
      };

      setState(() {
        _netEarnings = (e['netEarnings'] as num?)?.toDouble() ?? 0;
        _changePercent = (e['changePercent'] as num?)?.toDouble() ?? 0;
        _orderCount = (e['orderCount'] as num?)?.toInt() ?? 0;
        _totalRevenue = (e['totalRevenue'] as num?)?.toDouble() ?? 0;
        _appFee = (e['appFee'] as num?)?.toDouble() ?? 0;
        _days = daysRaw.map((d) => DailyActivity(
          dayLabel: d['dayLabel'] as String? ?? '',
          percent: (d['percent'] as num?)?.toDouble() ?? 0,
          highlighted: d['highlighted'] == true,
        )).toList();
        _recent = recentRaw.map((r) => RecentEarningEntry(
          orderId: r['orderId'] as String? ?? '',
          icon: iconMap[r['icon'] as String?] ?? Icons.receipt_long_outlined,
          timeLabel: r['timeLabel'] as String? ?? '',
          amount: (r['amount'] as num?)?.toDouble() ?? 0,
        )).toList();
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() { _error = 'Failed to load earnings'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final positive = _changePercent >= 0;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: GestureDetector(
          onTap: _load,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
              Text('Tap to retry', style: TextStyle(color: AppColors.textMutedOf(brightness))),
            ],
          ),
        ),
      );
    }

    final breakdown = [
      EarningsBreakdownItem(
          icon: Icons.payments_outlined, label: 'Total Revenue', amount: _totalRevenue),
      EarningsBreakdownItem(
          icon: Icons.info_outline, label: 'Platform Fee (10%)', amount: _appFee, isNegative: true),
      EarningsBreakdownItem(
          icon: Icons.account_balance_wallet_outlined, label: 'Net Earnings', amount: _netEarnings),
    ];

    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding, vertical: AppSpacing.md),
        children: [
          Text('Earnings',
              style: AppTextStyles.headlineLg
                  .copyWith(color: AppColors.textOf(brightness))),
          const SizedBox(height: 2),
          Text('$_orderCount completed orders',
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
                    Text('NET EARNINGS',
                        style: AppTextStyles.overline
                            .copyWith(color: AppColors.textMutedOf(brightness))),
                    Row(
                      children: [
                        Icon(
                          positive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                          size: 16,
                          color: positive ? AppColors.success : AppColors.ember,
                        ),
                        Text('${positive ? '+' : ''}${_changePercent.toStringAsFixed(1)}%',
                            style: AppTextStyles.labelLg
                                .copyWith(color: positive ? AppColors.success : AppColors.ember)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('EGP ${_netEarnings.toStringAsFixed(2)}',
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
                WeeklyActivityChart(days: _days),
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
                for (int i = 0; i < breakdown.length; i++)
                  BreakdownRow(item: breakdown[i], showDivider: i != breakdown.length - 1),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Earnings',
                  style: AppTextStyles.titleLg
                      .copyWith(color: AppColors.textOf(brightness))),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          SectionCard(
            child: _recent.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Text('No completed orders yet',
                        style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMutedOf(brightness))),
                  )
                : Column(children: [for (final entry in _recent) RecentEarningTile(entry: entry)]),
          ),
        ],
      ),
    );
  }
}
