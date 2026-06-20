import 'package:flutter/material.dart';

/// Design-system spacing tokens used across the entire app.
class AppSpacing {
  AppSpacing._();

  // ── Numeric tokens (used in SizedBox, EdgeInsets, etc.) ──
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  /// Horizontal page-level gutter.
  static const double screenPadding = 20.0;

  /// Standard card inner padding.
  static const double cardPadding = 16.0;

  /// Default height for full-width CTA buttons.
  static const double buttonHeight = 52.0;

  /// Bottom navigation bar height.
  static const double bottomNavHeight = 64.0;

  // ── Radius tokens ──
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  // ── Pre-built BorderRadius helpers ──
  static final BorderRadius borderRadiusXs = BorderRadius.circular(radiusXs);
  static final BorderRadius borderRadiusSm = BorderRadius.circular(radiusSm);
  static final BorderRadius borderRadiusMd = BorderRadius.circular(radiusMd);
  static final BorderRadius borderRadiusLg = BorderRadius.circular(radiusLg);
  static final BorderRadius borderRadiusXl = BorderRadius.circular(radiusXl);
  static final BorderRadius borderRadiusFull = BorderRadius.circular(radiusFull);

  // ── Pre-built EdgeInsets helpers ──
  static const EdgeInsets cardInsets = EdgeInsets.all(cardPadding);
  static const EdgeInsets screenH =
      EdgeInsets.symmetric(horizontal: screenPadding);
}
