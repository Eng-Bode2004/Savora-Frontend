import 'package:flutter/material.dart';
import 'package:savora_app/core/routing/routes.dart' hide RecipeDetailArgs;
import 'package:savora_app/core/theme/app_colors.dart';
import 'package:savora_app/core/theme/app_spacing.dart';
import 'package:savora_app/core/theme/app_text_styles.dart';
import 'package:savora_app/data/models/dish_model.dart';

import '../../dashboard/widgets/dashboard_widgets.dart' show StatMiniCard;
import '../widgets/menu_widgets.dart';

/// Menu tab home: the chef's live dishes with availability toggles.
class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  List<DishModel> _dishes = [
    DishModel(
      id: 'shish-tawook',
      name: 'Shish Tawook',
      imageUrl:
          'https://images.unsplash.com/photo-1633321088355-d0f81d8c4f15?w=400',
      inStock: true,
      recipe: RecipeModel(
        category: 'Mediterranean Standard',
        title: 'Shish Tawook',
        description:
            'Marinated chargrilled chicken skewers, Savora house spice blend.',
        imageUrl:
            'https://images.unsplash.com/photo-1633321088355-d0f81d8c4f15?w=800',
        prepTimeMinutes: 30,
        servings: 2,
        ingredients: const [
          RecipeIngredient(id: '1', label: '600g Chicken Thigh, Cubed'),
          RecipeIngredient(id: '2', label: '1/2 Cup Yogurt Marinade'),
          RecipeIngredient(id: '3', label: '2 Tbsp Savora Spice Blend'),
        ],
        steps: const [
          RecipeStep(
              order: 1,
              title: 'Marinate',
              description:
                  'Marinate chicken for at least 4 hours, ideally overnight.'),
          RecipeStep(
              order: 2,
              title: 'Skewer',
              description:
                  'Thread onto skewers, leaving small gaps for even cooking.'),
          RecipeStep(
              order: 3,
              title: 'Grill',
              description:
                  'Grill over high heat, turning every 2 minutes until charred.'),
        ],
        qualityChecks: const [
          RecipeQualityCheck(
              label: 'Internal temperature reaches 75°C (165°F)'),
          RecipeQualityCheck(label: 'Even char on all sides'),
        ],
      ),
    ),
    DishModel(
      id: 'classic-kofta',
      name: 'Classic Kofta',
      imageUrl:
          'https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=400',
      inStock: true,
      recipe: RecipeModel(
        category: 'Mediterranean Standard',
        title: 'Classic Beef Kofta',
        description:
            'Traditional Lebanese-style minced beef skewers seasoned with warm spices and fresh herbs. A kitchen staple for efficiency and flavor.',
        imageUrl:
            'https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=800',
        prepTimeMinutes: 25,
        servings: 4,
        ingredients: const [
          RecipeIngredient(id: '1', label: '500g Ground Beef (80/20 Lean)'),
          RecipeIngredient(
              id: '2', label: '1/2 Cup Fresh Parsley, finely chopped'),
          RecipeIngredient(
              id: '3', label: '1 Small Onion, grated and squeezed'),
          RecipeIngredient(id: '4', label: '2 Garlic Cloves, minced'),
          RecipeIngredient(id: '5', label: '1 tsp Ground Allspice & Cumin'),
          RecipeIngredient(id: '6', label: 'Salt and Black Pepper to taste'),
        ],
        steps: const [
          RecipeStep(
            order: 1,
            title: 'Prep Aromatic Mix',
            description:
                'Combine the grated onion, minced garlic, and parsley in a large stainless steel bowl. Ensure all moisture is squeezed from the onions to maintain meat integrity.',
          ),
          RecipeStep(
            order: 2,
            title: 'Bind and Season',
            description:
                'Add the ground beef and dry spices. Mix thoroughly by hand for 3-4 minutes until the mixture becomes slightly tacky — this ensures the kofta stays on the skewer.',
          ),
          RecipeStep(
            order: 3,
            title: 'Skewer and Shape',
            description:
                'Divide into 4 equal portions. Mold each onto a metal or soaked wooden skewer into long cylinders. Chill for 10 minutes before grilling for best results.',
          ),
        ],
        qualityChecks: const [
          RecipeQualityCheck(
              label:
                  'Internal Temperature: Ensure beef reaches a safe 160°F (71°C) for service.'),
          RecipeQualityCheck(
              label:
                  'Visual Check: Deep caramelization (Maillard reaction) is required for authentic flavor.'),
        ],
      ),
    ),
    DishModel(
      id: 'artisan-falafel',
      name: 'Artisan Falafel',
      imageUrl:
          'https://images.unsplash.com/photo-1593001874117-c99c800e3eb6?w=400',
      inStock: false,
      recipe: RecipeModel(
        category: 'Mediterranean Standard',
        title: 'Artisan Falafel',
        description:
            'Crisp herb-packed chickpea falafel, hand-formed and fried to order.',
        imageUrl:
            'https://images.unsplash.com/photo-1593001874117-c99c800e3eb6?w=800',
        prepTimeMinutes: 20,
        servings: 4,
        ingredients: const [
          RecipeIngredient(id: '1', label: '500g Soaked Chickpeas')
        ],
        steps: const [
          RecipeStep(
              order: 1,
              title: 'Blend',
              description:
                  'Blend chickpeas with herbs and spices until coarse.')
        ],
        qualityChecks: const [
          RecipeQualityCheck(label: 'Golden-brown, crisp exterior')
        ],
      ),
    ),
  ];

  void _toggle(DishModel dish, bool inStock) {
    setState(() {
      _dishes = [
        for (final d in _dishes)
          if (d.id == dish.id) d.copyWith(inStock: inStock) else d
      ];
    });
  }

  void _viewStandard(DishModel dish) {
    if (dish.recipe == null) return;
    Navigator.of(context)
        .pushNamed(Routes.chefRecipeDetail, arguments: RecipeDetailArgs(dish));
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final activeCount = _dishes.where((d) => d.inStock).length;

    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding, vertical: AppSpacing.md),
        children: [
          Text('Menu Management',
              style: AppTextStyles.headlineLg
                  .copyWith(color: AppColors.textOf(brightness))),
          const SizedBox(height: 4),
          Text(
            'Update daily availability for your certified recipes.',
            style: AppTextStyles.bodyMd
                .copyWith(color: AppColors.textMutedOf(brightness)),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final dish in _dishes) ...[
            MenuItemCard(
              imageUrl: dish.imageUrl,
              name: dish.name,
              inStock: dish.inStock,
              isCertifiedStandard: dish.isCertifiedStandard,
              onToggle: (v) => _toggle(dish, v),
              onViewStandard: () => _viewStandard(dish),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          LowStockBanner(
            message:
                'Chef, you reported low stock on chickpeas. Refill inventory to reactivate this recipe for orders.',
            onOrderSupplies: () {},
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Expanded(
                child: StatMiniCard(
                  icon: Icons.trending_up_rounded,
                  iconColor: AppColors.gold,
                  value: '84%',
                  label: 'Menu Vitality',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatMiniCard(
                  icon: Icons.task_alt_rounded,
                  iconColor: AppColors.terracotta,
                  value: '$activeCount/${_dishes.length}',
                  label: 'Active Dishes',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
