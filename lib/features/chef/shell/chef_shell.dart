import 'package:flutter/material.dart';
import 'package:savora_app/core/theme/app_colors.dart';
import 'package:savora_app/state/providers/auth_provider.dart';
import '../widgets/chef_top_bar.dart';
import '../widgets/chef_bottom_nav.dart';
import '../dashboard/screens/partner_dashboard_screen.dart';
import '../menu_submission/screens/menu_management_screen.dart';
import '../earnings/screens/earnings_insights_screen.dart';
import '../profile/screens/chef_profile_screen.dart';
import '../auth/screens/partner_verification_screen.dart';

class ChefShell extends StatefulWidget {
  const ChefShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<ChefShell> createState() => _ChefShellState();
}

class _ChefShellState extends State<ChefShell> {
  late int _currentIndex = widget.initialIndex;

  List<Widget> get _tabs => [
    const PartnerDashboardScreen(),
    const MenuManagementScreen(),
    const EarningsInsightsScreen(),
    _verified ? const ChefProfileScreen() : const PartnerVerificationScreen(),
  ];

  static const List<String> _titles = [
    'Savora',
    'Savora',
    'Savora',
    'Savora Chef'
  ];

  bool get _verified => authState.isVerified;

  void _onNavTap(int i) {
    if (!_verified && i != 3) return;
    setState(() => _currentIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    final List<Widget> tabs = _tabs;

    return Scaffold(
      backgroundColor: AppColors.surfaceSunkenOf(brightness),
      appBar: ChefTopBar(
        title: _verified ? _titles[_currentIndex] : 'Complete Verification',
        showNotificationBell: _currentIndex == 0 && _verified,
      ),
      body: _verified
          ? IndexedStack(index: _currentIndex, children: tabs)
          : const PartnerVerificationScreen(),
      bottomNavigationBar: ChefBottomNav(
        currentIndex: _verified ? _currentIndex : 3,
        onTap: _onNavTap,
        lockedIndices: _verified ? const {} : const {0, 1, 2},
      ),
    );
  }
}
