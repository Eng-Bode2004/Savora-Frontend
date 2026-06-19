import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/animated_background.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/reveal.dart';
import 'delivery_choice_screen.dart';

const _kAccent = Color(0xFFE8A838);

class PasswordEntryScreen extends StatefulWidget {
  const PasswordEntryScreen({
    super.key,
    required this.phone,
    this.isDarkMode = true,
  });

  final String phone;
  final bool isDarkMode;

  @override
  State<PasswordEntryScreen> createState() => _PasswordEntryScreenState();
}

class _PasswordEntryScreenState extends State<PasswordEntryScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _float;
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmFocus = FocusNode();
  bool _passwordFocused = false;
  bool _confirmFocused = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _error;
  late bool _isDarkMode;

  Color get _bgColor => _isDarkMode ? AppColors.espresso : const Color(0xFFFDFBF7);
  Color get _bgColor2 => _isDarkMode ? AppColors.espresso : const Color(0xFFF7F4EE);
  Color get _textColor => _isDarkMode ? AppColors.cream : const Color(0xFF161618);
  Color get _subTextColor => _isDarkMode ? AppColors.creamDim : const Color(0xFF8A8A8A);
  Color get _fieldBgColor => _isDarkMode ? AppColors.glass : const Color(0xFFF5F3EF);
  Color get _fieldBorderColor =>
      _isDarkMode ? AppColors.glassBorder : const Color(0xFFE8E4DE);
  Color get _errorColor => _isDarkMode ? const Color(0xFFE57373) : const Color(0xFFD32F2F);

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _float = AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);
    _passwordCtrl.addListener(() => setState(() => _error = null));
    _confirmCtrl.addListener(() => setState(() => _error = null));
    _passwordFocus.addListener(() => setState(() => _passwordFocused = _passwordFocus.hasFocus));
    _confirmFocus.addListener(() => setState(() => _confirmFocused = _confirmFocus.hasFocus));
  }

  @override
  void dispose() {
    _entrance.dispose();
    _float.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  bool get _valid {
    final p = _passwordCtrl.text;
    return p.length >= 8 && _confirmCtrl.text == p;
  }

  void _continue() {
    FocusScope.of(context).unfocus();
    final l = AppLocalizations.of(context);
    final p = _passwordCtrl.text;
    if (p.length < 8) {
      setState(() => _error = l.t('passwordTooShort'));
      HapticFeedback.mediumImpact();
      return;
    }
    if (_confirmCtrl.text != p) {
      setState(() => _error = l.t('passwordsDontMatch'));
      HapticFeedback.mediumImpact();
      return;
    }
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeliveryChoiceScreen(
          phone: widget.phone,
          isDarkMode: _isDarkMode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          _buildBackground(),
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _BackButton(isDark: _isDarkMode, onTap: () => Navigator.of(context).pop()),
                    const SizedBox(height: 36),
                    Reveal(
                      controller: _entrance,
                      start: 0.0,
                      end: 0.6,
                      child: Text(
                        l.t('createPasswordTitle'),
                        style: TextStyle(
                          color: _textColor,
                          fontSize: 30,
                          height: 1.15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Reveal(
                      controller: _entrance,
                      start: 0.15,
                      end: 0.7,
                      child: Text(
                        l.t('createPasswordSubtitle'),
                        style: TextStyle(
                          color: _subTextColor,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    Reveal(
                      controller: _entrance,
                      start: 0.3,
                      end: 0.85,
                      child: _PasswordField(
                        controller: _passwordCtrl,
                        focusNode: _passwordFocus,
                        focused: _passwordFocused,
                        obscure: _obscurePassword,
                        hint: l.t('password'),
                        onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                        isDark: _isDarkMode,
                        fieldBg: _fieldBgColor,
                        fieldBorder: _fieldBorderColor,
                        textColor: _textColor,
                        subTextColor: _subTextColor,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Reveal(
                      controller: _entrance,
                      start: 0.4,
                      end: 0.9,
                      child: _PasswordField(
                        controller: _confirmCtrl,
                        focusNode: _confirmFocus,
                        focused: _confirmFocused,
                        obscure: _obscureConfirm,
                        hint: l.t('confirmPassword'),
                        onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        isDark: _isDarkMode,
                        fieldBg: _fieldBgColor,
                        fieldBorder: _fieldBorderColor,
                        textColor: _textColor,
                        subTextColor: _subTextColor,
                      ),
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Reveal(
                          controller: _entrance,
                          start: 0.5,
                          end: 1.0,
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: _errorColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    const Spacer(),
                    Reveal(
                      controller: _entrance,
                      start: 0.55,
                      end: 1.0,
                      child: PrimaryButton(
                        label: l.t('continue'),
                        icon: Icons.arrow_forward_rounded,
                        onPressed: _valid ? _continue : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.focusNode,
    required this.focused,
    required this.obscure,
    required this.hint,
    required this.onToggle,
    required this.isDark,
    required this.fieldBg,
    required this.fieldBorder,
    required this.textColor,
    required this.subTextColor,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool focused;
  final bool obscure;
  final String hint;
  final VoidCallback onToggle;
  final bool isDark;
  final Color fieldBg, fieldBorder, textColor, subTextColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      height: 62,
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: focused ? AppColors.saffron : fieldBorder,
          width: focused ? 1.6 : 1,
        ),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: AppColors.saffron.withValues(alpha: 0.22),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: focused ? AppColors.saffron : subTextColor,
            size: 20,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              obscureText: obscure,
              keyboardType: TextInputType.visiblePassword,
              cursorColor: AppColors.saffron,
              style: TextStyle(
                color: textColor,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: TextStyle(
                  color: isDark
                      ? AppColors.muted
                      : const Color(0xFF8A8A8A).withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
                counterText: '',
              ),
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: subTextColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.isDark, required this.onTap});
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.glass : Colors.white;
    final border = isDark ? AppColors.glassBorder : const Color(0xFFE8E4DE);
    final iconColor = isDark ? AppColors.cream : const Color(0xFF161618);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(color: border),
        ),
        child: Icon(Icons.arrow_back_rounded, color: iconColor, size: 20),
      ),
    );
  }
}
