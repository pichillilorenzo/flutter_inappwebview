import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_example/utils/responsive_utils.dart';

void main() {
  group('ResponsiveBreakpoints', () {
    test('test_responsive_breakpoint_detection', () {
      expect(ResponsiveBreakpoints.fromWidth(599), ResponsiveBreakpoint.mobile);
      expect(ResponsiveBreakpoints.fromWidth(600), ResponsiveBreakpoint.tablet);
      expect(ResponsiveBreakpoints.fromWidth(900), ResponsiveBreakpoint.tablet);
      expect(
        ResponsiveBreakpoints.fromWidth(901),
        ResponsiveBreakpoint.desktop,
      );
      expect(ResponsiveBreakpoints.isMobileWidth(320), isTrue);
      expect(ResponsiveBreakpoints.isTabletWidth(700), isTrue);
      expect(ResponsiveBreakpoints.isDesktopWidth(1280), isTrue);
    });
  });

  group('ResponsiveBuildContext', () {
    testWidgets('test_responsive_build_context_getters', (tester) async {
      late bool isMobile;
      late bool isTablet;
      late bool isDesktop;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(320, 800)),
          child: Builder(
            builder: (context) {
              isMobile = context.isMobile;
              isTablet = context.isTablet;
              isDesktop = context.isDesktop;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(isMobile, isTrue);
      expect(isTablet, isFalse);
      expect(isDesktop, isFalse);
    });

    testWidgets('test_responsive_build_context_getters_tablet', (tester) async {
      late bool isMobile;
      late bool isTablet;
      late bool isDesktop;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(700, 800)),
          child: Builder(
            builder: (context) {
              isMobile = context.isMobile;
              isTablet = context.isTablet;
              isDesktop = context.isDesktop;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(isMobile, isFalse);
      expect(isTablet, isTrue);
      expect(isDesktop, isFalse);
    });

    testWidgets('test_responsive_build_context_getters_desktop', (
      tester,
    ) async {
      late bool isMobile;
      late bool isTablet;
      late bool isDesktop;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1200, 800)),
          child: Builder(
            builder: (context) {
              isMobile = context.isMobile;
              isTablet = context.isTablet;
              isDesktop = context.isDesktop;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(isMobile, isFalse);
      expect(isTablet, isFalse);
      expect(isDesktop, isTrue);
    });
  });
}
