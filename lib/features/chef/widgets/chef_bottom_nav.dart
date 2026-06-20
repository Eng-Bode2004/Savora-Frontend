import 'package:flutter/material.dart';
import 'package:savora_app/core/theme/app_colors.dart';
import 'package:savora_app/core/theme/app_spacing.dart';
import 'package:savora_app/core/theme/app_text_styles.dart';

class ChefBottomNavItem {
  const ChefBottomNavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

/// Bottom navigation bar shared by every top-level Chef tab (Orders, Menu,
/// Earnings, Profile). The active tab renders inside a soft gold pill,
/// matching the partner dashboard design.
class ChefBottomNav extends StatelessWidget {
  const ChefBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<ChefBottomNavItem> items = [
    ChefBottomNavItem(icon: Icons.receipt_long_rounded, label: 'Orders'),
    ChefBottomNavItem(icon: Icons.restaurant_rounded, label: 'Menu'),
    ChefBottomNavItem(icon: Icons.payments_rounded, label: 'Earnings'),
    ChefBottomNavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final surface = AppColors.surfaceOf(brightness);
    final border = AppColors.borderOf(brightness);
    final inactive = AppColors.textMutedOf(brightness);

    return Container(
      decoration: BoxDecoration(
        color: surface,
        border: Border(top: BorderSide(color: border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSpacing.bottomNavHeight,
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = i == currentIndex;
              final item = items[i];
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.gold.withValues(alpha: 0.9)
                            : null,
                        borderRadius: AppSpacing.borderRadiusFull,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            size: 22,
                            color: selected ? AppColors.clay : inactive,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.label,
                            style: AppTextStyles.labelSm.copyWith(
                              color: selected ? AppColors.clay : inactive,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
