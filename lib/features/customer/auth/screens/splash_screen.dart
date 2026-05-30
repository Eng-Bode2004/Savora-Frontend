import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/savora_badge.dart';
import '../../../../shared/widgets/reveal.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _orbit;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();

    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();

    Future.delayed(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, animation, __, child) {
            final curved = CurvedAnimation(
                parent: animation, curve: Curves.easeOutCubic);
            return FadeTransition(
              opacity: curved,
              child: Transform.scale(
                scale: 0.96 + 0.04 * curved.value,
                child: child,
              ),
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    _orbit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              SizedBox(
                width: 360,
                height: 360,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _SonarPulse(controller: _entrance),
                    _OrbitingFood(
                      entrance: _entrance,
                      orbit: _orbit,
                      radius: 140,
                    ),
                    _BadgeReveal(controller: _entrance),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              Reveal(
                controller: _entrance,
                start: 0.55,
                end: 0.85,
                child: Text('Savora', style: AppTheme.wordmarkLight(52)),
              ),
              const SizedBox(height: 18),
              Reveal(
                controller: _entrance,
                start: 0.70,
                end: 1.00,
                child: Text(
                  l.t('splashTagline'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.saffron,
                    fontSize: 20,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

class _SonarPulse extends StatelessWidget {
  const _SonarPulse({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = const Interval(0.0, 0.65, curve: Curves.easeOut)
            .transform(controller.value);
        final size = 60 + 220 * t;
        final opacity = ((1 - t) * 0.45).clamp(0.0, 1.0);
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.saffron.withValues(alpha: opacity),
              width: 1.5,
            ),
          ),
        );
      },
    );
  }
}

class _BadgeReveal extends StatelessWidget {
  const _BadgeReveal({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final anim = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) {
        return Opacity(
          opacity: anim.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: anim.value.clamp(0.0, 1.2),
            child: child,
          ),
        );
      },
      child: const SavoraBadge(size: 120),
    );
  }
}

class _OrbitingFood extends StatelessWidget {
  const _OrbitingFood({
    required this.entrance,
    required this.orbit,
    required this.radius,
  });

  final AnimationController entrance;
  final AnimationController orbit;
  final double radius;

  static const List<String> _emojis = [
    '🍕', '🥗', '🍜', '🍰', '🍔', '🥘',
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([entrance, orbit]),
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: List.generate(_emojis.length, (i) {
            final n = _emojis.length;
            final baseAngle = -math.pi / 2 + (i / n) * 2 * math.pi;
            final currentAngle = baseAngle + orbit.value * 2 * math.pi;

            final stagger = 0.15 + (i / n) * 0.30;
            final raw =
            ((entrance.value - stagger) / 0.45).clamp(0.0, 1.0);
            final t = Curves.easeOutCubic.transform(raw);

            final r = radius * t;
            final dx = r * math.cos(currentAngle);
            final dy = r * math.sin(currentAngle);

            return Transform.translate(
              offset: Offset(dx, dy),
              child: Opacity(
                opacity: t,
                child: Transform.scale(
                  scale: 0.4 + 0.6 * t,
                  child: Text(
                    _emojis[i],
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
