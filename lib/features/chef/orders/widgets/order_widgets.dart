import 'package:flutter/material.dart';
import 'package:savora_app/core/theme/app_colors.dart';
import 'package:savora_app/core/theme/app_spacing.dart';
import 'package:savora_app/core/theme/app_text_styles.dart';

import '../../widgets/chef_ui_kit.dart';

/// Section title with a colored accent bar and a count pill — used to
/// group the Live Order Queue into Incoming / Preparing / Ready sections.
class OrderSectionHeader extends StatelessWidget {
  const OrderSectionHeader(
      {super.key,
      required this.title,
      required this.count,
      required this.accentColor});

  final String title;
  final int count;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Row(
      children: [
        Container(width: 4, height: 16, color: accentColor),
        const SizedBox(width: AppSpacing.xs),
        Text(title,
            style: AppTextStyles.titleLg
                .copyWith(color: AppColors.textOf(brightness))),
        const SizedBox(width: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
              color: AppColors.gold, borderRadius: AppSpacing.borderRadiusFull),
          child: Text('$count',
              style: AppTextStyles.labelSm.copyWith(color: AppColors.clay)),
        ),
      ],
    );
  }
}

/// A bordered card with a colored left accent bar, used by every order
/// queue card variant below.
class _AccentCard extends StatelessWidget {
  const _AccentCard({required this.accentColor, required this.child});

  final Color accentColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(brightness),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.borderOf(brightness)),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: brightness == Brightness.dark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 4, color: accentColor),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    child: child)),
          ],
        ),
      ),
    );
  }
}

/// An order awaiting Accept/Decline.
class IncomingQueueCard extends StatelessWidget {
  const IncomingQueueCard({
    super.key,
    required this.orderId,
    required this.timingLabel,
    required this.title,
    required this.customerName,
    required this.price,
    required this.onAccept,
    required this.onDecline,
  });

  final String orderId;
  final String timingLabel;
  final String title;
  final String customerName;
  final String price;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return _AccentCard(
      accentColor: AppColors.clay,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '#$orderId • ${timingLabel.toUpperCase()}',
                  style: AppTextStyles.overline
                      .copyWith(color: AppColors.textMutedOf(brightness)),
                ),
              ),
              Text(price,
                  style: AppTextStyles.headlineSm
                      .copyWith(color: AppColors.amber)),
            ],
          ),
          const SizedBox(height: 4),
          Text(title,
              style: AppTextStyles.titleLg
                  .copyWith(color: AppColors.textOf(brightness))),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(Icons.person_outline_rounded,
                  size: 15, color: AppColors.textMutedOf(brightness)),
              const SizedBox(width: 4),
              Text(customerName,
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.textMutedOf(brightness))),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                  flex: 2,
                  child: ChefDarkButton(
                      label: 'Accept Order', onPressed: onAccept)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                  child: ChefOutlineButton(
                      label: 'Decline', onPressed: onDecline)),
            ],
          ),
        ],
      ),
    );
  }
}

/// An order currently being cooked, with a prep-time progress bar.
class PreparingQueueCard extends StatelessWidget {
  const PreparingQueueCard({
    super.key,
    required this.orderId,
    required this.title,
    required this.statusLabel,
    required this.progress,
    required this.remainingLabel,
    required this.isUrgent,
    this.customerNote,
    required this.onMarkReady,
  });

  final String orderId;
  final String title;
  final String statusLabel;
  final double progress;
  final String remainingLabel;
  final bool isUrgent;
  final String? customerNote;
  final VoidCallback onMarkReady;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return _AccentCard(
      accentColor: isUrgent ? AppColors.ember : AppColors.gold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '#$orderId • ${statusLabel.toUpperCase()}',
                  style: AppTextStyles.overline
                      .copyWith(color: AppColors.textMutedOf(brightness)),
                ),
              ),
              if (isUrgent)
                Text(remainingLabel,
                    style: AppTextStyles.headlineSm
                        .copyWith(color: AppColors.ember))
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: AppSpacing.borderRadiusFull),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule_rounded,
                          size: 13, color: AppColors.clay),
                      const SizedBox(width: 4),
                      Text(remainingLabel,
                          style: AppTextStyles.labelSm
                              .copyWith(color: AppColors.clay)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(title,
              style: AppTextStyles.titleLg
                  .copyWith(color: AppColors.textOf(brightness))),
          if (customerNote != null) ...[
            const SizedBox(height: 4),
            Text(
              '"$customerNote"',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textMutedOf(brightness),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: AppSpacing.borderRadiusFull,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.borderOf(brightness),
              valueColor: AlwaysStoppedAnimation(
                  isUrgent ? AppColors.ember : AppColors.gold),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight - 4,
            child: ElevatedButton(
              onPressed: onMarkReady,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceSunkenOf(brightness),
                foregroundColor: AppColors.textOf(brightness),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderRadiusSm),
              ),
              child: Text('Mark as Ready',
                  style: AppTextStyles.labelLg
                      .copyWith(color: AppColors.textOf(brightness))),
            ),
          ),
        ],
      ),
    );
  }
}

/// A completed order, picked up by a driver.
class ReadyQueueCard extends StatelessWidget {
  const ReadyQueueCard({
    super.key,
    required this.orderId,
    required this.pickedUpBy,
    required this.title,
  });

  final String orderId;
  final String pickedUpBy;
  final String title;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return _AccentCard(
      accentColor: AppColors.textMutedOf(brightness),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#$orderId • PICKED UP BY ${pickedUpBy.toUpperCase()}',
                  style: AppTextStyles.overline
                      .copyWith(color: AppColors.textMutedOf(brightness)),
                ),
                const SizedBox(height: 4),
                Text(title,
                    style: AppTextStyles.titleLg
                        .copyWith(color: AppColors.textOf(brightness))),
              ],
            ),
          ),
          Icon(Icons.check_circle_outline_rounded,
              color: AppColors.success, size: 24),
        ],
      ),
    );
  }
}

/// 2x2 grid of quality checkpoints on the order-prep screen
/// (Temp Check, Plating, Sealing, Accuracy).
class QualityCheckpointGrid extends StatelessWidget {
  const QualityCheckpointGrid({super.key, required this.items});

  final List<({IconData icon, String label})> items;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, i) {
        final item = items[i];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceSunkenOf(brightness),
            borderRadius: AppSpacing.borderRadiusSm,
            border: Border.all(color: AppColors.borderOf(brightness)),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, color: AppColors.amber, size: 22),
              const SizedBox(height: 6),
              Text(item.label,
                  style: AppTextStyles.labelMd
                      .copyWith(color: AppColors.textOf(brightness))),
            ],
          ),
        );
      },
    );
  }
}
