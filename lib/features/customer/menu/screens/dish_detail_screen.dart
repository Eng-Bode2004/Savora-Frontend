import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../state/cart_state.dart';
import '../../../../state/providers/auth_provider.dart';
import '../../../../shared/widgets/auth_gate.dart';

const _kAccent = Color(0xFFE8A838);
const _kAccentLight = Color(0xFFF0B040);
const _kAccentDark = Color(0xFFD4952E);

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    this.dishId = '',
    this.name = 'Royal Lamb Fattah',
    this.basePrice = 245,
    this.rating = 4.9,
    this.prepTime = '25–35 min',
    this.tagline = 'Cloud Kitchen Special',
    this.description =
        'A classic Egyptian delicacy featuring tender, slow-cooked lamb chunks served over a bed of aromatic garlic-vinegar rice and toasted pita bread.',
    this.image = '',
    this.tone = const Color(0xFF8B3A1E),
    this.emoji = '🍛',
    this.chefId,
    this.chefName,
  });

  final String dishId, name, prepTime, tagline, description, image, emoji;
  final int basePrice;
  final double rating;
  final Color tone;
  final String? chefId, chefName;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  int _quantity = 1;

  bool get _isDarkMode => themeModeNotifier.value == ThemeMode.dark;

  final List<_AddOn> _addOns = [
    _AddOn('Extra Garlic Dip', 15),
    _AddOn('Spicy Sauce', 10),
    _AddOn('Extra Rice', 30),
  ];

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

  int get _total {
    int addOnSum = 0;
    for (final a in _addOns) {
      if (a.selected) addOnSum += a.price;
    }
    return (widget.basePrice + addOnSum) * _quantity;
  }

  void _changeQty(int delta) {
    HapticFeedback.selectionClick();
    setState(() => _quantity = (_quantity + delta).clamp(1, 99));
  }

  Widget _heroFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [widget.tone, widget.tone.withValues(alpha: 0.6)],
        ),
      ),
      child: Center(child: Text(widget.emoji, style: const TextStyle(fontSize: 80))),
    );
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
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildHero()),
                  SliverToBoxAdapter(
                    child: AnimatedBuilder(
                      animation: _entrance,
                      builder: (context, _) {
                        return Transform.translate(
                          offset: const Offset(0, -24),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _bgColor,
                              borderRadius:
                                  const BorderRadius.vertical(top: Radius.circular(28)),
                            ),
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 130),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _reveal(0.0, 0.30, _buildTitleRow()),
                                const SizedBox(height: 8),
                                _reveal(0.06, 0.36, _buildMeta()),
                                const SizedBox(height: 14),
                                _reveal(0.12, 0.42, _buildDescription()),
                                const SizedBox(height: 26),
                                _reveal(0.20, 0.50, _buildCustomizeHeader()),
                                const SizedBox(height: 12),
                                for (int i = 0; i < _addOns.length; i++) ...[
                                  _reveal(0.24 + i * 0.05, 0.60 + i * 0.05,
                                      _buildAddOnRow(_addOns[i])),
                                  const SizedBox(height: 10),
                                ],
                                const SizedBox(height: 16),
                                _reveal(0.40, 0.72, _buildQuantity()),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: _buildTopBar(),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildAddToCartBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    final hasNetworkImage = widget.image.startsWith('http');
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasNetworkImage)
            Image.network(widget.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _heroFallback())
          else
            Image.asset(
              widget.image.isNotEmpty ? widget.image : 'assets/images/Royal Lamb Fattah.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _heroFallback(),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, _bgColor.withValues(alpha: 0.4)],
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 36,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, size: 16, color: _kAccent),
                  const SizedBox(width: 4),
                  Text(
                    widget.rating.toString(),
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        _circleBtn(Icons.arrow_back_rounded, () => Navigator.of(context).maybePop()),
        const Spacer(),
        Text(
          'Savora',
          style: TextStyle(
            fontFamily: 'Playfair Display',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _isDarkMode ? AppColors.cream : Colors.white,
            shadows: const [Shadow(color: Colors.black54, blurRadius: 8)],
          ),
        ),
        const Spacer(),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
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

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back_rounded, size: 20, color: Colors.white),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            widget.name,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: _textColor,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'EGP ${widget.basePrice}',
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _kAccentDark,
          ),
        ),
      ],
    );
  }

  Widget _buildMeta() {
    return Row(
      children: [
        Text(
          widget.tagline,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _kAccentDark,
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.circle, size: 3, color: _subTextColor),
        const SizedBox(width: 8),
        Icon(Icons.access_time_rounded, size: 14, color: _subTextColor),
        const SizedBox(width: 4),
        Text(
          widget.prepTime,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            color: _subTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      widget.description,
      style: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 13.5,
        height: 1.55,
        color: _subTextColor,
      ),
    );
  }

  Widget _buildCustomizeHeader() {
    return Row(
      children: [
        Text(
          'Customize your meal',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _fieldBgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _fieldBorderColor, width: 0.5),
          ),
          child: Text(
            'Optional',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _subTextColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddOnRow(_AddOn a) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => a.selected = !a.selected);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: a.selected
              ? _kAccent.withValues(alpha: _isDarkMode ? 0.16 : 0.08)
              : _cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: a.selected ? _kAccent.withValues(alpha: 0.6) : _fieldBorderColor,
            width: a.selected ? 1.4 : 0.5,
          ),
          boxShadow: a.selected
              ? null
              : [BoxShadow(color: _shadowColor, blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: a.selected
                    ? const LinearGradient(colors: [_kAccentLight, _kAccentDark])
                    : null,
                color: a.selected ? null : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: a.selected ? Colors.transparent : _subTextColor.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: a.selected
                  ? const Icon(Icons.check_rounded, size: 15, color: Color(0xFF2C1810))
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                a.name,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textColor,
                ),
              ),
            ),
            Text(
              '+ EGP ${a.price}',
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _kAccentDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantity() {
    return Row(
      children: [
        Text(
          'Quantity',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
        const Spacer(),
        _qtyButton(Icons.remove_rounded, filled: false, onTap: () => _changeQty(-1)),
        Container(
          width: 50,
          alignment: Alignment.center,
          child: Text(
            '$_quantity',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
          ),
        ),
        _qtyButton(Icons.add_rounded, filled: true, onTap: () => _changeQty(1)),
      ],
    );
  }

  Widget _qtyButton(IconData icon, {required bool filled, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: filled
              ? const LinearGradient(colors: [_kAccentLight, _kAccentDark])
              : null,
          color: filled ? null : _fieldBgColor,
          shape: BoxShape.circle,
          border: filled ? null : Border.all(color: _fieldBorderColor, width: 0.5),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: _kAccent.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Icon(icon, size: 22, color: filled ? const Color(0xFF2C1810) : _textColor),
      ),
    );
  }

  Widget _buildAddToCartBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: _cardColor,
        border: Border(top: BorderSide(color: _fieldBorderColor, width: 0.5)),
        boxShadow: [
          BoxShadow(color: _shadowColor, blurRadius: 18, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () {
            if (!authState.isLoggedIn) {
              HapticFeedback.mediumImpact();
              showAuthRequiredDialog(context);
              return;
            }
            HapticFeedback.mediumImpact();
            final selectedAddOns = _addOns.where((a) => a.selected).toList();
            final addOnSum = selectedAddOns.fold(0, (sum, a) => sum + a.price);
            final itemPrice = widget.basePrice + addOnSum;

            if (widget.chefId != null) {
              cartState.setChef(id: widget.chefId!, name: widget.chefName ?? 'Chef');
            }

            cartState.addItem(
              CartItem(
                dishId: widget.dishId,
                name: widget.name,
                price: itemPrice,
                qty: _quantity,
                tone: widget.tone,
                emoji: widget.emoji,
                addOns: selectedAddOns
                    .map((a) => CartAddOn(name: a.name, price: a.price))
                    .toList(),
                image: widget.image.startsWith('http') ? widget.image : null,
              ),
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${widget.name} added to cart!',
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: _kAccentDark,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_basket_rounded,
                    size: 18, color: Color(0xFF2C1810)),
                const SizedBox(width: 8),
                Text(
                  'Add to Cart — EGP $_total',
                  style: const TextStyle(
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
      ),
    );
  }
}

class _AddOn {
  _AddOn(this.name, this.price, {this.selected = false});
  final String name;
  final int price;
  bool selected;
}
