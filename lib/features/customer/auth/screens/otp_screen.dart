import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/animated_background.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/reveal.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phone});

  final String phone;

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
      builder: (_) => _SuccessDialog(l: l),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _BackButton(onTap: () => Navigator.of(context).pop()),
                const SizedBox(height: 36),

                Reveal(
                  controller: _entrance,
                  start: 0.0,
                  end: 0.6,
                  child: Text(
                    l.t('verifyYourNumber'),
                    style: const TextStyle(
                      color: AppColors.cream,
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
                    style: const TextStyle(
                      color: AppColors.creamDim,
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
    );
  }
}

class _OtpBoxes extends StatelessWidget {
  const _OtpBoxes({
    required this.length,
    required this.controller,
    required this.focusNode,
    required this.onCompleted,
  });

  final int length;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onCompleted;

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
                  color: AppColors.glass,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: active
                        ? AppColors.saffron
                        : filled
                            ? AppColors.amber.withValues(alpha: 0.6)
                            : AppColors.glassBorder,
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
                  style: const TextStyle(
                    color: AppColors.cream,
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
    required this.onResend,
    required this.l,
  });

  final int seconds;
  final VoidCallback? onResend;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    if (seconds > 0) {
      return Text(
        '${l.t('resendIn')}${seconds.toString().padLeft(2, '0')}',
        style: const TextStyle(color: AppColors.muted, fontSize: 14),
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
  const _SuccessDialog({required this.l});
  final AppLocalizations l;

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
            color: AppColors.espressoSoft,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.glassBorder),
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
                style: const TextStyle(
                  color: AppColors.cream,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.t('welcome'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.creamDim, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.glass,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: const Icon(Icons.arrow_back_rounded,
            color: AppColors.cream, size: 20),
      ),
    );
  }
}
