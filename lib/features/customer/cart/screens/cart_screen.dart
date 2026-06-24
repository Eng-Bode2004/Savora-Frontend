import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../state/cart_state.dart';
import '../../../../state/providers/auth_provider.dart';
import '../../../../shared/widgets/auth_gate.dart';
import '../../checkout/screens/checkout_screen.dart';

const _kAccent = Color(0xFFE8A838);
const _kAccentLight = Color(0xFFF0B040);
const _kAccentDark = Color(0xFFD4952E);

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;

  static const int _deliveryFee = 20;

  bool get _isDarkMode => themeModeNotifier.value == ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    
    cartState.addListener(_onCartStateChanged);
  }

  @override
  void dispose() {
    cartState.removeListener(_onCartStateChanged);
    _entrance.dispose();
    super.dispose();
  }

  void _onCartStateChanged() {
    if (mounted) {
      setState(() {});
    }
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

  int get _subtotal =>
      cartState.items.fold(0, (sum, item) => sum + item.price * item.qty);
  int get _total => _subtotal + (cartState.items.isEmpty ? 0 : _deliveryFee);

  void _changeQty(CartItem item, int delta) {
    HapticFeedback.selectionClick();
    cartState.changeQty(item.dishId, delta);
  }

  void _removeItem(CartItem item) {
    HapticFeedback.mediumImpact();
    cartState.removeItem(item.dishId);
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
                    final itemsList = cartState.items;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                          child: _reveal(0.0, 0.25, _buildTopBar()),
                        ),
                        Expanded(
                          child: itemsList.isEmpty
                              ? _buildEmpty()
                              : SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        for (int i = 0; i < itemsList.length; i++) ...[
                                          _reveal(
                                            0.08 + i * 0.05,
                                            0.45 + i * 0.05,
                                            _buildCartItem(itemsList[i]),
                                          ),
                                          const SizedBox(height: 12),
                                        ],
                                        const SizedBox(height: 6),
                                        _reveal(0.35, 0.70, _buildPromoField()),
                                        const SizedBox(height: 18),
                                        _reveal(0.45, 0.85, _buildSummary()),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                        if (itemsList.isNotEmpty)
                          _reveal(0.55, 1.0, _buildCheckoutBar()),
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
          onTap: () => Navigator.of(context).maybePop(),
          child: Icon(Icons.arrow_back_rounded, size: 24, color: _textColor),
        ),
        const SizedBox(width: 14),
        Text(
          'My Cart',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
        const Spacer(),
        if (cartState.items.isNotEmpty)
          Text(
            '${cartState.items.length} items',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              color: _subTextColor,
            ),
          ),
      ],
    );
  }

  Widget _buildCartItem(CartItem item) {
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
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/${item.name}.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [item.tone, item.tone.withValues(alpha: 0.65)],
                  ),
                ),
                child: Center(child: Text(item.emoji, style: const TextStyle(fontSize: 28))),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _textColor,
                          height: 1.2,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _removeItem(item),
                      child: Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.close_rounded, size: 16, color: Colors.red),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'EGP ${item.price}',
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _kAccentDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildStepper(item),
        ],
      ),
    );
  }

  Widget _buildStepper(CartItem item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _stepperButton(
          icon: Icons.remove_rounded,
          filled: false,
          onTap: () => _changeQty(item, -1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '${item.qty}',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
          ),
        ),
        _stepperButton(
          icon: Icons.add_rounded,
          filled: true,
          onTap: () => _changeQty(item, 1),
        ),
      ],
    );
  }

  Widget _stepperButton({
    required IconData icon,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
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
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 18,
          color: filled ? const Color(0xFF2C1810) : _textColor,
        ),
      ),
    );
  }

  Widget _buildPromoField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: _fieldBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _fieldBorderColor, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(Icons.local_offer_rounded, size: 18, color: _subTextColor),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              style: TextStyle(fontFamily: 'DM Sans', fontSize: 14, color: _textColor),
              cursorColor: _kAccent,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Promo Code',
                hintStyle: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  color: _subTextColor.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => HapticFeedback.lightImpact(),
            child: const Text(
              'Apply',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _kAccentDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 14),
          _summaryRow('Subtotal', 'EGP $_subtotal'),
          const SizedBox(height: 10),
          _summaryRow('Delivery Fee', 'EGP $_deliveryFee'),
          const SizedBox(height: 14),
          Divider(color: _fieldBorderColor, height: 1, thickness: 0.5),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textColor,
                ),
              ),
              const Spacer(),
              Text(
                'EGP $_total',
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _kAccentDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            color: _subTextColor,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: _cardColor,
        border: Border(top: BorderSide(color: _fieldBorderColor, width: 0.5)),
        boxShadow: [
          BoxShadow(color: _shadowColor, blurRadius: 16, offset: const Offset(0, -4)),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          if (!authState.isLoggedIn) {
            HapticFeedback.mediumImpact();
            showAuthRequiredDialog(context);
            return;
          }
          HapticFeedback.mediumImpact();
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const CheckoutScreen(),
              transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
              transitionDuration: const Duration(milliseconds: 350),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
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
              Text(
                'Proceed to Checkout',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C1810),
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 18, color: Color(0xFF2C1810)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _kAccent.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Text('🛒', style: TextStyle(fontSize: 40)),
          ),
          const SizedBox(height: 20),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add some delicious meals to get started',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              color: _subTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
