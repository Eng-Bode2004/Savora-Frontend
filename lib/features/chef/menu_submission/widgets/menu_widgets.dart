import 'package:flutter/material.dart';
import 'package:savora_app/core/theme/app_colors.dart';
import 'package:savora_app/core/theme/app_spacing.dart';
import 'package:savora_app/core/theme/app_text_styles.dart';

import '../../widgets/chef_ui_kit.dart';

/// A dish row on the Menu Management screen with an availability toggle.
class MenuItemCard extends StatelessWidget {
  const MenuItemCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.inStock,
    required this.isCertifiedStandard,
    required this.onToggle,
    required this.onViewStandard,
  });

  final String imageUrl;
  final String name;
  final bool inStock;
  final bool isCertifiedStandard;
  final ValueChanged<bool> onToggle;
  final VoidCallback onViewStandard;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return SectionCard(
      backgroundColor: inStock
          ? AppColors.surfaceOf(brightness)
          : AppColors.textMutedOf(brightness).withValues(alpha: 0.08),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: AppSpacing.borderRadiusSm,
            child: Image.network(
              imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 64,
                height: 64,
                color: AppColors.surfaceSunkenOf(brightness),
                child: const Icon(Icons.restaurant_rounded,
                    color: AppColors.amber),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: AppTextStyles.titleLg
                            .copyWith(color: AppColors.textOf(brightness)),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          inStock ? 'In Stock' : 'Out of\nStock',
                          textAlign: TextAlign.right,
                          style: AppTextStyles.labelMd.copyWith(
                            color: inStock
                                ? AppColors.amber
                                : AppColors.textMutedOf(brightness),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (isCertifiedStandard) ...[
                  const SizedBox(height: 2),
                  Text(
                    'CERTIFIED SAVORA STANDARD',
                    style: AppTextStyles.overline
                        .copyWith(color: AppColors.textMutedOf(brightness)),
                  ),
                ],
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onViewStandard,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.visibility_outlined,
                          size: 15, color: AppColors.amber),
                      const SizedBox(width: 4),
                      Text('View Savora Standard',
                          style: AppTextStyles.labelMd
                              .copyWith(color: AppColors.amber)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: inStock,
            onChanged: onToggle,
            activeColor: AppColors.white,
            activeTrackColor: AppColors.clay,
            inactiveThumbColor: AppColors.white,
            inactiveTrackColor:
                AppColors.textMutedOf(brightness).withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

/// "Low on Ingredients?" warning banner on Menu Management.
class LowStockBanner extends StatelessWidget {
  const LowStockBanner(
      {super.key, required this.message, required this.onOrderSupplies});

  final String message;
  final VoidCallback onOrderSupplies;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return SectionCard(
      backgroundColor: AppColors.gold.withValues(alpha: 0.16),
      highlightColor: AppColors.gold.withValues(alpha: 0.4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.inventory_2_outlined, color: AppColors.amber),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Low on Ingredients?',
                    style: AppTextStyles.titleMd
                        .copyWith(color: AppColors.textOf(brightness))),
                const SizedBox(height: 4),
                Text(message,
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.textMutedOf(brightness))),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onOrderSupplies,
                  child: Text(
                    'Order Supplies',
                    style: AppTextStyles.labelLg.copyWith(
                      color: AppColors.clay,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Selectable culinary-specialty category tile (onboarding step 1).
class SpecialtyCategoryCard extends StatelessWidget {
  const SpecialtyCategoryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.infoOnly = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  /// Renders as a wide info row instead of a selectable tile
  /// (used by "Daily Specials").
  final bool infoOnly;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final content = infoOnly
        ? Row(
            children: [
              _IconBadge(icon: icon),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTextStyles.titleMd
                            .copyWith(color: AppColors.textOf(brightness))),
                    Text(subtitle,
                        style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.textMutedOf(brightness))),
                  ],
                ),
              ),
              Icon(Icons.info_outline,
                  color: AppColors.textMutedOf(brightness)),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconBadge(icon: icon),
              const SizedBox(height: AppSpacing.sm),
              Text(title,
                  style: AppTextStyles.titleLg
                      .copyWith(color: AppColors.textOf(brightness))),
              Text(subtitle,
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.textMutedOf(brightness))),
            ],
          );

    return GestureDetector(
      onTap: onTap,
      child: SectionCard(
        highlightColor: selected ? AppColors.gold : null,
        child: content,
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.18),
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Icon(icon, color: AppColors.amber, size: 22),
    );
  }
}

/// Selectable catalog recipe row (onboarding step 3 — "Select your Menu").
class RecipeSelectableCard extends StatelessWidget {
  const RecipeSelectableCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.isHighDemand,
    required this.selected,
    required this.onTap,
  });

  final String imageUrl;
  final String title;
  final String description;
  final bool isHighDemand;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return GestureDetector(
      onTap: onTap,
      child: SectionCard(
        highlightColor: selected ? AppColors.gold : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: AppSpacing.borderRadiusSm,
              child: Image.network(
                imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 60,
                  height: 60,
                  color: AppColors.surfaceSunkenOf(brightness),
                  child: const Icon(Icons.restaurant_rounded,
                      color: AppColors.amber),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.titleMd
                          .copyWith(color: AppColors.textOf(brightness))),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.textMutedOf(brightness)),
                  ),
                  if (isHighDemand) ...[
                    const SizedBox(height: 6),
                    const StatusPill(
                        label: 'High Demand', tone: PillTone.warning),
                  ],
                ],
              ),
            ),
            Checkbox(
              value: selected,
              onChanged: (_) => onTap(),
              activeColor: AppColors.gold,
              checkColor: AppColors.clay,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
          ],
        ),
      ),
    );
  }
}
