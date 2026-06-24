import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';

const _kAccent = Color(0xFFE8A838);
const _kAccentLight = Color(0xFFF0B040);
const _kAccentDark = Color(0xFFD4952E);

class TrackOrderScreen extends StatefulWidget {
  const TrackOrderScreen({super.key});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _pulse;
  late final AnimationController _dash;

  bool get _isDarkMode => themeModeNotifier.value == ThemeMode.dark;

  static const _activeStep = 2; // 0 Placed, 1 Preparing, 2 On way, 3 Delivered
  static const _captainName = 'Ahmed K.';
  static const _captainRating = 4.8;
  static const _eta = '4 mins away';

  static const List<_Step> _steps = [
    _Step('Placed', Icons.check_rounded),
    _Step('Preparing', Icons.soup_kitchen_rounded),
    _Step('On way', Icons.delivery_dining_rounded),
    _Step('Delivered', Icons.home_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _dash = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _pulse.dispose();
    _dash.dispose();
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

  Color get _bgColor => _isDarkMode ? AppColors.espresso : const Color(0xFFFDFBF7);
  Color get _textColor => _isDarkMode ? AppColors.cream : const Color(0xFF1A1410);
  Color get _subTextColor => _isDarkMode ? AppColors.creamDim : const Color(0xFF8A8A8A);
  Color get _cardColor => _isDarkMode ? AppColors.espressoSoft : Colors.white;
  Color get _fieldBgColor => _isDarkMode ? AppColors.glass : const Color(0xFFF5F3EF);
  Color get _fieldBorderColor =>
      _isDarkMode ? AppColors.glassBorder : const Color(0xFFE8E4DE);
  Color get _shadowColor =>
      _isDarkMode ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.06);

  @override
  Widget build(BuildContext context) {
    final isRtl = AppLocalizations.of(context).locale.languageCode == 'ar';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _bgColor,
        body: Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Stack(
            children: [
              Positioned.fill(child: _buildMap()),
              SafeArea(
                bottom: false,
                child: _reveal(0.0, 0.3, _buildTopBar()),
              ),
              _buildSheet(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMap() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulse, _dash]),
      builder: (context, _) {
        return CustomPaint(
          painter: _MapPainter(
            isDark: _isDarkMode,
            dashPhase: _dash.value,
          ),
          child: Stack(
            children: [
              Align(
                alignment: const Alignment(-0.15, -0.25),
                child: _buildRestaurantPin(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRestaurantPin() {
    final pulseT = _pulse.value;
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 50 + pulseT * 60,
            height: 50 + pulseT * 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _kAccent.withValues(alpha: (1 - pulseT) * 0.25),
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: _kAccent, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: _kAccent.withValues(alpha: 0.4),
                  blurRadius: 14,
                  spreadRadius: -2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.restaurant_rounded, size: 22, color: _kAccentDark),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          _circleBtn(Icons.arrow_back_rounded, () => Navigator.of(context).maybePop()),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: _cardColor.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: _shadowColor, blurRadius: 10, offset: const Offset(0, 2)),
                  ],
                ),
                child: Text(
                  'Track Order',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textColor,
                  ),
                ),
              ),
            ),
          ),
          _circleBtn(Icons.more_vert_rounded, () => HapticFeedback.lightImpact()),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: _cardColor.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: _shadowColor, blurRadius: 10, offset: const Offset(0, 2)),
          ],
        ),
        child: Icon(icon, size: 20, color: _textColor),
      ),
    );
  }

  Widget _buildSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.52,
      minChildSize: 0.52,
      maxChildSize: 0.82,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: AnimatedBuilder(
            animation: _entrance,
            builder: (context, _) {
              return ListView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _subTextColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _reveal(0.10, 0.40, _buildStatusHeader()),
                  const SizedBox(height: 24),
                  _reveal(0.20, 0.55, _buildStepTracker()),
                  const SizedBox(height: 24),
                  _reveal(0.35, 0.75, _buildCaptainCard()),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatusHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: _kAccent.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'ON THE WAY',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: _kAccentDark,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Captain is on the way',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              color: _subTextColor,
            ),
            children: [
              const TextSpan(text: 'Estimated arrival: '),
              TextSpan(
                text: _eta,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _kAccentDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepTracker() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const dotSize = 34.0;
        final segment = (width - dotSize) / (_steps.length - 1);
        final progress = _activeStep / (_steps.length - 1);

        return Column(
          children: [
            SizedBox(
              height: dotSize,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Positioned(
                    left: dotSize / 2,
                    right: dotSize / 2,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: _fieldBorderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Positioned(
                    left: dotSize / 2,
                    child: Container(
                      height: 3,
                      width: (width - dotSize) * progress,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [_kAccentLight, _kAccentDark]),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  for (int i = 0; i < _steps.length; i++)
                    Positioned(left: i * segment, child: _buildStepDot(i, dotSize)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (int i = 0; i < _steps.length; i++)
                  Expanded(
                    child: Text(
                      _steps[i].label,
                      textAlign: i == 0
                          ? TextAlign.start
                          : i == _steps.length - 1
                              ? TextAlign.end
                              : TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        fontWeight:
                            i <= _activeStep ? FontWeight.w700 : FontWeight.w500,
                        color: i <= _activeStep ? _textColor : _subTextColor,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStepDot(int index, double size) {
    final done = index < _activeStep;
    final active = index == _activeStep;
    final reached = index <= _activeStep;

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        return Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: reached
                ? const LinearGradient(colors: [_kAccentLight, _kAccentDark])
                : null,
            color: reached ? null : _cardColor,
            border: Border.all(
              color: reached ? Colors.transparent : _fieldBorderColor,
              width: 1.5,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: _kAccent.withValues(alpha: 0.3 + _pulse.value * 0.3),
                      blurRadius: 8 + _pulse.value * 10,
                      spreadRadius: _pulse.value * 2,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            done ? Icons.check_rounded : _steps[index].icon,
            size: 17,
            color: reached ? const Color(0xFF2C1810) : _subTextColor,
          ),
        );
      },
    );
  }

  Widget _buildCaptainCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _fieldBorderColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: _shadowColor,
            blurRadius: 16,
            spreadRadius: -4,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _kAccent.withValues(alpha: 0.5), width: 1.5),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/captain.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: _fieldBgColor,
                  child: Icon(Icons.person_rounded, size: 26, color: _subTextColor),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _captainName,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: _kAccent),
                    const SizedBox(width: 3),
                    Text(
                      '$_captainRating',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Delivery Captain',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        color: _subTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _actionBtn(Icons.chat_bubble_outline_rounded, filled: false),
          const SizedBox(width: 10),
          _actionBtn(Icons.call_rounded, filled: true),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, {required bool filled}) {
    return GestureDetector(
      onTap: () => HapticFeedback.mediumImpact(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: filled
              ? const LinearGradient(colors: [_kAccentLight, _kAccentDark])
              : null,
          color: filled ? null : _fieldBgColor,
          shape: BoxShape.circle,
          border: filled ? null : Border.all(color: _fieldBorderColor, width: 0.5),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: _kAccent.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 20,
          color: filled ? const Color(0xFF2C1810) : _textColor,
        ),
      ),
    );
  }
}

class _Step {
  const _Step(this.label, this.icon);
  final String label;
  final IconData icon;
}

class _MapPainter extends CustomPainter {
  _MapPainter({required this.isDark, required this.dashPhase});

  final bool isDark;
  final double dashPhase;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final land = Paint()
      ..color = isDark ? const Color(0xFF2A2018) : const Color(0xFFEDE8DF);
    canvas.drawRect(Offset.zero & size, land);

    final park = Paint()
      ..color = isDark
          ? const Color(0xFF243024)
          : const Color(0xFFD9E4CE);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.62, h * 0.04, w * 0.5, h * 0.22),
        const Radius.circular(24),
      ),
      park,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-w * 0.1, h * 0.30, w * 0.34, h * 0.18),
        const Radius.circular(24),
      ),
      park,
    );

    final roadWide = Paint()
      ..color = isDark ? const Color(0xFF3A2E22) : Colors.white
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final roadThin = Paint()
      ..color = isDark ? const Color(0xFF352A20) : const Color(0xFFF6F2EA)
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final main = Path()
      ..moveTo(-20, h * 0.16)
      ..lineTo(w * 0.45, h * 0.40)
      ..lineTo(w * 0.55, h * 0.52)
      ..lineTo(w + 20, h * 0.46);
    canvas.drawPath(main, roadWide);

    final vert = Path()
      ..moveTo(w * 0.30, -20)
      ..lineTo(w * 0.34, h * 0.30)
      ..lineTo(w * 0.30, h * 0.60)
      ..lineTo(w * 0.36, h + 20);
    canvas.drawPath(vert, roadThin);

    final horiz = Path()
      ..moveTo(-20, h * 0.62)
      ..lineTo(w * 0.5, h * 0.58)
      ..lineTo(w + 20, h * 0.64);
    canvas.drawPath(horiz, roadThin);

    final route = Path()
      ..moveTo(w * 0.42, h * 0.34)
      ..quadraticBezierTo(w * 0.70, h * 0.30, w * 0.78, h * 0.50)
      ..quadraticBezierTo(w * 0.85, h * 0.66, w * 1.02, h * 0.62);

    _drawDashedPath(canvas, route);

    final dest = Offset(w * 1.0, h * 0.62);
    canvas.drawCircle(dest, 8, Paint()..color = _kAccentDark);
    canvas.drawCircle(dest, 4, Paint()..color = Colors.white);
  }

  void _drawDashedPath(Canvas canvas, Path path) {
    final paint = Paint()
      ..color = _kAccentDark
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const dash = 12.0;
    const gap = 9.0;
    final metrics = path.computeMetrics().toList();
    for (final metric in metrics) {
      double distance = -((dash + gap) * dashPhase);
      while (distance < metric.length) {
        final start = distance.clamp(0.0, metric.length);
        final end = (distance + dash).clamp(0.0, metric.length);
        if (end > 0) {
          canvas.drawPath(metric.extractPath(start, end), paint);
        }
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_MapPainter old) =>
      old.dashPhase != dashPhase || old.isDark != isDark;
}
