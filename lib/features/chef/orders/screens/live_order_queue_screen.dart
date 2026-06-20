import 'package:flutter/material.dart';
import 'package:savora_app/core/routing/routes.dart' hide OrderPreparationArgs;
import 'package:savora_app/core/theme/app_colors.dart';
import 'package:savora_app/core/theme/app_spacing.dart';
import 'package:savora_app/core/theme/app_text_styles.dart';
import 'package:savora_app/data/models/order_model.dart';

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

  List<OrderModel> _orders = [
    OrderModel(
      id: '4092',
      customerName: 'David Miller',
      items: const [
        OrderItem(id: '1', name: 'Margherita Pizza', quantity: 2),
        OrderItem(id: '2', name: 'Garlic Knots', quantity: 1),
      ],
      total: 34.50,
      status: OrderStatus.incoming,
      fulfillmentType: FulfillmentType.delivery,
      targetPrepTime: 'As Soon As Possible',
    ),
    OrderModel(
      id: '4093',
      customerName: 'Olivia Bennett',
      items: const [
        OrderItem(id: '1', name: 'Truffle Risotto', quantity: 1),
        OrderItem(id: '2', name: 'House Salad', quantity: 1),
      ],
      total: 42.00,
      status: OrderStatus.incoming,
      fulfillmentType: FulfillmentType.scheduled,
      targetPrepTime: 'Scheduled 12:45 PM',
    ),
    OrderModel(
      id: '4088',
      customerName: 'Liam Carter',
      items: const [
        OrderItem(id: '1', name: 'Pan-Seared Salmon, Asparagus', quantity: 1)
      ],
      total: 38.00,
      status: OrderStatus.preparing,
      fulfillmentType: FulfillmentType.delivery,
      remainingSeconds: 518,
      totalPrepSeconds: 900,
      customerNote: 'Extra lemon on the side please.',
    ),
    OrderModel(
      id: '4085',
      customerName: 'Sophia Reyes',
      items: const [
        OrderItem(id: '1', name: 'Beef Wellington (Individual)', quantity: 1)
      ],
      total: 52.00,
      status: OrderStatus.preparing,
      fulfillmentType: FulfillmentType.pickup,
      remainingSeconds: 11,
      totalPrepSeconds: 600,
    ),
    OrderModel(
      id: '4080',
      customerName: 'Sarah',
      items: const [
        OrderItem(id: '1', name: 'Chicken Alfredo Pasta', quantity: 1)
      ],
      total: 28.00,
      status: OrderStatus.completed,
      fulfillmentType: FulfillmentType.delivery,
      pickedUpBy: 'Sarah',
    ),
  ];

  void _accept(OrderModel order) {
    setState(() {
      _orders = [
        for (final o in _orders)
          if (o.id == order.id)
            o
                .copyWith(status: OrderStatus.preparing, remainingSeconds: 900)
                .copyWith()
          else
            o,
      ];
    });
    final updated = _orders.firstWhere((o) => o.id == order.id);
    Navigator.of(context).pushNamed(
      Routes.chefOrderPreparation,
      arguments: OrderPreparationArgs(updated),
    );
  }

  void _decline(OrderModel order) {
    setState(() => _orders = _orders.where((o) => o.id != order.id).toList());
  }

  void _markReady(OrderModel order) {
    setState(() {
      _orders = [
        for (final o in _orders)
          if (o.id == order.id)
            o.copyWith(status: OrderStatus.readyForPickup)
          else
            o,
      ];
    });
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
    final incoming =
        _orders.where((o) => o.status == OrderStatus.incoming).toList();
    final preparing =
        _orders.where((o) => o.status == OrderStatus.preparing).toList();
    final ready = _orders
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
            child: _showHistory
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
