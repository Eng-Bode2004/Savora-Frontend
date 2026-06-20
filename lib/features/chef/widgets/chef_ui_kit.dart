import 'package:flutter/material.dart';
import 'package:savora_app/core/theme/app_colors.dart';
import 'package:savora_app/core/theme/app_spacing.dart';
import 'package:savora_app/core/theme/app_text_styles.dart';

/// A small, cohesive set of primitives shared across every Chef screen so
/// individual screens stay declarative instead of re-implementing the same
/// card/badge/button chrome. Mirrors the partner/chef "bento card" design
/// language: soft off-white cards, an 8px corner radius, and a single
/// vibrant-gold accent reserved for primary actions and active states.

// ════════════════════════════════════════════════════════════════════
// SECTION CARD
// ════════════════════════════════════════════════════════════════════

/// The recurring rounded, bordered card used to group content
/// throughout the Chef module ("Kitchen Overview", "Order Items",
/// "Breakdown", etc.).
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.cardInsets,
    this.highlightColor,
    this.backgroundColor,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// When set, renders a 2px border in this color instead of the default
  /// hairline — used for cards that need attention (e.g. an incoming
  /// order request).
  final Color? highlightColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceOf(brightness),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(
          color: highlightColor ?? AppColors.borderOf(brightness),
          width: highlightColor != null ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: brightness == Brightness.dark ? 0.25 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );
  }
}

/// A section title row with an optional trailing widget
/// (e.g. "Kitchen Overview" + "Today ⌄").
class SectionHeader extends StatelessWidget {
  const SectionHeader(
      {super.key, required this.title, this.trailing, this.padding});

  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: AppTextStyles.titleLg
                  .copyWith(color: AppColors.textOf(brightness))),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// STATUS PILL
// ════════════════════════════════════════════════════════════════════

enum PillTone { success, warning, danger, neutral, brand }

/// Small rounded status/label badge — "Completed", "In Progress",
/// "High Priority", "High Demand", "In Stock", "Top 5%", etc.
class StatusPill extends StatelessWidget {
  const StatusPill(
      {super.key, required this.label, this.tone = PillTone.brand, this.icon});

  final String label;
  final PillTone tone;
  final IconData? icon;

  Color _fg(Brightness b) {
    switch (tone) {
      case PillTone.success:
        return AppColors.success;
      case PillTone.warning:
        return AppColors.clay;
      case PillTone.danger:
        return AppColors.ember;
      case PillTone.neutral:
        return AppColors.textMutedOf(b);
      case PillTone.brand:
        return AppColors.clay;
    }
  }

  Color _bg(Brightness b) {
    switch (tone) {
      case PillTone.success:
        return AppColors.success.withValues(alpha: 0.14);
      case PillTone.warning:
        return AppColors.gold.withValues(alpha: 0.32);
      case PillTone.danger:
        return AppColors.ember.withValues(alpha: 0.12);
      case PillTone.neutral:
        return AppColors.textMutedOf(b).withValues(alpha: 0.12);
      case PillTone.brand:
        return AppColors.gold.withValues(alpha: 0.85);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
          color: _bg(brightness), borderRadius: AppSpacing.borderRadiusFull),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: _fg(brightness)),
            const SizedBox(width: 4),
          ],
          Text(label,
              style: AppTextStyles.labelSm.copyWith(color: _fg(brightness))),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// BUTTONS
// ════════════════════════════════════════════════════════════════════

/// The dominant call-to-action on a screen: bright gold fill, dark text.
/// ("Mark Order as Ready", "Confirm Location", "Finish Setup"...)
class ChefPrimaryButton extends StatelessWidget {
  const ChefPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return SizedBox(
      width: expand ? double.infinity : null,
      height: AppSpacing.buttonHeight,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          disabledBackgroundColor: AppColors.gold.withValues(alpha: 0.5),
          foregroundColor: AppColors.clay,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusSm),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.4, color: AppColors.clay),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label,
                      style:
                          AppTextStyles.button.copyWith(color: AppColors.clay)),
                  if (icon != null) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Icon(icon, size: 20, color: AppColors.clay),
                  ],
                ],
              ),
      ),
    );
  }
}

/// A strong secondary action used inline in lists ("Accept Order"): a
/// solid dark-espresso fill with white text.
class ChefDarkButton extends StatelessWidget {
  const ChefDarkButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.expand = true});

  final String label;
  final VoidCallback? onPressed;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expand ? double.infinity : null,
      height: AppSpacing.buttonHeight - 4,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.clay,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusSm),
        ),
        child: Text(label,
            style: AppTextStyles.labelLg.copyWith(color: AppColors.white)),
      ),
    );
  }
}

