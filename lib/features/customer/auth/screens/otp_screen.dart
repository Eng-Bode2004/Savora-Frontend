import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/animated_background.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/reveal.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phone, this.isDarkMode = true});

  final String phone;
  final bool isDarkMode;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  static const int _length = 5;

  late final AnimationController _entrance;
  final TextEditingController _code = TextEditingController();
  final FocusNode _focus = FocusNode();

  Timer? _timer;
  int _seconds = 45;

  bool get _isDark => widget.isDarkMode;

  Color get _bgColor => _isDark ? AppColors.espresso : const Color(0xFFFDFBF7);
  Color get _textColor => _isDark ? AppColors.cream : const Color(0xFF1A1410);
  Color get _subTextColor => _isDark ? AppColors.creamDim : const Color(0xFF6B6258);

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _code.addListener(() => setState(() {}));
    _startTimer();
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) _focus.requestFocus();
    });
  }

  void _startTimer() {
    _seconds = 45;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds == 0) {
        t.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    _code.dispose();
    _focus.dispose();
    _timer?.cancel();
    super.dispose();
  }

  bool get _complete => _code.text.length == _length;

  void _verify() {
    final l = AppLocalizations.of(context);
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _SuccessDialog(l: l, isDark: _isDark),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _bgColor,
        body: _isDark
            ? AnimatedBackground(
                child: _buildBody(l),
              )
            : _buildBody(l),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _BackButton(
                      isDark: _isDark,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 36),

                    Reveal(
                      controller: _entrance,
                      start: 0.0,
                      end: 0.6,
                      child: Text(
                        l.t('verifyYourNumber'),
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
                        '${l.t('enterCode')}${widget.phone}',
                        style: TextStyle(
                          color: _subTextColor,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    Reveal(
                      controller: _entrance,
                      start: 0.3,
                      end: 0.85,
                      child: _OtpBoxes(
                        length: _length,
                        controller: _code,
                        focusNode: _focus,
                        isDark: _isDark,
                        onCompleted: (_) {},
                      ),
                    ),
                    const SizedBox(height: 28),

                    Reveal(
                      controller: _entrance,
                      start: 0.4,
                      end: 0.9,
                      child: Center(
                        child: _ResendRow(
                          seconds: _seconds,
                          isDark: _isDark,
                          onResend: _seconds == 0 ? _startTimer : null,
                          l: l,
                        ),
                      ),
                    ),

                    const Spacer(),

                    Reveal(
                      controller: _entrance,
                      start: 0.45,
                      end: 1.0,
                      child: PrimaryButton(
                        label: l.t('verify'),
                        onPressed: _complete ? _verify : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OtpBoxes extends StatelessWidget {
  const _OtpBoxes({
    required this.length,
    required this.controller,
    required this.focusNode,
    required this.isDark,
    required this.onCompleted,
  });

  final int length;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isDark;
  final ValueChanged<String> onCompleted;

  Color get _boxBg => isDark ? AppColors.glass : const Color(0x0A1A1410);
  Color get _boxBorder => isDark ? AppColors.glassBorder : const Color(0xFFE8E4DE);
  Color get _textColor => isDark ? AppColors.cream : const Color(0xFF1A1410);

  @override
  Widget build(BuildContext context) {
    final text = controller.text;

    return GestureDetector(
      onTap: () => focusNode.requestFocus(),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(length, (i) {
              final filled = i < text.length;
              final active = i == text.length && focusNode.hasFocus;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                width: 54,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _boxBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: active
                        ? AppColors.saffron
                        : filled
                            ? AppColors.amber.withValues(alpha: 0.6)
                            : _boxBorder,
                    width: active ? 1.8 : 1.2,
                  ),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: AppColors.saffron.withValues(alpha: 0.25),
                            blurRadius: 16,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  filled ? text[i] : '',
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: TextInputType.number,
                maxLength: length,
                showCursor: false,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (v) {
                  if (v.length == length) onCompleted(v);
                },
                decoration: const InputDecoration(counterText: ''),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResendRow extends StatelessWidget {
  const _ResendRow({
    required this.seconds,
    required this.isDark,
    required this.onResend,
    required this.l,
  });

  final int seconds;
  final bool isDark;
  final VoidCallback? onResend;
  final AppLocalizations l;

  Color get _muted => isDark ? AppColors.muted : const Color(0xFF8A8073);

  @override
  Widget build(BuildContext context) {
    if (seconds > 0) {
      return Text(
        '${l.t('resendIn')}${seconds.toString().padLeft(2, '0')}',
        style: TextStyle(color: _muted, fontSize: 14),
      );
    }
    return GestureDetector(
      onTap: onResend,
      child: Text(
        l.t('resendCode'),
        style: const TextStyle(
          color: AppColors.saffron,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog({required this.l, required this.isDark});

  final AppLocalizations l;
  final bool isDark;

  Color get _bg => isDark ? AppColors.espressoSoft : Colors.white;
  Color get _text => isDark ? AppColors.cream : const Color(0xFF1A1410);
  Color get _sub => isDark ? AppColors.creamDim : const Color(0xFF6B6258);
  Color get _border => isDark ? AppColors.glassBorder : const Color(0xFFE8E4DE);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutBack,
        builder: (context, t, child) {
          return Transform.scale(scale: t, child: child);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  gradient: AppColors.accentGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: AppColors.espresso, size: 40),
              ),
              const SizedBox(height: 22),
              Text(
                l.t('youreIn'),
                style: TextStyle(
                  color: _text,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.t('welcome'),
                textAlign: TextAlign.center,
                style: TextStyle(color: _sub, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.isDark, required this.onTap});

  final bool isDark;
  final VoidCallback onTap;

  Color get _bg => isDark ? AppColors.glass : const Color(0x0A1A1410);
  Color get _border => isDark ? AppColors.glassBorder : const Color(0xFFE8E4DE);
  Color get _icon => isDark ? AppColors.cream : const Color(0xFF1A1410);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _bg,
          shape: BoxShape.circle,
          border: Border.all(color: _border),
        ),
        child: Icon(Icons.arrow_back_rounded, color: _icon, size: 20),
      ),
    );
  }
}
