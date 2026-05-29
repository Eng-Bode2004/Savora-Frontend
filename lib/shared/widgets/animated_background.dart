import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// A slow, living backdrop: soft warm glows drift behind the content,
/// giving the screen depth without distracting from it.
class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key, this.child});

  final Widget? child;

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _GlowPainter(_controller.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _GlowPainter extends CustomPainter {
  _GlowPainter(this.t);

  final double t;
  static const double _twoPi = 2 * math.pi;

  @override
  void paint(Canvas canvas, Size size) {
    // Solid base.
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.espresso,
    );

    _blob(
      canvas,
      size,
      cx: 0.24 + 0.10 * math.sin(t * _twoPi),
      cy: 0.16 + 0.06 * math.cos(t * _twoPi),
      radius: 0.62,
      color: AppColors.terracotta.withValues(alpha: 0.30),
    );

    _blob(
      canvas,
      size,
      cx: 0.84 + 0.08 * math.cos(t * _twoPi * 0.8),
      cy: 0.30 + 0.07 * math.sin(t * _twoPi * 0.8),
      radius: 0.55,
      color: AppColors.saffron.withValues(alpha: 0.22),
    );

    _blob(
      canvas,
      size,
      cx: 0.55 + 0.12 * math.sin(t * _twoPi * 0.6 + 1),
      cy: 0.88 + 0.05 * math.cos(t * _twoPi * 0.6 + 1),
      radius: 0.70,
      color: AppColors.amber.withValues(alpha: 0.16),
    );

    // Gentle darkening at the bottom so text stays readable.
    final fade = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, Color(0xCC14100C)],
        stops: [0.45, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, fade);
  }

  void _blob(
    Canvas canvas,
    Size size, {
    required double cx,
    required double cy,
    required double radius,
    required Color color,
  }) {
    final center = Offset(cx * size.width, cy * size.height);
    final r = radius * size.width;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawCircle(center, r, paint);
  }

  @override
  bool shouldRepaint(covariant _GlowPainter oldDelegate) => oldDelegate.t != t;
}
