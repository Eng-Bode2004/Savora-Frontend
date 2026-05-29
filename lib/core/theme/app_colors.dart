import 'package:flutter/material.dart';

/// Savora brand palette — warm, premium, appetite-driven.
class AppColors {
  AppColors._();

  // --- Base (deep espresso backdrop) ---
  static const Color espresso = Color(0xFF14100C);
  static const Color espressoSoft = Color(0xFF1E1813);
  static const Color charcoal = Color(0xFF24201A);

  // --- Warm accents ---
  static const Color saffron = Color(0xFFF2A93B);
  static const Color deepSaffron = Color(0xFF2D1F14);
  static const Color gold = Color(0xFFF5C842);
  static const Color amber = Color(0xFFE8893D);
  static const Color terracotta = Color(0xFFD2683E);
  static const Color ember = Color(0xFFC84B1A);
  static const Color clay = Color(0xFF2C1810);

  // --- Neutrals / text ---
  static const Color cream = Color(0xFFF6EFE3);
  static const Color creamDim = Color(0xFFC9BFB0);
  static const Color muted = Color(0xFF8A8073);

  // --- Glass surfaces ---
  static const Color glass = Color(0x14FFFFFF);
  static const Color glassStrong = Color(0x1FFFFFFF);
  static const Color glassBorder = Color(0x26FFFFFF);

  static const LinearGradient accentGradient = LinearGradient(
    colors: [saffron, terracotta],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
