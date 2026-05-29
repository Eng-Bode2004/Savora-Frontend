import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/animated_background.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/reveal.dart';
import 'otp_screen.dart';

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  final TextEditingController _phone = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _phone.addListener(() => setState(() {}));
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _entrance.dispose();
    _phone.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _valid => _phone.text.length >= 7;

  void _continue() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(
      fadeScaleRoute(OtpScreen(phone: '+20 ${_phone.text}')),
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
                    l.t('whatsYourNumber'),
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
                    l.t('weWillTextYou'),
                    style: const TextStyle(
                      color: AppColors.creamDim,
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
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({
    required this.controller,
    required this.focusNode,
    required this.focused,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      height: 62,
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: focused ? AppColors.saffron : AppColors.glassBorder,
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
          const Text(
            '+20',
            style: TextStyle(
              color: AppColors.cream,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            width: 1,
            height: 26,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            color: AppColors.glassBorder,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.phone,
              cursorColor: AppColors.saffron,
              style: const TextStyle(
                color: AppColors.cream,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '10 1234 5678',
                hintStyle: TextStyle(
                  color: AppColors.muted,
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
