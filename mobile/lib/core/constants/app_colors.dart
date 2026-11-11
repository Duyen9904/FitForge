import 'package:flutter/material.dart';

/// App color palette - Sporter Inspired Theme & Full Design System Tokens
///
/// Covers:
/// - Brand colors: Primary, Secondary, Tertiary (with light/dark/container variants)
/// - Neutral scale: Cool Grey 50–900 + Figma reference Neutral-01..09 (Light & Dark)
/// - Semantic colors: Success, Warning, Error, Info (base, dark, subtle container, on-color, border)
/// - Background & Surface colors (Light, Dark, Elevated levels 1–3, Hero, Overlays/Scrims)
/// - Text & Border colors (Light & Dark semantic hierarchy)
class AppColors {
  AppColors._();

  // ===========================================================================
  // 1. PRIMARY, SECONDARY, TERTIARY (BRAND PALETTE)
  // ===========================================================================

  /// Primary — Modern Violet
  static const Color primary = Color(0xFF7C5CFF);
  static const Color primaryLight = Color(0xFF9F86FF);
  static const Color primaryDark = Color(0xFF5B3DCC);
  static const Color primaryContainerLight = Color(0xFFEDE9FE);
  static const Color primaryContainerDark = Color(0xFF2E1B6B);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryDark = Color(0xFF0F172A);

  /// Secondary — Soft Purple Accent
  static const Color secondary = Color(0xFFB794F4);
  static const Color secondaryLight = Color(0xFFD6BCFA);
  static const Color secondaryDark = Color(0xFF805AD5);
  static const Color secondaryContainerLight = Color(0xFFF3E8FF);
  static const Color secondaryContainerDark = Color(0xFF3B2366);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryDark = Color(0xFF0F172A);

  /// Tertiary / Accent — Subtle Pinkish Purple & Athletic Neon Lime
  static const Color tertiary = Color(0xFFFF7EB6);
  static const Color tertiaryLight = Color(0xFFFFA3C9);
  static const Color tertiaryDark = Color(0xFFE0569A);
  static const Color tertiaryContainerLight = Color(0xFFFFE4F0);
  static const Color tertiaryContainerDark = Color(0xFF591C3B);
  static const Color onTertiary = Color(0xFFFFFFFF);

  // Backward-compatible Accent aliases
  static const Color accent = tertiary;
  static const Color accentLight = tertiaryLight;
  static const Color accentDark = tertiaryDark;

  /// Athletic / Fitness High-Contrast Accents
  static const Color neonLime = Color(0xFFA6F523);
  static const Color neonLimeDark = Color(0xFF84CC16);
  static const Color darkHero = Color(0xFF1B1E1C);

  // ===========================================================================
  // 2. NEUTRAL COLORS (COOL SLATE SYSTEM + FIGMA REFERENCE NEUTRALS)
  // ===========================================================================

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  /// Cool Grey Scale (50–900)
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

  /// Reference Neutral Scale — Light Mode (Neutral-01 to Neutral-09)
  static const Color neutralLight01 = Color(0xFFFFFFFF);
  static const Color neutralLight02 = Color(0xFFF2F2F7);
  static const Color neutralLight03 = Color(0xFFE5E5EA);
  static const Color neutralLight04 = Color(0xFFD1D1D6);
  static const Color neutralLight05 = Color(0xFFC7C7CC);
  static const Color neutralLight06 = Color(0xFFAEAEB2);
  static const Color neutralLight07 = Color(0xFF8E8E93);
  static const Color neutralLight08 = Color(0xFF3A3A3C);
  static const Color neutralLight09 = Color(0xFF000000);

  /// Reference Neutral Scale — Dark Mode (Neutral-01 to Neutral-09)
  static const Color neutralDark01 = Color(0xFF000000);
  static const Color neutralDark02 = Color(0xFF1C1C1E);
  static const Color neutralDark03 = Color(0xFF2C2C2E);
  static const Color neutralDark04 = Color(0xFF3A3A3C);
  static const Color neutralDark05 = Color(0xFF48484A);
  static const Color neutralDark06 = Color(0xFF636366);
  static const Color neutralDark07 = Color(0xFF8E8E93);
  static const Color neutralDark08 = Color(0xFFAEAEB2);
  static const Color neutralDark09 = Color(0xFFFFFFFF);

  // ===========================================================================
  // 3. SEMANTIC COLORS (SUCCESS, WARNING, ERROR, INFO)
  // ===========================================================================

