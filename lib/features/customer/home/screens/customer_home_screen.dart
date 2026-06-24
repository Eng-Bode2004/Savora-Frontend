import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savora_app/core/network/savora_api.dart';
import 'package:savora_app/state/providers/auth_provider.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../planner/screens/group_meal_planner_screen.dart';
import '../../menu/screens/dish_detail_screen.dart';
import '../../menu/screens/category_screen.dart';
import '../../menu/services/menu_service.dart';
import '../../auth/screens/customer_verification_screen.dart';

const _kAccent = Color(0xFFE8A838);
const _kAccentLight = Color(0xFFF0B040);
const _kAccentDark = Color(0xFFD4952E);

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  List<MenuItem> _menuCategories = [];
  List<MenuItem> _recommendedDishes = [];
  List<MenuItem> _popularDishes = [];
  bool _loadingMenu = true;

  bool get _isDarkMode => themeModeNotifier.value == ThemeMode.dark;
  bool _isVerified = authState.profileData?['Is_Verified'] == true;
  bool _loadingProfile = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProfileIfNeeded();
    _loadMenuData();
  }

  Future<void> _loadProfileIfNeeded() async {
    if (_loadingProfile || _isVerified) return;
    final userId = authState.userId;
    final profileId = authState.profileId;
    if (userId == null || profileId == null) return;
    setState(() => _loadingProfile = true);
    try {
      final data = await SavoraApi.getCustomerProfileByAuthId(userId);
      final profile = data['response'] as Map<String, dynamic>?;
      if (profile != null) {
        authState.setProfileData(profile);
        setState(() => _isVerified = profile['Is_Verified'] == true);
      }
    } catch (_) {}
    setState(() => _loadingProfile = false);
  }

  Future<void> _openVerification() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CustomerVerificationScreen(),
      ),
    );
    if (result == true) {
      _loadProfileIfNeeded();
    }
  }

  Future<void> _loadMenuData() async {
    if (!_loadingMenu) return;
    try {
      await MenuService.loadLanguage();
      final cats = await MenuService.getCategories();
      final recommended = await MenuService.getRecommendedDishes();
      final popular = await MenuService.getPopularDishes();
      if (mounted) {
        setState(() {
          _menuCategories = cats;
          _recommendedDishes = recommended;
          _popularDishes = popular;
          _loadingMenu = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingMenu = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  double _t(double start, double end) {
    final v = _entrance.value.clamp(start, end);
    return ((v - start) / (end - start)).clamp(0.0, 1.0);
  }

  static double _ease(double t) => 1.0 - math.pow(1.0 - t, 3.5).toDouble();

  Widget _reveal(double start, double end, Widget child, {double dy = 22}) {
    final t = _ease(_t(start, end));
    return Opacity(
      opacity: t,
      child: Transform.translate(offset: Offset(0, (1 - t) * dy), child: child),
    );
  }

  // ── theme ──
  Color get _bgColor => _isDarkMode ? AppColors.espresso : const Color(0xFFFDFBF7);
  Color get _bgColor2 => _isDarkMode ? AppColors.espresso : const Color(0xFFF7F4EE);
  Color get _textColor => _isDarkMode ? AppColors.cream : const Color(0xFF1A1410);
  Color get _subTextColor => _isDarkMode ? AppColors.creamDim : const Color(0xFF8A8A8A);
  Color get _cardColor => _isDarkMode ? AppColors.glass : Colors.white;
  Color get _fieldBgColor => _isDarkMode ? AppColors.glass : const Color(0xFFF5F3EF);
  Color get _fieldBorderColor =>
      _isDarkMode ? AppColors.glassBorder : const Color(0xFFE8E4DE);
  Color get _shadowColor =>
      _isDarkMode ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.06);

  @override
  Widget build(BuildContext context) {
    final isRtl = AppLocalizations.of(context).locale.languageCode == 'ar';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _bgColor,
        body: Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Stack(
            children: [
              _buildBackground(),
              SafeArea(
                bottom: false,
                child: AnimatedBuilder(
                  animation: _entrance,
                  builder: (context, _) {
                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _reveal(0.0, 0.25, _buildTopBar()),
                                const SizedBox(height: 18),
                                _reveal(0.05, 0.35, _buildSearchBar()),
                                if (!_isVerified) ...[
                                  const SizedBox(height: 14),
                                  _reveal(0.07, 0.37, _buildVerificationBanner()),
                                  const SizedBox(height: 14),
                                ] else
                                  const SizedBox(height: 24),
                                _reveal(0.10, 0.40,
                                    _buildSectionHeader('Categories', 'View all', onAction: () {
                                      Navigator.of(context).push(
                                        PageRouteBuilder(
                                          pageBuilder: (_, __, ___) => const CategoryScreen(),
                                          transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
                                          transitionDuration: const Duration(milliseconds: 350),
                                        ),
                                      );
                                    })),
                                const SizedBox(height: 14),
                                _reveal(0.15, 0.50, _buildCategories()),
                                const SizedBox(height: 22),
                                _reveal(0.22, 0.55, _buildGroupBanner()),
                                const SizedBox(height: 26),
                                _reveal(0.30, 0.60,
                                    _buildSectionHeader("Chef's Specials", null,
                                        subtitle: 'Recommended for you')),
                                const SizedBox(height: 14),
                              ],
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: _reveal(0.35, 0.68, _buildSpecialsCarousel()),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 26, 20, 14),
                            child: _reveal(0.45, 0.78,
                                _buildSectionHeader('Popular Near You', 'View Map')),
                          ),
                        ),
                        _buildPopularGrid(),
                        const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════ BACKGROUND ════════
  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: const Alignment(-0.5, -1.0),
          end: const Alignment(0.5, 1.2),
          colors: [_bgColor, _bgColor2],
        ),
      ),
    );
  }

  // ════════ TOP BAR ════════
  Widget _buildTopBar() {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_kAccentLight, _kAccentDark]),
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                color: _kAccent.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Text('🍴', style: TextStyle(fontSize: 18)),
        ),
        const SizedBox(width: 10),
        Text(
          'Savora',
          style: TextStyle(
            fontFamily: 'Playfair Display',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
        const Spacer(),
        _iconButton(Icons.notifications_none_rounded, badge: true, onTap: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const NotificationsScreen(),
              transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
              transitionDuration: const Duration(milliseconds: 350),
            ),
          );
        }),
        const SizedBox(width: 10),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _kAccent.withValues(alpha: 0.5), width: 1.5),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/avatar.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: _fieldBgColor,
                child: Icon(Icons.person_rounded, size: 20, color: _subTextColor),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _iconButton(IconData icon, {bool badge = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _cardColor,
              shape: BoxShape.circle,
              border: Border.all(color: _fieldBorderColor, width: 0.5),
              boxShadow: [
                BoxShadow(color: _shadowColor, blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Icon(icon, size: 20, color: _textColor),
          ),
          if (badge)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _kAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: _bgColor, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ════════ VERIFICATION BANNER ════════
  Widget _buildVerificationBanner() {
    return GestureDetector(
      onTap: _openVerification,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _kAccent.withValues(alpha: 0.15),
              _kAccent.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _kAccent.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _kAccent.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_outlined,
                  color: _kAccent, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complete your profile',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _isDarkMode
                          ? AppColors.cream
                          : const Color(0xFF2C1810),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Add payment, address & food preferences',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      color: _subTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _kAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_rounded,
                  color: Color(0xFF2C1810), size: 18),
            ),
          ],
        ),
      ),
    );
  }

  // ════════ SEARCH ════════
  Widget _buildSearchBar() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _fieldBorderColor, width: 0.5),
        boxShadow: [
          BoxShadow(color: _shadowColor, blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 22, color: _subTextColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Find Koshary, Grills or Om Ali…',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                color: _subTextColor.withValues(alpha: 0.7),
              ),
            ),
          ),
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _kAccent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.tune_rounded, size: 18, color: _kAccent),
          ),
        ],
      ),
    );
  }

  // ════════ SECTION HEADER ════════
  Widget _buildSectionHeader(String title, String? action, {String? subtitle, VoidCallback? onAction}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textColor,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    color: _subTextColor,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _kAccent,
              ),
            ),
          ),
      ],
    );
  }

  // ════════ CATEGORIES ════════
  Widget _buildCategories() {
    if (_loadingMenu) {
      return SizedBox(
        height: 84,
        child: Center(child: CircularProgressIndicator(color: _kAccent.withValues(alpha: 0.5))),
      );
    }
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _menuCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final c = _menuCategories[i];
          final hasImage = c.image != null && c.image!.isNotEmpty;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const CategoryScreen(),
                  transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
                  transitionDuration: const Duration(milliseconds: 350),
                ),
              );
            },
            child: Container(
              width: 82,
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _fieldBorderColor, width: 0.5),
                boxShadow: [
                  BoxShadow(color: _shadowColor, blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasImage)
                    Image.network(c.image!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _catIconFallback())
                  else
                    _catIconFallback(),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.65)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 6, right: 6, bottom: 6,
                    child: Text(
                      c.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'DM Sans', fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _catIconFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_kAccentLight.withValues(alpha: 0.3), _kAccentDark.withValues(alpha: 0.2)]),
      ),
      child: const Center(child: Icon(Icons.restaurant_menu_rounded, size: 28, color: _kAccent)),
    );
  }

  // ════════ GATHER & FEAST — group booking banner ════════
  Widget _buildGroupBanner() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const GroupMealPlannerScreen(),
            transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
            transitionDuration: const Duration(milliseconds: 350),
          ),
        );
      },
      child: Container(
        height: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: _shadowColor,
              blurRadius: 22,
              spreadRadius: -4,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/group_feast.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF8B5A2B), Color(0xFF4A2F1A)],
                    ),
                  ),
                  child: const Center(
                    child: Text('🍽️', style: TextStyle(fontSize: 60)),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.72),
                      Colors.black.withValues(alpha: 0.35),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_kAccentLight, _kAccentDark]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _kAccent.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: Color(0xFF2C1810),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'Gather & Feast',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Group bookings made easy with AI suggestions.',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12.5,
                        color: Colors.white.withValues(alpha: 0.88),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [_kAccentLight, _kAccentDark]),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _kAccent.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Plan a Group Meal',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2C1810),
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded,
                              size: 16, color: Color(0xFF2C1810)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════ CHEF'S SPECIALS / RECOMMENDED ════════
  Widget _buildSpecialsCarousel() {
    if (_loadingMenu) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator(color: _kAccent)),
      );
    }
    if (_recommendedDishes.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _recommendedDishes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) => _buildRecommendedCard(_recommendedDishes[i]),
      ),
    );
  }

  Widget _buildRecommendedCard(MenuItem dish) {
    final hasImage = dish.image != null && dish.image!.isNotEmpty;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => ProductDetailScreen(
              dishId: dish.id,
              name: dish.name,
              description: dish.description ?? 'Recommended dish just for you.',
              basePrice: (dish.price ?? 0).toInt(),
              rating: dish.rating ?? 0,
              image: dish.image ?? '',
              tone: _kAccent,
              chefId: dish.chefId,
            ),
            transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
            transitionDuration: const Duration(milliseconds: 350),
          ),
        );
      },
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(color: _shadowColor, blurRadius: 20, spreadRadius: -4, offset: const Offset(0, 10)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasImage)
                Image.network(dish.image!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _recPlaceholder())
              else
                _recPlaceholder(),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.15), Colors.black.withValues(alpha: 0.78)],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
              Positioned(
                top: 12, right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: _kAccent),
                      const SizedBox(width: 3),
                      Text(
                        (dish.rating ?? 0).toStringAsFixed(1),
                        style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16, right: 16, bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dish.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontFamily: 'DM Sans', fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 2),
                    if (dish.description != null)
                      Text(dish.description!, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontFamily: 'DM Sans', fontSize: 11.5, color: Colors.white.withValues(alpha: 0.85))),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (dish.price != null)
                          Text('EGP ${dish.price!.toInt()}',
                            style: const TextStyle(fontFamily: 'DM Sans', fontSize: 15, fontWeight: FontWeight.w700, color: _kAccentLight)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => HapticFeedback.mediumImpact(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [_kAccentLight, _kAccentDark]),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text('Add to Cart',
                              style: TextStyle(fontFamily: 'DM Sans', fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2C1810))),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _recPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_kAccentLight.withValues(alpha: 0.4), _kAccentDark.withValues(alpha: 0.3)]),
      ),
      child: const Center(child: Icon(Icons.restaurant_rounded, size: 56, color: _kAccent)),
    );
  }

  // ════════ POPULAR GRID ════════
  Widget _buildPopularGrid() {
    if (_loadingMenu) {
      return SliverToBoxAdapter(
        child: Container(
          height: 200,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(color: _kAccent),
        ),
      );
    }
    if (_popularDishes.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 14,
          childAspectRatio: 0.78,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) => _reveal(
            0.50 + i * 0.04,
            0.88 + i * 0.04,
            _buildPopularCard(_popularDishes[i]),
          ),
          childCount: _popularDishes.length,
        ),
      ),
    );
  }

  Widget _buildPopularCard(MenuItem d) {
    final hasImage = d.image != null && d.image!.isNotEmpty;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => ProductDetailScreen(
              dishId: d.id,
              name: d.name,
              description: d.description ?? 'Popular dish',
              basePrice: (d.price ?? 0).toInt(),
              rating: d.rating ?? 0,
              image: d.image ?? '',
              tone: _kAccent,
              chefId: d.chefId,
            ),
            transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
            transitionDuration: const Duration(milliseconds: 350),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _fieldBorderColor, width: 0.5),
          boxShadow: [
            BoxShadow(color: _shadowColor, blurRadius: 16, spreadRadius: -4, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: hasImage
                        ? Image.network(d.image!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _popPlaceholder())
                        : _popPlaceholder(),
                  ),
                  if (d.rating != null)
                    Positioned(
                      left: 8, top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 11, color: _kAccent),
                            const SizedBox(width: 2),
                            Text(d.rating!.toStringAsFixed(1),
                              style: const TextStyle(fontFamily: 'DM Sans', fontSize: 9.5, fontWeight: FontWeight.w600, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    right: 8, top: 8,
                    child: Container(
                      width: 26, height: 26,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_border_rounded, size: 15, color: Color(0xFFE0533D)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontFamily: 'DM Sans', fontSize: 14, fontWeight: FontWeight.w700, color: _textColor)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (d.price != null) ...[
                        Text('EGP ${d.price!.toInt()}',
                          style: TextStyle(fontFamily: 'DM Sans', fontSize: 12, fontWeight: FontWeight.w700, color: _kAccentDark)),
                        const SizedBox(width: 6),
                      ],
                      Icon(Icons.circle, size: 3, color: _subTextColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          d.rating != null ? '${d.rating!.toStringAsFixed(1)} ★' : '',
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontFamily: 'DM Sans', fontSize: 11, color: _subTextColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _popPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_kAccentLight.withValues(alpha: 0.3), _kAccentDark.withValues(alpha: 0.2)]),
      ),
      child: const Center(child: Icon(Icons.restaurant_rounded, size: 30, color: _kAccent)),
    );
  }
}


