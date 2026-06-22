import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'verification_state.dart';
import 'verification_bottom_sheets.dart';

// ── Public API ─────────────────────────────────────────────────────────────────
class VerificationProgressCard extends ConsumerWidget {
  const VerificationProgressCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(verificationProvider);
    if (state.isFullyVerified) return const _VerifiedBanner();
    return _VerificationCard(state: state);
  }
}

// ── Fully-verified compact banner ──────────────────────────────────────────────
class _VerifiedBanner extends StatelessWidget {
  const _VerifiedBanner();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withOpacity(
            Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.primary.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_rounded, color: cs.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('تم التحقق من حسابك',
                    style: tt.bodyLarge?.copyWith(color: cs.primary)),
                Text('حسابك نشط وجاهز للاستلام', style: tt.labelSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Main verification card ─────────────────────────────────────────────────────
class _VerificationCard extends StatelessWidget {
  final VerificationState state;
  const _VerificationCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withOpacity(isDark ? 0.06 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('تفعيل الحساب', style: tt.titleLarge),
                        const SizedBox(height: 4),
                        Text('أكمل الخطوات لبدء الاستلام',
                            style: tt.bodyMedium),
                      ],
                    ),
                  ),
                  _CircularProgressBadge(
                      percent: state.progressPercent, cs: cs, tt: tt),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: _AnimatedProgressBar(progress: state.progress, cs: cs),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 20, 12, 20),
              child: _StepTimeline(state: state),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Circular progress badge ────────────────────────────────────────────────────
class _CircularProgressBadge extends StatelessWidget {
  final int percent;
  final ColorScheme cs;
  final TextTheme tt;
  const _CircularProgressBadge(
      {required this.percent, required this.cs, required this.tt});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: percent / 100),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) => CircularProgressIndicator(
              value: value,
              strokeWidth: 5,
              backgroundColor: cs.outlineVariant.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation(cs.primary),
              strokeCap: StrokeCap.round,
            ),
          ),
          Text('$percent%',
              style: tt.labelLarge?.copyWith(color: cs.primary, fontSize: 13)),
        ],
      ),
    );
  }
}

// ── Animated linear progress bar ──────────────────────────────────────────────
class _AnimatedProgressBar extends StatelessWidget {
  final double progress;
  final ColorScheme cs;
  const _AnimatedProgressBar({required this.progress, required this.cs});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (_, value, __) => LinearProgressIndicator(
          value: value,
          minHeight: 6,
          backgroundColor: cs.outlineVariant.withOpacity(0.25),
          valueColor: AlwaysStoppedAnimation(cs.primary),
        ),
      ),
    );
  }
}

// ── Horizontal Step Timeline ───────────────────────────────────────────────────
class _StepTimeline extends StatelessWidget {
  final VerificationState state;
  const _StepTimeline({required this.state});

  static const _steps = [
    _StepMeta(VerificationStep.vehicle, Icons.two_wheeler, 'بيانات\nالمركبة'),
    _StepMeta(VerificationStep.zone, Icons.location_on_outlined, 'منطقة\nالتوصيل'),
    _StepMeta(VerificationStep.identity, Icons.badge_outlined, 'التحقق\nالهوية'),
    _StepMeta(VerificationStep.review, Icons.verified_outlined, 'مراجعة\nالحساب'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final leftIdx = i ~/ 2;
          final isLeftDone = state.isCompleted(_steps[leftIdx].step);
          final isRightDone = state.isCompleted(_steps[leftIdx + 1].step);
          return Expanded(
            child: VerificationConnector(filled: isLeftDone && isRightDone),
          );
        }
        final idx = i ~/ 2;
        final meta = _steps[idx];
        return VerificationStepItem(
          icon: meta.icon,
          label: meta.label,
          completed: state.isCompleted(meta.step),
          active: state.activeStep == meta.step,
          onTap: () => _openSheet(context, meta.step),
        );
      }),
    );
  }

  void _openSheet(BuildContext context, VerificationStep step) {
    switch (step) {
      case VerificationStep.vehicle:
        VehicleInfoBottomSheet.show(context);
      case VerificationStep.zone:
        DeliveryZoneBottomSheet.show(context);
      case VerificationStep.identity:
        IdentityVerificationBottomSheet.show(context);
      case VerificationStep.review:
        AccountReviewBottomSheet.show(context);
    }
  }
}

class _StepMeta {
  final VerificationStep step;
  final IconData icon;
  final String label;
  const _StepMeta(this.step, this.icon, this.label);
}

// ── Public reusable: VerificationStepItem ─────────────────────────────────────
class VerificationStepItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool completed;
  final bool active;
  final VoidCallback onTap;

  const VerificationStepItem({
    super.key,
    required this.icon,
    required this.label,
    required this.completed,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor;
    final Color iconColor;
    final Color borderColor;

    if (completed) {
      bgColor = cs.primary;
      iconColor = cs.onPrimary;
      borderColor = cs.primary;
    } else if (active) {
      bgColor = cs.primaryContainer.withOpacity(isDark ? 0.25 : 0.55);
      iconColor = cs.primary;
      borderColor = cs.primary;
    } else {
      bgColor = cs.surfaceContainerHighest;
      iconColor = cs.onSurfaceVariant;
      borderColor = cs.outlineVariant;
    }

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: active ? 1.05 : 1.0),
              duration: const Duration(milliseconds: 350),
              curve: Curves.elasticOut,
              builder: (_, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: borderColor, width: active ? 2.5 : 1.5),
                  boxShadow: active || completed
                      ? [
                          BoxShadow(
                            color: cs.primary.withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : [],
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: completed
                        ? Icon(Icons.check_rounded,
                            key: const ValueKey('check'),
                            color: iconColor,
                            size: 24)
                        : Icon(icon,
                            key: ValueKey(icon), color: iconColor, size: 22),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: (tt.labelSmall ?? const TextStyle()).copyWith(
                color: active || completed ? cs.primary : cs.onSurfaceVariant,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                fontSize: 10.5,
                height: 1.3,
              ),
              child: Text(label, textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Public reusable: VerificationConnector ────────────────────────────────────
class VerificationConnector extends StatelessWidget {
  final bool filled;
  const VerificationConnector({super.key, required this.filled});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Align(
        alignment: Alignment.center,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: filled ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          builder: (_, value, __) {
            return Stack(
              children: [
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: value,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
