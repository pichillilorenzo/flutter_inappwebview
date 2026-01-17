import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_example/widgets/common/support_badge.dart';
import 'package:flutter_inappwebview_example/utils/constants.dart';

void main() {
  group('SupportBadge', () {
    testWidgets('should render badge for multiple platforms', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SupportBadge(
              supportedPlatforms: ['android', 'ios'],
              currentPlatform: 'android',
            ),
          ),
        ),
      );

      // Should find at least platform icons/indicators
      expect(find.byType(SupportBadge), findsOneWidget);
    });

    testWidgets('should show green indicator for supported platform', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SupportBadge(
              supportedPlatforms: ['android', 'ios'],
              currentPlatform: 'android',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find a widget with the supported color
      final supportedColorFinder = find.byWidgetPredicate((widget) {
        if (widget is Icon) {
          return widget.color == SupportBadgeColors.supported;
        }
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          return decoration.color == SupportBadgeColors.supported;
        }
        return false;
      });

      expect(supportedColorFinder, findsWidgets);
    });

    testWidgets('should show red indicator for unsupported platform', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SupportBadge(
              supportedPlatforms: ['android', 'ios'],
              currentPlatform: 'web',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find a widget with the unsupported color
      final unsupportedColorFinder = find.byWidgetPredicate((widget) {
        if (widget is Icon) {
          return widget.color == SupportBadgeColors.unsupported;
        }
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          return decoration.color == SupportBadgeColors.unsupported;
        }
        return false;
      });

      expect(unsupportedColorFinder, findsWidgets);
    });

    testWidgets('should display platform names on tap', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SupportBadge(
              supportedPlatforms: ['android', 'ios', 'macos'],
              currentPlatform: 'android',
            ),
          ),
        ),
      );

      // Tap the badge
      await tester.tap(find.byType(SupportBadge));
      await tester.pumpAndSettle();

      // Should show tooltip or dialog with platform names
      // This is tested by checking if platform names appear
      final androidFinder = find.textContaining('Android', findRichText: true);
      final iosFinder = find.textContaining('iOS', findRichText: true);

      expect(
        androidFinder.evaluate().length + iosFinder.evaluate().length,
        greaterThan(0),
      );
    });
  });
}
