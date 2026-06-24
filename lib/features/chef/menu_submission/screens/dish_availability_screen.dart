import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/network/savora_api.dart';
import '../../../../state/providers/auth_provider.dart';

class DishAvailabilityScreen extends StatefulWidget {
  const DishAvailabilityScreen({super.key});

  @override
  State<DishAvailabilityScreen> createState() => _DishAvailabilityScreenState();
}

class _DishAvailabilityScreenState extends State<DishAvailabilityScreen> {
  bool _loading = true;
  final List<_InventoryItem> _items = [];
  String _today = '';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    _load();
  }

  Future<void> _load() async {
    final chefId = authState.profileId;
    if (chefId == null) return;
    setState(() => _loading = true);
    _items.clear();
    try {
      final prefData = await SavoraApi.getPreferredDishes(chefId);
      final prefList = prefData['preferred'] as List? ?? [];

      final dishIds = prefList
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

      final availData = await SavoraApi.getAvailabilityByChiefAndDate(chefId, _today);
      final availList = availData['availabilities'] as List? ?? [];

      final availMap = <String, Map<String, dynamic>>{};
      for (final a in availList) {
        final did = a['dish_id'] as String? ?? '';
        if (did.isNotEmpty) availMap[did] = a as Map<String, dynamic>;
      }

      for (final p in prefList) {
        final pMap = p as Map<String, dynamic>;
        final dishId = pMap['dish_id'] as String? ?? '';
        final dish = details[dishId];
        final dishName = dish?['english_name'] as String? ??
            pMap['dish_name'] as String? ??
            pMap['english_name'] as String? ??
            dishId;
        final imageUrl = dish?['image'] as String? ?? '';
        final existing = availMap[dishId];
        if (existing != null) {
          _items.add(_InventoryItem(
            dishId: dishId,
            dishName: existing['dish_name'] as String? ?? dishName,
            imageUrl: imageUrl,
            piecesAvailable: (existing['pieces_available'] as num?)?.toInt() ?? 0,
            piecesSold: (existing['pieces_sold'] as num?)?.toInt() ?? 0,
          ));
        } else {
          _items.add(_InventoryItem(
            dishId: dishId,
            dishName: dishName,
            imageUrl: imageUrl,
            piecesAvailable: 0,
            piecesSold: 0,
          ));
        }
      }

      if (mounted) setState(() => _loading = false);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateStock(String dishId, String dishName) async {
    final chefId = authState.profileId;
    if (chefId == null) return;
    final ctrl = TextEditingController();
    await _showStockDialog(context, ctrl, dishName);
    final qty = int.tryParse(ctrl.text);
    if (qty == null || qty < 0) return;
    try {
      await SavoraApi.setDailyAvailability(
        chiefId: chefId,
        dishId: dishId,
        date: _today,
        piecesAvailable: qty,
      );
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed: $e'),
          backgroundColor: Colors.red.shade700,
        ));
      }
    }
  }

  Future<void> _showStockDialog(BuildContext context, TextEditingController ctrl, String dishName) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceOf(Theme.of(context).brightness),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Set Stock', style: TextStyle(
          fontFamily: 'DM Sans', fontWeight: FontWeight.w700,
          color: AppColors.textOf(Theme.of(context).brightness),
        )),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dishName, style: TextStyle(
              fontFamily: 'DM Sans', fontSize: 13,
              color: AppColors.textMutedOf(Theme.of(context).brightness),
            )),
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
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.ember)),
          ),
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
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textColor = AppColors.textOf(brightness);
    final mutedColor = AppColors.textMutedOf(brightness);
    final surface = AppColors.surfaceOf(brightness);

    return Scaffold(
      backgroundColor: AppColors.surfaceSunkenOf(brightness),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Today\'s Stock', style: TextStyle(
          fontFamily: 'DM Sans', fontWeight: FontWeight.w700, color: textColor,
        )),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64, color: mutedColor),
                      const SizedBox(height: 16),
                      Text('No preferred dishes yet', style: TextStyle(color: mutedColor)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  itemBuilder: (_, i) {
                    final item = _items[i];
                    final isSet = item.piecesAvailable > 0;
                    final remaining = item.piecesAvailable - item.piecesSold;
                    return Card(
                      color: surface,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: item.imageUrl.isNotEmpty
                              ? Image.network(item.imageUrl, width: 48, height: 48, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.restaurant_rounded, color: AppColors.gold, size: 22))
                              : const Icon(Icons.restaurant_rounded, color: AppColors.gold, size: 22),
                        ),
                        title: Text(item.dishName, style: TextStyle(
                          fontFamily: 'DM Sans', fontWeight: FontWeight.w600, color: textColor,
                        )),
                        subtitle: isSet
                            ? Text(
                                'Stock: ${item.piecesAvailable} | Sold: ${item.piecesSold} | Left: $remaining',
                                style: TextStyle(fontSize: 12, color: mutedColor),
                              )
                            : Text('Not set for today',
                                style: TextStyle(fontSize: 12, color: AppColors.ember)),
                        trailing: Icon(
                          isSet ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                          color: isSet ? AppColors.gold : mutedColor,
                        ),
                        onTap: () => _updateStock(item.dishId, item.dishName),
                      ),
                    );
                  },
                ),
    );
  }
}

class _InventoryItem {
  final String dishId;
  final String dishName;
  final String imageUrl;
  final int piecesAvailable;
  final int piecesSold;

  _InventoryItem({
    required this.dishId,
    required this.dishName,
    this.imageUrl = '',
    required this.piecesAvailable,
    required this.piecesSold,
  });
}
