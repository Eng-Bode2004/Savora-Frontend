import 'package:flutter/material.dart';

/// Centralised text styles — referenced by every chef screen via
/// `AppTextStyles.headlineLg`, etc.
class AppTextStyles {
  AppTextStyles._();

  // ── Display ──
  static const TextStyle displayLg = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  // ── Headlines ──
  static const TextStyle headlineLg = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static const TextStyle headlineMd = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const TextStyle headlineSm = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  // ── Titles ──
  static const TextStyle titleLg = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle titleMd = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // ── Body ──
  static const TextStyle bodyMd = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  static const TextStyle bodySm = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // ── Labels ──
  static const TextStyle labelLg = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle labelMd = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle labelSm = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  // ── Overline ──
  static const TextStyle overline = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    height: 1.3,
  );

  // ── Button ──
  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
}