/// A ghost/outline button — "Decline".
class ChefOutlineButton extends StatelessWidget {
  const ChefOutlineButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.expand = true});

  final String label;
  final VoidCallback? onPressed;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return SizedBox(
      width: expand ? double.infinity : null,
      height: AppSpacing.buttonHeight - 4,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textOf(brightness),
          side: BorderSide(color: AppColors.borderOf(brightness)),
          shape:
              RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusSm),
        ),
        child: Text(label,
            style: AppTextStyles.labelLg
                .copyWith(color: AppColors.textOf(brightness))),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// STEP PROGRESS (onboarding / verification flows)
// ════════════════════════════════════════════════════════════════════

/// A single continuous progress bar with a "STEP x OF y" caption above it
/// — used by single-task wizards (e.g. Kitchen Location setup).
class LinearStepHeader extends StatelessWidget {
  const LinearStepHeader({
    super.key,
    required this.stepLabel,
    required this.title,
    required this.progress,
  });

  final String stepLabel;
  final String title;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          stepLabel.toUpperCase(),
          style: AppTextStyles.overline.copyWith(color: AppColors.amber),
        ),
        const SizedBox(height: 4),
        Text(title,
            style: AppTextStyles.headlineMd
                .copyWith(color: AppColors.textOf(brightness))),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: AppSpacing.borderRadiusFull,
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.borderOf(brightness),
            valueColor: const AlwaysStoppedAnimation(AppColors.gold),
          ),
        ),
      ],
    );
  }
}

/// Equal-width segmented progress bar (e.g. 3 segments for a 3-step
/// onboarding flow), with segments before [currentStep] filled gold.
class SegmentedStepProgress extends StatelessWidget {
  const SegmentedStepProgress(
      {super.key, required this.totalSteps, required this.currentStep});

  final int totalSteps;
  final int currentStep; // 1-based

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Row(
      children: List.generate(totalSteps, (i) {
        final filled = i < currentStep;
        return Expanded(
          child: Container(
            margin:
                EdgeInsets.only(right: i == totalSteps - 1 ? 0 : AppSpacing.xs),
            height: 5,
            decoration: BoxDecoration(
              color: filled ? AppColors.gold : AppColors.borderOf(brightness),
              borderRadius: AppSpacing.borderRadiusFull,
            ),
          ),
        );
      }),
    );
  }
}

/// Circular numbered/checked stepper connected by lines, with labels below
/// each node — used by "Account Setup" style wizards
/// (Basic Info → Certification → Banking).
class NumberedStepper extends StatelessWidget {
  const NumberedStepper(
      {super.key, required this.steps, required this.currentIndex});

  /// 0-based index of the step currently in progress.
  final List<String> steps;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Row(
      children: List.generate(steps.length, (i) {
        final isCompleted = i < currentIndex;
        final isCurrent = i == currentIndex;
        final node = _StepNode(
          label: steps[i],
          state: isCompleted
              ? _StepState.completed
              : isCurrent
                  ? _StepState.current
                  : _StepState.upcoming,
          number: i + 1,
        );
        if (i == steps.length - 1) return node;
        return Expanded(
          child: Row(
            children: [
              node,
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 20),
                  color: isCompleted
                      ? AppColors.gold
                      : AppColors.borderOf(brightness),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

enum _StepState { completed, current, upcoming }

class _StepNode extends StatelessWidget {
  const _StepNode(
      {required this.label, required this.state, required this.number});

  final String label;
  final _StepState state;
  final int number;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bool active = state != _StepState.upcoming;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? AppColors.gold
                : AppColors.textMutedOf(brightness).withValues(alpha: 0.15),
          ),
          child: state == _StepState.completed
              ? const Icon(Icons.check_rounded, size: 18, color: AppColors.clay)
              : Text(
                  '$number',
                  style: AppTextStyles.labelLg.copyWith(
                    color: active
                        ? AppColors.clay
                        : AppColors.textMutedOf(brightness),
                  ),
                ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: active
                ? AppColors.textOf(brightness)
                : AppColors.textMutedOf(brightness),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// UPLOAD DROPZONE
// ════════════════════════════════════════════════════════════════════

/// Dashed-border upload card used by identity/certificate verification
/// steps ("Upload Identity Document", "Tap to upload certificate").
class UploadDropzone extends StatelessWidget {
  const UploadDropzone({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return DottedBorderBox(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg, horizontal: AppSpacing.md),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.18),
              ),
              child: Icon(icon, color: AppColors.amber, size: 28),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLg
                  .copyWith(color: AppColors.textOf(brightness)),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySm
                  .copyWith(color: AppColors.textMutedOf(brightness)),
            ),
            const SizedBox(height: AppSpacing.md),
            ChefDarkButton(label: buttonLabel, onPressed: onTap, expand: false),
          ],
        ),
      ),
    );
  }
}

/// A simple dashed-border container (Flutter has no built-in dashed
/// border, so this paints one) — reused by [UploadDropzone].
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox(
      {super.key, required this.child, this.radius = AppSpacing.radiusMd});

  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: AppColors.borderOf(brightness),
        radius: radius,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final dashPath = Path();
    const dashWidth = 6.0;
    const dashGap = 5.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashGap;
      }
    }
    canvas.drawPath(
      dashPath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
