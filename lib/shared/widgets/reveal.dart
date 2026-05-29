import 'package:flutter/material.dart';

/// Fades + slides a child up, driven by a slice of a parent controller.
/// Lets you stagger many elements off a single AnimationController.
class Reveal extends StatelessWidget {
  const Reveal({
    super.key,
    required this.controller,
    required this.start,
    required this.end,
    required this.child,
    this.dy = 28,
  });

  final AnimationController controller;
  final double start;
  final double end;
  final double dy;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final anim = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) {
        return Opacity(
          opacity: anim.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - anim.value) * dy),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// A soft fade + subtle scale route — feels more premium than a hard slide.
Route<T> fadeScaleRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 520),
    reverseTransitionDuration: const Duration(milliseconds: 360),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: Transform.scale(
          scale: 0.97 + 0.03 * curved.value,
          child: child,
        ),
      );
    },
  );
}
