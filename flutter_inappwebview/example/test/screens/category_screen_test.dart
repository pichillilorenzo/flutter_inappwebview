import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview_example/screens/category_screen.dart';
import 'package:flutter_inappwebview_example/utils/constants.dart';
import 'package:flutter_inappwebview_example/utils/test_registry.dart';
import 'package:flutter_inappwebview_example/models/test_case.dart';
import 'package:flutter_inappwebview_example/models/test_result.dart';
import 'package:flutter_inappwebview_example/providers/event_log_provider.dart';
import 'package:flutter_inappwebview_example/providers/settings_manager.dart';
import 'package:flutter_inappwebview_example/providers/test_runner.dart';
import 'package:flutter_inappwebview_example/providers/network_monitor.dart';

void main() {
  group('CategoryScreen', () {
    setUp(() {
      TestRegistry.clear();
    });

    Widget createTestWidget(TestCategory category) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => EventLogProvider()),
          ChangeNotifierProvider(create: (_) => SettingsManager()),
          ChangeNotifierProvider(create: (_) => TestRunner()),
          ChangeNotifierProvider(create: (_) => NetworkMonitor()),
        ],
        child: MaterialApp(home: CategoryScreen(category: category)),
      );
    }

    testWidgets('displays category name in AppBar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(TestCategory.navigation));

      expect(find.text('Navigation Tests'), findsOneWidget);
    });

    testWidgets('displays tests from registry', (WidgetTester tester) async {
      // Register a test
      TestRegistry.register(
        TestCase(
          id: 'test_1',
          title: 'Test Title',
          description: 'Test description',
          category: TestCategory.navigation,
          complexity: TestComplexity.quick,
          supportedPlatforms: ['android'],
          execute: () async => TestResult(
            passed: true,
            message: 'Test passed',
            duration: Duration.zero,
          ),
        ),
      );

      await tester.pumpWidget(createTestWidget(TestCategory.navigation));

      expect(find.text('Test Title'), findsOneWidget);
    });

    testWidgets('displays empty state when no tests', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(TestCategory.navigation));

      expect(find.text('No tests available'), findsOneWidget);
      expect(
        find.text('No tests registered for this category'),
        findsOneWidget,
      );
    });

    testWidgets('displays multiple tests', (WidgetTester tester) async {
      TestRegistry.register(
        TestCase(
          id: 'test_1',
          title: 'Test 1',
          description: 'Description 1',
          category: TestCategory.navigation,
          complexity: TestComplexity.quick,
          supportedPlatforms: ['android'],
          execute: () async => TestResult(
            passed: true,
            message: 'Test passed',
            duration: Duration.zero,
          ),
        ),
      );

      TestRegistry.register(
        TestCase(
          id: 'test_2',
          title: 'Test 2',
          description: 'Description 2',
          category: TestCategory.navigation,
          complexity: TestComplexity.medium,
          supportedPlatforms: ['ios'],
          execute: () async => TestResult(
            passed: true,
            message: 'Test passed',
            duration: Duration.zero,
          ),
        ),
      );

      await tester.pumpWidget(createTestWidget(TestCategory.navigation));

      expect(find.text('Test 1'), findsOneWidget);
      expect(find.text('Test 2'), findsOneWidget);
    });

    testWidgets('has platform filter button', (WidgetTester tester) async {
      TestRegistry.register(
        TestCase(
          id: 'test_1',
          title: 'Test 1',
          description: 'Description',
          category: TestCategory.navigation,
          complexity: TestComplexity.quick,
          supportedPlatforms: ['android', 'ios'],
          execute: () async => TestResult(
            passed: true,
            message: 'Test passed',
            duration: Duration.zero,
          ),
        ),
      );

      await tester.pumpWidget(createTestWidget(TestCategory.navigation));

      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });

    testWidgets('displays test count', (WidgetTester tester) async {
      TestRegistry.register(
        TestCase(
          id: 'test_1',
          title: 'Test 1',
          description: 'Description',
          category: TestCategory.navigation,
          complexity: TestComplexity.quick,
          supportedPlatforms: ['android'],
          execute: () async => TestResult(
            passed: true,
            message: 'Test passed',
            duration: Duration.zero,
          ),
        ),
      );

      await tester.pumpWidget(createTestWidget(TestCategory.navigation));

      expect(find.textContaining('1 test'), findsOneWidget);
    });
  });
}
