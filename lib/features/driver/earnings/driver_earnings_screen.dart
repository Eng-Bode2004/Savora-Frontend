import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savora_app/features/driver/providers/driver_state.dart';
import 'package:savora_app/features/driver/services/driver_theme.dart';

class DriverEarningsScreen extends ConsumerWidget {
  const DriverEarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(driverUserProvider);
    final transactions = ref.watch(driverTransactionsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Earnings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: cs.primaryContainer.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: cs.primary.withOpacity(0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Text('CURRENT BALANCE',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                  Text('\$${userState.balance.toStringAsFixed(2)}',
                      style: Theme.of(context)
                          .textTheme
                          .displayLarge
                          ?.copyWith(color: cs.primary)),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: userState.balance > 0
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Payout initiated to bank account.')),
                            );
                            ref
                                .read(driverUserProvider.notifier)
                                .withdrawBalance();
                          }
                        : null,
                    child: const Text('Cash Out Now'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text('Recent Activity',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ...transactions.map((tx) {
            final isNegative = tx.amount < 0;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: cs.surfaceContainerHighest,
                child: Icon(
                  tx.type == 'delivery'
                      ? Icons.local_shipping
                      : (tx.type == 'bonus' ? Icons.star : Icons.account_balance),
                  color: tx.type == 'payout' ? cs.onSurfaceVariant : cs.primary,
                  size: 20,
                ),
              ),
              title: Text(tx.title,
                  style: Theme.of(context).textTheme.bodyLarge),
              subtitle: Text(tx.subtitle,
                  style: Theme.of(context).textTheme.labelSmall),
              trailing: Text(
                '${isNegative ? '-' : '+'}\$${tx.amount.abs().toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isNegative ? cs.onSurfaceVariant : cs.primary,
                    ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
