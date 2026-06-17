import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/animated_background.dart';
import 'otp_screen.dart';

const _kAccent = Color(0xFFE8A838);
const _kAccentLight = Color(0xFFF0B040);
const _kAccentDark = Color(0xFFD4952E);

class DeliveryChoiceScreen extends StatefulWidget {
  const DeliveryChoiceScreen({
    super.key,
    required this.phone,
    this.isDarkMode = true,
  });

  final String phone;
  final bool isDarkMode;

  @override
  State<DeliveryChoiceScreen> createState() => _DeliveryChoiceScreenState();
}

class _DeliveryChoiceScreenState extends State<DeliveryChoiceScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _float;
  bool _selectedWhatsApp = false;
  bool _selectedSms = false;
  late bool _isDarkMode;

  Color get _bgColor => _isDarkMode ? AppColors.espresso : const Color(0xFFFDFBF7);
  Color get _bgColor2 => _isDarkMode ? AppColors.espresso : const Color(0xFFF7F4EE);
  Color get _textColor => _isDarkMode ? AppColors.cream : const Color(0xFF161618);
  Color get _subTextColor => _isDarkMode ? AppColors.creamDim : const Color(0xFF8A8A8A);
  Color get _cardColor => _isDarkMode ? AppColors.glass : Colors.white;
  Color get _fieldBorderColor =>
      _isDarkMode ? AppColors.glassBorder : const Color(0xFFE8E4DE);
  Color get _shadowColor =>
      _isDarkMode ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.06);
  Color get _fieldBgColor => _isDarkMode ? AppColors.glass : const Color(0xFFF5F3EF);

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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

  bool get _canContinue => _selectedWhatsApp || _selectedSms;

  void _continueToOtp() {
    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();
    if (_selectedWhatsApp) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpScreen(
            contact: widget.phone,
            isDarkMode: _isDarkMode,
            viaWhatsApp: true,
          ),
        ),
      );
    } else if (_selectedSms) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpScreen(
            contact: widget.phone,
            isDarkMode: _isDarkMode,
            viaSms: true,
          ),
        ),
      );
    }
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
            SafeArea(
              child: AnimatedBuilder(
                animation: Listenable.merge([_entrance, _float]),
                builder: (context, _) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          _reveal(0.0, 0.22, _buildBackButton()),
                          const SizedBox(height: 32),
                          _reveal(0.06, 0.35, _buildHero()),
                          const SizedBox(height: 20),
                          _reveal(0.14, 0.45, _buildTitle(l)),
                          const SizedBox(height: 10),
                          _reveal(0.20, 0.55, _buildSubtitle(l)),
                          const SizedBox(height: 32),
                          _reveal(0.30, 0.70, _buildWhatsAppCard(l), dy: 26),
                          const SizedBox(height: 14),
                          _reveal(0.40, 0.80, _buildSmsCard(l), dy: 26),
                          const SizedBox(height: 24),
                          _reveal(0.55, 1.0, _buildContinueButton(l)),
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

  Widget _buildBackground() {
    if (_isDarkMode) return const AnimatedBackground(child: SizedBox.expand());
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
          top: -80, right: -50,
          child: Container(
            width: 240, height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [_kAccent.withValues(alpha: 0.08), Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -70, left: -60,
          child: Container(
            width: 220, height: 220,
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

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: _cardColor,
          shape: BoxShape.circle,
          border: Border.all(color: _fieldBorderColor, width: 0.5),
          boxShadow: [BoxShadow(color: _shadowColor, blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Icon(Icons.arrow_back_rounded, size: 20, color: _textColor),
      ),
    );
  }

  Widget _buildHero() {
    final bob = math.sin(_float.value * 2 * math.pi) * 6;
    return Center(
      child: Transform.translate(
        offset: Offset(0, bob),
        child: Container(
          width: 84, height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [_kAccentLight, _kAccentDark]),
            boxShadow: [
              BoxShadow(
                color: _kAccent.withValues(alpha: 0.4),
                blurRadius: 22, spreadRadius: -4, offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.markunread_rounded, color: Color(0xFF2C1810), size: 38),
        ),
      ),
    );
  }

  Widget _buildTitle(AppLocalizations l) {
    return Text(
      l.t('chooseDeliveryTitle'),
      style: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: _textColor,
        height: 1.15,
      ),
    );
  }

  Widget _buildSubtitle(AppLocalizations l) {
    return Text(
      '${l.t('chooseDeliverySubtitle')} ${widget.phone}',
      style: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 14,
        color: _subTextColor,
        height: 1.4,
      ),
    );
  }

  Widget _buildWhatsAppCard(AppLocalizations l) {
    final selected = _selectedWhatsApp;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedWhatsApp = true;
          _selectedSms = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment(-0.8, -1.0),
                  end: Alignment(0.8, 1.0),
                  colors: [_kAccentLight, _kAccent, _kAccentDark],
                )
              : null,
          color: selected ? null : _cardColor,
          borderRadius: BorderRadius.circular(20),
          border: selected ? null : Border.all(color: _fieldBorderColor, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: selected ? _kAccent.withValues(alpha: 0.30) : _shadowColor,
              blurRadius: selected ? 18 : 16,
              spreadRadius: -4,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF2C1810).withValues(alpha: 0.12)
                    : const Color(0xFF25D366).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.chat_rounded,
                color: selected ? const Color(0xFF2C1810) : const Color(0xFF25D366),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.t('whatsapp'),
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: selected ? const Color(0xFF2C1810) : _textColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    l.t('whatsappSub'),
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      color: selected
                          ? const Color(0xFF2C1810).withValues(alpha: 0.7)
                          : _subTextColor,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              size: 20,
              color: selected ? const Color(0xFF2C1810) : _subTextColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmsCard(AppLocalizations l) {
    final selected = _selectedSms;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedSms = true;
          _selectedWhatsApp = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment(-0.8, -1.0),
                  end: Alignment(0.8, 1.0),
                  colors: [_kAccentLight, _kAccent, _kAccentDark],
                )
              : null,
          color: selected ? null : _cardColor,
          borderRadius: BorderRadius.circular(20),
          border: selected ? null : Border.all(color: _fieldBorderColor, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: selected ? _kAccent.withValues(alpha: 0.30) : _shadowColor,
              blurRadius: selected ? 18 : 16,
              spreadRadius: -4,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF2C1810).withValues(alpha: 0.12)
                    : _kAccent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.sms_rounded,
                color: selected ? const Color(0xFF2C1810) : _kAccent,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.t('sms'),
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: selected ? const Color(0xFF2C1810) : _textColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    l.t('smsSub'),
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      color: selected
                          ? const Color(0xFF2C1810).withValues(alpha: 0.7)
                          : _subTextColor,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              size: 20,
              color: selected ? const Color(0xFF2C1810) : _subTextColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(AppLocalizations l) {
    final enabled = _canContinue;
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: GestureDetector(
        onTap: enabled ? _continueToOtp : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: enabled
                ? const LinearGradient(
                    begin: Alignment(-0.8, -1.0),
                    end: Alignment(0.8, 1.0),
                    colors: [_kAccentLight, _kAccent, _kAccentDark],
                  )
                : null,
            color: enabled ? null : _fieldBgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: enabled ? Colors.transparent : _fieldBorderColor,
              width: 0.5,
            ),
            boxShadow: enabled
                ? [BoxShadow(color: _kAccent.withValues(alpha: 0.3), blurRadius: 16, spreadRadius: -4, offset: const Offset(0, 5))]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l.t('continue'),
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: enabled ? const Color(0xFF2C1810) : _subTextColor,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: enabled ? const Color(0xFF2C1810) : _subTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
