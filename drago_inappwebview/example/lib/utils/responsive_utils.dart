import 'package:flutter/widgets.dart';

/// Breakpoints used for responsive layouts in the example app.
enum ResponsiveBreakpoint { mobile, tablet, desktop }

/// Shared breakpoint helpers for responsive layouts.
class ResponsiveBreakpoints {
  static const double tabletMinWidth = 600;
  static const double tabletMaxWidth = 900;

  static ResponsiveBreakpoint fromWidth(double width) {
    if (width < tabletMinWidth) {
      return ResponsiveBreakpoint.mobile;
    }
    if (width <= tabletMaxWidth) {
      return ResponsiveBreakpoint.tablet;
    }
    return ResponsiveBreakpoint.desktop;
  }

  static bool isMobileWidth(double width) =>
      fromWidth(width) == ResponsiveBreakpoint.mobile;

  static bool isTabletWidth(double width) =>
      fromWidth(width) == ResponsiveBreakpoint.tablet;

  static bool isDesktopWidth(double width) =>
      fromWidth(width) == ResponsiveBreakpoint.desktop;
}

/// Convenience getters for responsive checks from a [BuildContext].
extension ResponsiveBuildContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  ResponsiveBreakpoint get breakpoint =>
      ResponsiveBreakpoints.fromWidth(screenWidth);

  bool get isMobile => breakpoint == ResponsiveBreakpoint.mobile;

  bool get isTablet => breakpoint == ResponsiveBreakpoint.tablet;

  bool get isDesktop => breakpoint == ResponsiveBreakpoint.desktop;
}
