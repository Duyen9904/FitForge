import 'package:flutter/material.dart';

/// Spacing system built on a 4dp base grid with micro half-steps (2, 6, 10, 14).
class AppSpacing {
  AppSpacing._();

  // Primitive scale
  static const double s0 = 0.0;
  static const double s2 = 2.0;
  static const double s4 = 4.0;
  static const double s6 = 6.0;
  static const double s8 = 8.0;
  static const double s10 = 10.0;
  static const double s12 = 12.0;
  static const double s14 = 14.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;
  static const double s40 = 40.0;
  static const double s48 = 48.0;
  static const double s56 = 56.0;
  static const double s64 = 64.0;
  static const double s80 = 80.0;
  static const double s96 = 96.0;

  // Semantic spacing aliases
  static const double none = s0;
  static const double xxs = s2;
  static const double xs = s4;
  static const double sm = s8;
  static const double md = s12;
  static const double lg = s16;
  static const double xl = s20;
  static const double xxl = s24;
  static const double xxxl = s32;
  static const double huge = s48;

  // Component & layout spacing tokens
  static const double inlineGap = s8;
  static const double itemGap = s12;
  static const double cardPadding = s16;
  static const double heroCardPadding = s20;
  static const double sectionGap = s24;
  static const double screenHorizontal = s16;
  static const double screenVertical = s24;

  // Common EdgeInsets presets
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screenHorizontal,
    vertical: screenVertical,
  );
  static const EdgeInsets cardInsets = EdgeInsets.all(cardPadding);
  static const EdgeInsets heroCardInsets = EdgeInsets.all(heroCardPadding);
}

/// Sizing system for interactive controls, avatars, badges, icons, and bars.
class AppSizing {
  AppSizing._();

  // Accessibility touch targets
  static const double minTouchTargetIos = 44.0;
  static const double minTouchTargetAndroid = 48.0;

  // Button heights
  static const double buttonHeightSm = 36.0;
  static const double buttonHeightMd = 44.0;
  static const double buttonHeightLg = 52.0;

  // Input & field heights
  static const double inputHeightSm = 40.0;
  static const double inputHeightMd = 48.0;
  static const double inputHeightLg = 52.0;
  static const double searchBarHeight = 44.0;

  // Avatar sizes
  static const double avatarXs = 24.0;
  static const double avatarSm = 32.0;
  static const double avatarMd = 40.0;
  static const double avatarLg = 56.0;
  static const double avatarXl = 80.0;
  static const double avatarProfile = 96.0;

  // Chip & badge heights
  static const double badgeDotSize = 7.0;
  static const double chipHeightSm = 24.0;
  static const double chipHeightMd = 32.0;
  static const double chipHeightLg = 38.0;

  // Icon sizes
  static const double iconXs = 14.0;
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;
  static const double iconXxl = 48.0;

  // Navigation & bars
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 80.0;
  static const double bottomSheetHandleWidth = 36.0;
  static const double bottomSheetHandleHeight = 4.0;
}

/// Border radius scale and pre-built [BorderRadius] tokens.
class AppRadius {
  AppRadius._();

  static const double none = 0.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double circle = 100.0;
  static const double full = 999.0;

  static const BorderRadius borderRadiusNone = BorderRadius.zero;
  static const BorderRadius borderRadiusXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderRadiusXxl = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius borderRadiusXxxl = BorderRadius.all(Radius.circular(xxxl));
  static const BorderRadius borderRadiusFull = BorderRadius.all(Radius.circular(full));
}

/// App dimension constants for spacing and sizing (backward-compatible facade).
class AppDimensions {
  AppDimensions._();

  // Spacing
  static const double spacing2 = AppSpacing.s2;
  static const double spacing4 = AppSpacing.s4;
  // Common 6px spacing used in badges and chips
  static const double spacing6 = AppSpacing.s6;
  static const double spacing8 = AppSpacing.s8;
  static const double spacing10 = AppSpacing.s10;
  static const double spacing12 = AppSpacing.s12;
  static const double spacing14 = AppSpacing.s14;
  static const double spacing16 = AppSpacing.s16;
  static const double spacing20 = AppSpacing.s20;
  static const double spacing24 = AppSpacing.s24;
  static const double spacing32 = AppSpacing.s32;
  static const double spacing40 = AppSpacing.s40;
  static const double spacing48 = AppSpacing.s48;
  static const double spacing56 = AppSpacing.s56;
  static const double spacing64 = AppSpacing.s64;

  // Border Radius
  static const double radiusSmall = AppRadius.xs;
  static const double radiusMedium = AppRadius.sm;
  static const double radiusLarge = AppRadius.md;
  static const double radiusXLarge = AppRadius.lg;
  static const double radiusRound = AppRadius.xxl;
  static const double radiusCircle = AppRadius.circle;
  static const double radiusFull = AppRadius.full;
  static const double radius20 = AppRadius.xl;
  static const double radius24 = AppRadius.xxl;

  // Semantic aliases for border radii used throughout the UI
  // Keep these mapped to the base radius values above for consistency.
  static const double borderRadius8 = radiusMedium;
  static const double borderRadius12 = radiusLarge;
  static const double borderRadius16 = radiusXLarge;
  static const double borderRadius20 = radius20;
  static const double borderRadius24 = radius24;

  // Icon Sizes
  static const double iconSmall = AppSizing.iconSm;
  static const double iconMedium = AppSizing.iconLg;
  static const double iconLarge = AppSizing.iconXl;
  static const double iconXLarge = AppSizing.iconXxl;

  // Button Heights
  static const double buttonHeightSmall = AppSizing.buttonHeightSm;
  static const double buttonHeightMedium = AppSizing.buttonHeightMd;
  static const double buttonHeightLarge = AppSizing.buttonHeightLg;

  // Input Heights
  static const double inputHeight = AppSizing.inputHeightLg;

  // Card Elevation
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // Screen Padding
  static const double screenPaddingHorizontal = AppSpacing.screenHorizontal;
  static const double screenPaddingVertical = AppSpacing.screenVertical;

  // Bottom Navigation
  static const double bottomNavHeight = AppSizing.bottomNavHeight;

  // App Bar
  static const double appBarHeight = AppSizing.appBarHeight;
}
