import 'package:flutter/material.dart';
import 'package:savora_app/core/theme/app_colors.dart';
import 'package:savora_app/core/theme/app_spacing.dart';
import 'package:savora_app/core/theme/app_text_styles.dart';
import 'package:savora_app/data/models/dish_model.dart';

import '../../widgets/chef_top_bar.dart';
import '../../widgets/chef_ui_kit.dart';

/// Full certified recipe card: ingredients, numbered steps, and the
/// Savora Standard quality checklist for a dish.
class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key, required this.dish});

  final DishModel dish;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final recipe = dish.recipe;

    if (recipe == null) {
      return Scaffold(
        appBar: const ChefTopBar(leading: ChefTopBarLeading.back),
        body: Center(
          child: Text('No recipe available for ${dish.name}',
              style: AppTextStyles.bodyMd),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceSunkenOf(brightness),
      appBar: const ChefTopBar(leading: ChefTopBarLeading.back),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(AppSpacing.radiusLg)),
                child: Image.network(
                  recipe.imageUrl,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 220,
                    color: AppColors.surfaceSunkenOf(brightness),
                    child: const Icon(Icons.restaurant_rounded,
                        size: 48, color: AppColors.amber),
                  ),
                ),
              ),
              Positioned(
                left: AppSpacing.md,
                bottom: AppSpacing.md,
                child: Row(
                  children: [
                    _Chip(
                        icon: Icons.schedule_rounded,
                        label: '${recipe.prepTimeMinutes} min'),
                    const SizedBox(width: AppSpacing.xs),
                    _Chip(
                        icon: Icons.restaurant_menu_rounded,
                        label: '${recipe.servings} servings'),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.category.toUpperCase(),
                  style:
                      AppTextStyles.overline.copyWith(color: AppColors.amber),
                ),
                const SizedBox(height: 4),
                Text(recipe.title,
                    style: AppTextStyles.headlineLg
                        .copyWith(color: AppColors.textOf(brightness))),
                const SizedBox(height: AppSpacing.xs),
                Text(recipe.description,
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
                          Row(
                            children: [
                              const Icon(Icons.shopping_basket_outlined,
                                  size: 18, color: AppColors.amber),
                              const SizedBox(width: 6),
                              Text('Ingredients',
                                  style: AppTextStyles.titleLg.copyWith(
                                      color: AppColors.textOf(brightness))),
                            ],
                          ),
                          Text(
                            '${recipe.ingredients.length} Items',
                            style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.textMutedOf(brightness)),
                          ),
                        ],
                      ),
                      for (int i = 0; i < recipe.ingredients.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.sm),
                          child: Column(
                            children: [
                              if (i > 0)
                                Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: AppSpacing.sm),
                                    child: Divider(
                                        height: 1,
                                        color: AppColors.borderOf(brightness))),
                              Row(
                                children: [
                                  Icon(Icons.check_box_outline_blank_rounded,
                                      size: 18,
                                      color: AppColors.textMutedOf(brightness)),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      recipe.ingredients[i].label,
                                      style: AppTextStyles.bodyMd.copyWith(
                                          color: AppColors.textOf(brightness)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    const Icon(Icons.menu_book_outlined,
                        size: 18, color: AppColors.amber),
                    const SizedBox(width: 6),
                    Text('Preparation Steps',
                        style: AppTextStyles.titleLg
                            .copyWith(color: AppColors.textOf(brightness))),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final step in recipe.steps)
                  _StepRow(
                      step: step, isLast: step.order == recipe.steps.length),
                if (recipe.qualityChecks.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  SectionCard(
                    backgroundColor: AppColors.gold.withValues(alpha: 0.14),
                    highlightColor: AppColors.gold.withValues(alpha: 0.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.verified_outlined,
                                color: AppColors.amber, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              'Savora Standard Quality',
                              style: AppTextStyles.titleMd.copyWith(
                                  color: AppColors.textOf(brightness)),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        for (final check in recipe.qualityChecks)
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.xs),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle_outline_rounded,
                                    size: 16, color: AppColors.amber),
                                const SizedBox(width: AppSpacing.xs),
                                Expanded(
                                  child: Text(
                                    check.label,
                                    style: AppTextStyles.bodySm.copyWith(
                                        color: AppColors.textOf(brightness)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                ChefPrimaryButton(
                  label: 'Mark as Read & Understood',
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

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: AppSpacing.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.white),
          const SizedBox(width: 4),
          Text(label,
              style: AppTextStyles.labelSm.copyWith(color: AppColors.white)),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.isLast});

  final RecipeStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: AppColors.gold),
                child: Text('${step.order}',
                    style:
                        AppTextStyles.labelLg.copyWith(color: AppColors.clay)),
              ),
              if (!isLast)
                Expanded(
                    child: Container(
                        width: 2, color: AppColors.borderOf(brightness))),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.title,
                      style: AppTextStyles.titleMd
                          .copyWith(color: AppColors.textOf(brightness))),
                  const SizedBox(height: 2),
                  Text(step.description,
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.textMutedOf(brightness))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
