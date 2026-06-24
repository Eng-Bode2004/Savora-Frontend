import 'package:flutter/material.dart';
import 'package:savora_app/core/network/savora_api.dart';
import 'package:savora_app/core/routing/routes.dart' hide RecipeDetailArgs;
import 'package:savora_app/core/theme/app_colors.dart';
import 'package:savora_app/core/theme/app_spacing.dart';
import 'package:savora_app/core/theme/app_text_styles.dart';
import 'package:savora_app/data/models/dish_model.dart';
import 'package:savora_app/data/models/order_model.dart';

import '../../widgets/chef_top_bar.dart';
import '../../widgets/chef_ui_kit.dart';
import '../widgets/order_widgets.dart';

/// Single order detail / preparation checklist — reached by accepting an
/// order or tapping into one from the live queue.
class OrderPreparationScreen extends StatefulWidget {
  const OrderPreparationScreen({super.key, required this.order});

  final OrderModel order;

  @override
  State<OrderPreparationScreen> createState() => _OrderPreparationScreenState();
}

class _OrderPreparationScreenState extends State<OrderPreparationScreen> {
  late final List<bool> _checked = List.filled(widget.order.items.length, false);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final order = widget.order;
    final initials = order.customerName.trim().isEmpty
        ? '?'
        : order.customerName
            .trim()
            .split(' ')
            .map((p) => p[0])
            .take(2)
            .join()
            .toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.surfaceSunkenOf(brightness),
      appBar: const ChefTopBar(leading: ChefTopBarLeading.back),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          SectionCard(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: AppColors.gold),
                  child: Text(initials,
                      style: AppTextStyles.titleLg
                          .copyWith(color: AppColors.clay)),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.customerName,
                          style: AppTextStyles.titleLg
                              .copyWith(color: AppColors.textOf(brightness))),
                      Text(
                        'Order #${order.id} • ${order.fulfillmentType.name[0].toUpperCase()}${order.fulfillmentType.name.substring(1)}',
                        style: AppTextStyles.bodySm
                            .copyWith(color: AppColors.textMutedOf(brightness)),
                      ),
                    ],
                  ),
                ),
                if (order.targetPrepTime != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('TARGET PREP',
                          style: AppTextStyles.overline.copyWith(
                              color: AppColors.textMutedOf(brightness))),
                      Text(order.targetPrepTime!,
                          style: AppTextStyles.labelLg
                              .copyWith(color: AppColors.amber)),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Remaining Time',
                        style: AppTextStyles.titleMd
                            .copyWith(color: AppColors.textOf(brightness))),
                    Text(order.formattedRemaining,
                        style: AppTextStyles.titleLg
                            .copyWith(color: AppColors.amber)),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: AppSpacing.borderRadiusFull,
                  child: LinearProgressIndicator(
                    value: order.prepProgress,
                    minHeight: 6,
                    backgroundColor: AppColors.borderOf(brightness),
                    valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Order Items',
                        style: AppTextStyles.titleLg
                            .copyWith(color: AppColors.textOf(brightness))),
                    StatusPill(
                        label: '${order.itemCount} Items Total',
                        tone: PillTone.neutral),
                  ],
                ),
                for (int i = 0; i < order.items.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (i > 0)
                          Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: Divider(
                                  height: 1,
                                  color: AppColors.borderOf(brightness))),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(order.items[i].quantityLabel,
                                      style: AppTextStyles.titleMd.copyWith(
                                          color: AppColors.textOf(brightness))),
                                  Text(
                                    order.items[i].note ??
                                        'Standard preparation',
                                    style: AppTextStyles.bodySm.copyWith(
                                        color:
                                            AppColors.textMutedOf(brightness)),
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () async {
                                      try {
                                        // Show loading overlay or just wait
                                        final res = await SavoraApi.getDishById(order.items[i].id);
                                        final dishData = res['dish'] ?? res['data'] ?? res;
                                        final realDish = DishModel.fromJson(dishData);

                                        if (!context.mounted) return;
                                        Navigator.of(context).pushNamed(
                                          Routes.chefRecipeDetail,
                                          arguments: RecipeDetailArgs(realDish),
                                        );
                                      } catch (e) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Failed to load dish details: $e')),
                                        );
                                      }
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.menu_book_rounded,
                                            size: 15, color: AppColors.amber),
                                        const SizedBox(width: 4),
                                        Text('View Recipe',
                                            style: AppTextStyles.labelMd
                                                .copyWith(
                                                    color: AppColors.amber)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Checkbox(
                              value: _checked[i],
                              activeColor: AppColors.gold,
                              checkColor: AppColors.clay,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                              onChanged: (v) =>
                                  setState(() => _checked[i] = v ?? false),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quality Checkpoints',
                    style: AppTextStyles.titleLg
                        .copyWith(color: AppColors.textOf(brightness))),
                const SizedBox(height: AppSpacing.sm),
                QualityCheckpointGrid(
                  items: const [
                    (icon: Icons.thermostat_rounded, label: 'Temp Check'),
                    (icon: Icons.restaurant_rounded, label: 'Plating'),
                    (icon: Icons.inventory_2_outlined, label: 'Sealing'),
                    (icon: Icons.fact_check_outlined, label: 'Accuracy'),
                  ],
                ),
              ],
            ),
          ),
          if (order.customerNote != null) ...[
            const SizedBox(height: AppSpacing.sm),
            SectionCard(
              highlightColor: AppColors.gold,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CUSTOMER NOTE',
                      style: AppTextStyles.overline
                          .copyWith(color: AppColors.amber)),
                  const SizedBox(height: 4),
                  Text(
                    '"${order.customerNote}"',
                    style: AppTextStyles.bodyMd
                        .copyWith(color: AppColors.textOf(brightness)),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          ChefPrimaryButton(
            label: 'Mark Order as Ready',
            icon: Icons.check_circle_outline_rounded,
            onPressed: () async {
              try {
                await SavoraApi.updateOrderStatus(widget.order.id, 'ready');
                if (!context.mounted) return;
                Navigator.of(context).pop();
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to mark ready: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
