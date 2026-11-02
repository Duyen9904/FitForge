import 'package:flutter/material.dart';

/// App color palette - Sporter Inspired Theme
class AppColors {
  AppColors._();

  // ================= PRIMARY (Modern Violet)
  static const Color primary = Color(0xFF7C5CFF);
  static const Color primaryLight = Color(0xFF9F86FF);
  static const Color primaryDark = Color(0xFF5B3DCC);

  // ================= SECONDARY (Soft Purple Accent)
  static const Color secondary = Color(0xFFB794F4);
  static const Color secondaryLight = Color(0xFFD6BCFA);
  static const Color secondaryDark = Color(0xFF805AD5);

  // ================= ACCENT (Subtle Pinkish Purple)
  static const Color accent = Color(0xFFFF7EB6);
  static const Color accentLight = Color(0xFFFFA3C9);
  static const Color accentDark = Color(0xFFE0569A);

  // ================= NEUTRALS (Cool Grey System)
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color grey50 = Color(0xFFF8F9FC);
  static const Color grey100 = Color(0xFFF1F2F6);
  static const Color grey200 = Color(0xFFE2E5EC);
  static const Color grey300 = Color(0xFFC9CED8);
  static const Color grey400 = Color(0xFF9FA6B2);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF0F172A);

  // ================= SEMANTIC
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ================= BACKGROUND
  static const Color backgroundLight = Color(0xFFF6F7FB);
  static const Color backgroundDark = Color(0xFF0F172A);

  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E293B);

  // ================= ATHLETIC / FITNESS ACCENTS
  static const Color neonLime = Color(0xFFA6F523);
  static const Color darkHero = Color(0xFF1B1E1C);

  // ================= GRADIENTS (Fitness App Style)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C5CFF), Color(0xFF9F86FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF7EB6), Color(0xFF7C5CFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
