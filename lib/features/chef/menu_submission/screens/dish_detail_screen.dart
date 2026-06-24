import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savora_app/core/network/savora_api.dart';
import 'package:savora_app/state/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class DishDetailScreen extends StatefulWidget {
  final String dishId;
  final Map<String, dynamic>? initialData;

  const DishDetailScreen({super.key, required this.dishId, this.initialData});

  @override
  State<DishDetailScreen> createState() => _DishDetailScreenState();
}

class _DishDetailScreenState extends State<DishDetailScreen> {
  Map<String, dynamic>? _dish;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _dish = widget.initialData;
      _loading = false;
    } else {
      _fetchDish();
    }
  }

  Future<void> _fetchDish() async {
    try {
      final data = await SavoraApi.getDishById(widget.dishId);
      if (mounted) setState(() { _dish = data['dish'] as Map<String, dynamic>?; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _setStock() async {
    final chefId = authState.profileId;
    if (chefId == null) return;
    final ctrl = TextEditingController();
    final now = DateTime.now();
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final brightness = Theme.of(context).brightness;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceOf(brightness),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Set Stock', style: TextStyle(
          fontFamily: 'DM Sans', fontWeight: FontWeight.w700,
          color: AppColors.textOf(brightness),
        )),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_dish?['english_name'] as String? ?? '',
                style: TextStyle(fontFamily: 'DM Sans', fontSize: 13,
                    color: AppColors.textMutedOf(brightness))),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Pieces available today',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppColors.ember))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.clay,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    final qty = int.tryParse(ctrl.text);
    if (qty == null || qty < 0) return;
    try {
      await SavoraApi.setDailyAvailability(
        chiefId: chefId,
        dishId: widget.dishId,
        date: today,
        piecesAvailable: qty,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Stock set to $qty'),
          backgroundColor: Colors.green.shade700,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed: $e'),
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

    if (_loading) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0,
            leading: IconButton(icon: Icon(Icons.arrow_back_rounded, color: AppColors.textOf(brightness)),
                onPressed: () => Navigator.of(context).maybePop())),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final image = _dish?['image'] as String? ?? '';
    final name = _dish?['english_name'] as String? ?? 'Dish';
    final description = _dish?['english_description'] as String? ?? '';
    final price = (_dish?['price'] as num?)?.toInt() ?? 0;
    final unitType = _dish?['unit_type'] as String? ?? 'pieces';
    final ingredients = (_dish?['english_ingredients'] as List?)?.cast<String>() ?? <String>[];
    final steps = (_dish?['english_Recipe_steps'] as List?)?.cast<String>() ?? <String>[];

    final _items = [
      if (price > 0) {'icon': Icons.attach_money_rounded, 'label': '$price EGP / $unitType'},
      {'icon': Icons.restaurant_menu_rounded, 'label': '${ingredients.length} ingredients'},
      {'icon': Icons.menu_book_rounded, 'label': '${steps.length} steps'},
    ];

    return Scaffold(
      backgroundColor: AppColors.surfaceSunkenOf(brightness),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Dish Details', style: TextStyle(
            fontFamily: 'DM Sans', fontWeight: FontWeight.w700, color: textColor)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: image.isNotEmpty
                ? Image.network(image, width: double.infinity, height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200, color: AppColors.surfaceOf(brightness),
                      child: const Icon(Icons.restaurant_rounded, size: 48, color: AppColors.gold)),
                  )
                : Container(
                    height: 200, color: AppColors.surfaceOf(brightness),
                    child: const Icon(Icons.restaurant_rounded, size: 48, color: AppColors.gold)),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: _items.map((i) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceOf(brightness),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(i['icon'] as IconData, color: AppColors.gold, size: 20),
                    const SizedBox(height: 4),
                    Text(i['label'] as String,
                        style: TextStyle(fontSize: 11, color: mutedColor),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(name, style: AppTextStyles.headlineLg.copyWith(color: textColor)),
          if (description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(description, style: AppTextStyles.bodyMd.copyWith(color: mutedColor)),
          ],
          const SizedBox(height: AppSpacing.lg),

          if (ingredients.isNotEmpty) ...[
            Row(children: [
              const Icon(Icons.shopping_basket_outlined, size: 18, color: AppColors.gold),
              const SizedBox(width: 6),
              Text('Ingredients', style: AppTextStyles.titleLg.copyWith(color: textColor)),
            ]),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              decoration: BoxDecoration(
                color: AppColors.surfaceOf(brightness),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: ingredients.map((ing) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.check_box_outline_blank_rounded, size: 16, color: AppColors.gold),
                      const SizedBox(width: 8),
                      Expanded(child: Text(ing, style: AppTextStyles.bodyMd.copyWith(color: textColor))),
                    ],
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          if (steps.isNotEmpty) ...[
            Row(children: [
              const Icon(Icons.menu_book_outlined, size: 18, color: AppColors.gold),
              const SizedBox(width: 6),
              Text('Recipe Steps', style: AppTextStyles.titleLg.copyWith(color: textColor)),
            ]),
            const SizedBox(height: AppSpacing.sm),
            ...List.generate(steps.length, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28, height: 28, alignment: Alignment.center,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.gold),
                    child: Text('${i + 1}',
                        style: AppTextStyles.labelLg.copyWith(color: AppColors.clay)),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceOf(brightness),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(steps[i], style: AppTextStyles.bodyMd.copyWith(color: textColor)),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: AppSpacing.lg),
          ],

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.clay,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.inventory_2_rounded, size: 20),
            label: const Text('Set Today\'s Stock',
                style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w700, fontSize: 15)),
            onPressed: _setStock,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
