import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savora_app/features/driver/models/order.dart';
import 'package:savora_app/features/driver/models/notification.dart';
import 'package:savora_app/features/driver/models/transaction.dart';
import 'package:savora_app/features/driver/models/dummy_data.dart';
import 'package:savora_app/core/network/savora_api.dart';

// ── User State (Online status, balance) ────────────────────────────────────────
class DriverUserState {
  final bool isOnline;
  final double balance;

  DriverUserState({required this.isOnline, required this.balance});

  DriverUserState copyWith({bool? isOnline, double? balance}) {
    return DriverUserState(
      isOnline: isOnline ?? this.isOnline,
      balance: balance ?? this.balance,
    );
  }
}

final driverUserProvider =
    StateNotifierProvider<DriverUserNotifier, DriverUserState>((ref) {
  return DriverUserNotifier();
});

class DriverUserNotifier extends StateNotifier<DriverUserState> {
  DriverUserNotifier()
      : super(DriverUserState(isOnline: false, balance: 1240.5));

  void toggleOnline() {
    state = state.copyWith(isOnline: !state.isOnline);
  }

  void addBalance(double amount) {
    state = state.copyWith(balance: state.balance + amount);
  }

  void withdrawBalance() {
    state = state.copyWith(balance: 0.0);
  }
}

// ── Orders Provider ───────────────────────────────────────────────────────────
final driverOrdersProvider =
    StateNotifierProvider<DriverOrdersNotifier, List<DriverOrder>>((ref) {
  return DriverOrdersNotifier();
});

class DriverOrdersNotifier extends StateNotifier<List<DriverOrder>> {
  DriverOrdersNotifier() : super([]) {
    fetchAvailableOrders();
  }

  Future<void> fetchAvailableOrders() async {
    try {
      final res = await SavoraApi.getAvailableOrdersForDriver();
      final orders = (res['orders'] as List<dynamic>?)
          ?.map((o) => DriverOrder.fromJson(o))
          .toList() ?? [];
      state = orders;
    } catch (_) {}
  }

  Future<void> acceptOrder(String orderId) async {
    try {
      // For testing, assuming dummy driver ID or backend extracts from token
      await SavoraApi.acceptOrderDriver(orderId, 'driver_id_here');
      state = state.map((o) {
        if (o.id == orderId) {
          return o.copyWith(status: 'active', deliveryStep: 'accepted');
        }
        if (o.status == 'active') {
          return o.copyWith(status: 'available');
        }
        return o;
      }).toList();
    } catch (_) {}
  }

  void rejectOrder(String orderId) {
    state = state
        .map((o) => o.id == orderId ? o.copyWith(status: 'rejected') : o)
        .toList();
  }

  void updateDeliveryStep(String orderId, String step) {
    state = state
        .map((o) => o.id == orderId ? o.copyWith(deliveryStep: step) : o)
        .toList();
  }

  Future<void> completeOrder(String orderId) async {
    try {
      await SavoraApi.deliverOrderDriver(orderId);
      state = state.map((o) {
        if (o.id == orderId) {
          return o.copyWith(status: 'completed', deliveryStep: 'delivered');
        }
        return o;
      }).toList();
    } catch (_) {}
  }
}

// ── Notifications Provider ────────────────────────────────────────────────────
final driverNotificationsProvider = StateNotifierProvider<
    DriverNotificationsNotifier, List<DriverNotification>>((ref) {
  return DriverNotificationsNotifier();
});

class DriverNotificationsNotifier
    extends StateNotifier<List<DriverNotification>> {
  DriverNotificationsNotifier() : super(mockDriverNotifications);

  void addNotification(DriverNotification notification) {
    state = [notification, ...state];
  }

  void markAllAsRead() {
    state = state.map((n) => n.copyWith(read: true)).toList();
  }

  void removeNotification(String notifId) {
    state = state.where((n) => n.id != notifId).toList();
  }
}

// ── Transactions Provider ─────────────────────────────────────────────────────
final driverTransactionsProvider = StateNotifierProvider<
    DriverTransactionsNotifier, List<DriverTransaction>>((ref) {
  return DriverTransactionsNotifier();
});

class DriverTransactionsNotifier
    extends StateNotifier<List<DriverTransaction>> {
  DriverTransactionsNotifier() : super(mockDriverTransactions);

  void addTransaction(DriverTransaction tx) {
    state = [tx, ...state];
  }
}
