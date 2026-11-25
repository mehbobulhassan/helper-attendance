import 'package:flutter/material.dart';

/// Colours taken from the mockup.
class AppColors {
  AppColors._();
  static const primary = Color(0xFF0F766E);
  static const background = Color(0xFFF6F7F9);
  static const border = Color(0xFFE3E7EC);
  static const inputBorder = Color(0xFF8A94A3);
  static const text = Color(0xFF1B2430);
  static const textSecondary = Color(0xFF5B6675);
  static const avatarBackground = Color(0xFFCCFBF1);
  static const avatarText = Color(0xFF115E59);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.primary)
      .copyWith(primary: AppColors.primary);

  OutlineInputBorder outline(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: outline(AppColors.inputBorder),
      enabledBorder: outline(AppColors.inputBorder),
      focusedBorder: outline(AppColors.primary, 2),
      errorBorder: outline(scheme.error),
      focusedErrorBorder: outline(scheme.error, 2),
    ),
  );
}