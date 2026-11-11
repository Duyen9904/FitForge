import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Border stroke widths, border presets, and divider specifications.
class AppBorders {
  AppBorders._();

  // Stroke widths
  static const double widthNone = 0.0;
  static const double widthHairline = 0.5;
  static const double widthThin = 1.0;
  static const double widthMedium = 1.5;
  static const double widthThick = 2.0;

  // Divider specs
  static const double dividerThickness = 1.0;
  static const double dividerInsetIndent = 16.0;
  static const double dividerMiddleMargin = 16.0;

  // Light mode BorderSides
  static const BorderSide subtleSideLight = BorderSide(
    color: AppColors.borderSubtleLight,
    width: widthThin,
  );
  static const BorderSide defaultSideLight = BorderSide(
    color: AppColors.borderDefaultLight,
    width: widthThin,
  );
  static const BorderSide strongSideLight = BorderSide(
    color: AppColors.borderStrongLight,
    width: widthMedium,
  );
  static const BorderSide focusSideLight = BorderSide(
    color: AppColors.borderFocusLight,
    width: widthThick,
  );
  static const BorderSide errorSideLight = BorderSide(
    color: AppColors.borderErrorLight,
    width: widthThick,
  );

  // Dark mode BorderSides
  static const BorderSide subtleSideDark = BorderSide(
    color: AppColors.borderSubtleDark,
    width: widthThin,
  );
  static const BorderSide defaultSideDark = BorderSide(
    color: AppColors.borderDefaultDark,
    width: widthThin,
  );
  static const BorderSide strongSideDark = BorderSide(
    color: AppColors.borderStrongDark,
    width: widthMedium,
  );
  static const BorderSide focusSideDark = BorderSide(
    color: AppColors.borderFocusDark,
    width: widthThick,
  );
  static const BorderSide errorSideDark = BorderSide(
    color: AppColors.borderErrorDark,
    width: widthThick,
  );

  // Full BoxBorders
  static final Border cardBorderLight = Border.fromBorderSide(subtleSideLight);
  static final Border cardBorderDark = Border.fromBorderSide(subtleSideDark);
  static final Border focusBorderLight = Border.fromBorderSide(focusSideLight);
  static final Border focusBorderDark = Border.fromBorderSide(focusSideDark);
}

/// Shadow and elevation system for surfaces, cards, floating bars, and modals.
class AppShadows {
  AppShadows._();

  // Material elevation levels
  static const double elevation0 = 0.0;
  static const double elevation1 = 2.0;
  static const double elevation2 = 4.0;
  static const double elevation3 = 8.0;
  static const double elevation4 = 12.0;
  static const double elevation5 = 24.0;

  /// Level 0 — No shadow (flat surface / filled inputs)
  static const List<BoxShadow> none = [];

  /// Level 1 (XS) — Subtle elevation for chips, pills, and compact tiles
  static const List<BoxShadow> xs = [
    BoxShadow(
      color: Color(0x085B3DCC), // ~3% primaryDark
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  /// Level 2 (SM) — Default surface card shadow (`AppSurfaceCard`)
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0A5B3DCC), // ~4% primaryDark
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  /// Level 3 (MD) — Raised cards, sticky headers, and active dropdowns
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x120F172A), // ~7% grey900
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x085B3DCC),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  /// Level 4 (LG) — Bottom navigation bar, floating workout player, sheets
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1A0F172A), // ~10% grey900
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  /// Level 5 (XL) — Dialogs, modal popups, and overlays
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x290F172A), // ~16% grey900
      blurRadius: 48,
      offset: Offset(0, 20),
    ),
  ];

  /// Brand Glow — Primary violet ambient glow for primary CTAs and active states
  static const List<BoxShadow> brandGlow = [
    BoxShadow(
      color: Color(0x477C5CFF), // ~28% primary
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  /// Dark Hero Card Shadow — Deep ambient shadow for `AppDarkHeroCard`
  static const List<BoxShadow> darkHero = [
    BoxShadow(
      color: Color(0x260F172A), // ~15% grey900
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];
}
