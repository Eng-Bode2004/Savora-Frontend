import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/theme_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../home/screens/customer_home_screen.dart';
import '../orders/screens/orders_screen.dart';
import '../cart/screens/cart_screen.dart';
import '../profile/screens/profile_screen.dart';

const _kAccent = Color(0xFFE8A838);

class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _currentIndex = 0;

  bool get _isDarkMode => themeModeNotifier.value == ThemeMode.dark;

  final _pages = const [
    CustomerHomeScreen(),
    OrdersScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    themeModeNotifier.addListener(_onThemeChange);
  }

  @override
  void dispose() {
    themeModeNotifier.removeListener(_onThemeChange);
    super.dispose();
  }

  void _onThemeChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        isDark: _isDarkMode,
        onTap: (i) {
          HapticFeedback.selectionClick();
          setState(() => _currentIndex = i);
        },
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.currentIndex,
    required this.isDark,
    required this.onTap,
  });

  final int currentIndex;
  final bool isDark;
  final ValueChanged<int> onTap;

  Color get _cardColor => isDark ? AppColors.glass : Colors.white;
  Color get _subTextColor => isDark ? AppColors.creamDim : const Color(0xFF8A8A8A);
  Color get _fieldBorderColor =>
      isDark ? AppColors.glassBorder : const Color(0xFFE8E4DE);
  Color get _shadowColor =>
      isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.06);

  static const _items = [
    (Icons.home_rounded, 'Home'),
    (Icons.receipt_long_rounded, 'Orders'),
    (Icons.shopping_cart_rounded, 'Cart'),
    (Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        border: Border(top: BorderSide(color: _fieldBorderColor, width: 0.5)),
        boxShadow: [
          BoxShadow(color: _shadowColor, blurRadius: 16, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final selected = i == currentIndex;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                      decoration: BoxDecoration(
                        color: selected
                            ? _kAccent.withValues(alpha: isDark ? 0.2 : 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _items[i].$1,
                        size: 23,
                        color: selected ? _kAccent : _subTextColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _items[i].$2,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 10,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? _kAccent : _subTextColor,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

