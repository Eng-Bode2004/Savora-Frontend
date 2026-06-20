import 'dart:async';
import 'package:flutter/material.dart';
import 'package:savora_app/core/routing/routes.dart' hide OrderPreparationArgs;
import 'package:savora_app/core/theme/app_colors.dart';
import 'package:savora_app/core/theme/app_spacing.dart';
import 'package:savora_app/core/theme/app_text_styles.dart';
import 'package:savora_app/data/models/order_model.dart';

import '../../widgets/chef_ui_kit.dart';
import '../widgets/dashboard_widgets.dart';

/// Orders tab home: kitchen earnings snapshot, quick stats, the single
/// highest-priority incoming order, and the kitchen open/closed toggle.
class PartnerDashboardScreen extends StatefulWidget {
  const PartnerDashboardScreen({super.key});

  @override
  State<PartnerDashboardScreen> createState() => _PartnerDashboardScreenState();
}

class _PartnerDashboardScreenState extends State<PartnerDashboardScreen> {
  bool _kitchenOpen = true;
  OrderModel? _incomingOrder = const OrderModel(
    id: '4102',
    customerName: 'Walk-in',
    items: [
      OrderItem(id: '1', name: 'Gourmet Truffle Burger', quantity: 2),
      OrderItem(id: '2', name: 'Fries', quantity: 1),
    ],
    total: 345.00,
    status: OrderStatus.incoming,
    fulfillmentType: FulfillmentType.delivery,
    distanceKm: 2.4,
    remainingSeconds: 162,
    totalPrepSeconds: 180,
  );

  Timer? _countdown;

  @override
  void initState() {
    super.initState();
    _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      final order = _incomingOrder;
      if (order == null || order.remainingSeconds == null) return;
      if (order.remainingSeconds! <= 0) {
        setState(() => _incomingOrder = null);
        return;
      }
      setState(() {
        _incomingOrder =
            order.copyWith(remainingSeconds: order.remainingSeconds! - 1);
      });
    });
  }

  @override
  void dispose() {
    _countdown?.cancel();
    super.dispose();
  }

  void _acceptOrder() {
    final order = _incomingOrder;
    if (order == null) return;
    Navigator.of(context)
        .pushNamed(
      Routes.chefOrderPreparation,
      arguments:
          OrderPreparationArgs(order.copyWith(status: OrderStatus.preparing)),
    )
        .then((_) {
      if (mounted) setState(() => _incomingOrder = null);
    });
  }

  void _declineOrder() {
    setState(() => _incomingOrder = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order declined')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final order = _incomingOrder;

    return Scaffold(
      backgroundColor: AppColors.surfaceSunkenOf(brightness),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.md,
          ),
          children: [
            Text(
              'Good Morning, Maria',
              style: AppTextStyles.headlineLg
                  .copyWith(color: AppColors.textOf(brightness)),
            ),
            const SizedBox(height: 4),
            Text(
              'Your kitchen is open and ready for service.',
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.textMutedOf(brightness)),
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(
              title: 'Kitchen Overview',
              trailing: Row(
                children: [
                  Text('Today',
                      style: AppTextStyles.labelLg
                          .copyWith(color: AppColors.amber)),
                  Icon(Icons.expand_more_rounded,
                      size: 18, color: AppColors.amber),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const KitchenOverviewCard(
              totalEarnings: 'EGP 4,250.00',
              changePercent: 12,
              caption: 'from 18 completed orders today',
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: const [
                Expanded(
                  child: StatMiniCard(
                    icon: Icons.receipt_long_rounded,
                    iconColor: AppColors.gold,
                    value: '24',
                    label: 'Total Orders',
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: StatMiniCard(
                    icon: Icons.timer_outlined,
                    iconColor: AppColors.terracotta,
                    value: '6.5h',
                    label: 'Active Hours',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (order != null) ...[
              IncomingOrderCard(
                orderTotal: 'EGP ${order.total.toStringAsFixed(2)}',
                remainingLabel: order.formattedRemaining,
                distanceKm: order.distanceKm ?? 0,
                itemCount: order.itemCount,
                itemsSummary:
                    order.items.map((i) => i.quantityLabel).join(', '),
                onAccept: _acceptOrder,
                onDecline: _declineOrder,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            KitchenStatusToggle(
              isOpen: _kitchenOpen,
              onChanged: (v) => setState(() => _kitchenOpen = v),
            ),
          ],
        ),
      ),
    );
  }
}
