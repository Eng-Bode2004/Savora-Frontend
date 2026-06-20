import 'package:flutter/material.dart';
import 'package:savora_app/core/theme/app_colors.dart';
import '../widgets/chef_top_bar.dart';
import '../widgets/chef_bottom_nav.dart';
import '../dashboard/screens/partner_dashboard_screen.dart';
import '../menu_submission/screens/menu_management_screen.dart';
import '../earnings/screens/earnings_insights_screen.dart';
import '../auth/screens/partner_verification_screen.dart';

/// Bottom-navigation host for the Chef module's four top-level tabs:
/// Orders (dashboard), Menu, Earnings, and Profile (verification status).
///
/// Mirrors `CustomerShell` in spirit: a single [Scaffold] owns the app bar
/// and bottom nav, while an [IndexedStack] preserves each tab's state as
/// the chef switches between them.
class ChefShell extends StatefulWidget {
  const ChefShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<ChefShell> createState() => _ChefShellState();
}

class _ChefShellState extends State<ChefShell> {
  late int _currentIndex = widget.initialIndex;

  static const List<Widget> _tabs = [
    PartnerDashboardScreen(),
    MenuManagementScreen(),
    EarningsInsightsScreen(),
    PartnerVerificationScreen(),
  ];

  static const List<String> _titles = [
    'Savora',
    'Savora',
    'Savora',
    'Savora Chef'
  ];

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      backgroundColor: AppColors.surfaceSunkenOf(brightness),
      appBar: ChefTopBar(
        title: _titles[_currentIndex],
        showNotificationBell: _currentIndex == 0,
      ),
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: ChefBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
