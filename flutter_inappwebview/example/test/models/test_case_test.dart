import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_example/models/test_case.dart';
import 'package:flutter_inappwebview_example/utils/constants.dart';

void main() {
  group('TestCase', () {
    test('fromMap should deserialize JSON correctly', () {
      final map = {
        'id': 'test_1',
        'title': 'Test Title',
        'description': 'Test Description',
        'supportedPlatforms': ['android', 'ios'],
        'category': 'navigation',
        'complexity': 'quick',
      };

      final testCase = TestCase.fromMap(map);

      expect(testCase.id, 'test_1');
      expect(testCase.title, 'Test Title');
      expect(testCase.description, 'Test Description');
      expect(testCase.supportedPlatforms, ['android', 'ios']);
      expect(testCase.category, TestCategory.navigation);
      expect(testCase.complexity, TestComplexity.quick);
    });

    test('toMap should serialize to JSON correctly', () {
      final testCase = TestCase(
        id: 'test_2',
        title: 'Test Title 2',
        description: 'Test Description 2',
        supportedPlatforms: ['web', 'windows'],
        category: TestCategory.javascript,
        complexity: TestComplexity.medium,
        execute: () async {
          return null;
        },
      );

      final map = testCase.toMap();

      expect(map['id'], 'test_2');
      expect(map['title'], 'Test Title 2');
      expect(map['description'], 'Test Description 2');
      expect(map['supportedPlatforms'], ['web', 'windows']);
      expect(map['category'], 'javascript');
      expect(map['complexity'], 'medium');
    });

    test('isSupportedOnPlatform should check platform support correctly', () {
      final testCase = TestCase(
        id: 'test_3',
        title: 'Test',
        description: 'Test',
        supportedPlatforms: ['android', 'ios', 'macos'],
        category: TestCategory.content,
        complexity: TestComplexity.quick,
        execute: () async {
          return null;
        },
      );

      expect(testCase.isSupportedOnPlatform('android'), true);
      expect(testCase.isSupportedOnPlatform('ios'), true);
      expect(testCase.isSupportedOnPlatform('macos'), true);
      expect(testCase.isSupportedOnPlatform('web'), false);
      expect(testCase.isSupportedOnPlatform('windows'), false);
      expect(testCase.isSupportedOnPlatform('linux'), false);
    });

    test('equality should work correctly', () {
      final testCase1 = TestCase(
        id: 'test_1',
        title: 'Test',
        description: 'Test',
        supportedPlatforms: ['android'],
        category: TestCategory.navigation,
        complexity: TestComplexity.quick,
        execute: () async {
          return null;
        },
      );

      final testCase2 = TestCase(
        id: 'test_1',
        title: 'Test',
        description: 'Test',
        supportedPlatforms: ['android'],
        category: TestCategory.navigation,
        complexity: TestComplexity.quick,
        execute: () async {
          return null;
        },
      );

      final testCase3 = TestCase(
        id: 'test_2',
        title: 'Test',
        description: 'Test',
        supportedPlatforms: ['android'],
        category: TestCategory.navigation,
        complexity: TestComplexity.quick,
        execute: () async {
          return null;
        },
      );

      expect(testCase1, testCase2);
      expect(testCase1, isNot(testCase3));
    });
  });
}
