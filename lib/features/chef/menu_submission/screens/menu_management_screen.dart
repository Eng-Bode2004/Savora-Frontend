import 'package:flutter/material.dart';
import 'package:savora_app/core/theme/app_colors.dart';
import 'package:savora_app/core/theme/app_spacing.dart';
import 'package:savora_app/core/theme/app_text_styles.dart';
import 'package:savora_app/core/network/savora_api.dart';
import 'package:savora_app/state/providers/auth_provider.dart';

import 'dish_availability_screen.dart';
import 'dish_detail_screen.dart';
import 'package:savora_app/features/chef/auth/screens/Select%20Specialized%20Categories.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  bool _loading = true;
  String? _error;
  List<_PreferredDish> _dishes = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final chefId = authState.profileId;
    if (chefId == null) {
      if (mounted) setState(() { _error = 'Please log in first'; _loading = false; });
      return;
    }
    setState(() => _loading = true);
    try {
      final data = await SavoraApi.getPreferredDishes(chefId);
      final list = data['preferred'] as List? ?? [];

      final dishIds = list
          .map((e) => (e as Map<String, dynamic>)['dish_id'] as String? ?? '')
          .where((id) => id.isNotEmpty)
          .toList();

      final details = <String, Map<String, dynamic>>{};
      if (dishIds.isNotEmpty) {
        final results = await Future.wait(
          dishIds.map((id) => SavoraApi.getDishById(id).catchError((_) => <String, dynamic>{})),
        );
        for (int i = 0; i < dishIds.length; i++) {
          final r = results[i];
          if (r.isNotEmpty) {
            final dish = r['dish'] as Map<String, dynamic>?;
            if (dish != null) details[dishIds[i]] = dish;
          }
        }
      }

      final now = DateTime.now();
      final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final availMap = <String, Map<String, dynamic>>{};
      try {
        final availData = await SavoraApi.getAvailabilityByChiefAndDate(chefId, today);
        final availList = availData['availabilities'] as List? ?? [];
        for (final a in availList) {
          final did = a['dish_id'] as String? ?? '';
          if (did.isNotEmpty) availMap[did] = a as Map<String, dynamic>;
        }
      } catch (_) {}

      _dishes = list.map((e) {
        final m = e as Map<String, dynamic>;
        final dishId = m['dish_id'] as String? ?? '';
        final dish = details[dishId];
        final avail = availMap[dishId];
        final dishName = dish?['english_name'] as String? ??
            m['dish_name'] as String? ?? m['english_name'] as String? ?? dishId;
        return _PreferredDish(
          dishId: dishId,
          dishName: dishName,
          imageUrl: dish?['image'] as String? ?? '',
          price: (dish?['price'] as num?)?.toInt() ?? 0,
          unitType: dish?['unit_type'] as String? ?? '',
          stockAvailable: (avail?['pieces_available'] as num?)?.toInt() ?? 0,
          stockSold: (avail?['pieces_sold'] as num?)?.toInt() ?? 0,
          dishData: dish,
        );
      }).toList();
      _error = null;
    } catch (e) { _error = 'Failed to load: $e'; }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _remove(String dishId) async {
    final chefId = authState.profileId;
    if (chefId == null) return;
    try {
      await SavoraApi.removePreferredDish(chiefId: chefId, dishId: dishId);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to remove: $e'),
          backgroundColor: Colors.red.shade700,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textColor = AppColors.textOf(brightness);
    final mutedColor = AppColors.textMutedOf(brightness);
    final surface = AppColors.surfaceOf(brightness);

    return SafeArea(
      top: false,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding, vertical: AppSpacing.md),
              children: [
                Text('Menu Management',
                    style: AppTextStyles.headlineLg.copyWith(color: textColor)),
                const SizedBox(height: 4),
                Text('Set today\'s stock & manage your preferred dishes.',
                    style: AppTextStyles.bodyMd.copyWith(color: mutedColor)),
                const SizedBox(height: AppSpacing.lg),

                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DishAvailabilityScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.inventory_2_rounded, color: AppColors.gold, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('Set Today\'s Stock',
                              style: AppTextStyles.bodyMd.copyWith(
                                  fontWeight: FontWeight.w700, color: textColor)),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, size: 14, color: mutedColor),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                GestureDetector(
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SelectSpecializedCategories(fromManagement: true)),
                    );
                    if (mounted) _load();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderOf(brightness)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.add_circle_outline_rounded, color: AppColors.gold, size: 20),
                        const SizedBox(width: 12),
                        Text('Add dishes to your menu',
                            style: AppTextStyles.bodyMd.copyWith(color: textColor)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.ember.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.ember, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_error!, style: TextStyle(color: AppColors.ember, fontSize: 13))),
                      ],
                    ),
                  ),

                if (_dishes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('Your Dishes (${_dishes.length})',
                        style: AppTextStyles.titleLg.copyWith(color: textColor)),
                  ),

                if (_error == null && _dishes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.restaurant_menu_rounded, size: 64, color: mutedColor),
                          const SizedBox(height: 16),
                          Text('No preferred dishes yet',
                              style: AppTextStyles.bodyMd.copyWith(color: mutedColor)),
                        ],
                      ),
                    ),
                  )
                else
                  ..._dishes.map((d) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _DishCard(
                      dish: d,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DishDetailScreen(
                              dishId: d.dishId,
                              initialData: d.dishData,
                            ),
                          ),
                        );
                      },
                      onDelete: () => _remove(d.dishId),
                    ),
                  )),
              ],
            ),
    );
  }
}

class _DishCard extends StatelessWidget {
  final _PreferredDish dish;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _DishCard({required this.dish, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textColor = AppColors.textOf(brightness);
    final mutedColor = AppColors.textMutedOf(brightness);
    final hasStock = dish.stockAvailable > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceOf(brightness),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderOf(brightness)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
              child: dish.imageUrl.isNotEmpty
                  ? Image.network(dish.imageUrl, width: 90, height: 90, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 90, height: 90,
                        color: AppColors.surfaceSunkenOf(brightness),
                        child: const Icon(Icons.restaurant_rounded, color: AppColors.gold, size: 28),
                      ))
                  : Container(
                      width: 90, height: 90,
                      color: AppColors.surfaceSunkenOf(brightness),
                      child: const Icon(Icons.restaurant_rounded, color: AppColors.gold, size: 28)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dish.dishName,
                        style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w600, color: textColor, fontSize: 15),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (dish.price > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text('${dish.price} EGP${dish.unitType.isNotEmpty ? ' / ${dish.unitType}' : ''}',
                            style: TextStyle(fontSize: 12, color: AppColors.gold)),
                      ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: hasStock ? Colors.green.withValues(alpha: 0.1) : AppColors.ember.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        hasStock ? 'Stock: ${dish.stockAvailable}' : 'Not set today',
                        style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          color: hasStock ? Colors.green.shade700 : AppColors.ember,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: onDelete,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.ember.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: AppColors.ember, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreferredDish {
  final String dishId;
  final String dishName;
  final String imageUrl;
  final int price;
  final String unitType;
  final int stockAvailable;
  final int stockSold;
  final Map<String, dynamic>? dishData;

  _PreferredDish({
    required this.dishId,
    required this.dishName,
    this.imageUrl = '',
    this.price = 0,
    this.unitType = '',
    this.stockAvailable = 0,
    this.stockSold = 0,
    this.dishData,
  });
}
