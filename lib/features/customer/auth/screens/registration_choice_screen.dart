import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import 'signup_screen.dart';

const _kAccent = Color(0xFFE8A838);
const _kAccentLight = Color(0xFFF0B040);
const _kAccentDark = Color(0xFFD4952E);

class RegistrationChoiceScreen extends StatefulWidget {
  const RegistrationChoiceScreen({super.key});

  @override
  State<RegistrationChoiceScreen> createState() =>
      _RegistrationChoiceScreenState();
}

class _RegistrationChoiceScreenState extends State<RegistrationChoiceScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _float;

  bool _isDarkMode = themeModeNotifier.value == ThemeMode.dark;

  Color get _bgColor => _isDarkMode ? AppColors.espresso : const Color(0xFFFDFBF7);
  Color get _bgColor2 => _isDarkMode ? AppColors.espresso : const Color(0xFFF7F4EE);
  Color get _textColor => _isDarkMode ? AppColors.cream : const Color(0xFF1A1410);
  Color get _subTextColor => _isDarkMode ? AppColors.creamDim : const Color(0xFF6B6258);
  Color get _cardColor => _isDarkMode ? AppColors.glass : Colors.white;
  Color get _fieldBorderColor =>
      _isDarkMode ? AppColors.glassBorder : const Color(0xFFE8E4DE);
  Color get _shadowColor =>
      _isDarkMode ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.06);

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _float = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _float.dispose();
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

  Route _route(Widget page) => PageRouteBuilder(
    pageBuilder: (_, a, __) => page,
    transitionsBuilder: (_, a, __, child) => FadeTransition(
      opacity: CurvedAnimation(parent: a, curve: Curves.easeOutExpo),
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.06), end: Offset.zero)
            .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
        child: child,
      ),
    ),
    transitionDuration: const Duration(milliseconds: 500),
  );

  void _choosePhone() {
    HapticFeedback.mediumImpact();
    // Your existing SignupScreen collects phone + does OTP
    Navigator.of(context).push(_route(const SignupScreen()));
  }

  void _chooseEmail() {
    HapticFeedback.mediumImpact();
    // Until you build a dedicated email screen, route to SignupScreen too.
    // Swap to your EmailSignupScreen once it exists.
    Navigator.of(context).push(_route(const SignupScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isRtl = l.locale.languageCode == 'ar';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _bgColor,
        body: Stack(
          children: [
            _buildBackground(),
            SafeArea(
              child: Directionality(
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_entrance, _float]),
                  builder: (context, _) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height -
                              MediaQuery.of(context).padding.vertical,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Column(
                            children: [
                              const SizedBox(height: 12),
                              _reveal(0.0, 0.22, _buildTopBar()),
                              const SizedBox(height: 16),
                              _reveal(0.06, 0.40, _buildHeroAnimation()),
                              const SizedBox(height: 8),
                              _reveal(0.14, 0.45, _buildHeader(l)),
                              const SizedBox(height: 36),
                              _reveal(0.30, 0.65, _buildPhoneCard(l), dy: 26),
                              const SizedBox(height: 16),
                              _reveal(0.40, 0.75, _buildEmailCard(l), dy: 26),
                               const SizedBox(height: 20),

                              _reveal(0.55, 1.0, _buildFooter(l)),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════ BACKGROUND ════════
  Widget _buildBackground() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: const Alignment(-0.5, -1.0),
              end: const Alignment(0.5, 1.2),
              colors: [_bgColor, _bgColor2],
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -50,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [_kAccent.withValues(alpha: 0.08), Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -70,
          left: -60,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [_kAccent.withValues(alpha: 0.04), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ════════ TOP BAR ════════
  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _cardColor,
              shape: BoxShape.circle,
              border: Border.all(color: _fieldBorderColor, width: 0.5),
              boxShadow: [
                BoxShadow(color: _shadowColor, blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Icon(Icons.arrow_back_rounded, size: 20, color: _textColor),
          ),
        ),
      ],
    );
  }

  // ════════ HERO ANIMATION (Flutter-drawn, no asset) ════════
  Widget _buildHeroAnimation() {
    final bob = math.sin(_float.value * 2 * math.pi) * 8;
    final orbit = _float.value * 2 * math.pi;

    return SizedBox(
      height: 170,
      child: Center(
        child: Transform.translate(
          offset: Offset(0, bob),
          child: SizedBox(
            width: 180,
            height: 170,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [_kAccent.withValues(alpha: 0.14), Colors.transparent],
                    ),
                  ),
                ),
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [_kAccentLight, _kAccentDark],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _kAccent.withValues(alpha: 0.40),
                        blurRadius: 26,
                        spreadRadius: -4,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🍽️', style: TextStyle(fontSize: 50)),
                  ),
                ),
                Transform.translate(
                  offset: Offset(math.cos(orbit) * 76, math.sin(orbit) * 76),
                  child: _orbitBadge('✉️'),
                ),
                Transform.translate(
                  offset: Offset(
                    math.cos(orbit + math.pi) * 76,
                    math.sin(orbit + math.pi) * 76,
                  ),
                  child: _orbitBadge('📱'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _orbitBadge(String emoji) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _cardColor,
        shape: BoxShape.circle,
        border: Border.all(color: _fieldBorderColor, width: 0.5),
        boxShadow: [
          BoxShadow(color: _shadowColor, blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 20)),
    );
  }

  // ════════ HEADER ════════
  Widget _buildHeader(AppLocalizations l) {
    return Column(
      children: [
        Text(
          l.t('signUp'),
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l.t('createAccount'),
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'DM Sans', fontSize: 14, color: _subTextColor),
        ),
      ],
    );
  }

  // ════════ PHONE CARD (filled) ════════
  Widget _buildPhoneCard(AppLocalizations l) {
    return _ChoiceCard(
      icon: Icons.phone_iphone_rounded,
      title: l.t('registerWithPhone'),
      subtitle: l.t('registerWithPhoneSub'),
      filled: true,
      cardColor: _cardColor,
      textColor: _textColor,
      subTextColor: _subTextColor,
      borderColor: _fieldBorderColor,
      shadowColor: _shadowColor,
      onTap: _choosePhone,
    );
  }

  // ════════ EMAIL CARD (outlined) ════════
  Widget _buildEmailCard(AppLocalizations l) {
    return _ChoiceCard(
      icon: Icons.alternate_email_rounded,
      title: l.t('registerWithEmail'),
      subtitle: l.t('registerWithEmailSub'),
      filled: false,
      cardColor: _cardColor,
      textColor: _textColor,
      subTextColor: _subTextColor,
      borderColor: _fieldBorderColor,
      shadowColor: _shadowColor,
      onTap: _chooseEmail,
    );
  }

  // ════════ FOOTER ════════
  Widget _buildFooter(AppLocalizations l) {
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              l.t('alreadyHaveAccount'),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: 'DM Sans', fontSize: 13, color: _subTextColor),
            ),
          ),
          Text(
            l.t('logIn'),
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _kAccent,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// CHOICE CARD (spring press; filled = accent gradient)
// ════════════════════════════════════════════════════════
class _ChoiceCard extends StatefulWidget {
  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.filled,
    required this.cardColor,
    required this.textColor,
    required this.subTextColor,
    required this.borderColor,
    required this.shadowColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool filled;
  final Color cardColor, textColor, subTextColor, borderColor, shadowColor;
  final VoidCallback onTap;

  @override
  State<_ChoiceCard> createState() => _ChoiceCardState();
}

class _ChoiceCardState extends State<_ChoiceCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final showFilled = _pressed || widget.filled;
    final titleColor = showFilled ? const Color(0xFF2C1810) : widget.textColor;
    final subColor = showFilled
        ? const Color(0xFF2C1810).withValues(alpha: 0.7)
        : widget.subTextColor;
    final iconBg = showFilled
        ? const Color(0xFF2C1810).withValues(alpha: 0.12)
        : _kAccent.withValues(alpha: 0.14);
    final iconColor = showFilled ? const Color(0xFF2C1810) : _kAccent;

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.mediumImpact();
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(_pressed ? 0.98 : 1.0),
        transformAlignment: Alignment.center,
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: showFilled
              ? const LinearGradient(
            begin: Alignment(-0.8, -1.0),
            end: Alignment(0.8, 1.0),
            colors: [_kAccentLight, _kAccent, _kAccentDark],
          )
              : null,
          color: showFilled ? null : widget.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: showFilled ? null : Border.all(color: widget.borderColor, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: showFilled
                  ? _kAccent.withValues(alpha: _pressed ? 0.42 : 0.30)
                  : widget.shadowColor,
              blurRadius: showFilled ? (_pressed ? 24 : 18) : 16,
              spreadRadius: showFilled ? -4 : -6,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(widget.icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      color: subColor,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: showFilled ? const Color(0xFF2C1810) : widget.subTextColor,
            ),
          ],
        ),
      ),
    );
  }
}