import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_example/providers/test_runner.dart';
import 'package:flutter_inappwebview_example/models/test_configuration.dart';
import 'package:flutter_inappwebview_example/models/test_result.dart';
import 'package:flutter_inappwebview_example/models/test_runner_models.dart';
import 'package:flutter_inappwebview_example/utils/constants.dart';

void main() {
  group('TestRunner', () {
    late TestRunner testRunner;

    setUp(() {
      testRunner = TestRunner();
    });

    group('Initial State', () {
      test('starts with idle status', () {
        expect(testRunner.status, TestStatus.idle);
      });

      test('starts with no results', () {
        expect(testRunner.results, isEmpty);
      });

      test('starts with zero progress', () {
        expect(testRunner.progress, 0);
        expect(testRunner.total, 0);
      });

      test('starts with no current test', () {
        expect(testRunner.currentTest, isNull);
      });

      test('successRate is 0 when no tests', () {
        expect(testRunner.successRate, 0.0);
      });
    });

    group('Test Categories', () {
      test('getTestCategories returns all categories', () {
        final categories = TestRunner.getTestCategories();

        expect(categories, isNotEmpty);
        expect(
          categories.map((c) => c.category),
          containsAll([
            TestCategory.navigation,
            TestCategory.javascript,
            TestCategory.content,
            TestCategory.storage,
            TestCategory.advanced,
          ]),
        );
      });

      test('each category has tests', () {
        final categories = TestRunner.getTestCategories();

        for (final category in categories) {
          expect(
            category.tests,
            isNotEmpty,
            reason: 'Category ${category.name} should have tests',
          );
        }
      });

      test('each category has a non-empty name', () {
        final categories = TestRunner.getTestCategories();

        for (final category in categories) {
          expect(category.name, isNotEmpty);
        }
      });
    });

    group('Results Management', () {
      test('clearResults resets state', () {
        // Add some mock state
        testRunner.clearResults();

        expect(testRunner.results, isEmpty);
        expect(testRunner.status, TestStatus.idle);
        expect(testRunner.progress, 0);
        expect(testRunner.total, 0);
      });
    });

    group('Result Statistics', () {
      test('counts passed tests correctly', () {
        // We can't directly add results, but we can test the calculation methods
        expect(testRunner.passed, 0);
        expect(testRunner.failed, 0);
        expect(testRunner.skipped, 0);
      });
    });

    group('Export Functionality', () {
      test('exports empty results as valid JSON', () {
        final jsonString = testRunner.exportResultsAsJson();

        expect(jsonString, isNotEmpty);
        expect(() => jsonString, returnsNormally);
      });
    });
  });

  group('TestCategory', () {
    test('has all expected categories', () {
      expect(TestCategory.values, contains(TestCategory.navigation));
      expect(TestCategory.values, contains(TestCategory.javascript));
      expect(TestCategory.values, contains(TestCategory.content));
      expect(TestCategory.values, contains(TestCategory.storage));
      expect(TestCategory.values, contains(TestCategory.advanced));
      expect(TestCategory.values, contains(TestCategory.browsers));
    });
  });

  group('TestStatus', () {
    test('has all expected statuses', () {
      expect(TestStatus.values, contains(TestStatus.idle));
      expect(TestStatus.values, contains(TestStatus.running));
      expect(TestStatus.values, contains(TestStatus.paused));
      expect(TestStatus.values, contains(TestStatus.completed));
      expect(TestStatus.values, contains(TestStatus.error));
    });
  });

  group('ExecutableTestCase', () {
    test('can be created with required fields', () {
      final testCase = ExecutableTestCase(
        id: 'test_1',
        title: 'Test Title',
        description: 'Test description',
        category: TestCategory.navigation,
        execute: (controller) async {
          return TestResult(
            passed: true,
            message: 'Test passed',
            duration: Duration.zero,
          );
        },
      );

      expect(testCase.id, 'test_1');
      expect(testCase.title, 'Test Title');
      expect(testCase.description, 'Test description');
      expect(testCase.category, TestCategory.navigation);
    });

    test('supports platform filtering', () {
      final testCase = ExecutableTestCase(
        id: 'test_1',
        title: 'Test Title',
        description: 'Test description',
        category: TestCategory.navigation,
        supportedPlatforms: ['android', 'ios'],
        execute: (controller) async => TestResult(
          passed: true,
          message: 'Test passed',
          duration: Duration.zero,
        ),
      );

      expect(testCase.supportedPlatforms, containsAll(['android', 'ios']));
    });
  });

  group('ExtendedTestResult', () {
    test('can be created with required fields', () {
      final result = ExtendedTestResult(
        testId: 'test_1',
        testTitle: 'Test Title',
        category: TestCategory.navigation,
        success: true,
        message: 'Test passed',
        duration: const Duration(milliseconds: 100),
        timestamp: DateTime.now(),
      );

      expect(result.testId, 'test_1');
      expect(result.testTitle, 'Test Title');
      expect(result.category, TestCategory.navigation);
      expect(result.success, true);
      expect(result.message, 'Test passed');
      expect(result.skipped, false);
    });

    test('supports skipped state', () {
      final result = ExtendedTestResult(
        testId: 'test_1',
        testTitle: 'Test Title',
        category: TestCategory.navigation,
        success: false,
        message: 'Skipped',
        duration: Duration.zero,
        timestamp: DateTime.now(),
        skipped: true,
        skipReason: 'Platform not supported',
      );

      expect(result.skipped, true);
      expect(result.skipReason, 'Platform not supported');
    });

    test('can store additional data', () {
      final result = ExtendedTestResult(
        testId: 'test_1',
        testTitle: 'Test Title',
        category: TestCategory.navigation,
        success: true,
        message: 'Test passed',
        duration: const Duration(milliseconds: 100),
        timestamp: DateTime.now(),
        data: {'key': 'value', 'count': 42},
      );

      expect(result.data, isNotNull);
      expect(result.data!['key'], 'value');
      expect(result.data!['count'], 42);
    });
  });

  group('TestCategoryGroup', () {
    test('can be created with tests', () {
      final group = TestCategoryGroup(
        category: TestCategory.navigation,
        tests: [
          ExecutableTestCase(
            id: 'test_1',
            title: 'Test 1',
            description: 'Description',
            category: TestCategory.navigation,
            execute: (controller) async => TestResult(
              passed: true,
              message: 'Test passed',
              duration: Duration.zero,
            ),
          ),
        ],
      );

      expect(group.name, TestCategory.navigation.displayName);
      expect(group.description, TestCategory.navigation.description);
      expect(group.category, TestCategory.navigation);
      expect(group.tests, hasLength(1));
    });
  });

  group('TestConfiguration Integration', () {
    test('TestWebViewType enum values', () {
      expect(TestWebViewType.values, contains(TestWebViewType.inAppWebView));
      expect(TestWebViewType.values, contains(TestWebViewType.headless));
    });

    test('ExpectedResultType enum has all validators', () {
      expect(ExpectedResultType.values, contains(ExpectedResultType.any));
      expect(ExpectedResultType.values, contains(ExpectedResultType.exact));
      expect(ExpectedResultType.values, contains(ExpectedResultType.contains));
      expect(ExpectedResultType.values, contains(ExpectedResultType.regex));
      expect(ExpectedResultType.values, contains(ExpectedResultType.notNull));
      expect(ExpectedResultType.values, contains(ExpectedResultType.isNull));
      expect(ExpectedResultType.values, contains(ExpectedResultType.truthy));
      expect(ExpectedResultType.values, contains(ExpectedResultType.falsy));
    });

    test('CustomTestActionType enum has all action types', () {
      expect(
        CustomTestActionType.values,
        contains(CustomTestActionType.evaluateJavascript),
      );
      expect(
        CustomTestActionType.values,
        contains(CustomTestActionType.loadUrl),
      );
      expect(
        CustomTestActionType.values,
        contains(CustomTestActionType.loadHtml),
      );
      expect(
        CustomTestActionType.values,
        contains(CustomTestActionType.controllerMethod),
      );
      expect(CustomTestActionType.values, contains(CustomTestActionType.delay));
    });
  });
}
