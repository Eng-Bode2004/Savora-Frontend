import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/animated_background.dart';
import 'otp_screen.dart';

const _kAccent = Color(0xFFE8A838);
const _kAccentLight = Color(0xFFF0B040);
const _kAccentDark = Color(0xFFD4952E);

final _nameGen = math.Random();

final List<String> _adjectives = [
  'Chef', 'Foodie', 'Tasty', 'Yummy', 'Spicy', 'Savory', 'Zesty',
  'Crispy', 'Juicy', 'Toasty', 'Frosty', 'Golden', 'Silky', 'Cozy',
  'Urban', 'Fresh', 'Wild', 'Sunny', 'Moonlit', 'Stormy',
];

final List<String> _nouns = [
  'Kitchen', 'Plate', 'Bowl', 'Spoon', 'Oven', 'Grill', 'Pan',
  'Feast', 'Savor', 'Morsel', 'Taste', 'Aroma', 'Herb', 'Spice',
  'Hearth', 'Table', 'Toast', 'Bake', 'Roast', 'Steam',
];

String generateUsername() {
  final adj = _adjectives[_nameGen.nextInt(_adjectives.length)];
  final noun = _nouns[_nameGen.nextInt(_nouns.length)];
  final num = _nameGen.nextInt(999);
  return '$adj$noun$num';
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  // ── Controllers / focus ──
  final _usernameCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  final _usernameFocus = FocusNode();
  final _nameFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  final _phoneFocus = FocusNode();

  // ── Animations ──
  late final AnimationController _entrance;
  late final AnimationController _float;
  late final AnimationController _shimmer;
  late final AnimationController _genSpin;

  // ── State ──
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool get _isDarkMode => themeModeNotifier.value == ThemeMode.dark;
  bool _isLoading = false;
  bool _buttonPressed = false;

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _float = AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);
    _shimmer = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat();
    _genSpin = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    for (final f in [_usernameFocus, _nameFocus, _passwordFocus, _confirmFocus, _phoneFocus]) {
      f.addListener(() => setState(() {}));
    }
    for (final c in [_passwordCtrl, _confirmCtrl]) {
      c.addListener(() => setState(() {}));
    }

    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _entrance.forward();
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    _float.dispose();
    _shimmer.dispose();
    _genSpin.dispose();
    _usernameCtrl.dispose();
    _nameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _phoneCtrl.dispose();
    _usernameFocus.dispose();
    _nameFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  // ── Actions ──
  void _generateUsername() {
    HapticFeedback.lightImpact();
    _genSpin.forward(from: 0);
    setState(() => _usernameCtrl.text = generateUsername());
  }

  void _toggleDarkMode() {
    HapticFeedback.lightImpact();
    setState(() {
      themeModeNotifier.value = _isDarkMode ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void _handleSignup() {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreen(contact: _phoneCtrl.text, isDarkMode: _isDarkMode),
          ),
        );
      }
    });
  }

  void _goToLogin() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
  }

  // ── Animation helpers (staggered reveal) ──
  double _t(double start, double end) {
    final v = _entrance.value.clamp(start, end);
    return ((v - start) / (end - start)).clamp(0.0, 1.0);
  }

  static double _ease(double t) => 1.0 - math.pow(1.0 - t, 3.5).toDouble();

  Widget _reveal(double start, double end, Widget child, {double dy = 18}) {
    final t = _ease(_t(start, end));
    return Opacity(
      opacity: t,
      child: Transform.translate(offset: Offset(0, (1 - t) * dy), child: child),
    );
  }

  // ── Password strength: 0..4 ──
  int get _strength {
    final p = _passwordCtrl.text;
    if (p.isEmpty) return 0;
    int s = 0;
    if (p.length >= 8) s++;
    if (RegExp(r'[A-Z]').hasMatch(p) && RegExp(r'[a-z]').hasMatch(p)) s++;
    if (RegExp(r'[0-9]').hasMatch(p)) s++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]').hasMatch(p)) s++;
    return s;
  }

  bool get _confirmMatches =>
      _confirmCtrl.text.isNotEmpty && _confirmCtrl.text == _passwordCtrl.text;

  // ── Theme colors — dark mode mirrors OTP exactly ──
  Color get _bgColor => _isDarkMode ? AppColors.espresso : const Color(0xFFFDFBF7);
  Color get _bgColor2 => _isDarkMode ? AppColors.espresso : const Color(0xFFF7F4EE);
  Color get _cardColor => _isDarkMode ? AppColors.glass : Colors.white;
  Color get _textColor => _isDarkMode ? AppColors.cream : const Color(0xFF161618);
  Color get _subTextColor => _isDarkMode ? AppColors.creamDim : const Color(0xFF8A8A8A);
  Color get _fieldBgColor => _isDarkMode ? AppColors.glass : const Color(0xFFF5F3EF);
  Color get _fieldBorderColor =>
      _isDarkMode ? AppColors.glassBorder : const Color(0xFFE8E4DE);
  Color get _shadowColor =>
      _isDarkMode ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.06);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _bgColor,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            _buildBackground(),
            if (!_isDarkMode) _FloatingDecor(floatAnim: _float),
            SafeArea(
              // ★ FIX: listen to _entrance so _reveal() rebuilds while animating.
              child: AnimatedBuilder(
                animation: _entrance,
                builder: (context, _) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          _reveal(0.0, 0.22, _buildTopBar(l)),
                          const SizedBox(height: 28),
                          _reveal(0.08, 0.30, _buildHeader(l)),
                          const SizedBox(height: 30),
                          _reveal(0.18, 0.55, _buildFormCard(l), dy: 28),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════ BACKGROUND ════════
  Widget _buildBackground() {
    // Dark mode → identical to OTP screen
    if (_isDarkMode) {
      return const AnimatedBackground(child: SizedBox.expand());
    }
    // Light mode → soft cream with drifting accent orbs
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
          child: AnimatedBuilder(
            animation: _float,
            builder: (_, __) {
              final shift = _float.value * 30;
              return Transform.translate(
                offset: Offset(0, shift),
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
              );
            },
          ),
        ),
        Positioned(
          bottom: -70,
          left: -60,
          child: AnimatedBuilder(
            animation: _float,
            builder: (_, __) {
              final shift = _float.value * 30;
              return Transform.translate(
                offset: Offset(0, -shift),
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
              );
            },
          ),
        ),
      ],
    );
  }

  // ════════ TOP BAR ════════
  Widget _buildTopBar(AppLocalizations l) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _CircleIconButton(
          icon: Icons.arrow_back_rounded,
          rounded: false,
          color: _textColor,
          bg: _cardColor,
          border: _fieldBorderColor,
          shadow: _shadowColor,
          onTap: _goToLogin,
        ),
        _CircleIconButton(
          icon: _isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          rounded: true,
          color: _isDarkMode ? _kAccent : const Color(0xFF2C1810),
          bg: _cardColor,
          border: _fieldBorderColor,
          shadow: _shadowColor,
          onTap: _toggleDarkMode,
        ),
      ],
    );
  }

  // ════════ HEADER ════════
  Widget _buildHeader(AppLocalizations l) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _float,
          builder: (_, __) {
            final s = 1.0 + math.sin(_float.value * math.pi) * 0.04;
            return Transform.scale(
              scale: s,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [_kAccentLight, _kAccentDark],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _kAccent.withValues(alpha: 0.35),
                      blurRadius: 18,
                      spreadRadius: -2,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(child: Text('🍲', style: TextStyle(fontSize: 30))),
              ),
            );
          },
        ),
        const SizedBox(height: 18),
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

  // ════════ FORM CARD ════════
  Widget _buildFormCard(AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _fieldBorderColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: _shadowColor,
            blurRadius: 28,
            spreadRadius: -6,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Username + AI generate
          Row(
            children: [
              Expanded(
                child: _buildField(
                  controller: _usernameCtrl,
                  focusNode: _usernameFocus,
                  hint: l.t('username'),
                  icon: Icons.alternate_email_rounded,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _generateUsername,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_kAccentLight, _kAccent, _kAccentDark],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: _kAccent.withValues(alpha: 0.30),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: AnimatedBuilder(
                    animation: _genSpin,
                    builder: (_, child) => Transform.rotate(
                      angle: _genSpin.value * 2 * math.pi,
                      child: child,
                    ),
                    child: const Icon(Icons.auto_awesome_rounded,
                        color: Color(0xFF2C1810), size: 22),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _nameCtrl,
            focusNode: _nameFocus,
            hint: l.t('fullName'),
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _phoneCtrl,
            focusNode: _phoneFocus,
            hint: l.t('phoneNumber'),
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _passwordCtrl,
            focusNode: _passwordFocus,
            hint: l.t('password'),
            icon: Icons.lock_outline_rounded,
            obscure: _obscurePassword,
            toggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          _buildStrengthMeter(),
          const SizedBox(height: 14),
          _buildField(
            controller: _confirmCtrl,
            focusNode: _confirmFocus,
            hint: l.t('confirmPassword'),
            icon: Icons.lock_outline_rounded,
            obscure: _obscureConfirm,
            toggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
            statusIcon: _confirmCtrl.text.isEmpty
                ? null
                : (_confirmMatches ? Icons.check_circle_rounded : Icons.cancel_rounded),
            statusColor: _confirmMatches ? const Color(0xFF35A853) : const Color(0xFFE0533D),
          ),
          const SizedBox(height: 22),
          _buildSignupButton(l),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: _goToLogin,
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
                Flexible(
                  child: Text(
                    l.t('logIn'),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _kAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════ STRENGTH METER ════════
  Widget _buildStrengthMeter() {
    final s = _strength;
    final labels = ['', 'Weak', 'Fair', 'Good', 'Strong'];
    final colors = [
      _fieldBorderColor,
      const Color(0xFFE0533D),
      const Color(0xFFE8A838),
      const Color(0xFF7CB342),
      const Color(0xFF35A853),
    ];

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      child: _passwordCtrl.text.isEmpty
          ? const SizedBox(width: double.infinity)
          : Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          children: [
            ...List.generate(4, (i) {
              final active = i < s;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 4,
                  margin: EdgeInsets.only(right: i < 3 ? 5 : 0),
                  decoration: BoxDecoration(
                    color: active ? colors[s] : _fieldBorderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
            const SizedBox(width: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                labels[s],
                key: ValueKey(s),
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colors[s],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════ SIGN-UP BUTTON (spring + shimmer) ════════
  Widget _buildSignupButton(AppLocalizations l) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.mediumImpact();
        setState(() => _buttonPressed = true);
      },
      onTapUp: (_) {
        setState(() => _buttonPressed = false);
        _handleSignup();
      },
      onTapCancel: () => setState(() => _buttonPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        transform: Matrix4.identity()..scale(_buttonPressed ? 0.97 : 1.0),
        transformAlignment: Alignment.center,
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
              color: _kAccent.withValues(alpha: _buttonPressed ? 0.42 : 0.30),
              blurRadius: _buttonPressed ? 22 : 16,
              spreadRadius: -4,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: AnimatedBuilder(
                  animation: _shimmer,
                  builder: (_, __) {
                    final left = -90 + _shimmer.value * 480;
                    return Transform.translate(
                      offset: Offset(left, 0),
                      child: Container(
                        width: 70,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.18),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2C1810)),
                ),
              )
                  : Text(
                l.t('signUp'),
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
    );
  }

  // ════════ FIELD ════════
  Widget _buildField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    bool obscure = false,
    VoidCallback? toggleObscure,
    TextInputType keyboardType = TextInputType.text,
    IconData? statusIcon,
    Color? statusColor,
  }) {
    final focused = focusNode.hasFocus;

    Widget? suffix;
    if (toggleObscure != null) {
      suffix = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (statusIcon != null) ...[
            Icon(statusIcon, size: 18, color: statusColor),
            const SizedBox(width: 6),
          ],
          GestureDetector(
            onTap: toggleObscure,
            child: Icon(
              obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 20,
              color: _subTextColor.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(width: 12),
        ],
      );
    } else if (statusIcon != null) {
      suffix = Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Icon(statusIcon, size: 18, color: statusColor),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: _fieldBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: focused ? _kAccent.withValues(alpha: 0.55) : _fieldBorderColor,
          width: focused ? 1.5 : 1,
        ),
        boxShadow: focused
            ? [BoxShadow(color: _kAccent.withValues(alpha: 0.16), blurRadius: 14, spreadRadius: 1)]
            : null,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: TextStyle(fontFamily: 'DM Sans', fontSize: 14, color: _textColor),
        cursorColor: _kAccent,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            color: _subTextColor.withValues(alpha: 0.6),
          ),
          prefixIcon: Icon(icon, size: 20, color: focused ? _kAccent : _subTextColor.withValues(alpha: 0.5)),
          suffixIcon: suffix,
          suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// CIRCLE / ROUNDED ICON BUTTON (spring)
// ════════════════════════════════════════════════════════
class _CircleIconButton extends StatefulWidget {
  const _CircleIconButton({
    required this.icon,
    required this.rounded,
    required this.color,
    required this.bg,
    required this.border,
    required this.shadow,
    required this.onTap,
  });

  final IconData icon;
  final bool rounded;
  final Color color, bg, border, shadow;
  final VoidCallback onTap;

  @override
  State<_CircleIconButton> createState() => _CircleIconButtonState();
}

class _CircleIconButtonState extends State<_CircleIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        transform: Matrix4.identity()..scale(_pressed ? 0.92 : 1.0),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: widget.bg,
          shape: widget.rounded ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: widget.rounded ? null : BorderRadius.circular(12),
          border: Border.all(color: widget.border, width: 0.5),
          boxShadow: [BoxShadow(color: widget.shadow, blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (c, a) =>
              RotationTransition(turns: a, child: FadeTransition(opacity: a, child: c)),
          child: Icon(widget.icon, key: ValueKey(widget.icon), size: 20, color: widget.color),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// FLOATING FOOD DECOR (light mode only — dark uses AnimatedBackground)
// ════════════════════════════════════════════════════════
class _FloatingDecor extends StatelessWidget {
  const _FloatingDecor({required this.floatAnim});

  final AnimationController floatAnim;

  static const List<_FoodSpec> _specs = [
    _FoodSpec('🍕', x: -0.88, y: -0.82, size: 22, freqX: 1.0, freqY: 0.9, ampX: 4, ampY: 7, phase: 0.0),
    _FoodSpec('🥗', x: 0.90, y: -0.74, size: 20, freqX: 1.2, freqY: 1.1, ampX: 5, ampY: 6, phase: 1.2),
    _FoodSpec('🍜', x: -0.92, y: -0.30, size: 18, freqX: 0.9, freqY: 1.0, ampX: 3, ampY: 8, phase: 2.4),
    _FoodSpec('🫕', x: 0.92, y: 0.62, size: 20, freqX: 1.3, freqY: 1.2, ampX: 4, ampY: 7, phase: 3.6),
    _FoodSpec('🥘', x: -0.86, y: 0.88, size: 22, freqX: 1.1, freqY: 0.8, ampX: 5, ampY: 6, phase: 4.8),
    _FoodSpec('🍣', x: 0.88, y: 0.92, size: 18, freqX: 1.0, freqY: 1.3, ampX: 3, ampY: 7, phase: 6.0),
  ];

  @override
  Widget build(BuildContext context) {
    const opacity = 0.05;
    return AnimatedBuilder(
      animation: floatAnim,
      builder: (context, _) {
        return IgnorePointer(
          child: Stack(
            children: _specs.map((s) {
              final t = floatAnim.value * 2 * math.pi;
              final dx = math.sin(t * s.freqX + s.phase) * s.ampX;
              final dy = math.cos(t * s.freqY + s.phase) * s.ampY;
              return Align(
                alignment: Alignment(s.x, s.y),
                child: Transform.translate(
                  offset: Offset(dx, dy),
                  child: Opacity(opacity: opacity, child: Text(s.emoji, style: TextStyle(fontSize: s.size))),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _FoodSpec {
  const _FoodSpec(this.emoji,
      {required this.x, required this.y, required this.size,
        required this.freqX, required this.freqY,
        required this.ampX, required this.ampY, required this.phase});
  final String emoji;
  final double x, y, size, freqX, freqY, ampX, ampY, phase;
}