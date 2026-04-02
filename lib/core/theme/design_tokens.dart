import 'package:flutter/material.dart';

class AppTokens {
  AppTokens._();

  static const Color primary = Color(0xFF7A7CE8);
  static const Color secondary = Color(0xFF6EA8FF);
  static const Color accent = Color(0xFF9A7CF3);
  static const Color textPrimary = Color(0xFF24324F);
  static const Color textMuted = Color(0xFF4D5A78);
  static const Color borderSoft = Color(0xFFE4E2FB);
  static const Color surfaceGlass = Color(0xF5FFFFFF);

  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 18;
  static const double radiusXl = 22;
  static const double radiusPill = 999;

  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;

  static const List<BoxShadow> shadowCard = [
    BoxShadow(color: Color(0x1A8B97D9), blurRadius: 16, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x0D5A67A6), blurRadius: 2, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> shadowCardHover = [
    BoxShadow(color: Color(0x298B97D9), blurRadius: 22, offset: Offset(0, 12)),
    BoxShadow(color: Color(0x145A67A6), blurRadius: 3, offset: Offset(0, 1)),
  ];

  static const Duration motionFast = Duration(milliseconds: 180);
  static const Duration motionMedium = Duration(milliseconds: 320);
}
