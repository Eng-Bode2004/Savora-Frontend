import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// A gradient badge with a soft, breathing glow and a serif monogram.
class SavoraBadge extends StatefulWidget {
  const SavoraBadge({super.key, this.size = 86});

  final double size;

  @override
  State<SavoraBadge> createState() => _SavoraBadgeState();
}

class _SavoraBadgeState extends State<SavoraBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
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
        final glow = 0.35 + 0.35 * _controller.value;
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            gradient: AppColors.accentGradient,
            borderRadius: BorderRadius.circular(widget.size * 0.30),
            boxShadow: [
              BoxShadow(
                color: AppColors.saffron.withValues(alpha: glow * 0.55),
                blurRadius: 34 + 18 * _controller.value,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: AppColors.terracotta.withValues(alpha: glow * 0.35),
                blurRadius: 50,
                spreadRadius: 4,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Center(
        child: Text(
          'S',
          style: AppTheme.wordmark(widget.size * 0.52).copyWith(
            color: AppColors.espresso,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
