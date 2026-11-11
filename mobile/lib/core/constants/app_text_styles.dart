import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';

/// Font family tokens for the design system.
///
/// To use custom Outfit font, download from https://fonts.google.com/specimen/Outfit
/// and enable in pubspec.yaml, then set [primary] to `'Outfit'`.
class AppFontFamilies {
  AppFontFamilies._();

  /// Primary UI and heading font family (`null` uses platform default, or `'Outfit'`).
  static const String? primary = null;

  /// Monospace font family used for workout timers, countdowns, and tabular metrics.
  static const String monospace = 'monospace';
}

/// Standardized font weight tokens.
class AppFontWeights {
  AppFontWeights._();

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
}

/// Standardized font size scale (in logical pixels / sp).
class AppFontSizes {
  AppFontSizes._();

  // Display scale (Material 3 + Figma Reference scale)
  static const double displayLarge = 57.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;

  static const double refDisplayLarge = 64.0; // Figma reference h1
  static const double refDisplayMedium = 56.0; // Figma reference h2
  static const double refDisplaySmall = 48.0; // Figma reference h3

  // Headline scale
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 28.0;
  static const double headlineSmall = 24.0;
  static const double refHeadlineLarge = 40.0; // Figma reference h4

  // Title scale
  static const double titleLarge = 22.0;
  static const double refTitleLarge = 20.0; // Figma reference Title large
  static const double titleMedium = 16.0;
  static const double titleSmall = 14.0;

  // Body scale
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;

  // Button scale
  static const double buttonLarge = 16.0;
  static const double buttonMedium = 14.0;
  static const double buttonSmall = 12.0;

  // Label scale
  static const double labelLarge = 14.0;
  static const double labelMedium = 12.0;
  static const double labelSmall = 11.0;
  static const double labelXSmall = 10.0; // Figma reference Label small
}

/// Line height tokens (both pixel targets and Flutter `TextStyle.height` multipliers).
class AppLineHeights {
  AppLineHeights._();

  // Pixel line heights (from Figma specimen 2:20 & M3)
  static const double displayLargePx = 64.0;
  static const double displayMediumPx = 52.0;
  static const double displaySmallPx = 44.0;

  static const double headlineLargePx = 40.0;
  static const double headlineMediumPx = 36.0;
  static const double headlineSmallPx = 32.0;

  static const double titleLargePx = 28.0;
  static const double titleMediumPx = 24.0;
  static const double titleSmallPx = 20.0;

  static const double bodyLargePx = 24.0;
  static const double bodyMediumPx = 20.0;
  static const double bodySmallPx = 16.0;

  static const double buttonLargePx = 24.0;
  static const double buttonMediumPx = 20.0;
  static const double buttonSmallPx = 16.0;

  static const double labelLargePx = 20.0;
  static const double labelMediumPx = 16.0;
  static const double labelSmallPx = 16.0;
  static const double labelXSmallPx = 14.0;

  // Multiplier ratios (lineHeightPx / fontSizePx) for Flutter TextStyle.height
  static const double displayLarge = 64.0 / 57.0; // ~1.12
  static const double displayMedium = 52.0 / 45.0; // ~1.16
  static const double displaySmall = 44.0 / 36.0; // ~1.22

  static const double headlineLarge = 40.0 / 32.0; // 1.25
  static const double headlineMedium = 36.0 / 28.0; // ~1.29
  static const double headlineSmall = 32.0 / 24.0; // ~1.33

  static const double titleLarge = 28.0 / 22.0; // ~1.27
  static const double titleMedium = 24.0 / 16.0; // 1.50
  static const double titleSmall = 20.0 / 14.0; // ~1.43

  static const double bodyLarge = 24.0 / 16.0; // 1.50
  static const double bodyMedium = 20.0 / 14.0; // ~1.43
  static const double bodySmall = 16.0 / 12.0; // ~1.33

  static const double buttonLarge = 24.0 / 16.0; // 1.50
  static const double buttonMedium = 20.0 / 14.0; // ~1.43
  static const double buttonSmall = 16.0 / 12.0; // ~1.33

  static const double labelLarge = 20.0 / 14.0; // ~1.43
  static const double labelMedium = 16.0 / 12.0; // ~1.33
  static const double labelSmall = 16.0 / 11.0; // ~1.45
  static const double labelXSmall = 14.0 / 10.0; // 1.40
}

/// Standardized letter-spacing tokens (in logical pixels).
class AppLetterSpacing {
  AppLetterSpacing._();

  static const double tight = -0.25;
  static const double normal = 0.0;
  static const double slight = 0.1;
  static const double medium = 0.15;
  static const double body = 0.25;
  static const double wide = 0.4;
  static const double wider = 0.5;
  static const double button = 1.25;
}

/// App text styles - Material 3 + Figma Specimen (node 2:20) complete hierarchy.
class AppTextStyles {
  AppTextStyles._();

  static const String? _fontFamily = AppFontFamilies.primary;

