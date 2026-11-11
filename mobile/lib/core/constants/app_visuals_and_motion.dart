import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// Iconography specifications: sizes, stroke weights, and optical bounds.
class AppIconography {
  AppIconography._();

  // Icon sizes (logical pixels)
  static const double xs = 14.0; // Badge and micro-tag icons
  static const double sm = 16.0; // Inline metadata and caption icons
  static const double md = 20.0; // Button leading/trailing and input prefix icons
  static const double lg = 24.0; // Default navigation and AppBar action icons
  static const double xl = 32.0; // Feature card headers and workout category icons
  static const double xxl = 48.0; // Empty states and hero highlights

  // Stroke weights (for custom vector / SVG icons)
  static const double strokeThin = 1.5;
  static const double strokeRegular = 1.75;
  static const double strokeBold = 2.0;

  // Optical live-area padding inside a 24x24 icon frame
  static const double opticalPadding = 2.0;
}

/// Illustration style specifications: container sizes, aspect ratios, and backdrop treatments.
class AppIllustrations {
  AppIllustrations._();

  // Standard container dimensions
  static const double spotSmall = 64.0;
  static const double spotMedium = 80.0;
  static const double cardBannerHeight = 140.0;
  static const double emptyStateSize = 180.0;
  static const double onboardingHeroSize = 280.0;

  // Ambient glow backdrop opacity for dark/light mode adaptation
  static const double backdropGlowOpacityLight = 0.08;
  static const double backdropGlowOpacityDark = 0.14;
}

/// Motion and animation tokens: durations, easing curves, and spring physics.
class AppMotion {
  AppMotion._();

  // Durations
  static const Duration instant = Duration(milliseconds: 50);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
  static const Duration pageTransition = Duration(milliseconds: 400);
  static const Duration shimmerCycle = Duration(milliseconds: 1500);

  // Easing curves
  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;
  static const Curve decelerate = Curves.decelerate;
  static const Curve accelerate = Curves.easeInCubic;
  static const Curve bounce = Curves.elasticOut;

  // Spring physics for interactive gestures, workout completion, and sheet snapping
  static const SpringDescription snappySpring = SpringDescription(
    mass: 1.0,
    stiffness: 300.0,
    damping: 22.0,
  );

  static const SpringDescription gentleSpring = SpringDescription(
    mass: 1.0,
    stiffness: 180.0,
    damping: 20.0,
  );
}

/// Logical Z-index stacking layers for Stack widgets, overlays, and portals.
class AppZIndex {
  AppZIndex._();

  /// Base scrollable content and surface cards
  static const int base = 0;

  /// Sticky section headers and inline badges
  static const int raised = 10;

  /// Floating Action Buttons (FAB) and active workout mini-player bar
  static const int floating = 20;

  /// Top AppBar and BottomNavigationBar
  static const int navigation = 30;

  /// Modal bottom sheets, side drawers, and filter panels
  static const int drawerAndSheet = 40;

  /// Dialogs, confirmation popups, and full-screen LoadingOverlay
  static const int modal = 50;

  /// Snackbars and top toast alerts
  static const int toast = 60;

  /// Tooltips, coach marks, and onboarding spotlights
  static const int tooltip = 70;
}
