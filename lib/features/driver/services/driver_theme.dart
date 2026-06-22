import 'package:flutter/material.dart';

/// Driver module theme constants.
/// Uses the same warm saffron/amber palette that aligns with the main
/// Savora AppTheme. All screens in the driver module reference these
/// constants so that:
///   - Dark mode: rich espresso + amber accents
///   - Light mode: ivory backgrounds + deep saffron accents
///
/// Color resolution at runtime happens through Theme.of(context).colorScheme
/// where possible; these static constants are fallbacks and dark-mode
/// convenience references kept for backward compatibility.
class DriverTheme {
  DriverTheme._();

  // ── Dark palette ──────────────────────────────────────────────────────────
  static const Color primary              = Color(0xFFFFB86E);
  static const Color onPrimary            = Color(0xFF492900);
  static const Color primaryContainer     = Color(0xFFBF6C00);
  static const Color onPrimaryContainer   = Color(0xFF5A3300);

  static const Color secondary            = Color(0xFFCAC99F);
  static const Color secondaryContainer   = Color(0xFF4B4B2A);
  static const Color onSecondaryContainer = Color(0xFFBCBB91);

  static const Color background           = Color(0xFF171212);
  static const Color onBackground         = Color(0xFFEBE0E0);
  static const Color surface              = Color(0xFF2D1E1E);
  static const Color surfaceContainer     = Color(0xFF241E1F);
  static const Color surfaceContainerHigh = Color(0xFF2F2829);

  static const Color onSurface           = Color(0xFFEBE0E0);
  static const Color onSurfaceVariant    = Color(0xFFD8C3B1);
  static const Color outlineVariant      = Color(0xFF524437);

  // ── Adaptive helper ───────────────────────────────────────────────────────
  /// Returns [dark] in dark mode and [light] in light mode.
  static Color adaptive(
    BuildContext context, {
    required Color dark,
    required Color light,
  }) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }

  // ── Convenience resolve from ColorScheme ──────────────────────────────────
  /// Shortcut to the theme's primary color (works in both light & dark).
  static Color p(BuildContext context) =>
      Theme.of(context).colorScheme.primary;
}

/// Theme-mode provider lives in main_theme_extension.dart and is driven by
/// the existing [themeModeNotifier] in core/theme/theme_notifier.dart.
/// The driver module reads [themeModeNotifier] directly so it stays in sync
/// with the rest of the app without an extra dependency.
