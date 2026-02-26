import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_example/models/test_case.dart';
import 'package:flutter_inappwebview_example/models/test_result.dart';
import 'package:flutter_inappwebview_example/utils/constants.dart';
import 'package:flutter_inappwebview_example/utils/test_registry.dart';

void main() {
  group('TestRegistry', () {
    setUp(() {
      TestRegistry.clear();
    });

    test('registers and retrieves test by category', () {
      final testCase = TestCase(
        id: 'test_1',
        title: 'Test Case 1',
        description: 'Test description',
        category: TestCategory.navigation,
        complexity: TestComplexity.quick,
        supportedPlatforms: ['android', 'ios'],
        execute: () async => TestResult(
          passed: true,
          message: 'Test passed',
          duration: Duration.zero,
        ),
      );

      TestRegistry.register(testCase);

      final retrieved = TestRegistry.getTestsByCategory(
        TestCategory.navigation,
      );
      expect(retrieved, hasLength(1));
      expect(retrieved.first.id, 'test_1');
      expect(retrieved.first.title, 'Test Case 1');
    });

    test('retrieves multiple tests for same category', () {
      final testCase1 = TestCase(
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
      );

      final testCase2 = TestCase(
        id: 'test_2',
        title: 'Test 2',
        description: 'Description',
        category: TestCategory.navigation,
        complexity: TestComplexity.medium,
        supportedPlatforms: ['ios'],
        execute: () async => TestResult(
          passed: true,
          message: 'Test passed',
          duration: Duration.zero,
        ),
      );

      TestRegistry.register(testCase1);
      TestRegistry.register(testCase2);

      final retrieved = TestRegistry.getTestsByCategory(
        TestCategory.navigation,
      );
      expect(retrieved, hasLength(2));
    });

    test('returns empty list for category with no tests', () {
      final retrieved = TestRegistry.getTestsByCategory(
        TestCategory.javascript,
      );
      expect(retrieved, isEmpty);
    });

    test('getAllTests returns all registered tests', () {
      final testCase1 = TestCase(
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
      );

      final testCase2 = TestCase(
        id: 'test_2',
        title: 'Test 2',
        description: 'Description',
        category: TestCategory.javascript,
        complexity: TestComplexity.medium,
        supportedPlatforms: ['ios'],
        execute: () async => TestResult(
          passed: true,
          message: 'Test passed',
          duration: Duration.zero,
        ),
      );

      TestRegistry.register(testCase1);
      TestRegistry.register(testCase2);

      final allTests = TestRegistry.getAllTests();
      expect(allTests, hasLength(2));
    });

    test('getTestById returns correct test', () {
      final testCase = TestCase(
        id: 'unique_test',
        title: 'Unique Test',
        description: 'Description',
        category: TestCategory.navigation,
        complexity: TestComplexity.quick,
        supportedPlatforms: ['android'],
        execute: () async => TestResult(
          passed: true,
          message: 'Test passed',
          duration: Duration.zero,
        ),
      );

      TestRegistry.register(testCase);

      final retrieved = TestRegistry.getTestById('unique_test');
      expect(retrieved, isNotNull);
      expect(retrieved?.id, 'unique_test');
      expect(retrieved?.title, 'Unique Test');
    });

    test('getTestById returns null for non-existent id', () {
      final retrieved = TestRegistry.getTestById('non_existent');
      expect(retrieved, isNull);
    });

    test('init registers sample tests', () {
      TestRegistry.init();

      final allTests = TestRegistry.getAllTests();
      expect(allTests.isNotEmpty, true);
      expect(allTests.length, greaterThanOrEqualTo(10));
    });
  });
}
