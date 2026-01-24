import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_example/models/test_result.dart';
import 'package:flutter_inappwebview_example/models/test_runner_models.dart';
import 'package:flutter_inappwebview_example/utils/constants.dart';

void main() {
  test('ExtendedTestResult round-trips via JSON', () {
    final now = DateTime.now();
    final original = ExtendedTestResult(
      testId: 'test_1',
      testTitle: 'Test Title',
      category: TestCategory.navigation,
      success: true,
      message: 'Test passed',
      duration: const Duration(milliseconds: 100),
      timestamp: now,
      data: {'key': 'value'},
      skipped: false,
    );

    final json = original.toJson();
    final restored = ExtendedTestResult.fromJson(json);

    expect(restored.testId, original.testId);
    expect(restored.testTitle, original.testTitle);
    expect(restored.category, original.category);
    expect(restored.success, original.success);
    expect(restored.message, original.message);
    expect(restored.data?['key'], 'value');
  });

  test('ExecutableTestCase exposes metadata', () {
    final testCase = ExecutableTestCase(
      id: 'case_1',
      title: 'Case 1',
      description: 'Desc',
      category: TestCategory.content,
      execute: (controller) async =>
          TestResult(passed: true, message: 'ok', duration: Duration.zero),
      supportedPlatforms: const ['android', 'ios'],
    );

    expect(testCase.id, 'case_1');
    expect(testCase.supportedPlatforms, containsAll(['android', 'ios']));
  });

  test('TestCategoryGroup exposes display name and description', () {
    final group = TestCategoryGroup(
      category: TestCategory.navigation,
      tests: const [],
    );

    expect(group.name, TestCategory.navigation.displayName);
    expect(group.description, TestCategory.navigation.description);
  });
}
