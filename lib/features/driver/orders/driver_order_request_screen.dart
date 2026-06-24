import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:savora_app/features/driver/providers/driver_state.dart';
import 'package:savora_app/features/driver/services/driver_theme.dart';

class DriverOrderRequestScreen extends ConsumerWidget {
  final String orderId;

  const DriverOrderRequestScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final formattedId = '#$orderId';
    final orders = ref.watch(driverOrdersProvider);

    final order = orders.isNotEmpty
        ? orders.firstWhere(
          (o) => o.id == formattedId,
      orElse: () => orders.first,
    )
        : null;

    if (order == null) {
      return const Scaffold(
        body: Center(child: Text('No orders available')),
      );
    }

    return Scaffold(
      backgroundColor: cs.surface,

      appBar: AppBar(
        title: Text('Order $formattedId'),
        centerTitle: false,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/driver/orders');
            }
          },
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          // ================= HERO CARD =================
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cs.outline.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.local_shipping, color: cs.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #$orderId',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'New delivery request available',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'URGENT',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cs.primary.withOpacity(0.15),
                  cs.surfaceContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: cs.outline.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Text(
                  '\$${order.estPayout.toStringAsFixed(2)}',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Estimated Earnings',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ================= CHEF DETAILS =================
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: cs.primary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.storefront, color: cs.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text('CHEF / PICKUP',
                        style: theme.textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: cs.primary.withOpacity(0.12),
                      backgroundImage: order.chefImage.isNotEmpty
                          ? NetworkImage(order.chefImage)
                          : null,
                      child: order.chefImage.isEmpty
                          ? Icon(Icons.person, color: cs.primary)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order.chefName.isNotEmpty ? order.chefName : order.pickupName,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          if (order.chefPhone.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(order.chefPhone,
                                style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                          ],
                        ],
                      ),
                    ),
                    if (order.chefPhone.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.phone, color: cs.primary),
                        onPressed: () {},
                      ),
                  ],
                ),
                if (order.chefAddress.isNotEmpty || order.pickupAddress.isNotEmpty) ...[
                  const Divider(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, size: 18, color: cs.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.chefAddress.isNotEmpty ? order.chefAddress : order.pickupAddress,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ================= CUSTOMER DETAILS =================
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: cs.secondary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cs.secondary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.person, color: cs.secondary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text('CUSTOMER / DROP-OFF',
                        style: theme.textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: cs.secondary.withOpacity(0.12),
                      backgroundImage: order.customerAvatar != null
                          ? NetworkImage(order.customerAvatar!)
                          : null,
                      child: order.customerAvatar == null
                          ? Icon(Icons.person, color: cs.secondary)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order.customerName,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          if (order.customerPhone.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(order.customerPhone,
                                style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                          ],
                        ],
                      ),
                    ),
                    if (order.customerPhone.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.phone, color: cs.secondary),
                        onPressed: () {},
                      ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on, size: 18, color: cs.secondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (order.dropoffLabel.isNotEmpty)
                            Text(order.dropoffLabel,
                                style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                          Text(
                            order.dropoffAddress,
                            style: theme.textTheme.bodyMedium,
                          ),
                          if (order.dropoffCity.isNotEmpty)
                            Text(order.dropoffCity,
                                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ================= ITEMS =================
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: cs.outline.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Items',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 12),

                ...order.items.map(
                      (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: cs.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${item.quantity}x',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.name,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ================= ACTION BAR =================
      bottomSheet: Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
    decoration: BoxDecoration(
    color: cs.surface,
    border: Border(
    top: BorderSide(color: cs.outline.withOpacity(0.2)),
    ),
    ),
    child: Row(
    children: [
    Expanded(
    child: OutlinedButton(
    style: OutlinedButton.styleFrom(
    foregroundColor: cs.error,
    side: BorderSide(color: cs.error.withOpacity(0.4)),
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    ),
    ),
    onPressed: () {
    ref.read(driverOrdersProvider.notifier)
        .rejectOrder(order.id);
    context.go('/driver/orders');
    },
    child: const Text('Decline'),
    ),
    ),

    const SizedBox(width: 12),

    Expanded(
    child: ElevatedButton(
    style: ElevatedButton.styleFrom(
    backgroundColor: cs.primary,
    foregroundColor: cs.onPrimary,
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    ),
    ),
    onPressed: () {
    ref.read(driverOrdersProvider.notifier)
        .acceptOrder(order.id);
    context.go('/driver/active_delivery');
    },
    child: const Text('Accept Order'),
    ),
    ),
    ],
    ),
    )
    );
  }
}

