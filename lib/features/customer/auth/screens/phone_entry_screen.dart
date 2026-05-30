import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/animated_background.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/reveal.dart';
import 'otp_screen.dart';

const _kAccent = Color(0xFFE8A838);

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key, this.isDarkMode = true});

  final bool isDarkMode;

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _float;
  final TextEditingController _phone = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _focused = false;

  late bool _isDarkMode;

  Color get _bgColor => _isDarkMode ? AppColors.espresso : const Color(0xFFFDFBF7);
  Color get _bgColor2 => _isDarkMode ? AppColors.espresso : const Color(0xFFF7F4EE);
  Color get _textColor => _isDarkMode ? AppColors.cream : const Color(0xFF161618);
  Color get _subTextColor => _isDarkMode ? AppColors.creamDim : const Color(0xFF8A8A8A);
  Color get _fieldBgColor => _isDarkMode ? AppColors.glass : const Color(0xFFF5F3EF);
  Color get _fieldBorderColor =>
      _isDarkMode ? AppColors.glassBorder : const Color(0xFFE8E4DE);

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
    _phone.addListener(() => setState(() {}));
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _entrance.dispose();
    _float.dispose();
    _phone.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _valid => _phone.text.length >= 7;

  // ★ FIX: route through OTP (was jumping to RoleSelectionScreen)
  void _continue() {
    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();
    final fullNumber = '+20 ${_phone.text}';
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtpScreen(
          contact: fullNumber,
          isDarkMode: _isDarkMode,
          viaEmail: false, // phone OTP
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
                        l.t('whatsYourNumber'),
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
                        l.t('weWillTextYou'),
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
                      child: _PhoneField(
                        controller: _phone,
                        focusNode: _focus,
                        focused: _focused,
                        isDark: _isDarkMode,
                        fieldBg: _fieldBgColor,
                        fieldBorder: _fieldBorderColor,
                        textColor: _textColor,
                      ),
                    ),
                    const Spacer(),
                    Reveal(
                      controller: _entrance,
                      start: 0.45,
                      end: 1.0,
                      child: PrimaryButton(
                        label: l.t('sendCode'),
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

class _PhoneField extends StatelessWidget {
  const _PhoneField({
    required this.controller,
    required this.focusNode,
    required this.focused,
    required this.isDark,
    required this.fieldBg,
    required this.fieldBorder,
    required this.textColor,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool focused;
  final bool isDark;
  final Color fieldBg, fieldBorder, textColor;

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
          const Text('🇪🇬', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Text(
            '+20',
            style: TextStyle(
              color: textColor,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            width: 1,
            height: 26,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            color: fieldBorder,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.phone,
              cursorColor: AppColors.saffron,
              style: TextStyle(
                color: textColor,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '10 1234 5678',
                hintStyle: TextStyle(
                  color: isDark
                      ? AppColors.muted
                      : const Color(0xFF8A8A8A).withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                ),
                counterText: '',
              ),
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