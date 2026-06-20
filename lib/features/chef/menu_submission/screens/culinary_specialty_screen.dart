import 'package:flutter/material.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/dish_model.dart';
import '../../widgets/chef_ui_kit.dart';
import '../widgets/menu_widgets.dart';

/// Onboarding step 1 of the menu-setup wizard: "What will you be cooking
/// today?" — the chef picks their culinary specialties.
///
/// Note: the design hand-off only included steps 1 and 3 of this wizard
/// (this screen, and [MenuSelectionScreen]); there is no step-2 "Profile"
/// screen to wire in, so "Continue Setup" advances straight to step 3.
class CulinarySpecialtyScreen extends StatefulWidget {
  const CulinarySpecialtyScreen({super.key});

  @override
  State<CulinarySpecialtyScreen> createState() => _CulinarySpecialtyScreenState();
}

class _CulinarySpecialtyScreenState extends State<CulinarySpecialtyScreen> {
  final List<SpecialtyCategoryModel> _categories = const [
    SpecialtyCategoryModel(id: 'grills', title: 'Egyptian Grills', subtitle: 'Kebab, Kofta & Chops'),
    SpecialtyCategoryModel(id: 'koshary', title: 'Koshary', subtitle: 'Classic Rice & Lentils'),
    SpecialtyCategoryModel(id: 'mahshi', title: 'Mahshi', subtitle: 'Stuffed Veggies & Vine'),
    SpecialtyCategoryModel(id: 'feteer', title: 'Feteer', subtitle: 'Pastries & Pies'),
    SpecialtyCategoryModel(id: 'tagines', title: 'Tagines', subtitle: 'Slow Cooked Clay Pots'),
    SpecialtyCategoryModel(id: 'sweets', title: 'Oriental Sweets', subtitle: 'Basbousa & Kunafa'),
  ];

  static const Map<String, IconData> _icons = {
    'grills': Icons.outdoor_grill_rounded,
    'koshary': Icons.restaurant_rounded,
    'mahshi': Icons.soup_kitchen_rounded,
    'feteer': Icons.bakery_dining_rounded,
    'tagines': Icons.join_full_rounded,
    'sweets': Icons.icecream_rounded,
  };

  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.surfaceSunkenOf(brightness),
      appBar: AppBar(
        backgroundColor: AppColors.surfaceOf(brightness),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.textOf(brightness)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const SegmentedStepProgress(totalSteps: 3, currentStep: 1),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Text('STEP 1 OF 3', style: AppTextStyles.overline.copyWith(color: AppColors.amber)),
          const SizedBox(height: 4),
          Text(
            'What will you be cooking today?',
            style: AppTextStyles.headlineLg.copyWith(color: AppColors.textOf(brightness)),
          ),
          const SizedBox(height: 4),
          Text(
            'Select your culinary specializations to personalize your kitchen dashboard.',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMutedOf(brightness)),
          ),
          const SizedBox(height: AppSpacing.lg),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, i) {
              final c = _categories[i];
              return SpecialtyCategoryCard(
                icon: _icons[c.id]!,
                title: c.title,
                subtitle: c.subtitle,
                selected: _selected.contains(c.id),
                onTap: () => setState(() {
                  if (!_selected.add(c.id)) _selected.remove(c.id);
                }),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          SpecialtyCategoryCard(
            icon: Icons.event_repeat_rounded,
            title: 'Daily Specials',
            subtitle: 'Rotational Home Cooking',
            selected: false,
            infoOnly: true,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Daily Specials rotate automatically — no setup needed.')),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: AppSpacing.borderRadiusMd,
            child: Stack(
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1556909212-d5b65c1f7878?w=900',
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height: 140, color: AppColors.charcoal),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black.withValues(alpha: 0.75), Colors.transparent],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: AppSpacing.sm,
                  bottom: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.gold, borderRadius: AppSpacing.borderRadiusXs),
                        child: Text('KITCHEN TIP', style: AppTextStyles.labelSm.copyWith(color: AppColors.clay)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Choose at least 2 for better menu sync.',
                        style: AppTextStyles.titleMd.copyWith(color: AppColors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ChefPrimaryButton(
            label: 'Continue Setup',
            icon: Icons.arrow_forward_rounded,
            onPressed: _selected.isEmpty
                ? null
                : () => Navigator.of(context).pushNamed(Routes.chefMenuSelection),
          ),
        ],
      ),
    );
  }
}

class SpecialtyCategoryModel {
  final String id;
  final String title;
  final String subtitle;

  const SpecialtyCategoryModel({
    required this.id,
    required this.title,
    required this.subtitle,
  });
}

