import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../state/cart_state.dart';

const _kAccent = Color(0xFFE8A838);
const _kAccentLight = Color(0xFFF0B040);
const _kAccentDark = Color(0xFFD4952E);

class PersonalizedFeastScreen extends StatefulWidget {
  const PersonalizedFeastScreen({super.key, this.guests = 4});

  final int guests;

  @override
  State<PersonalizedFeastScreen> createState() => _PersonalizedFeastScreenState();
}

class _PersonalizedFeastScreenState extends State<PersonalizedFeastScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _spin;

  bool _isDarkMode = themeModeNotifier.value == ThemeMode.dark;

  static const _total = 'EGP 1,840.00';
  static const _eta = '45–55m';

  final List<_Dish> _feast = [
    _Dish('Mix Grill Platter', 'Kebab, Kofta, and Shish Tawook with garlic dip.',
        'Large Plate', const Color(0xFF7A2E1E), '🍢', 650),
    _Dish('Egyptian Fattah', 'Slow-cooked beef with garlic-vinegar rice and crisp bread.',
        'Family Size', const Color(0xFF8B3A1E), '🍛', 490),
    _Dish('Assorted Mahshi', 'Vine leaves, zucchini, and bell peppers stuffed with herb rice.',
        '24 Pieces', const Color(0xFF3E6B4A), '🫑', 420),
    _Dish('Royal Om Ali', 'Egyptian bread pudding with cream, nuts, and cinnamon.',
        'Shareable Bowl', const Color(0xFF9A5B2A), '🍮', 280),
  ];

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _entrance.dispose();
    _spin.dispose();
    super.dispose();
  }

  double _t(double start, double end) {
    final v = _entrance.value.clamp(start, end);
    return ((v - start) / (end - start)).clamp(0.0, 1.0);
  }

  static double _ease(double t) => 1.0 - math.pow(1.0 - t, 3.5).toDouble();

  Widget _reveal(double start, double end, Widget child, {double dy = 20}) {
    final t = _ease(_t(start, end));
    return Opacity(
      opacity: t,
      child: Transform.translate(offset: Offset(0, (1 - t) * dy), child: child),
    );
  }

  void _regenerate() {
    HapticFeedback.mediumImpact();
    _spin.forward(from: 0);
    _entrance.forward(from: 0);
  }

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
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                          child: _reveal(0.0, 0.22, _buildTopBar()),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _reveal(0.05, 0.30, _buildHeader()),
                                  const SizedBox(height: 24),
                                  _reveal(0.12, 0.38, _buildMenuHeader()),
                                  const SizedBox(height: 14),
                                  for (int i = 0; i < _feast.length; i++) ...[
                                    _reveal(0.16 + i * 0.06, 0.55 + i * 0.06,
                                        _buildDishCard(_feast[i])),
                                    const SizedBox(height: 12),
                                  ],
                                  const SizedBox(height: 10),
                                  _reveal(0.55, 0.90, _buildRegenerateButton()),
                                ],
                              ),
                            ),
                          ),
                        ),
                        _buildFooterBar(),
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

  Widget _buildTopBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => HapticFeedback.lightImpact(),
          child: Icon(Icons.menu_rounded, size: 24, color: _textColor),
        ),
        const Spacer(),
        Text(
          'Savora',
          style: TextStyle(
            fontFamily: 'Playfair Display',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _kAccentDark,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => HapticFeedback.lightImpact(),
          child: Icon(Icons.shopping_cart_outlined, size: 23, color: _textColor),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, size: 16, color: _kAccentDark),
            const SizedBox(width: 6),
            Text(
              'AI CURATED',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: _kAccentDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Your Personalized Feast',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: _textColor,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'A perfectly balanced Egyptian menu optimized for ${widget.guests} guests.',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            height: 1.4,
            color: _subTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuHeader() {
    return Row(
      children: [
        Text(
          'Balanced Menu',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _regenerate,
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _spin,
                builder: (_, child) => Transform.rotate(
                  angle: _spin.value * 2 * math.pi,
                  child: child,
                ),
                child: const Icon(Icons.refresh_rounded, size: 16, color: _kAccentDark),
              ),
              const SizedBox(width: 5),
              const Text(
                'Regenerate',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _kAccentDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDishCard(_Dish d) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _fieldBorderColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: _shadowColor,
            blurRadius: 16,
            spreadRadius: -4,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
            clipBehavior: Clip.antiAlias,
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
                child: Center(child: Text(d.emoji, style: const TextStyle(fontSize: 34))),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.name,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _kAccent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    d.serving,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _kAccentDark,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  d.desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    height: 1.35,
                    color: _subTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegenerateButton() {
    return GestureDetector(
      onTap: _regenerate,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _fieldBgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kAccent.withValues(alpha: 0.5), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome_rounded, size: 18, color: _kAccentDark),
            const SizedBox(width: 8),
            Text(
              'Regenerate Recommendations',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _kAccentDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      decoration: BoxDecoration(
        color: _cardColor,
        border: Border(top: BorderSide(color: _fieldBorderColor, width: 0.5)),
        boxShadow: [
          BoxShadow(color: _shadowColor, blurRadius: 18, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ESTIMATED TOTAL',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: _subTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _total,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _textColor,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Free Delivery',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF35A853),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Arrives in $_eta',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        color: _subTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                for (final d in _feast) {
                  cartState.addItem(
                    CartItem(
                      name: d.name,
                      price: d.price,
                      qty: 1,
                      tone: d.tone,
                      emoji: d.emoji,
                    ),
                  );
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Added entire feast to cart!',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: _kAccentDark,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment(-0.8, -1.0),
                    end: Alignment(0.8, 1.0),
                    colors: [_kAccentLight, _kAccent, _kAccentDark],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _kAccent.withValues(alpha: 0.3),
                      blurRadius: 16,
                      spreadRadius: -4,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_basket_rounded, size: 18, color: Color(0xFF2C1810)),
                    SizedBox(width: 8),
                    Text(
                      'Add Entire Feast to Cart',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C1810),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dish {
  const _Dish(this.name, this.desc, this.serving, this.tone, this.emoji, this.price);
  final String name, desc, serving, emoji;
  final Color tone;
  final int price;
}
