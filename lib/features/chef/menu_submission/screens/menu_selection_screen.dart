import 'package:flutter/material.dart';
import 'package:savora_app/core/routing/routes.dart';
import 'package:savora_app/core/theme/app_colors.dart';
import 'package:savora_app/core/theme/app_spacing.dart';
import 'package:savora_app/core/theme/app_text_styles.dart';
import 'package:savora_app/data/models/dish_model.dart';

import '../../widgets/chef_ui_kit.dart';
import '../widgets/menu_widgets.dart';

/// Onboarding step 3 of 3: "Select your Menu" — chef opts into catalog
/// recipes within their chosen specialty before finishing setup.
class MenuSelectionScreen extends StatefulWidget {
  const MenuSelectionScreen({super.key});

  @override
  State<MenuSelectionScreen> createState() => _MenuSelectionScreenState();
}

class _MenuSelectionScreenState extends State<MenuSelectionScreen> {
  List<CatalogRecipeModel> _recipes = const [
    CatalogRecipeModel(
      id: 'kofta-grills',
      title: 'Signature Kofta Grills',
      description:
          'Traditional spiced minced meat skewers grilled over charcoal.',
      imageUrl:
          'https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=400',
      isHighDemand: true,
      selected: true,
    ),
    CatalogRecipeModel(
      id: 'shish-tawook',
      title: 'Spicy Shish Tawook',
      description:
          'Marinated chicken cubes with garlic, lemon, and Egyptian spices.',
      imageUrl:
          'https://images.unsplash.com/photo-1633321088355-d0f81d8c4f15?w=400',
      isHighDemand: true,
    ),
    CatalogRecipeModel(
      id: 'mixed-grill',
      title: 'Mixed Grill Platter',
      description:
          'A generous combination of ribs, tawook, and kofta for sharing.',
      imageUrl:
          'https://images.unsplash.com/photo-1544025162-d76694265947?w=400',
      isHighDemand: true,
    ),
    CatalogRecipeModel(
      id: 'hawawshi',
      title: 'Charcoal Hawawshi',
      description:
          'Crispy pita bread stuffed with seasoned minced beef and peppers.',
      imageUrl:
          'https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=400',
      isHighDemand: true,
    ),
  ];

  void _toggle(CatalogRecipeModel recipe) {
    setState(() {
      _recipes = [
        for (final r in _recipes)
          if (r.id == recipe.id) r.copyWith(selected: !r.selected) else r,
      ];
    });
  }

  void _finishSetup() {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(Routes.chefShell, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final hasSelection = _recipes.any((r) => r.selected);

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ONBOARDING',
                style: AppTextStyles.overline.copyWith(color: AppColors.amber)),
            Text('Step 3 of 3',
                style: AppTextStyles.titleLg
                    .copyWith(color: AppColors.textOf(brightness))),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          const NumberedStepper(
              steps: ['Profile', 'Categories', 'Menu'], currentIndex: 2),
          const SizedBox(height: AppSpacing.lg),
          Text('Select your Menu',
              style: AppTextStyles.headlineLg
                  .copyWith(color: AppColors.textOf(brightness))),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.textMutedOf(brightness)),
              children: [
                const TextSpan(text: 'Choose the best recipes for your '),
                TextSpan(
                  text: 'Egyptian Grills',
                  style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.amber, fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: ' category to start your journey.'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final recipe in _recipes) ...[
            RecipeSelectableCard(
              imageUrl: recipe.imageUrl,
              title: recipe.title,
              description: recipe.description,
              isHighDemand: recipe.isHighDemand,
              selected: recipe.selected,
              onTap: () => _toggle(recipe),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.sm),
          ChefPrimaryButton(
            label: 'Finish Setup',
            onPressed: hasSelection ? _finishSetup : null,
          ),
        ],
      ),
    );
  }
}
