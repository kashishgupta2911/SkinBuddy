import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color background = Color(0xFFFFF3E4);
  static const Color surface = Color(0xFFFFF9F2);
  static const Color cardFill = Color(0xFFFFF8EE);
  static const Color primary = Color(0xFFD4874D);
  static const Color primaryDark = Color(0xFFB8703A);
  static const Color brownDark = Color(0xFF5D4E37);
  static const Color brownMedium = Color(0xFF8B7355);
  static const Color brownLight = Color(0xFFBFA98A);
  static const Color cameraBg = Color(0xFF8B6C4F);
  static const Color greenChip = Color(0xFFE0EDDA);
  static const Color greenText = Color(0xFF4A7A3A);
  static const Color yellowChip = Color(0xFFFFF4CC);
  static const Color yellowText = Color(0xFFB8860B);
  static const Color redChip = Color(0xFFFDD0D0);
  static const Color redText = Color(0xFFB83A3A);
  static const Color disclaimerBg = Color(0xFFFFF0DB);
  static const Color textPrimary = Color(0xFF3A3027);
  static const Color textSecondary = Color(0xFF7A6B5A);
  static const Color iconBg = Color(0xFFE8DDD0);
  static const Color navUnselected = Color(0xFFB0A090);
  static const Color tipCardBg = Color(0xFFFFFBF8);
  static const confidenceHigh = Color(0xFF3B82F6); // blue
  static const confidenceModerate = Color(0xFFF59E0B); // amber
  static const confidenceLow = Color(0xFFEF4444); // soft red
}

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorSchemeSeed: AppColors.primary,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      foregroundColor: AppColors.brownDark,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.brownDark,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
        side: const BorderSide(color: AppColors.brownLight),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
