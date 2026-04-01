import 'package:flutter/material.dart';

import 'design_tokens.dart';

class AppTheme {
  static ThemeData get light {
    const surfaceTint = Color(0xFFF5F2FF);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppTokens.primary,
        brightness: Brightness.light,
        primary: AppTokens.primary,
        secondary: AppTokens.secondary,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFFF7F7FF),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppTokens.textPrimary,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 22, color: AppTokens.textPrimary),
        titleMedium: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppTokens.textPrimary),
        titleSmall: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTokens.textPrimary),
        bodyMedium: TextStyle(fontSize: 14, height: 1.35, color: AppTokens.textPrimary),
        bodySmall: TextStyle(fontSize: 12, height: 1.3, color: Color(0xFF4D5A78)),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFFFFFFF),
        elevation: 0,
        shadowColor: const Color(0xFFB8C7FF).withValues(alpha: 0.16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusXl),
        ),
      ),
      focusColor: AppTokens.primary.withValues(alpha: 0.12),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
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
    );
  }
}
