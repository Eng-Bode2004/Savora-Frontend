import 'package:flutter/material.dart';
import 'package:savora_app/core/theme/app_colors.dart';
import 'package:savora_app/core/theme/app_spacing.dart';
import 'package:savora_app/core/theme/app_text_styles.dart';

import '../../widgets/chef_ui_kit.dart';

/// Step 2 of the verification wizard: confirm the kitchen's pickup
/// location on a map.
class LocationSetupScreen extends StatelessWidget {
  const LocationSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.surfaceSunkenOf(brightness),
      appBar: AppBar(
        backgroundColor: AppColors.surfaceOf(brightness),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: AppColors.textOf(brightness)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline_rounded,
                color: AppColors.textOf(brightness)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding, vertical: AppSpacing.sm),
            child: const LinearStepHeader(
              stepLabel: 'Step 2 of 3',
              title: 'Kitchen Location',
              progress: 2 / 3,
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                      color: AppColors.textMutedOf(brightness)
                          .withValues(alpha: 0.12)),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: 6),
                        decoration: BoxDecoration(
                            color: AppColors.clay,
                            borderRadius: AppSpacing.borderRadiusSm),
                        child: Text('Savora Kitchen',
                            style: AppTextStyles.labelMd
                                .copyWith(color: AppColors.white)),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.gold, width: 3),
                          color: AppColors.surfaceOf(brightness),
                        ),
                        child: const Icon(Icons.restaurant_rounded,
                            color: AppColors.amber, size: 18),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: AppSpacing.screenPadding,
                  right: AppSpacing.screenPadding,
                  top: AppSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceOf(brightness),
                      borderRadius: AppSpacing.borderRadiusFull,
                      border: Border.all(color: AppColors.gold),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8)
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded,
                            color: AppColors.amber, size: 20),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            '742 Evergreen Terrace',
                            style: AppTextStyles.bodyMd
                                .copyWith(color: AppColors.textOf(brightness)),
                          ),
                        ),
                        Icon(Icons.my_location_rounded,
                            color: AppColors.textMutedOf(brightness), size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding,
                AppSpacing.sm, AppSpacing.screenPadding, AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceOf(brightness),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusXl)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    decoration: BoxDecoration(
                        color: AppColors.borderOf(brightness),
                        borderRadius: AppSpacing.borderRadiusFull),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Set Kitchen Site',
                              style: AppTextStyles.titleLg.copyWith(
                                  color: AppColors.textOf(brightness))),
                          Text(
                            'Verify the pinpoint for delivery pickup.',
                            style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.textMutedOf(brightness)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: AppSpacing.borderRadiusSm),
                      child: const Icon(Icons.storefront_rounded,
                          color: AppColors.clay),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                SectionCard(
                  backgroundColor: AppColors.surfaceSunkenOf(brightness),
                  child: Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: AppColors.amber),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('742 Evergreen Terrace',
                                style: AppTextStyles.titleMd.copyWith(
                                    color: AppColors.textOf(brightness))),
                            Text(
                              'Springfield, OR 97477, United States',
                              style: AppTextStyles.bodySm.copyWith(
                                  color: AppColors.textMutedOf(brightness)),
                            ),
                          ],
                        ),
                      ),
                      Text('Edit',
                          style: AppTextStyles.labelLg.copyWith(
                              color: AppColors.amber,
                              decoration: TextDecoration.underline)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ChefPrimaryButton(
                  label: 'Confirm Location',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
