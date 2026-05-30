import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.espresso,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.saffron,
        secondary: AppColors.terracotta,
        surface: AppColors.espressoSoft,
        onPrimary: AppColors.espresso,
        onSurface: AppColors.cream,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
        bodyColor: AppColors.cream,
        displayColor: AppColors.cream,
      ),
      // Kill the default Material ripple for a cleaner, custom feel.
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
    );
  }

  /// Light / white theme for onboarding & overall app.
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.warmWhite,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.saffron,
        secondary: AppColors.terracotta,
        surface: AppColors.white,
        onPrimary: AppColors.white,
        onSurface: AppColors.darkText,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
        bodyColor: AppColors.darkText,
        displayColor: AppColors.darkText,
      ),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
    );
  }

  /// Elegant serif wordmark style — dark bg version.
  static TextStyle wordmark(double size) => GoogleFonts.playfairDisplay(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: AppColors.cream,
        letterSpacing: 0.5,
        height: 1.0,
      );

  /// Light wordmark for white/light backgrounds.
  static TextStyle wordmarkLight(double size) => GoogleFonts.playfairDisplay(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: AppColors.darkText,
        letterSpacing: 0.5,
        height: 1.0,
      );
}
