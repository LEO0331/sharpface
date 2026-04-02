import 'package:flutter/material.dart';

import 'design_tokens.dart';

class AppTheme {
  static ThemeData get light {
    const surfaceTint = Color(0xFFF6F4FF);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppTokens.primary,
        brightness: Brightness.light,
        primary: AppTokens.primary,
        secondary: AppTokens.secondary,
        tertiary: AppTokens.accent,
        surface: AppTokens.surfaceGlass,
      ),
      scaffoldBackgroundColor: const Color(0xFFF7F7FF),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppTokens.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          letterSpacing: -0.3,
          color: AppTokens.textPrimary,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 22,
          letterSpacing: -0.2,
          color: AppTokens.textPrimary,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          letterSpacing: -0.1,
          color: AppTokens.textPrimary,
        ),
        titleSmall: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: AppTokens.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.4,
          color: AppTokens.textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          height: 1.35,
          color: AppTokens.textMuted,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.92),
        elevation: 0,
        shadowColor: const Color(0xFFB8C7FF).withValues(alpha: 0.16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          side: const BorderSide(color: Color(0xFFDCE3FF), width: 1),
        ),
      ),
      focusColor: AppTokens.primary.withValues(alpha: 0.12),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            ),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          textStyle: WidgetStateProperty.all(
            const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppTokens.primary.withValues(alpha: 0.4);
            }
            return AppTokens.primary;
          }),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.focused)) {
              return const BorderSide(color: Color(0xFF2E4A9E), width: 2);
            }
            return BorderSide.none;
          }),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStateProperty.all(
            const TextStyle(fontWeight: FontWeight.w600),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            ),
          ),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.focused)) {
              return const BorderSide(color: Color(0xFF4F63D6), width: 1.6);
            }
            return BorderSide.none;
          }),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceTint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: const BorderSide(color: Color(0xFFE3E2FB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: const BorderSide(color: Color(0xFF6D73DD), width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.86),
        selectedColor: const Color(0xFFE5E8FF),
        disabledColor: const Color(0xFFEEF1F8),
        labelStyle: const TextStyle(
          color: AppTokens.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        side: const BorderSide(color: Color(0xFFD7DEFA)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        ),
      ),
    );
  }
}
