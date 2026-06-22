import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:savora_app/features/driver/providers/driver_state.dart';

class DriverNotificationsScreen extends ConsumerWidget {
  const DriverNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(driverNotificationsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
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
        actions: [
          TextButton(
            onPressed: () =>
                ref.read(driverNotificationsProvider.notifier).markAllAsRead(),
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Text('No notifications',
                  style: Theme.of(context).textTheme.bodyLarge))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final n = notifications[index];
                final IconData iconData;
                switch (n.icon) {
                  case 'star':
                    iconData = Icons.star;
                  case 'local_pizza':
                    iconData = Icons.local_pizza;
                  default:
                    iconData = Icons.notifications;
                }

                return Dismissible(
                  key: Key(n.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    ref
                        .read(driverNotificationsProvider.notifier)
                        .removeNotification(n.id);
                  },
                  child: Container(
                    color: n.read
                        ? Colors.transparent
                        : cs.primaryContainer.withOpacity(0.05),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: n.read
                            ? cs.surfaceContainerHighest
                            : cs.primaryContainer.withOpacity(0.2),
                        child: Icon(iconData,
                            color: n.read ? cs.onSurfaceVariant : cs.primary),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(n.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: n.read
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                  )),
                          Text(n.time,
                              style: Theme.of(context).textTheme.labelSmall),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(n.body,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: n.read
                                      ? cs.onSurfaceVariant
                                      : cs.onSurface,
                                )),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