  /// Success (Green)
  static const Color success = Color(0xFF22C55E);
  static const Color successDark = Color(0xFF4ADE80);
  static const Color successSubtleLight = Color(0xFFDCFCE7);
  static const Color successSubtleDark = Color(0xFF14532D);
  static const Color onSuccessLight = Color(0xFF15803D);
  static const Color onSuccessDark = Color(0xFFDCFCE7);
  static const Color successBorder = Color(0xFF86EFAC);

  /// Warning (Amber / Orange)
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFFBBF24);
  static const Color warningSubtleLight = Color(0xFFFEF3C7);
  static const Color warningSubtleDark = Color(0xFF78350F);
  static const Color onWarningLight = Color(0xFFB45309);
  static const Color onWarningDark = Color(0xFFFEF3C7);
  static const Color warningBorder = Color(0xFFFCD34D);

  /// Error (Red)
  static const Color error = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFF87171);
  static const Color errorSubtleLight = Color(0xFFFEE2E2);
  static const Color errorSubtleDark = Color(0xFF7F1D1D);
  static const Color onErrorLight = Color(0xFFB91C1C);
  static const Color onErrorDark = Color(0xFFFEE2E2);
  static const Color errorBorder = Color(0xFFFCA5A5);

  /// Info (Blue)
  static const Color info = Color(0xFF3B82F6);
  static const Color infoDark = Color(0xFF60A5FA);
  static const Color infoSubtleLight = Color(0xFFDBEAFE);
  static const Color infoSubtleDark = Color(0xFF1E3A8A);
  static const Color onInfoLight = Color(0xFF1D4ED8);
  static const Color onInfoDark = Color(0xFFDBEAFE);
  static const Color infoBorder = Color(0xFF93C5FD);

  // ===========================================================================
  // 4. BACKGROUND & SURFACE COLORS
  // ===========================================================================

  /// Backgrounds
  static const Color backgroundLight = Color(0xFFF6F7FB);
  static const Color backgroundSecondaryLight = Color(0xFFF1F2F6);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color backgroundSecondaryDark = Color(0xFF090E1A);

  /// Surfaces — Light Mode (Elevation tiers 1–3)
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surface1Light = Color(0xFFFFFFFF);
  static const Color surface2Light = Color(0xFFF8F9FC);
  static const Color surface3Light = Color(0xFFF1F2F6);

  /// Surfaces — Dark Mode (Elevation tiers 1–3)
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surface1Dark = Color(0xFF1E293B);
  static const Color surface2Dark = Color(0xFF273549);
  static const Color surface3Dark = Color(0xFF334155);

  /// Overlays & Scrims
  static const Color scrimLight = Color(0x660F172A); // 40% opacity
  static const Color scrimDark = Color(0x99000000); // 60% opacity
  static const Color glassOverlayLight = Color(0xCCFFFFFF); // 80% white
  static const Color glassOverlayDark = Color(0xCC1E293B); // 80% slate

  // ===========================================================================
  // 5. TEXT & BORDER COLORS
  // ===========================================================================

  /// Text Colors — Light Mode
  static const Color textPrimaryLight = grey900; // #0F172A
  static const Color textSecondaryLight = grey600; // #4B5563
  static const Color textTertiaryLight = grey500; // #6B7280
  static const Color textDisabledLight = grey400; // #9FA6B2
  static const Color textInverseLight = white; // #FFFFFF
  static const Color textLinkLight = primary; // #7C5CFF

  /// Text Colors — Dark Mode
  static const Color textPrimaryDark = grey50; // #F8F9FC
  static const Color textSecondaryDark = grey300; // #C9CED8
  static const Color textTertiaryDark = grey400; // #9FA6B2
  static const Color textDisabledDark = grey600; // #4B5563
  static const Color textInverseDark = grey900; // #0F172A
  static const Color textLinkDark = primaryLight; // #9F86FF

  /// Border & Divider Colors — Light Mode
  static const Color borderSubtleLight = grey200; // #E2E5EC
  static const Color borderDefaultLight = grey300; // #C9CED8
  static const Color borderStrongLight = grey400; // #9FA6B2
  static const Color borderFocusLight = primary; // #7C5CFF
  static const Color borderErrorLight = error; // #EF4444
  static const Color dividerLight = grey200; // #E2E5EC

  /// Border & Divider Colors — Dark Mode
  static const Color borderSubtleDark = grey800; // #1F2937
  static const Color borderDefaultDark = grey700; // #374151
  static const Color borderStrongDark = grey600; // #4B5563
  static const Color borderFocusDark = primaryLight; // #9F86FF
  static const Color borderErrorDark = errorDark; // #F87171
  static const Color dividerDark = grey800; // #1F2937

  // ===========================================================================
  // 6. GRADIENTS (FITNESS APP STYLE)
  // ===========================================================================

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

  static const LinearGradient darkHeroGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
