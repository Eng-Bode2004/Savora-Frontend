import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';

const _kAccent = Color(0xFFE8A838);
const _kAccentLight = Color(0xFFF0B040);
const _kAccentDark = Color(0xFFD4952E);

class BuildYourOwnScreen extends StatefulWidget {
  const BuildYourOwnScreen({super.key, this.guests = 4});

  final int guests;

  @override
  State<BuildYourOwnScreen> createState() => _BuildYourOwnScreenState();
}

class _BuildYourOwnScreenState extends State<BuildYourOwnScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  int _categoryIndex = 0;

  bool _isDarkMode = themeModeNotifier.value == ThemeMode.dark;

  static const List<String> _categories = ['Grills', 'Sides', 'Dips & Bread'];

  final Map<int, List<_Dish>> _dishesByCategory = {
    0: [
      _Dish('Mix Grill Platter', 'Lamb kebab, chicken tawook, and kofta',
          48.00, 'Serves 4', const Color(0xFF7A2E1E), '🍢'),
      _Dish('Hawawshi', 'A halved spiced meat-stuffed pita',
          22.00, 'Large Platter', const Color(0xFF8B3A1E), '🥙'),
    ],
    1: [
      _Dish('Mezze Sampler', 'Hummus, baba ghanoush, and falafel',
          18.50, 'Serves 2–4', const Color(0xFF6B6B2E), '🥗'),
      _Dish('Stuffed Vine Leaves', 'Hand-rolled with rice and herbs',
          16.00, 'Serves 3', const Color(0xFF3E6B4A), '🍃'),
    ],
    2: [
      _Dish('Baladi Bread Basket', 'Fresh-baked Egyptian flatbread',
          8.00, 'Serves 4', const Color(0xFFC2882E), '🫓'),
      _Dish('Tahini & Dips Trio', 'Tahini, garlic dip, and chili sauce',
          12.50, 'Serves 4', const Color(0xFF9A5B2A), '🥣'),
    ],
  };

  final Map<String, int> _cart = {};

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
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

  Widget _reveal(double start, double end, Widget child, {double dy = 20}) {
    final t = _ease(_t(start, end));
    return Opacity(
      opacity: t,
      child: Transform.translate(offset: Offset(0, (1 - t) * dy), child: child),
    );
  }

  List<_Dish> get _currentDishes => _dishesByCategory[_categoryIndex] ?? [];

  int get _itemCount => _cart.values.fold(0, (a, b) => a + b);

  double get _total {
    double sum = 0;
    for (final list in _dishesByCategory.values) {
      for (final d in list) {
        sum += (_cart[d.name] ?? 0) * d.price;
      }
    }
    return sum;
  }

  void _addDish(_Dish d) {
    HapticFeedback.selectionClick();
    setState(() => _cart[d.name] = (_cart[d.name] ?? 0) + 1);
  }

  void _removeDish(_Dish d) {
    HapticFeedback.selectionClick();
    setState(() {
      final q = (_cart[d.name] ?? 0) - 1;
      if (q <= 0) {
        _cart.remove(d.name);
      } else {
        _cart[d.name] = q;
      }
    });
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
                          child: Column(
                            children: [
                              _reveal(0.0, 0.22, _buildTopBar()),
                              const SizedBox(height: 16),
                              _reveal(0.05, 0.30, _buildFilterRow()),
                              const SizedBox(height: 16),
                              _reveal(0.10, 0.36, _buildCategoryTabs()),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                            itemCount: _currentDishes.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 16),
                            itemBuilder: (context, i) => _reveal(
                              0.15 + i * 0.06,
                              0.55 + i * 0.06,
                              _buildDishCard(_currentDishes[i]),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              if (_itemCount > 0)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildBottomBar(),
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
          onTap: () => Navigator.of(context).maybePop(),
          child: Icon(Icons.arrow_back_rounded, size: 24, color: _textColor),
        ),
        const SizedBox(width: 14),
        Text(
          'Build Your Own',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => HapticFeedback.lightImpact(),
          child: Icon(Icons.info_outline_rounded, size: 22, color: _subTextColor),
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        _filterPill(Icons.groups_rounded, 'Plan for ${widget.guests} Guests', filled: true),
        const SizedBox(width: 10),
        _filterPill(Icons.eco_rounded, 'Vegetarian', filled: false),
      ],
    );
  }

  Widget _filterPill(IconData icon, String label, {required bool filled}) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: filled ? _kAccent.withValues(alpha: 0.14) : _cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: filled ? _kAccent.withValues(alpha: 0.5) : _fieldBorderColor,
            width: filled ? 1 : 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: filled ? _kAccentDark : _subTextColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: filled ? _kAccentDark : _textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final selected = i == _categoryIndex;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _categoryIndex = i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(colors: [_kAccentLight, _kAccentDark])
                    : null,
                color: selected ? null : _cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? Colors.transparent : _fieldBorderColor,
                  width: 0.5,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: _kAccent.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                _categories[i],
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? const Color(0xFF2C1810) : _subTextColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDishCard(_Dish d) {
    final qty = _cart[d.name] ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _fieldBorderColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: _shadowColor,
            blurRadius: 18,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: SizedBox(
                  height: 130,
                  width: double.infinity,
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
                      child: Center(child: Text(d.emoji, style: const TextStyle(fontSize: 44))),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    d.serving,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.name,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _textColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        d.desc,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          color: _subTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${d.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _kAccentDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                qty == 0
                    ? _addButton(d)
                    : _qtyControl(d, qty),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _addButton(_Dish d) {
    return GestureDetector(
      onTap: () => _addDish(d),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_kAccentLight, _kAccentDark]),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _kAccent.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, size: 24, color: Color(0xFF2C1810)),
      ),
    );
  }

  Widget _qtyControl(_Dish d, int qty) {
    return Container(
      decoration: BoxDecoration(
        color: _fieldBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kAccent.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _removeDish(d),
            child: Container(
              width: 34,
              height: 40,
              alignment: Alignment.center,
              child: Icon(Icons.remove_rounded, size: 20, color: _textColor),
            ),
          ),
          Text(
            '$qty',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
          ),
          GestureDetector(
            onTap: () => _addDish(d),
            child: Container(
              width: 34,
              height: 40,
              alignment: Alignment.center,
              child: const Icon(Icons.add_rounded, size: 20, color: _kAccentDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: _cardColor,
        border: Border(top: BorderSide(color: _fieldBorderColor, width: 0.5)),
        boxShadow: [
          BoxShadow(color: _shadowColor, blurRadius: 18, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _kAccent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_basket_rounded, size: 22, color: _kAccentDark),
                  Positioned(
                    right: -6,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0533D),
                        shape: BoxShape.circle,
                        border: Border.all(color: _cardColor, width: 1.5),
                      ),
                      child: Text(
                        '$_itemCount',
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_itemCount items added',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11,
                    color: _subTextColor,
                  ),
                ),
                Text(
                  '\$${_total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _textColor,
                  ),
                ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => HapticFeedback.mediumImpact(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                      blurRadius: 14,
                      spreadRadius: -4,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Continue to Checkout',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C1810),
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF2C1810)),
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
  const _Dish(this.name, this.desc, this.price, this.serving, this.tone, this.emoji);
  final String name, desc, serving, emoji;
  final double price;
  final Color tone;
}
