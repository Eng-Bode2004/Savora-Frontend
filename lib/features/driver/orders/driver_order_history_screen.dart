import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:savora_app/features/driver/providers/driver_state.dart';

class DriverOrderHistoryScreen extends ConsumerWidget {
  const DriverOrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(driverOrdersProvider);
    final history = orders.where((o) => o.status == 'completed').toList();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/driver/dashboard');
            }
          },
        ),
      ),
      body: history.isEmpty
          ? Center(
              child: Text('No completed orders yet.',
                  style: Theme.of(context).textTheme.bodyLarge))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final order = history[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: cs.surfaceContainerHighest,
                      child: Icon(Icons.check_circle, color: cs.primary),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Order ${order.id}',
                            style: Theme.of(context).textTheme.titleLarge),
                        Text(
                          '\$${order.estPayout.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: cs.primary),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order.customerName,
                              style: Theme.of(context).textTheme.bodyLarge),
                          const SizedBox(height: 4),
                          Text(order.dropoffAddress,
                              style: Theme.of(context).textTheme.labelSmall),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
