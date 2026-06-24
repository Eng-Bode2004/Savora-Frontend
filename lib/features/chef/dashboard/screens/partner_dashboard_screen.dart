import 'dart:async';
import 'package:flutter/material.dart';
import 'package:savora_app/core/network/savora_api.dart';
import 'package:savora_app/core/routing/routes.dart' hide OrderPreparationArgs;
import 'package:savora_app/core/theme/app_colors.dart';
import 'package:savora_app/core/theme/app_spacing.dart';
import 'package:savora_app/core/theme/app_text_styles.dart';
import 'package:savora_app/data/models/order_model.dart';
import 'package:savora_app/state/providers/auth_provider.dart';

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
  OrderModel? _incomingOrder;
  int _totalOrders = 0;
  bool _loading = true;

  double _totalEarnings = 0;
  double _changePercent = 0;
  int _completedCount = 0;
  String? _chefId;

  @override
  void initState() {
    super.initState();
    _chefId = authState.profileId;
    if (_chefId != null) _load();
  }

  Future<void> _load() async {
    final chefId = _chefId;
    if (chefId == null) return;
    await Future.wait([_loadIncomingOrder(), _loadEarnings(), _loadKitchenStatus()]);
  }

  Future<void> _loadKitchenStatus() async {
    final chefId = _chefId;
    if (chefId == null) return;
    try {
      final data = await SavoraApi.getChiefProfile(chefId);
      final profile = data['profile'] as Map<String, dynamic>? ?? data as Map<String, dynamic>? ?? {};
      if (mounted) setState(() {
        _kitchenOpen = profile['kitchen_open'] != false;
      });
    } catch (_) {}
  }

  Future<void> _loadIncomingOrder() async {
    final chefId = _chefId;
    if (chefId == null) return;
    try {
      final data = await SavoraApi.getChefOrders(chefId);
      final orders = List<Map<String, dynamic>>.from(data['orders'] ?? []);
      _totalOrders = orders.length;
      final incoming = orders.firstWhere(
        (o) => (o['order_status'] as String?) == 'pending' || (o['order_status'] as String?) == 'accepted',
        orElse: () => <String, dynamic>{},
      );
      if (incoming.isNotEmpty) {
        final items = List<Map<String, dynamic>>.from(incoming['items'] ?? []);
        setState(() {
          _incomingOrder = OrderModel(
            id: (incoming['_id'] as String?) ?? '',
            customerName: (incoming['customer_id'] as String?) ?? 'Customer',
            items: items.asMap().entries.map((e) {
              final i = e.value;
              return OrderItem(
                id: (i['dish_id'] as String?) ?? '${e.key}',
                name: (i['name'] as String?) ?? '',
                quantity: (i['qty'] as num?)?.toInt() ?? 1,
              );
            }).toList(),
            total: ((incoming['total'] as num?)?.toDouble() ?? 0),
            status: OrderStatus.incoming,
            fulfillmentType: FulfillmentType.delivery,
          );
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadEarnings() async {
    final chefId = _chefId;
    if (chefId == null) return;
    try {
      final data = await SavoraApi.getChefEarnings(chefId);
      final e = data['earnings'] as Map<String, dynamic>? ?? {};
      if (mounted) setState(() {
        _totalEarnings = (e['netEarnings'] as num?)?.toDouble() ?? 0;
        _changePercent = (e['changePercent'] as num?)?.toDouble() ?? 0;
        _completedCount = (e['orderCount'] as num?)?.toInt() ?? 0;
      });
    } catch (_) {}
  }

  void _acceptOrder() {
    final order = _incomingOrder;
    if (order == null) return;
    SavoraApi.acceptOrder(order.id).then((_) {
      Navigator.of(context)
          .pushNamed(
        Routes.chefOrderPreparation,
        arguments: OrderPreparationArgs(order.copyWith(status: OrderStatus.preparing)),
      )
          .then((_) {
        if (mounted) {
          setState(() => _incomingOrder = null);
          _loadIncomingOrder();
        }
      });
    }).catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to accept: $e')),
        );
      }
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
            KitchenOverviewCard(
              totalEarnings: 'EGP ${_totalEarnings.toStringAsFixed(2)}',
              changePercent: _changePercent,
              caption: 'from $_completedCount completed orders',
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: StatMiniCard(
                    icon: Icons.receipt_long_rounded,
                    iconColor: AppColors.gold,
                    value: _loading ? '--' : '$_totalOrders',
                    label: 'Total Orders',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: StatMiniCard(
                    icon: Icons.timer_outlined,
                    iconColor: AppColors.terracotta,
                    value: _loading ? '--' : (_incomingOrder != null ? 'Active' : 'Idle'),
                    label: 'Status',
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
              onChanged: (v) async {
                setState(() => _kitchenOpen = v);
                final id = _chefId;
                if (id != null) {
                  await SavoraApi.setKitchenStatus(id, v).catchError((_) {});
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
