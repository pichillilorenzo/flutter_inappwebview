import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_example/widgets/common/test_card.dart';
import 'package:flutter_inappwebview_example/models/test_case.dart';
import 'package:flutter_inappwebview_example/utils/constants.dart';

void main() {
  group('TestCard', () {
    late TestCase testCase;

    setUp(() {
      testCase = TestCase(
        id: 'test_1',
        title: 'Test Title',
        description: 'Test Description',
        supportedPlatforms: ['android', 'ios'],
        category: TestCategory.navigation,
        complexity: TestComplexity.quick,
        execute: () async => null,
      );
    });

    testWidgets('should render title, description, and run button', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestCard(testCase: testCase, onRun: () {}),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('should call onRun when run button is tapped', (tester) async {
      bool runCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestCard(
              testCase: testCase,
              onRun: () {
                runCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the run button
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      expect(runCalled, true);
    });

    testWidgets('should expand and collapse details on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestCard(testCase: testCase, onRun: () {}),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially collapsed - details should not be visible
      expect(find.text('Category:'), findsNothing);

      // Tap the card to expand
      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      // Details should now be visible
      expect(find.text('Category:'), findsOneWidget);
      expect(find.text('Complexity:'), findsOneWidget);

      // Tap again to collapse
      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      // Details should be hidden again
      expect(find.text('Category:'), findsNothing);
    });

    testWidgets('should display status indicator when status is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestCard(
              testCase: testCase,
              onRun: () {},
              status: TestStatus.passed,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should find a success/passed indicator
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should display failed status indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestCard(
              testCase: testCase,
              onRun: () {},
              status: TestStatus.failed,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should find a failed indicator
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('should display running status indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestCard(
              testCase: testCase,
              onRun: () {},
              status: TestStatus.running,
            ),
          ),
        ),
      );

      await tester.pump();

      // Should find a running/progress indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
