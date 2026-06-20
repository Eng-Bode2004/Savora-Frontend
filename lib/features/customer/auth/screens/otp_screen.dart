import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/animated_background.dart';
import '../../../../core/network/savora_api.dart';
import 'role_selection_screen.dart';

const _kAccent = Color(0xFFE8A838);
const _kAccentLight = Color(0xFFF0B040);
const _kAccentDark = Color(0xFFD4952E);

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.contact,
    this.userId,
    this.isDarkMode = true,
    this.viaEmail = false,
    this.viaWhatsApp = false,
    this.viaSms = false,
    this.onVerified,
  });

  final String contact;
  final String? userId;
  final bool isDarkMode;
  final bool viaEmail;
  final bool viaWhatsApp;
  final bool viaSms;
  final VoidCallback? onVerified;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with TickerProviderStateMixin {
  static const int _length = 6;

  late final AnimationController _entrance;
  late final AnimationController _float;
  final TextEditingController _code = TextEditingController();
  final FocusNode _focus = FocusNode();

  Timer? _timer;
  int _seconds = 45;
  bool _verifying = false;
  bool _sendingOtp = false;
  String? _otpError;
  late bool _isDarkMode;

  // ── theme ──
  Color get _bgColor => _isDarkMode ? AppColors.espresso : const Color(0xFFFDFBF7);
  Color get _bgColor2 => _isDarkMode ? AppColors.espresso : const Color(0xFFF7F4EE);
  Color get _textColor => _isDarkMode ? AppColors.cream : const Color(0xFF161618);
  Color get _subTextColor => _isDarkMode ? AppColors.creamDim : const Color(0xFF8A8A8A);
  Color get _fieldBg => _isDarkMode ? AppColors.glass : const Color(0xFFF5F3EF);
  Color get _fieldBorder => _isDarkMode ? AppColors.glassBorder : const Color(0xFFE8E4DE);

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
    _code.addListener(() => setState(() {}));
    _startTimer();
    _sendOtp();
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) _focus.requestFocus();
    });
  }

  void _startTimer() {
    setState(() => _seconds = 45);
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
    _float.dispose();
    _code.dispose();
    _focus.dispose();
    _timer?.cancel();
    super.dispose();
  }

  bool get _complete => _code.text.length == _length;

  Future<void> _sendOtp() async {
    final userId = widget.userId;
    if (userId == null || userId.isEmpty) return;

    setState(() => _sendingOtp = true);

    try {
      if (widget.viaEmail) {
        await SavoraApi.sendOtpEmail(email: widget.contact, userId: userId);
      } else if (widget.viaWhatsApp) {
        await SavoraApi.sendOtpWhatsApp(phone: widget.contact, userId: userId);
      } else {
        await SavoraApi.sendOtpPhone(phone: widget.contact, userId: userId);
      }
      if (mounted) setState(() => _sendingOtp = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _sendingOtp = false;
          _otpError = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  void _verify() async {
    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();

    final userId = widget.userId;
    if (userId == null || userId.isEmpty) {
      _navigateAfterVerify();
      return;
    }

    setState(() => _verifying = true);

    try {
      await SavoraApi.verifyOtp(userId: userId, otpCode: _code.text);
      if (!mounted) return;
      setState(() => _verifying = false);
      _navigateAfterVerify();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _otpError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _navigateAfterVerify() {
    HapticFeedback.heavyImpact();
    if (widget.onVerified != null) {
      widget.onVerified!();
      return;
    }
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, a, __) => RoleSelectionScreen(userId: widget.userId),
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
            Positioned.fill(
              child: SafeArea(
                child: AnimatedBuilder(
                  animation: Listenable.merge([_entrance, _float]),
                  builder: (context, _) {
                    // ★ FIX: LayoutBuilder + scrollable + minHeight keeps the
                    // verify button at the bottom when there's room, and lets the
                    // whole page scroll (no overflow) when the keyboard shrinks it.
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: IntrinsicHeight(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 28),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    _reveal(0.0, 0.3, _buildBackButton()),
                                    const SizedBox(height: 28),
                                    _reveal(0.05, 0.4, _buildHero()),
                                    const SizedBox(height: 28),
                                    _reveal(0.1, 0.5, _buildTitle(l)),
                                    const SizedBox(height: 12),
                                    _reveal(0.18, 0.6, _buildSubtitle(l)),
                                    const SizedBox(height: 36),
                                    _reveal(0.3, 0.75, _buildOtpBoxes()),
                                    const SizedBox(height: 26),
                                    _reveal(0.4, 0.85, Center(child: _buildResend(l))),
                                    const Spacer(),
                                    _reveal(0.45, 1.0, _buildVerifyButton(l)),
                                    const SizedBox(height: 24),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
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

  // ════════ BACK BUTTON ════════
  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _isDarkMode ? AppColors.glass : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: _fieldBorder),
        ),
        child: Icon(Icons.arrow_back_rounded, color: _textColor, size: 20),
      ),
    );
  }

  // ════════ HERO ════════
  Widget _buildHero() {
    final bob = math.sin(_float.value * 2 * math.pi) * 6;
    return Center(
      child: Transform.translate(
        offset: Offset(0, bob),
        child: Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [_kAccentLight, _kAccentDark]),
            boxShadow: [
              BoxShadow(
                color: _kAccent.withValues(alpha: 0.4),
                blurRadius: 22,
                spreadRadius: -4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            widget.viaWhatsApp
                ? Icons.chat_rounded
                : widget.viaEmail
                    ? Icons.mark_email_read_rounded
                    : Icons.sms_rounded,
            color: const Color(0xFF2C1810),
            size: 38,
          ),
        ),
      ),
    );
  }

  // ════════ TITLE ════════
  Widget _buildTitle(AppLocalizations l) {
    return Text(
      l.t('verifyYourNumber'),
      style: TextStyle(
        color: _textColor,
        fontSize: 28,
        height: 1.15,
        fontWeight: FontWeight.w700,
        fontFamily: 'DM Sans',
      ),
    );
  }

  // ════════ SUBTITLE ════════
  Widget _buildSubtitle(AppLocalizations l) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: _subTextColor,
          fontSize: 15,
          height: 1.5,
          fontFamily: 'DM Sans',
        ),
        children: [
          TextSpan(text: '${l.t('enterCode')} '),
          TextSpan(
            text: widget.contact,
            style: TextStyle(color: _textColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ════════ OTP BOXES ════════
  Widget _buildOtpBoxes() {
    final text = _code.text;
    return GestureDetector(
      onTap: () => _focus.requestFocus(),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_length, (i) {
              final filled = i < text.length;
              final active = i == text.length && _focus.hasFocus;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                width: 54,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _fieldBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: active
                        ? _kAccent
                        : filled
                        ? _kAccent.withValues(alpha: 0.6)
                        : _fieldBorder,
                    width: active ? 1.8 : 1.2,
                  ),
                  boxShadow: active
                      ? [
                    BoxShadow(
                      color: _kAccent.withValues(alpha: 0.25),
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
                controller: _code,
                focusNode: _focus,
                keyboardType: TextInputType.number,
                maxLength: _length,
                showCursor: false,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(counterText: ''),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════ RESEND ════════
  Widget _buildResend(AppLocalizations l) {
    if (_seconds > 0) {
      return Text(
        '${l.t('resendIn')}${_seconds.toString().padLeft(2, '0')}',
        style: TextStyle(color: _subTextColor, fontSize: 14, fontFamily: 'DM Sans'),
      );
    }
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _startTimer();
        _sendOtp();
      },
      child: Text(
        l.t('resendCode'),
        style: const TextStyle(
          color: _kAccent,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          fontFamily: 'DM Sans',
        ),
      ),
    );
  }

  // ════════ VERIFY BUTTON ════════
  Widget _buildVerifyButton(AppLocalizations l) {
    final enabled = _complete && !_verifying && !_sendingOtp;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_otpError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              _otpError!,
              style: const TextStyle(
                color: Color(0xFFE0533D),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        Opacity(
          opacity: enabled ? 1 : 0.5,
          child: GestureDetector(
            onTap: enabled ? _verify : null,
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
              child: Center(
                child: _verifying || _sendingOtp
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2C1810)),
                  ),
                )
                    : Text(
                  l.t('verify'),
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C1810),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}