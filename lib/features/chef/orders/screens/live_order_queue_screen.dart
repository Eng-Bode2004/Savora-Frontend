import 'package:flutter/material.dart';
import 'package:savora_app/core/network/savora_api.dart';
import 'package:savora_app/core/routing/routes.dart' hide OrderPreparationArgs;
import 'package:savora_app/core/theme/app_colors.dart';
import 'package:savora_app/core/theme/app_spacing.dart';
import 'package:savora_app/core/theme/app_text_styles.dart';
import 'package:savora_app/data/models/order_model.dart';
import 'package:savora_app/state/providers/auth_provider.dart';

import '../../widgets/chef_top_bar.dart';
import '../widgets/order_widgets.dart';

/// Full order queue: Active (Incoming / Preparing / Ready for Pickup) vs
/// History, reached by drilling in from the dashboard.
class LiveOrderQueueScreen extends StatefulWidget {
  const LiveOrderQueueScreen({super.key});

  @override
  State<LiveOrderQueueScreen> createState() => _LiveOrderQueueScreenState();
}

class _LiveOrderQueueScreenState extends State<LiveOrderQueueScreen> {
  bool _showHistory = false;
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final chefId = authState.profileId;
    if (chefId == null) return;
    setState(() => _loading = true);
    try {
      final data = await SavoraApi.getChefOrders(chefId);
      setState(() {
        _orders = List<Map<String, dynamic>>.from(data['orders'] ?? []);
        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  /// Map API order_status to OrderStatus enum
  OrderStatus _mapStatus(String? status) {
    switch (status) {
      case 'accepted':
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready':
        return OrderStatus.readyForPickup;
      case 'completed':
        return OrderStatus.completed;
      default:
        return OrderStatus.incoming;
    }
  }

  OrderModel _mapOrder(Map<String, dynamic> order) {
    final items = List<Map<String, dynamic>>.from(order['items'] ?? []);
    return OrderModel(
      id: (order['_id'] as String?) ?? '',
      customerName: (order['customer_id'] as String?) ?? 'Customer',
      items: items.asMap().entries.map((e) {
        final i = e.value;
        return OrderItem(
          id: (i['dish_id'] as String?) ?? '${e.key}',
          name: (i['name'] as String?) ?? '',
          quantity: (i['qty'] as num?)?.toInt() ?? 1,
        );
      }).toList(),
      total: ((order['total'] as num?)?.toDouble() ?? 0),
      status: _mapStatus(order['order_status'] as String?),
      fulfillmentType: FulfillmentType.delivery,
    );
  }

  Future<void> _accept(OrderModel order) async {
    try {
      await SavoraApi.acceptOrder(order.id);
      _loadOrders();
      Navigator.of(context).pushNamed(
        Routes.chefOrderPreparation,
        arguments: OrderPreparationArgs(order),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to accept: $e')),
        );
      }
    }
  }

  void _decline(OrderModel order) {
    // No decline API; just remove from local list
    setState(() => _orders.removeWhere((o) => o['_id'] == order.id));
  }

  Future<void> _markReady(OrderModel order) async {
    try {
      await SavoraApi.updateOrderStatus(order.id, 'ready');
      _loadOrders();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  void _openDetail(OrderModel order) {
    Navigator.of(context).pushNamed(
      Routes.chefOrderPreparation,
      arguments: OrderPreparationArgs(order),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final models = _orders.map(_mapOrder).toList();
    final incoming =
        models.where((o) => o.status == OrderStatus.incoming).toList();
    final preparing =
        models.where((o) => o.status == OrderStatus.preparing).toList();
    final ready = models
        .where((o) =>
            o.status == OrderStatus.readyForPickup ||
            o.status == OrderStatus.completed)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.surfaceSunkenOf(brightness),
      appBar: const ChefTopBar(leading: ChefTopBarLeading.back),
      body: Column(
        children: [
          _SegmentTabs(
            showHistory: _showHistory,
            onChanged: (v) => setState(() => _showHistory = v),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: GestureDetector(
                          onTap: _loadOrders,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Failed to load orders'),
                              const SizedBox(height: 8),
                              Text('Tap to retry',
                                  style: TextStyle(
                                      color: AppColors.textMutedOf(
                                          brightness))),
                            ],
                          ),
                        ),
                      )
                    : _showHistory
                ? Center(
                    child: Text(
                      'No order history yet',
                      style: AppTextStyles.bodyMd
                          .copyWith(color: AppColors.textMutedOf(brightness)),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(AppSpacing.screenPadding),
                    children: [
                      if (incoming.isNotEmpty) ...[
                        OrderSectionHeader(
                            title: 'Incoming',
                            count: incoming.length,
                            accentColor: AppColors.clay),
                        const SizedBox(height: AppSpacing.sm),
                        for (final order in incoming) ...[
                          IncomingQueueCard(
                            orderId: order.id,
                            timingLabel: order.targetPrepTime ?? '',
                            title: order.items
                                .map((i) => i.quantityLabel)
                                .join(', '),
                            customerName: order.customerName,
                            price: '\$${order.total.toStringAsFixed(2)}',
                            onAccept: () => _accept(order),
                            onDecline: () => _decline(order),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      if (preparing.isNotEmpty) ...[
                        OrderSectionHeader(
                            title: 'Preparing',
                            count: preparing.length,
                            accentColor: AppColors.gold),
                        const SizedBox(height: AppSpacing.sm),
                        for (final order in preparing) ...[
                          GestureDetector(
                            onTap: () => _openDetail(order),
                            child: PreparingQueueCard(
                              orderId: order.id,
                              title: order.items
                                  .map((i) => i.quantityLabel)
                                  .join(', '),
                              statusLabel: (order.remainingSeconds ?? 0) <= 30
                                  ? 'Dash Door Pickup'
                                  : 'In Progress',
                              progress: order.prepProgress,
                              remainingLabel: order.formattedRemaining,
                              isUrgent: (order.remainingSeconds ?? 0) <= 30,
                              customerNote: order.customerNote,
                              onMarkReady: () => _markReady(order),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      if (ready.isNotEmpty) ...[
                        OrderSectionHeader(
                          title: 'Ready for Pickup',
                          count: ready.length,
                          accentColor: AppColors.textMutedOf(brightness),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        for (final order in ready)
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: ReadyQueueCard(
                              orderId: order.id,
                              pickedUpBy: order.pickedUpBy ?? 'Driver',
                              title: order.items
                                  .map((i) => i.quantityLabel)
                                  .join(', '),
                            ),
                          ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SegmentTabs extends StatelessWidget {
  const _SegmentTabs({required this.showHistory, required this.onChanged});

  final bool showHistory;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(brightness),
        border:
            Border(bottom: BorderSide(color: AppColors.borderOf(brightness))),
      ),
      child: Row(
        children: [
          Expanded(
              child: _SegmentTab(
                  label: 'Active',
                  selected: !showHistory,
                  onTap: () => onChanged(false))),
          Expanded(
              child: _SegmentTab(
                  label: 'History',
                  selected: showHistory,
                  onTap: () => onChanged(true))),
        ],
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  const _SegmentTab(
      {required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? AppColors.amber : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.titleMd.copyWith(
            color:
                selected ? AppColors.amber : AppColors.textMutedOf(brightness),
          ),
        ),
      ),
    );
  }
}
