import 'package:flutter_riverpod/flutter_riverpod.dart';

final driverAuthProvider =
    StateNotifierProvider<DriverAuthNotifier, bool>((ref) {
  return DriverAuthNotifier();
});

class DriverAuthNotifier extends StateNotifier<bool> {
  DriverAuthNotifier() : super(false);

  void login() {
    state = true;
  }

  void logout() {
    state = false;
  }
}
