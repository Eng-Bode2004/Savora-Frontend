import 'package:flutter/material.dart';
import 'package:savora_app/core/theme/app_colors.dart';
import 'package:savora_app/core/theme/app_spacing.dart';
import 'package:savora_app/core/theme/app_text_styles.dart';

import '../../widgets/chef_ui_kit.dart';

/// "Kitchen Overview" earnings summary card on the dashboard home.
class KitchenOverviewCard extends StatelessWidget {
  const KitchenOverviewCard({
    super.key,
    required this.totalEarnings,
    required this.changePercent,
    required this.caption,
    this.onTap,
  });

  final String totalEarnings;
  final double changePercent;
  final String caption;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final positive = changePercent >= 0;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL EARNINGS',
                style: AppTextStyles.overline
                    .copyWith(color: AppColors.textMutedOf(brightness)),
              ),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: const Icon(Icons.payments_rounded,
                      color: AppColors.clay, size: 19),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(totalEarnings,
                  style: AppTextStyles.displayLg
                      .copyWith(color: AppColors.textOf(brightness))),
              const SizedBox(width: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      positive
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 15,
                      color: positive ? AppColors.success : AppColors.ember,
                    ),
                    Text(
                      '${changePercent.abs().toStringAsFixed(0)}%',
                      style: AppTextStyles.labelLg.copyWith(
                        color: positive ? AppColors.success : AppColors.ember,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(caption,
              style: AppTextStyles.bodySm
                  .copyWith(color: AppColors.textMutedOf(brightness))),
        ],
      ),
    );
  }
}

/// Compact stat tile ("24 Total Orders", "6.5h Active Hours").
class StatMiniCard extends StatelessWidget {
  const StatMiniCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: iconColor, borderRadius: AppSpacing.borderRadiusSm),
            child: Icon(icon, color: AppColors.clay, size: 19),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(value,
              style: AppTextStyles.headlineLg
                  .copyWith(color: AppColors.textOf(brightness))),
          const SizedBox(height: 2),
          Text(label,
              style: AppTextStyles.bodySm
                  .copyWith(color: AppColors.textMutedOf(brightness))),
        ],
      ),
    );
  }
}

/// The highlighted "Active Task" / "New Order Request" card with an
/// accept/decline countdown — the centerpiece of the dashboard.
class IncomingOrderCard extends StatelessWidget {
  const IncomingOrderCard({
    super.key,
    required this.orderTotal,
    required this.remainingLabel,
    required this.distanceKm,
    required this.itemCount,
    required this.itemsSummary,
    required this.onAccept,
    required this.onDecline,
  });

  final String orderTotal;
  final String remainingLabel;
  final double distanceKm;
  final int itemCount;
  final String itemsSummary;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: AppColors.clay),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text('Active Task',
                    style: AppTextStyles.titleMd
                        .copyWith(color: AppColors.textOf(brightness))),
              ],
            ),
            const StatusPill(label: 'High Priority', tone: PillTone.danger),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SectionCard(
          highlightColor: AppColors.gold,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NEW ORDER REQUEST',
                        style: AppTextStyles.overline
                            .copyWith(color: AppColors.textMutedOf(brightness)),
                      ),
                      const SizedBox(height: 2),
                      Text(orderTotal,
                          style: AppTextStyles.headlineMd
                              .copyWith(color: AppColors.textOf(brightness))),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(remainingLabel,
                          style: AppTextStyles.headlineSm
                              .copyWith(color: AppColors.amber)),
                      Text('Remains',
                          style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.textMutedOf(brightness))),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child:
                    Divider(height: 1, color: AppColors.borderOf(brightness)),
              ),
              Row(
                children: [
                  Expanded(
                    child: _InfoColumn(
                      icon: Icons.location_on_outlined,
                      label: 'Distance',
                      value: '${distanceKm.toStringAsFixed(1)} km',
                    ),
                  ),
                  Expanded(
                    child: _InfoColumn(
                      icon: Icons.restaurant_outlined,
                      label: 'Items',
                      value: '$itemCount Items',
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child:
                    Divider(height: 1, color: AppColors.borderOf(brightness)),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: AppColors.textMutedOf(brightness)),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(itemsSummary,
                        style: AppTextStyles.bodySm
                            .copyWith(color: AppColors.textOf(brightness))),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                      child: ChefOutlineButton(
                          label: 'Decline', onPressed: onDecline)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                      flex: 2,
                      child: ChefDarkButton(
                          label: 'Accept Order', onPressed: onAccept)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoColumn extends StatelessWidget {
  const _InfoColumn(
      {required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMutedOf(brightness)),
        const SizedBox(width: AppSpacing.xs),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.textMutedOf(brightness))),
            Text(value,
                style: AppTextStyles.titleMd
                    .copyWith(color: AppColors.textOf(brightness))),
          ],
        ),
      ],
    );
  }
}

/// "Kitchen is Open" row with a toggle switch.
class KitchenStatusToggle extends StatelessWidget {
  const KitchenStatusToggle(
      {super.key, required this.isOpen, required this.onChanged});

  final bool isOpen;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return SectionCard(
      backgroundColor: AppColors.surfaceSunkenOf(brightness),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOpen
                      ? AppColors.success
                      : AppColors.textMutedOf(brightness),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                isOpen ? 'Kitchen is Open' : 'Kitchen is Closed',
                style: AppTextStyles.titleMd
                    .copyWith(color: AppColors.textOf(brightness)),
              ),
            ],
          ),
          Switch(
            value: isOpen,
            onChanged: onChanged,
            activeColor: AppColors.white,
            activeTrackColor: AppColors.success,
            inactiveThumbColor: AppColors.white,
            inactiveTrackColor:
                AppColors.textMutedOf(brightness).withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}
