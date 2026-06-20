import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/animated_background.dart';
import '../../../../core/network/savora_api.dart';
import '../../../../state/providers/auth_provider.dart';
import '../../shell/customer_shell.dart';
import '../../../chef/shell/chef_shell.dart';
import 'name_entry_screen.dart' show NameEntryScreen;
import 'otp_screen.dart';

const _kAccent = Color(0xFFE8A838);
const _kAccentLight = Color(0xFFF0B040);
const _kAccentDark = Color(0xFFD4952E);

enum _LoginMethod { phone, account }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _plate;
  late final AnimationController _float;
  late final AnimationController _breathe;
  late final AnimationController _shimmer;

  final _userController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  final _userFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passFocus = FocusNode();

  bool _isDarkMode = themeModeNotifier.value == ThemeMode.dark;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _guestLoading = false;
  final bool _isLoginMode = true;
  bool _buttonPressed = false;

  _LoginMethod _method = _LoginMethod.phone;

  static const List<String> _emojis = ['🍲', '🥘', '🍕', '🥗', '🍜', '🍰', '🫕'];
  int _emojiIdx = 0;

  static const List<_Lang> _languages = [
    _Lang('en', 'English', 'English', '🇬🇧'),
    _Lang('ar', 'Arabic', 'العربية', '🇸🇦'),
    _Lang('es', 'Spanish', 'Español', '🇪🇸'),
    _Lang('zh', 'Chinese', '中文', '🇨🇳'),
    _Lang('fr', 'French', 'Français', '🇫🇷'),
  ];

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _plate = AnimationController(vsync: this, duration: const Duration(seconds: 16))
      ..repeat();
    _float = AnimationController(vsync: this, duration: const Duration(seconds: 7))
      ..repeat(reverse: true);
    _breathe = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
    _shimmer = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat();

    _userFocus.addListener(() => setState(() {}));
    _phoneFocus.addListener(() => setState(() {}));
    _passFocus.addListener(() => setState(() {}));

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _entrance.forward();
    });
    _scheduleEmojiCycle();
  }

  void _scheduleEmojiCycle() {
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() => _emojiIdx = (_emojiIdx + 1) % _emojis.length);
      _scheduleEmojiCycle();
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    _plate.dispose();
    _float.dispose();
    _breathe.dispose();
    _shimmer.dispose();
    _userController.dispose();
    _phoneController.dispose();
    _passController.dispose();
    _userFocus.dispose();
    _phoneFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _toggleDarkMode() {
    HapticFeedback.lightImpact();
    setState(() {
      _isDarkMode = !_isDarkMode;
      themeModeNotifier.value = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _setMethod(_LoginMethod m) {
    if (_method == m) return;
    HapticFeedback.selectionClick();
    setState(() => _method = m);
  }

  void _goToSignup() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, a, __) => const NameEntryScreen(),
        transitionsBuilder: (_, a, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeOutExpo),
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 0.06), end: Offset.zero)
                .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _enterShell({String? roleKey}) {
    Widget page;
    switch (roleKey) {
      case 'Chef':
        page = const ChefShell();
        break;
      case 'Delivery':
        // No Delivery shell yet — send to customer as fallback
        page = const CustomerShell();
        break;
      default:
        page = const CustomerShell();
    }

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, a, __) => page,
        transitionsBuilder: (_, a, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeOutExpo),
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 0.04), end: Offset.zero)
                .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 600),
      ),
          (route) => false,
    );
  }

  void _login() {
    HapticFeedback.mediumImpact();
    if (_method == _LoginMethod.phone) {
      final phone = _phoneController.text.trim();
      if (phone.length < 7) return;
      final fullNumber = '+20 $phone';
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpScreen(
            contact: fullNumber,
            isDarkMode: _isDarkMode,
            viaEmail: false,
            onVerified: () => _enterShell(),
          ),
        ),
      );
      return;
    }
    _doLoginWithEmail();
  }

  Future<void> _doLoginWithEmail() async {
    final email = _userController.text.trim();
    final password = _passController.text;
    if (email.isEmpty || password.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final result = await SavoraApi.loginUser(identifier: email, password: password);
      if (!mounted) return;

      final data = result['data'] as Map<String, dynamic>?;
      final user = data?['user'] as Map<String, dynamic>?;
      final token = data?['token'] as String? ?? '';
      final userId = user?['_id'] as String? ?? '';
      final roleData = data?['role'] as Map<String, dynamic>?;
      final englishName = roleData?['english_name'] as String?;

      authState.login(userId: userId, email: email, token: token);

      setState(() => _isLoading = false);
      _enterShell(roleKey: englishName);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ★ Guest mode — straight into the customer app, no auth.
  void _continueAsGuest() {
    HapticFeedback.mediumImpact();
    setState(() => _guestLoading = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _guestLoading = false);
      _enterShell();
    });
  }

  // ── Language picker bottom sheet ──
  void _openLanguagePicker() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      isScrollControlled: true,
      builder: (_) => _LanguageSheet(
        languages: _languages,
        current: localeProvider.locale.languageCode,
        isDark: _isDarkMode,
        onSelect: (code) {
          HapticFeedback.selectionClick();
          localeProvider.setLocale(Locale(code));
          Navigator.of(context).pop();
        },
      ),
    );
  }

  double _t(double start, double end) {
    final v = _entrance.value.clamp(start, end);
    return ((v - start) / (end - start)).clamp(0.0, 1.0);
  }

  static double _ease(double t) => 1.0 - math.pow(1.0 - t, 3.5).toDouble();
  static double _easeBack(double t) {
    const c1 = 1.70158, c3 = c1 + 1;
    return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2);
  }

  // ════════ THEME COLORS ════════
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

  _Lang get _currentLang =>
      _languages.firstWhere((l) => l.code == localeProvider.locale.languageCode);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isRtl = l.locale.languageCode == 'ar';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _bgColor,
        resizeToAvoidBottomInset: true,
        body: AnimatedBuilder(
          animation: Listenable.merge([_entrance, _plate, _float, _breathe, _shimmer]),
          builder: (context, _) {
            return Stack(
              children: [
                _buildBackground(),
                if (!_isDarkMode) _FloatingDecor(floatAnim: _float),
                SafeArea(
                  child: Directionality(
                    textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            _buildTopBar(_t(0.0, 0.25), l),
                            const SizedBox(height: 24),
                            _buildPlateHero(_t(0.05, 0.40)),
                            const SizedBox(height: 20),
                            _buildWordmark(_t(0.12, 0.45)),
                            const SizedBox(height: 8),
                            _buildTagline(_t(0.18, 0.50), l),
                            const SizedBox(height: 30),
                            _buildLoginCard(_t(0.30, 0.70), l),
                            const SizedBox(height: 16),
                            _buildGuestButton(_t(0.50, 0.82), l),
                            const SizedBox(height: 22),
                            _buildSocialSection(_t(0.60, 0.90), l),
                            const SizedBox(height: 22),
                            _buildTerms(_t(0.72, 1.00), l),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ════════ BACKGROUND ════════
  Widget _buildBackground() {
    if (_isDarkMode) {
      return const AnimatedBackground(child: SizedBox.expand());
    }
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
  Widget _buildTopBar(double t, AppLocalizations l) {
    return Opacity(
      opacity: _ease(t),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _openLanguagePicker,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _fieldBorderColor, width: 0.5),
                boxShadow: [
                  BoxShadow(color: _shadowColor, blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language_rounded, size: 16, color: _kAccent),
                  const SizedBox(width: 6),
                  Text(_currentLang.flag, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 5),
                  Text(
                    _currentLang.code.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _textColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: _subTextColor),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: _toggleDarkMode,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _cardColor,
                shape: BoxShape.circle,
                border: Border.all(color: _fieldBorderColor, width: 0.5),
                boxShadow: [
                  BoxShadow(color: _shadowColor, blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (c, a) =>
                    RotationTransition(turns: a, child: FadeTransition(opacity: a, child: c)),
                child: Icon(
                  _isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  key: ValueKey(_isDarkMode),
                  size: 20,
                  color: _isDarkMode ? _kAccent : const Color(0xFF2C1810),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════ PLATE HERO ════════
  Widget _buildPlateHero(double t) {
    final scale = 0.70 + _easeBack(t.clamp(0.0, 1.0)) * 0.30;
    final spin1 = _plate.value * 2 * math.pi;
    final spin2 = -_plate.value * 2 * math.pi * 1.3;
    final breatheScale = 1.0 + (_breathe.value - 0.5) * 0.025;
    final ringColor = _kAccent.withValues(alpha: _isDarkMode ? 0.18 : 0.20);

    return Opacity(
      opacity: _ease(t),
      child: Transform.scale(
        scale: scale * breatheScale,
        child: SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 140 + _breathe.value * 6,
                height: 140 + _breathe.value * 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [_kAccent.withValues(alpha: 0.12), Colors.transparent],
                  ),
                ),
              ),
              Transform.rotate(
                angle: spin1,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: ringColor, width: 1),
                  ),
                  child: Stack(
                    children: List.generate(8, (i) {
                      final a = (i / 8) * 2 * math.pi;
                      return Positioned(
                        left: 65 + math.cos(a) * 63 - 1.5,
                        top: 65 + math.sin(a) * 63 - 1.5,
                        child: Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _kAccent.withValues(alpha: 0.25),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              Transform.rotate(
                angle: spin2,
                child: Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: ringColor.withValues(alpha: 0.5), width: 1),
                  ),
                ),
              ),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.3, -0.3),
                    radius: 1.3,
                    colors: _isDarkMode
                        ? const [Color(0xFF4A2512), Color(0xFF2A1508), Color(0xFF1A0D05)]
                        : const [Color(0xFFFFF8F0), Color(0xFFF5EDE3), Color(0xFFE8DDD0)],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                  border: Border.all(color: _kAccent.withValues(alpha: 0.28), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: _isDarkMode
                          ? Colors.black.withValues(alpha: 0.4)
                          : _kAccent.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (c, a) =>
                        ScaleTransition(scale: a, child: FadeTransition(opacity: a, child: c)),
                    child: Text(
                      _emojis[_emojiIdx],
                      key: ValueKey(_emojiIdx),
                      style: const TextStyle(fontSize: 36),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════ WORDMARK ════════
  Widget _buildWordmark(double t) {
    const word = 'Savora';
    final italic = {1, 3, 5};
    return Opacity(
      opacity: _ease(t),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: word.characters.toList().asMap().entries.map((e) {
            final charT = _t(0.12 + e.key * 0.03, 0.12 + (e.key + 1) * 0.03 + 0.08);
            final isItalic = italic.contains(e.key);
            return Transform.translate(
              offset: Offset(0, (1 - _ease(charT)) * 14),
              child: Opacity(
                opacity: _ease(charT),
                child: Text(
                  e.value,
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                    color: isItalic ? _kAccent : _textColor,
                    height: 1.0,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ════════ TAGLINE ════════
  Widget _buildTagline(double t, AppLocalizations l) {
    return Transform.translate(
      offset: Offset(0, (1 - _ease(t)) * 10),
      child: Opacity(
        opacity: _ease(t),
        child: Text(
          l.t('splashTagline'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _kAccent,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  // ════════ LOGIN CARD ════════
  Widget _buildLoginCard(double t, AppLocalizations l) {
    return Transform.translate(
      offset: Offset(0, (1 - _ease(t)) * 20),
      child: Opacity(
        opacity: _ease(t),
        child: Container(
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
              // ── method toggle ──
              _buildMethodToggle(l),
              const SizedBox(height: 18),
              // ── identity field (phone OR account) ──
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SizeTransition(sizeFactor: anim, axisAlignment: -1, child: child),
                ),
                child: _method == _LoginMethod.phone
                    ? _buildPhoneField(l, key: const ValueKey('phone'))
                    : _buildTextField(
                  key: const ValueKey('account'),
                  controller: _userController,
                  focusNode: _userFocus,
                  hint: l.t('phoneOrUsername'),
                  icon: Icons.person_outline_rounded,
                  isPassword: false,
                ),
              ),
              if (_method == _LoginMethod.account) ...[
                const SizedBox(height: 14),
                _buildTextField(
                  controller: _passController,
                  focusNode: _passFocus,
                  hint: l.t('password'),
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                ),
              ],
              const SizedBox(height: 10),
              if (_isLoginMode && _method == _LoginMethod.account)
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {},
                    child: Text(
                      l.t('forgotPassword'),
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _kAccent,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              _buildLoginButton(l),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: _goToSignup,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        l.t('dontHaveAccount'),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 13,
                          color: _subTextColor,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        l.t('signUp'),
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
        ),
      ),
    );
  }

  // ════════ METHOD TOGGLE — Phone / Account ════════
  Widget _buildMethodToggle(AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _fieldBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _fieldBorderColor, width: 0.5),
      ),
      child: Row(
        children: [
          _methodTab(
            label: l.t('phoneNumber'),
            icon: Icons.phone_iphone_rounded,
            selected: _method == _LoginMethod.phone,
            onTap: () => _setMethod(_LoginMethod.phone),
          ),
          _methodTab(
            label: l.t('username'),
            icon: Icons.alternate_email_rounded,
            selected: _method == _LoginMethod.account,
            onTap: () => _setMethod(_LoginMethod.account),
          ),
        ],
      ),
    );
  }

  Widget _methodTab({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(colors: [_kAccentLight, _kAccentDark])
                : null,
            borderRadius: BorderRadius.circular(11),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? const Color(0xFF2C1810) : _subTextColor,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected ? const Color(0xFF2C1810) : _subTextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════ PHONE FIELD — +20 Egypt ════════
  Widget _buildPhoneField(AppLocalizations l, {Key? key}) {
    final focused = _phoneFocus.hasFocus;
    return AnimatedContainer(
      key: key,
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
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Text('🇪🇬', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 6),
          Text(
            '+20',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
          ),
          Container(
            width: 1,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: _fieldBorderColor,
          ),
          Expanded(
            child: TextField(
              controller: _phoneController,
              focusNode: _phoneFocus,
              keyboardType: TextInputType.phone,
              cursorColor: _kAccent,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
                color: _textColor,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              decoration: InputDecoration(
                hintText: '10 1234 5678',
                hintStyle: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  letterSpacing: 1.0,
                  color: _subTextColor.withValues(alpha: 0.6),
                ),
                border: InputBorder.none,
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  // ════════ LOGIN BUTTON ════════
  Widget _buildLoginButton(AppLocalizations l) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.mediumImpact();
        setState(() => _buttonPressed = true);
      },
      onTapUp: (_) {
        setState(() => _buttonPressed = false);
        _login();
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
                left: -90 + _shimmer.value * 480,
                top: 0,
                bottom: 0,
                width: 70,
                child: Container(
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
                l.t('logIn'),
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

  // ════════ GUEST BUTTON ════════
  Widget _buildGuestButton(double t, AppLocalizations l) {
    return Transform.translate(
      offset: Offset(0, (1 - _ease(t)) * 14),
      child: Opacity(
        opacity: _ease(t),
        child: GestureDetector(
          onTap: _guestLoading ? null : _continueAsGuest,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kAccent.withValues(alpha: 0.55), width: 1.2),
              boxShadow: [
                BoxShadow(color: _shadowColor, blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_guestLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(_kAccentDark),
                    ),
                  )
                else ...[
                  const Icon(Icons.fastfood_rounded, size: 18, color: _kAccentDark),
                  const SizedBox(width: 8),
                  Text(
                    l.t('continueAsGuest'),
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: _kAccentDark,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded, size: 16, color: _kAccentDark),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ════════ TEXT FIELD ════════
  Widget _buildTextField({
    Key? key,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    required bool isPassword,
  }) {
    final focused = focusNode.hasFocus;
    return AnimatedContainer(
      key: key,
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
            ? [
          BoxShadow(
            color: _kAccent.withValues(alpha: 0.16),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ]
            : null,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword ? _obscurePassword : false,
        style: TextStyle(fontFamily: 'DM Sans', fontSize: 14, color: _textColor),
        cursorColor: _kAccent,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            color: _subTextColor.withValues(alpha: 0.6),
          ),
          prefixIcon: Icon(
            icon,
            size: 20,
            color: focused ? _kAccent : _subTextColor.withValues(alpha: 0.5),
          ),
          suffixIcon: isPassword
              ? GestureDetector(
            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
            child: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
              color: _subTextColor.withValues(alpha: 0.5),
            ),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        ),
      ),
    );
  }

  // ════════ SOCIAL ════════
  Widget _buildSocialSection(double t, AppLocalizations l) {
    return Transform.translate(
      offset: Offset(0, (1 - _ease(t)) * 14),
      child: Opacity(
        opacity: _ease(t),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _divider(toRight: true)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    l.t('orContinueWith'),
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      color: _subTextColor.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                Expanded(child: _divider(toRight: false)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SocialButton(
                    label: l.t('continueWithGoogle'),
                    icon: Icons.g_mobiledata_rounded,
                    isDark: _isDarkMode,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SocialButton(
                    label: l.t('continueWithApple'),
                    icon: Icons.apple,
                    isDark: _isDarkMode,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider({required bool toRight}) {
    return Container(
      height: 0.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: toRight
              ? [Colors.transparent, _subTextColor.withValues(alpha: 0.25)]
              : [_subTextColor.withValues(alpha: 0.25), Colors.transparent],
        ),
      ),
    );
  }

  // ════════ TERMS ════════
  Widget _buildTerms(double t, AppLocalizations l) {
    return Opacity(
      opacity: _ease(t),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 11,
            fontWeight: FontWeight.w300,
            color: _subTextColor.withValues(alpha: 0.6),
            height: 1.5,
          ),
          children: [
            TextSpan(text: l.t('termsPrefix')),
            TextSpan(text: l.t('terms'), style: const TextStyle(fontWeight: FontWeight.w500, color: _kAccent)),
            TextSpan(text: l.t('and')),
            TextSpan(text: l.t('privacyPolicy'), style: const TextStyle(fontWeight: FontWeight.w500, color: _kAccent)),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// LANGUAGE MODEL + BOTTOM SHEET
// ════════════════════════════════════════════════════════
class _Lang {
  const _Lang(this.code, this.english, this.native, this.flag);
  final String code, english, native, flag;
}

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet({
    required this.languages,
    required this.current,
    required this.isDark,
    required this.onSelect,
  });

  final List<_Lang> languages;
  final String current;
  final bool isDark;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final sheetColor = isDark ? AppColors.espressoSoft : Colors.white;
    final textColor = isDark ? AppColors.cream : const Color(0xFF161618);
    final subColor = isDark ? AppColors.muted : const Color(0xFF8A8A8A);
    final fieldBorder = isDark ? AppColors.glassBorder : const Color(0xFFE8E4DE);
    final tileBg = isDark ? AppColors.glass : const Color(0xFFF5F3EF);

    return Container(
      decoration: BoxDecoration(
        color: sheetColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: subColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.language_rounded, color: _kAccent, size: 22),
              const SizedBox(width: 10),
              Text(
                'Choose language',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...languages.map((lang) {
            final selected = lang.code == current;
            return GestureDetector(
              onTap: () => onSelect(lang.code),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: selected
                      ? _kAccent.withValues(alpha: isDark ? 0.16 : 0.10)
                      : tileBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected ? _kAccent.withValues(alpha: 0.5) : fieldBorder,
                    width: selected ? 1.4 : 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Text(lang.flag, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.native,
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          Text(
                            lang.english,
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 12,
                              color: subColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selected)
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: _kAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded,
                            size: 16, color: Color(0xFF2C1810)),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// FLOATING DECOR (light mode only)
// ════════════════════════════════════════════════════════
class _FloatingDecor extends StatelessWidget {
  const _FloatingDecor({required this.floatAnim});

  final AnimationController floatAnim;

  static const List<_FoodSpec> _specs = [
    _FoodSpec('🍕', x: -0.84, y: -0.78, size: 22, freqX: 1.0, freqY: 0.9, ampX: 4, ampY: 7, phase: 0.0),
    _FoodSpec('🥗', x: 0.86, y: -0.68, size: 20, freqX: 1.2, freqY: 1.1, ampX: 5, ampY: 6, phase: 1.2),
    _FoodSpec('🍜', x: -0.90, y: 0.05, size: 18, freqX: 0.9, freqY: 1.0, ampX: 3, ampY: 8, phase: 2.4),
    _FoodSpec('🫕', x: 0.90, y: 0.15, size: 20, freqX: 1.3, freqY: 1.2, ampX: 4, ampY: 7, phase: 3.6),
    _FoodSpec('🥘', x: -0.80, y: 0.80, size: 22, freqX: 1.1, freqY: 0.8, ampX: 5, ampY: 6, phase: 4.8),
    _FoodSpec('🍣', x: 0.84, y: 0.86, size: 18, freqX: 1.0, freqY: 1.3, ampX: 3, ampY: 7, phase: 6.0),
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
                  child: Opacity(
                    opacity: opacity,
                    child: Text(s.emoji, style: TextStyle(fontSize: s.size)),
                  ),
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
      {required this.x,
        required this.y,
        required this.size,
        required this.freqX,
        required this.freqY,
        required this.ampX,
        required this.ampY,
        required this.phase});
  final String emoji;
  final double x, y, size, freqX, freqY, ampX, ampY, phase;
}

// ════════════════════════════════════════════════════════
// SOCIAL BUTTON
// ════════════════════════════════════════════════════════
class _SocialButton extends StatefulWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.isDark,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool isDark;
  final VoidCallback onPressed;

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(_pressed ? 0.97 : 1.0),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.glassStrong : const Color(0xFFF5F3EF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isDark
                ? AppColors.glassBorder
                : const Color(0xFFE8E4DE),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              size: 20,
              color: widget.isDark ? AppColors.cream.withValues(alpha: 0.8) : const Color(0xFF2C1810),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                widget.label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: widget.isDark ? AppColors.cream.withValues(alpha: 0.75) : const Color(0xFF2C1810),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}