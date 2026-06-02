import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../planner/screens/group_meal_planner_screen.dart';
import '../../menu/screens/dish_detail_screen.dart';

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
  int _categoryIndex = 0;

  bool _isDarkMode = themeModeNotifier.value == ThemeMode.dark;

  // ── data ──
  static const List<_Category> _categories = [
    _Category('Mahshi', Icons.local_fire_department_rounded),
    _Category('Koshary', Icons.ramen_dining_rounded),
    _Category('Grills', Icons.outdoor_grill_rounded),
    _Category('Desserts', Icons.cake_rounded),
    _Category('Drinks', Icons.local_cafe_rounded),
  ];

  static const List<_Special> _specials = [
    _Special('Royal Lamb Fattah',
        'Slow-cooked lamb with garlic-vinegar rice', 'EGP 245', 4.9, Color(0xFF8B3A1E)),
    _Special('Signature Koshary',
        'Lentils, rice, pasta, crispy onions', 'EGP 95', 4.8, Color(0xFFC25A2E)),
  ];

  static const List<_Dish> _popular = [
    _Dish('Cairo Grills', 4.5, '25–35 min', 'EGP 15.00', Color(0xFF6B3410)),
    _Dish('Green Nile Bowl', 4.6, '20–30 min', 'free', Color(0xFF3E6B4A)),
    _Dish("Grandma's Om Ali", 4.7, '15–25 min', 'EGP 10.00', Color(0xFF9A5B2A)),
    _Dish('The Grill Hub', 4.4, '30–40 min', 'EGP 20.00', Color(0xFF7A2E1E)),
  ];

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
                                const SizedBox(height: 24),
                                _reveal(0.10, 0.40,
                                    _buildSectionHeader('Categories', 'View all')),
                                const SizedBox(height: 14),
                                _reveal(0.15, 0.50, _buildCategories()),
                                const SizedBox(height: 22),
                                _reveal(0.22, 0.55, _buildGroupBanner()),
                                const SizedBox(height: 26),
                                _reveal(0.30, 0.60,
                                    _buildSectionHeader("Chef's Specials", null,
                                        subtitle: 'Handpicked Egyptian delicacies')),
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
  Widget _buildSectionHeader(String title, String? action, {String? subtitle}) {
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
          Text(
            action,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _kAccent,
            ),
          ),
      ],
    );
  }

  // ════════ CATEGORIES ════════
  Widget _buildCategories() {
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final c = _categories[i];
          final selected = i == _categoryIndex;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _categoryIndex = i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 72,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(colors: [_kAccentLight, _kAccentDark])
                    : null,
                color: selected ? null : _cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? Colors.transparent : _fieldBorderColor,
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: selected ? _kAccent.withValues(alpha: 0.3) : _shadowColor,
                    blurRadius: selected ? 14 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    c.icon,
                    size: 24,
                    color: selected ? const Color(0xFF2C1810) : _kAccent,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    c.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: selected ? const Color(0xFF2C1810) : _textColor,
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

  // ════════ CHEF'S SPECIALS ════════
  Widget _buildSpecialsCarousel() {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _specials.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) => _buildSpecialCard(_specials[i]),
      ),
    );
  }

  Widget _buildSpecialCard(_Special s) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => ProductDetailScreen(
              name: s.name,
              description: s.desc,
              basePrice: int.tryParse(s.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
              rating: s.rating,
              tone: s.tone,
            ),
            transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
            transitionDuration: const Duration(milliseconds: 350),
          ),
        );
      },
      child: Container(
      width: 290,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _shadowColor,
            blurRadius: 20,
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
              'assets/images/${s.name}.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [s.tone, s.tone.withValues(alpha: 0.7)],
                  ),
                ),
                child: const Center(child: Text('🍛', style: TextStyle(fontSize: 56))),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.78),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
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
                      s.rating.toString(),
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.name,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s.desc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11.5,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        s.price,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _kAccentLight,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => HapticFeedback.mediumImpact(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [_kAccentLight, _kAccentDark]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2C1810),
                            ),
                          ),
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

  // ════════ POPULAR GRID ════════
  Widget _buildPopularGrid() {
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
            _buildDishCard(_popular[i]),
          ),
          childCount: _popular.length,
        ),
      ),
    );
  }

  Widget _buildDishCard(_Dish d) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => ProductDetailScreen(
              name: d.name,
              rating: d.rating,
              prepTime: d.time,
              tone: d.tone,
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
            BoxShadow(
              color: _shadowColor,
              blurRadius: 16,
              spreadRadius: -4,
              offset: const Offset(0, 8),
            ),
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
                    child: Image.asset(
                      'assets/images/${d.name}.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [d.tone, d.tone.withValues(alpha: 0.65)],
                          ),
                        ),
                        child: const Center(
                            child: Text('🍽️', style: TextStyle(fontSize: 34))),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        d.time,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_border_rounded,
                          size: 15, color: Color(0xFFE0533D)),
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
                  Text(
                    d.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: _kAccent),
                      const SizedBox(width: 3),
                      Text(
                        d.rating.toString(),
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _textColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.circle, size: 3, color: _subTextColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          d.fee == 'free' ? 'Free delivery' : '${d.fee} delivery',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11,
                            color: _subTextColor,
                          ),
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
}

// ════════════════════════════════════════════════════════
// DATA MODELS
// ════════════════════════════════════════════════════════
class _Category {
  const _Category(this.name, this.icon);
  final String name;
  final IconData icon;
}

class _Special {
  const _Special(this.name, this.desc, this.price, this.rating, this.tone);
  final String name, desc, price;
  final double rating;
  final Color tone;
}

class _Dish {
  const _Dish(this.name, this.rating, this.time, this.fee, this.tone);
  final String name, time, fee;
  final double rating;
  final Color tone;
}
