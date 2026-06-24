import 'package:flutter/material.dart';
import 'package:savora_app/core/theme/app_colors.dart';
import 'package:savora_app/core/theme/app_spacing.dart';
import 'package:savora_app/core/theme/app_text_styles.dart';
import 'package:savora_app/core/network/savora_api.dart';
import 'package:savora_app/state/providers/auth_provider.dart';

class MenuSelectionScreen extends StatefulWidget {
  const MenuSelectionScreen({super.key});

  @override
  State<MenuSelectionScreen> createState() => _MenuSelectionScreenState();
}

class _MenuSelectionScreenState extends State<MenuSelectionScreen> {
  List<Map<String, dynamic>> _allDishes = [];
  Set<String> _existingIds = {};
  Set<String> _selectedIds = {};
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final chefId = authState.profileId;
    if (chefId == null) { if (mounted) setState(() { _error = 'Please log in first'; _loading = false; }); return; }
    setState(() => _loading = true);
    try {
      final prefData = await SavoraApi.getPreferredDishes(chefId);
      final prefList = prefData['preferred'] as List? ?? [];
      _existingIds = prefList
          .map((e) => (e as Map<String, dynamic>)['dish_id'] as String? ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();

      final allData = await SavoraApi.getAllDishes();
      final dishes = allData['dishes'] as List? ?? [];
      _allDishes = dishes.cast<Map<String, dynamic>>().toList();
      _error = null;
    } catch (e) { _error = 'Failed to load: $e'; }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _submit() async {
    final chefId = authState.profileId;
    if (chefId == null) return;
    setState(() => _submitting = true);
    int added = 0;
    for (final id in _selectedIds) {
      try {
        await SavoraApi.setPreferredDish(chiefId: chefId, dishId: id, preferred: true);
        added++;
      } catch (_) {}
    }
    if (mounted) {
      setState(() => _submitting = false);
      if (added > 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Added $added dish${added > 1 ? 'es' : ''}'),
          backgroundColor: Colors.green.shade700,
        ));
      }
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textColor = AppColors.textOf(brightness);
    final mutedColor = AppColors.textMutedOf(brightness);
    final hasNew = _selectedIds.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.surfaceSunkenOf(brightness),
      appBar: AppBar(
        backgroundColor: AppColors.surfaceOf(brightness),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.textOf(brightness)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Add Dishes',
            style: AppTextStyles.titleLg.copyWith(color: textColor)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: AppColors.ember.withValues(alpha: 0.1),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.ember, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_error!, style: TextStyle(color: AppColors.ember, fontSize: 13))),
                      ],
                    ),
                  ),
                Expanded(
                  child: _allDishes.isEmpty
                      ? Center(
                          child: Text('No dishes available',
                              style: AppTextStyles.bodyMd.copyWith(color: mutedColor)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(AppSpacing.screenPadding),
                          itemCount: _allDishes.length,
                          itemBuilder: (_, i) {
                            final dish = _allDishes[i];
                            final id = dish['_id'] as String? ?? '';
                            final name = dish['english_name'] as String? ?? 'Unknown';
                            final desc = dish['english_description'] as String? ?? '';
                            final image = dish['image'] as String? ?? '';
                            final price = (dish['price'] as num?)?.toInt() ?? 0;
                            final isExisting = _existingIds.contains(id);
                            final isSelected = _selectedIds.contains(id);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: GestureDetector(
                                onTap: isExisting ? null : () {
                                  setState(() {
                                    if (isSelected) _selectedIds.remove(id);
                                    else _selectedIds.add(id);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isExisting
                                        ? AppColors.gold.withValues(alpha: 0.08)
                                        : AppColors.surfaceOf(brightness),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.gold
                                          : isExisting
                                              ? AppColors.gold.withValues(alpha: 0.3)
                                              : AppColors.borderOf(brightness),
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: image.isNotEmpty
                                            ? Image.network(image, width: 56, height: 56, fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => Container(
                                                  width: 56, height: 56,
                                                  color: AppColors.surfaceSunkenOf(brightness),
                                                  child: const Icon(Icons.restaurant_rounded, color: AppColors.gold, size: 24),
                                                ))
                                            : Container(
                                                width: 56, height: 56,
                                                color: AppColors.surfaceSunkenOf(brightness),
                                                child: const Icon(Icons.restaurant_rounded, color: AppColors.gold, size: 24)),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(name,
                                                style: TextStyle(fontWeight: FontWeight.w600, color: textColor, fontSize: 14),
                                                maxLines: 1, overflow: TextOverflow.ellipsis),
                                            if (desc.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 2),
                                                child: Text(desc,
                                                    style: TextStyle(fontSize: 12, color: mutedColor),
                                                    maxLines: 2, overflow: TextOverflow.ellipsis),
                                              ),
                                            if (price > 0)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 2),
                                                child: Text('$price EGP',
                                                    style: TextStyle(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w600)),
                                              ),
                                          ],
                                        ),
                                      ),
                                      if (isExisting)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.gold.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text('Added', style: TextStyle(fontSize: 11, color: AppColors.gold, fontWeight: FontWeight.w600)),
                                        )
                                      else
                                        Checkbox(
                                          value: isSelected,
                                          onChanged: (_) => setState(() {
                                            if (isSelected) _selectedIds.remove(id);
                                            else _selectedIds.add(id);
                                          }),
                                          activeColor: AppColors.gold,
                                          checkColor: AppColors.clay,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                if (_allDishes.isNotEmpty)
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.screenPadding),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasNew ? AppColors.gold : AppColors.borderOf(brightness),
                            foregroundColor: hasNew ? AppColors.clay : mutedColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: (hasNew && !_submitting) ? _submit : null,
                          child: _submitting
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : Text('Add Selected (${_selectedIds.length})',
                                  style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w700, fontSize: 15)),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
