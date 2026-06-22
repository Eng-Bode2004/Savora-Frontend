import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:savora_app/features/driver/dashboard/driver_dashboard_screen.dart';
import 'package:savora_app/features/driver/orders/driver_available_orders_screen.dart';
import 'package:savora_app/features/driver/orders/driver_order_request_screen.dart';
import 'package:savora_app/features/driver/orders/driver_order_history_screen.dart';
import 'package:savora_app/features/driver/delivery_active/driver_active_delivery_screen.dart';
import 'package:savora_app/features/driver/map/driver_map_tracking_screen.dart';
import 'package:savora_app/features/driver/earnings/driver_earnings_screen.dart';
import 'package:savora_app/features/driver/profile/driver_profile_screen.dart';
import 'package:savora_app/features/driver/notifications/driver_notifications_screen.dart';


// Root tabs for the Driver module — must match paths used in [DriverShell]
const _driverRootTabs = {
  '/driver/dashboard',
  '/driver/orders',
  '/driver/earnings',
  '/driver/profile',
};

/// Shell scaffold with Driver bottom navigation bar.
///
/// Wraps the driver ShellRoute children.  [PopScope] prevents accidental
/// exit via the Android back button on root tabs.
class DriverShell extends ConsumerWidget {
  final Widget child;
  const DriverShell({super.key, required this.child});

  int _calculateIndex(String location) {
    if (location.startsWith('/driver/dashboard')) return 0;
    if (location.startsWith('/driver/orders')) return 1;
    if (location.startsWith('/driver/earnings')) return 2;
    if (location.startsWith('/driver/profile')) return 3;

    // fallback
    return 0;
  }

  bool _isRootTab(String location) {
    const roots = [
      '/driver/dashboard',
      '/driver/orders',
      '/driver/earnings',
      '/driver/profile',
    ];

    return roots.any((r) => location.startsWith(r));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _calculateIndex(location);
    final isRootTab = _isRootTab(location);

    return PopScope(
      canPop: !isRootTab,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (!isRootTab && context.canPop()) context.pop();
      },
      child: Scaffold(
        body: child,

        // --- PREMIUM NAVBAR ---
        bottomNavigationBar: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;

            return NavigationBar(
              selectedIndex: currentIndex,
              height: 68,
              elevation: 0,

              // 🔥 IMPORTANT: makes it adapt to dark/light automatically
              backgroundColor: colorScheme.surface,
              surfaceTintColor: Colors.transparent,

              indicatorColor: colorScheme.primary.withValues(alpha: 0.15),

              onDestinationSelected: (index) {
                switch (index) {
                  case 0:
                    context.go('/driver/dashboard');
                    break;
                  case 1:
                    context.go('/driver/orders');
                    break;
                  case 2:
                    context.go('/driver/earnings');
                    break;
                  case 3:
                    context.go('/driver/profile');
                    break;
                }
              },

              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.local_shipping_outlined),
                  selectedIcon: Icon(Icons.local_shipping),
                  label: 'Orders',
                ),
                NavigationDestination(
                  icon: Icon(Icons.payments_outlined),
                  selectedIcon: Icon(Icons.payments),
                  label: 'Earnings',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// All driver routes.  Consumed by the top-level router via [driverRoutes].
///
/// Each path is prefixed with `/driver/` so there are zero conflicts with the
/// existing customer or chef route namespaces.
List<RouteBase> get driverRoutes => [
      ShellRoute(
        builder: (context, state, child) => DriverShell(child: child),
        routes: [
          GoRoute(
            path: '/driver/dashboard',
            builder: (context, state) => const DriverDashboardScreen(),
          ),
          GoRoute(
            path: '/driver/orders',
            builder: (context, state) => const DriverAvailableOrdersScreen(),
            routes: [
              GoRoute(
                path: 'request/:id',
                builder: (context, state) => DriverOrderRequestScreen(
                    orderId: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/driver/active_delivery',
            builder: (context, state) => const DriverActiveDeliveryScreen(),
            routes: [
              GoRoute(
                path: 'map',
                builder: (context, state) => const DriverMapTrackingScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/driver/earnings',
            builder: (context, state) => const DriverEarningsScreen(),
          ),
          GoRoute(
            path: '/driver/history',
            builder: (context, state) => const DriverOrderHistoryScreen(),
          ),
          GoRoute(
            path: '/driver/profile',
            builder: (context, state) => const DriverProfileScreen(),
          ),
          GoRoute(
            path: '/driver/notifications',
            builder: (context, state) => const DriverNotificationsScreen(),
          ),
        ],
      ),
    ];

/// Convenience provider: standalone GoRouter for running the Driver module
/// independently (e.g. driver-only builds or deep-link testing).
///
/// In the integrated app, [driverRoutes] is spliced into the main router instead.
final driverRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/driver/dashboard',
    routes: driverRoutes,
  );
});
