import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_example/widgets/common/performance_indicator.dart';
import 'package:flutter_inappwebview_example/utils/constants.dart';

void main() {
  group('PerformanceIndicator', () {
    testWidgets('should show green for duration < 100ms', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PerformanceIndicator(duration: Duration(milliseconds: 50)),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find green colored indicator
      final greenFinder = find.byWidgetPredicate((widget) {
        if (widget is Icon) {
          return widget.color == PerformanceColors.fast;
        }
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          return decoration.color == PerformanceColors.fast;
        }
        if (widget is Text) {
          return widget.style?.color == PerformanceColors.fast;
        }
        return false;
      });

      expect(greenFinder, findsWidgets);
    });

    testWidgets('should show yellow for duration between 100-500ms', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PerformanceIndicator(duration: Duration(milliseconds: 250)),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find yellow colored indicator
      final yellowFinder = find.byWidgetPredicate((widget) {
        if (widget is Icon) {
          return widget.color == PerformanceColors.medium;
        }
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          return decoration.color == PerformanceColors.medium;
        }
        if (widget is Text) {
          return widget.style?.color == PerformanceColors.medium;
        }
        return false;
      });

      expect(yellowFinder, findsWidgets);
    });

    testWidgets('should show red for duration >= 500ms', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PerformanceIndicator(duration: Duration(milliseconds: 750)),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find red colored indicator
      final redFinder = find.byWidgetPredicate((widget) {
        if (widget is Icon) {
          return widget.color == PerformanceColors.slow;
        }
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          return decoration.color == PerformanceColors.slow;
        }
        if (widget is Text) {
          return widget.style?.color == PerformanceColors.slow;
        }
        return false;
      });

      expect(redFinder, findsWidgets);
    });

    testWidgets('should display duration text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PerformanceIndicator(duration: Duration(milliseconds: 123)),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display some duration text
      expect(find.textContaining('ms', findRichText: true), findsOneWidget);
    });

    testWidgets('should handle boundary at 100ms', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PerformanceIndicator(duration: Duration(milliseconds: 100)),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 100ms should be yellow (medium)
      final yellowFinder = find.byWidgetPredicate((widget) {
        if (widget is Icon) {
          return widget.color == PerformanceColors.medium;
        }
        if (widget is Text) {
          return widget.style?.color == PerformanceColors.medium;
        }
        return false;
      });

      expect(yellowFinder, findsWidgets);
    });

    testWidgets('should handle boundary at 500ms', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PerformanceIndicator(duration: Duration(milliseconds: 500)),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 500ms should be red (slow)
      final redFinder = find.byWidgetPredicate((widget) {
        if (widget is Icon) {
          return widget.color == PerformanceColors.slow;
        }
        if (widget is Text) {
          return widget.style?.color == PerformanceColors.slow;
        }
        return false;
      });

      expect(redFinder, findsWidgets);
    });
  });
}
