import 'package:flutter/material.dart';

/// Window size classes following Material 3 responsive layout guidelines.
enum AppWindowSizeClass {
  /// Phones in portrait (`width < 600dp`)
  compact,

  /// Tablets in portrait & large foldables (`600dp <= width < 840dp`)
  medium,

  /// Tablets in landscape & desktop (`width >= 840dp`)
  expanded,
}

/// Breakpoints and responsive layout rules.
class AppBreakpoints {
  AppBreakpoints._();

  /// Maximum width for compact (mobile portrait) layouts
  static const double compactMax = 599.0;

  /// Minimum width for medium (tablet portrait / foldable) layouts
  static const double mediumMin = 600.0;

  /// Maximum width for medium layouts
  static const double mediumMax = 839.0;

  /// Minimum width for expanded (tablet landscape / desktop) layouts
  static const double expandedMin = 840.0;

  /// Minimum width for large widescreen desktop layouts
  static const double largeMin = 1200.0;

  /// Resolves the [AppWindowSizeClass] for a given viewport width.
  static AppWindowSizeClass sizeClassForWidth(double width) {
    if (width < mediumMin) return AppWindowSizeClass.compact;
    if (width < expandedMin) return AppWindowSizeClass.medium;
    return AppWindowSizeClass.expanded;
  }

  /// Resolves the [AppWindowSizeClass] from [BuildContext].
  static AppWindowSizeClass of(BuildContext context) {
    return sizeClassForWidth(MediaQuery.sizeOf(context).width);
  }

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mediumMin;

  static bool isMedium(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mediumMin && width < expandedMin;
  }

  static bool isExpanded(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= expandedMin;
}

/// Grid system and layout specifications across Compact, Medium, and Expanded viewports.
class AppGrid {
  AppGrid._();

  // Column counts per breakpoint
  static const int mobileColumns = 4;
  static const int tabletColumns = 8;
  static const int desktopColumns = 12;

  // Horizontal outer margins per breakpoint
  static const double mobileMargin = 16.0;
  static const double tabletMargin = 24.0;
  static const double desktopMargin = 32.0;

  // Gutters (spacing between columns) per breakpoint
  static const double mobileGutter = 12.0;
  static const double tabletGutter = 16.0;
  static const double desktopGutter = 24.0;

  // Max content container widths
  static const double maxContentWidthMobile = 480.0;
  static const double maxContentWidthTablet = 768.0;
  static const double maxContentWidthDesktop = 1200.0;

  /// Returns active column count for [width].
  static int columnsForWidth(double width) {
    switch (AppBreakpoints.sizeClassForWidth(width)) {
      case AppWindowSizeClass.compact:
        return mobileColumns;
      case AppWindowSizeClass.medium:
        return tabletColumns;
      case AppWindowSizeClass.expanded:
        return desktopColumns;
    }
  }

  /// Returns active horizontal screen margin for [width].
  static double marginForWidth(double width) {
    switch (AppBreakpoints.sizeClassForWidth(width)) {
      case AppWindowSizeClass.compact:
        return mobileMargin;
      case AppWindowSizeClass.medium:
        return tabletMargin;
      case AppWindowSizeClass.expanded:
        return desktopMargin;
    }
  }

  /// Returns active grid gutter for [width].
  static double gutterForWidth(double width) {
    switch (AppBreakpoints.sizeClassForWidth(width)) {
      case AppWindowSizeClass.compact:
        return mobileGutter;
      case AppWindowSizeClass.medium:
        return tabletGutter;
      case AppWindowSizeClass.expanded:
        return desktopGutter;
    }
  }

  /// Computes the width of a single grid column for a given [viewportWidth].
  static double singleColumnWidth(double viewportWidth) {
    final cols = columnsForWidth(viewportWidth);
    final margin = marginForWidth(viewportWidth);
    final gutter = gutterForWidth(viewportWidth);
    final availableWidth = viewportWidth - (margin * 2) - (gutter * (cols - 1));
    return availableWidth / cols;
  }

  /// Computes the width of [span] columns (including internal gutters) for [viewportWidth].
  static double spanWidth(double viewportWidth, int span) {
    final colWidth = singleColumnWidth(viewportWidth);
    final gutter = gutterForWidth(viewportWidth);
    return (colWidth * span) + (gutter * (span - 1));
  }
}