  // ===========================================================================
  // DISPLAY STYLES (h1, h2, h3)
  // ===========================================================================
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppFontSizes.displayLarge,
    fontWeight: AppFontWeights.bold,
    height: AppLineHeights.displayLarge,
    letterSpacing: AppLetterSpacing.tight,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppFontSizes.displayMedium,
    fontWeight: AppFontWeights.bold,
    height: AppLineHeights.displayMedium,
    letterSpacing: AppLetterSpacing.normal,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppFontSizes.displaySmall,
    fontWeight: AppFontWeights.semiBold,
    height: AppLineHeights.displaySmall,
    letterSpacing: AppLetterSpacing.normal,
  );

  // ===========================================================================
  // HEADLINE STYLES (h4, h5, h6)
  // ===========================================================================
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppFontSizes.headlineLarge,
    fontWeight: AppFontWeights.semiBold,
    height: AppLineHeights.headlineLarge,
    letterSpacing: AppLetterSpacing.normal,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppFontSizes.headlineMedium,
    fontWeight: AppFontWeights.semiBold,
    height: AppLineHeights.headlineMedium,
    letterSpacing: AppLetterSpacing.normal,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppFontSizes.headlineSmall,
    fontWeight: AppFontWeights.semiBold,
    height: AppLineHeights.headlineSmall,
    letterSpacing: AppLetterSpacing.normal,
  );

  // ===========================================================================
  // TITLE STYLES (SemiBold & Regular variants from Figma specimen)
  // ===========================================================================
  static const TextStyle titleLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppFontSizes.titleLarge,
    fontWeight: AppFontWeights.semiBold,
    height: AppLineHeights.titleLarge,
    letterSpacing: AppLetterSpacing.normal,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppFontSizes.titleMedium,
    fontWeight: AppFontWeights.semiBold,
    height: AppLineHeights.titleMedium,
    letterSpacing: AppLetterSpacing.medium,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppFontSizes.titleSmall,
    fontWeight: AppFontWeights.semiBold,
    height: AppLineHeights.titleSmall,
    letterSpacing: AppLetterSpacing.slight,
  );

  /// Figma Specimen: `Title medium - reg` (16px / 24px, Regular)
  static const TextStyle titleMediumRegular = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppFontSizes.titleMedium,
    fontWeight: AppFontWeights.regular,
    height: AppLineHeights.titleMedium,
    letterSpacing: AppLetterSpacing.medium,
  );

  /// Figma Specimen: `Title small - reg` (14px / 20px, Regular)
  static const TextStyle titleSmallRegular = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppFontSizes.titleSmall,
    fontWeight: AppFontWeights.regular,
    height: AppLineHeights.titleSmall,
    letterSpacing: AppLetterSpacing.slight,
  );

  // ===========================================================================
  // BODY STYLES
  // ===========================================================================
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppFontSizes.bodyLarge,
    fontWeight: AppFontWeights.regular,
    height: AppLineHeights.bodyLarge,
    letterSpacing: AppLetterSpacing.wider,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppFontSizes.bodyMedium,
    fontWeight: AppFontWeights.regular,
    height: AppLineHeights.bodyMedium,
    letterSpacing: AppLetterSpacing.body,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppFontSizes.bodySmall,
    fontWeight: AppFontWeights.regular,
    height: AppLineHeights.bodySmall,
    letterSpacing: AppLetterSpacing.wide,
  );

  // ===========================================================================
  // BUTTON STYLES (Large 16/24, Medium 14/20, Small 12/16)
  // ===========================================================================
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppFontSizes.buttonLarge,
    fontWeight: AppFontWeights.semiBold,
    height: AppLineHeights.buttonLarge,
    letterSpacing: AppLetterSpacing.wider,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppFontSizes.buttonMedium,
    fontWeight: AppFontWeights.semiBold,
    height: AppLineHeights.buttonMedium,
    letterSpacing: AppLetterSpacing.button,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppFontSizes.buttonSmall,
    fontWeight: AppFontWeights.semiBold,
    height: AppLineHeights.buttonSmall,
    letterSpacing: AppLetterSpacing.wider,
  );

  /// Default button text style alias (backward compatible)
  static const TextStyle button = buttonMedium;

  // ===========================================================================
  // LABEL STYLES
  // ===========================================================================
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppFontSizes.labelLarge,
    fontWeight: AppFontWeights.medium,
    height: AppLineHeights.labelLarge,
    letterSpacing: AppLetterSpacing.slight,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppFontSizes.labelMedium,
    fontWeight: AppFontWeights.medium,
    height: AppLineHeights.labelMedium,
    letterSpacing: AppLetterSpacing.wider,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppFontSizes.labelSmall,
    fontWeight: AppFontWeights.medium,
    height: AppLineHeights.labelSmall,
    letterSpacing: AppLetterSpacing.wider,
  );

  static const TextStyle labelXSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppFontSizes.labelXSmall,
    fontWeight: AppFontWeights.medium,
    height: AppLineHeights.labelXSmall,
    letterSpacing: AppLetterSpacing.wider,
  );

  // ===========================================================================
  // WORKOUT / METRIC STYLES (TABULAR NUMBERS)
  // ===========================================================================
  static const TextStyle timerDisplay = TextStyle(
    fontFamily: AppFontFamilies.monospace,
    fontSize: AppFontSizes.displaySmall,
    fontWeight: AppFontWeights.bold,
    height: AppLineHeights.displaySmall,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle metricValue = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppFontSizes.headlineMedium,
    fontWeight: AppFontWeights.bold,
    height: AppLineHeights.headlineMedium,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
