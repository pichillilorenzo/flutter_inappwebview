import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_example/models/test_configuration.dart';
import 'package:flutter_inappwebview_example/utils/constants.dart';
import 'package:flutter_inappwebview_example/widgets/common/parameter_dialog.dart';

void main() {
  group('CustomTestStep', () {
    test('creates step with required fields', () {
      final step = CustomTestStep(
        id: 'step_1',
        name: 'Test Step',
        description: 'A test step',
        category: TestCategory.navigation,
        action: CustomTestAction.loadUrl('https://example.com'),
      );

      expect(step.id, 'step_1');
      expect(step.name, 'Test Step');
      expect(step.description, 'A test step');
      expect(step.category, TestCategory.navigation);
      expect(step.enabled, true);
      expect(step.order, 0);
      expect(step.expectedResultType, ExpectedResultType.any);
    });

    test('serializes to JSON', () {
      final step = CustomTestStep(
        id: 'step_1',
        name: 'Test Step',
        description: 'A test step',
        category: TestCategory.navigation,
        action: CustomTestAction.loadUrl('https://example.com'),
        expectedResult: 'success',
        expectedResultType: ExpectedResultType.contains,
        enabled: true,
        order: 1,
      );

      final json = step.toJson();
      expect(json['id'], 'step_1');
      expect(json['name'], 'Test Step');
      expect(json['description'], 'A test step');
      expect(json['category'], TestCategory.navigation.name);
      expect(json['expectedResult'], 'success');
      expect(json['expectedResultType'], 'contains');
      expect(json['enabled'], true);
      expect(json['order'], 1);
    });

    test('deserializes from JSON', () {
      final json = {
        'id': 'step_1',
        'name': 'Test Step',
        'description': 'A test step',
        'category': TestCategory.navigation.name,
        'action': {'type': 'loadUrl', 'url': 'https://example.com'},
        'parameters': <String, dynamic>{},
        'expectedResult': 'success',
        'expectedResultType': 'contains',
        'enabled': true,
        'order': 1,
      };

      final step = CustomTestStep.fromJson(json);
      expect(step.id, 'step_1');
      expect(step.name, 'Test Step');
      expect(step.description, 'A test step');
      expect(step.category, TestCategory.navigation);
      expect(step.expectedResult, 'success');
      expect(step.expectedResultType, ExpectedResultType.contains);
      expect(step.enabled, true);
      expect(step.order, 1);
    });

    test('copyWith creates modified copy', () {
      final original = CustomTestStep(
        id: 'step_1',
        name: 'Original',
        description: 'Original description',
        category: TestCategory.navigation,
        action: CustomTestAction.loadUrl('https://example.com'),
      );

      final modified = original.copyWith(name: 'Modified', enabled: false);

      expect(modified.id, 'step_1');
      expect(modified.name, 'Modified');
      expect(modified.description, 'Original description');
      expect(modified.enabled, false);
    });
  });

  group('CustomTestStep validation', () {
    test('validates exact match', () {
      final step = CustomTestStep(
        id: 'step_1',
        name: 'Test',
        description: '',
        category: TestCategory.navigation,
        action: CustomTestAction.evaluateJs(''),
        expectedResult: 'hello',
        expectedResultType: ExpectedResultType.exact,
      );

      expect(step.validateResult('hello'), true);
      expect(step.validateResult('Hello'), false);
      expect(step.validateResult('hello world'), false);
    });

    test('validates contains match', () {
      final step = CustomTestStep(
        id: 'step_1',
        name: 'Test',
        description: '',
        category: TestCategory.navigation,
        action: CustomTestAction.evaluateJs(''),
        expectedResult: 'world',
        expectedResultType: ExpectedResultType.contains,
      );

      expect(step.validateResult('hello world'), true);
      expect(step.validateResult('Hello World'), false);
      expect(step.validateResult('hello'), false);
    });

    test('validates containsIgnoreCase match', () {
      final step = CustomTestStep(
        id: 'step_1',
        name: 'Test',
        description: '',
        category: TestCategory.navigation,
        action: CustomTestAction.evaluateJs(''),
        expectedResult: 'world',
        expectedResultType: ExpectedResultType.containsIgnoreCase,
      );

      expect(step.validateResult('hello world'), true);
      expect(step.validateResult('Hello World'), true);
      expect(step.validateResult('HELLO WORLD'), true);
    });

    test('validates regex match', () {
      final step = CustomTestStep(
        id: 'step_1',
        name: 'Test',
        description: '',
        category: TestCategory.navigation,
        action: CustomTestAction.evaluateJs(''),
        expectedResult: r'^\d{3}-\d{4}$',
        expectedResultType: ExpectedResultType.regex,
      );

      expect(step.validateResult('123-4567'), true);
      expect(step.validateResult('12-34567'), false);
      expect(step.validateResult('abc-defg'), false);
    });

    test('validates notNull', () {
      final step = CustomTestStep(
        id: 'step_1',
        name: 'Test',
        description: '',
        category: TestCategory.navigation,
        action: CustomTestAction.evaluateJs(''),
        expectedResultType: ExpectedResultType.notNull,
      );

      expect(step.validateResult('value'), true);
      expect(step.validateResult(123), true);
      expect(step.validateResult(null), false);
    });

    test('validates isNull', () {
      final step = CustomTestStep(
        id: 'step_1',
        name: 'Test',
        description: '',
        category: TestCategory.navigation,
        action: CustomTestAction.evaluateJs(''),
        expectedResultType: ExpectedResultType.isNull,
      );

      expect(step.validateResult(null), true);
      expect(step.validateResult('value'), false);
    });

    test('validates truthy', () {
      final step = CustomTestStep(
        id: 'step_1',
        name: 'Test',
        description: '',
        category: TestCategory.navigation,
        action: CustomTestAction.evaluateJs(''),
        expectedResultType: ExpectedResultType.truthy,
      );

      expect(step.validateResult(true), true);
      expect(step.validateResult('non-empty'), true);
      expect(step.validateResult(1), true);
      expect(step.validateResult([1, 2, 3]), true);
      expect(step.validateResult({'key': 'value'}), true);
      expect(step.validateResult(false), false);
      expect(step.validateResult(''), false);
      expect(step.validateResult(0), false);
      expect(step.validateResult([]), false);
      expect(step.validateResult(null), false);
    });

    test('validates falsy', () {
      final step = CustomTestStep(
        id: 'step_1',
        name: 'Test',
        description: '',
        category: TestCategory.navigation,
        action: CustomTestAction.evaluateJs(''),
        expectedResultType: ExpectedResultType.falsy,
      );

      expect(step.validateResult(false), true);
      expect(step.validateResult(''), true);
      expect(step.validateResult(0), true);
      expect(step.validateResult([]), true);
      expect(step.validateResult(null), true);
      expect(step.validateResult(true), false);
      expect(step.validateResult('value'), false);
    });

    test('validates typeIs', () {
      final step = CustomTestStep(
        id: 'step_1',
        name: 'Test',
        description: '',
        category: TestCategory.navigation,
        action: CustomTestAction.evaluateJs(''),
        expectedResult: 'String',
        expectedResultType: ExpectedResultType.typeIs,
      );

      expect(step.validateResult('hello'), true);
      expect(step.validateResult(123), false);
    });

    test('validates lengthEquals', () {
      final step = CustomTestStep(
        id: 'step_1',
        name: 'Test',
        description: '',
        category: TestCategory.navigation,
        action: CustomTestAction.evaluateJs(''),
        expectedResult: '3',
        expectedResultType: ExpectedResultType.lengthEquals,
      );

      expect(step.validateResult([1, 2, 3]), true);
      expect(step.validateResult('abc'), true);
      expect(step.validateResult({'a': 1, 'b': 2, 'c': 3}), true);
      expect(step.validateResult([1, 2]), false);
    });

    test('validates greaterThan', () {
      final step = CustomTestStep(
        id: 'step_1',
        name: 'Test',
        description: '',
        category: TestCategory.navigation,
        action: CustomTestAction.evaluateJs(''),
        expectedResult: '10',
        expectedResultType: ExpectedResultType.greaterThan,
      );

      expect(step.validateResult(15), true);
      expect(step.validateResult(10), false);
      expect(step.validateResult(5), false);
    });

    test('validates lessThan', () {
      final step = CustomTestStep(
        id: 'step_1',
        name: 'Test',
        description: '',
        category: TestCategory.navigation,
        action: CustomTestAction.evaluateJs(''),
        expectedResult: '10',
        expectedResultType: ExpectedResultType.lessThan,
      );

      expect(step.validateResult(5), true);
      expect(step.validateResult(10), false);
      expect(step.validateResult(15), false);
    });
  });

  group('CustomTestAction', () {
    test('creates loadUrl action', () {
      final action = CustomTestAction.loadUrl('https://example.com');
      expect(action.type, CustomTestActionType.loadUrl);
      expect(action.url, 'https://example.com');
    });

    test('creates evaluateJs action', () {
      final action = CustomTestAction.evaluateJs('return 1 + 1');
      expect(action.type, CustomTestActionType.evaluateJavascript);
      expect(action.script, 'return 1 + 1');
    });

    test('creates delay action', () {
      final action = CustomTestAction.delay(1000);
      expect(action.type, CustomTestActionType.delay);
      expect(action.delayMs, 1000);
    });

    test('creates controllerMethod action', () {
      final action = CustomTestAction.controllerMethod(
        'loadUrl',
        parameters: {'url': 'https://example.com'},
      );
      expect(action.type, CustomTestActionType.controllerMethod);
      expect(action.methodId, 'loadUrl');
      expect(action.methodParameters, {'url': 'https://example.com'});
    });

    test('serializes to JSON', () {
      final action = CustomTestAction.controllerMethod(
        'loadUrl',
        parameters: {
          'url': 'https://example.com',
          'headers': {'Accept': 'text/html'},
        },
      );

      final json = action.toJson();
      expect(json['type'], 'controllerMethod');
      expect(json['methodId'], 'loadUrl');
      expect(json['methodParameters']['url'], 'https://example.com');
    });

    test('deserializes from JSON', () {
      final json = {
        'type': 'controllerMethod',
        'methodId': 'loadUrl',
        'methodParameters': {'url': 'https://example.com'},
      };

      final action = CustomTestAction.fromJson(json);
      expect(action.type, CustomTestActionType.controllerMethod);
      expect(action.methodId, 'loadUrl');
      expect(action.methodParameters?['url'], 'https://example.com');
    });

    test('sanitizes ParameterValueHint values', () {
      final action = CustomTestAction.controllerMethod(
        'loadUrl',
        parameters: {
          'url': 'https://example.com',
          'body': const ParameterValueHint<Uint8List?>(
            null,
            ParameterValueType.bytes,
          ),
        },
      );

      final json = action.toJson();
      // ParameterValueHint with null value should become null
      expect(json['methodParameters']['body'], null);
    });

    test('sanitizes Uint8List values to base64', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final action = CustomTestAction.controllerMethod(
        'postUrl',
        parameters: {'url': 'https://example.com', 'postData': bytes},
      );

      final json = action.toJson();
      expect(json['methodParameters']['postData']['_type'], 'bytes');
      expect(
        json['methodParameters']['postData']['value'],
        base64.encode(bytes),
      );
    });

    test('deserializes base64 bytes', () {
      final originalBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final json = {
        'type': 'controllerMethod',
        'methodId': 'postUrl',
        'methodParameters': {
          'url': 'https://example.com',
          'postData': {'_type': 'bytes', 'value': base64.encode(originalBytes)},
        },
      };

      final action = CustomTestAction.fromJson(json);
      final postData = action.methodParameters?['postData'];
      expect(postData, isA<Uint8List>());
      expect(postData, equals(originalBytes));
    });

    test('handles nested maps and lists in parameters', () {
      final action = CustomTestAction.controllerMethod(
        'loadUrl',
        parameters: {
          'url': 'https://example.com',
          'headers': {
            'Accept': 'text/html',
            'Custom': ['value1', 'value2'],
          },
          'options': {
            'nested': {'deep': true},
          },
        },
      );

      final json = action.toJson();
      final deserialized = CustomTestAction.fromJson(json);

      expect(deserialized.methodParameters?['headers']['Accept'], 'text/html');
      expect(
        deserialized.methodParameters?['headers']['Custom'],
        equals(['value1', 'value2']),
      );
      expect(deserialized.methodParameters?['options']['nested']['deep'], true);
    });
  });

  group('TestConfiguration', () {
    test('creates empty configuration', () {
      final config = TestConfiguration.empty(name: 'My Config');
      expect(config.name, 'My Config');
      expect(config.customSteps, isEmpty);
      expect(config.webViewType, TestWebViewType.inAppWebView);
    });

    test('creates default configuration', () {
      final config = TestConfiguration.defaultConfig();
      expect(config.name, 'Default Test Configuration');
      expect(config.customSteps, isNotEmpty);
    });

    test('serializes to JSON', () {
      final config = TestConfiguration(
        id: 'config_1',
        name: 'Test Config',
        description: 'A test configuration',
        createdAt: DateTime(2024, 1, 1),
        modifiedAt: DateTime(2024, 1, 2),
        customSteps: [
          CustomTestStep(
            id: 'step_1',
            name: 'Step 1',
            description: 'First step',
            category: TestCategory.navigation,
            action: CustomTestAction.loadUrl('https://example.com'),
          ),
        ],
        webViewType: TestWebViewType.headless,
        initialUrl: 'https://start.com',
      );

      final json = config.toJson();
      expect(json['id'], 'config_1');
      expect(json['name'], 'Test Config');
      expect(json['description'], 'A test configuration');
      expect(json['customSteps'], hasLength(1));
      expect(json['webViewType'], 'headless');
      expect(json['initialUrl'], 'https://start.com');
    });

    test('deserializes from JSON', () {
      final json = {
        'id': 'config_1',
        'name': 'Test Config',
        'description': 'A test configuration',
        'createdAt': '2024-01-01T00:00:00.000',
        'modifiedAt': '2024-01-02T00:00:00.000',
        'customSteps': [
          {
            'id': 'step_1',
            'name': 'Step 1',
            'description': 'First step',
            'category': TestCategory.navigation.name,
            'action': {'type': 'loadUrl', 'url': 'https://example.com'},
            'parameters': <String, dynamic>{},
            'expectedResultType': 'any',
            'enabled': true,
            'order': 0,
          },
        ],
        'testOrdering': <String, dynamic>{},
        'enabledBuiltInTests': <String>[],
        'metadata': <String, dynamic>{},
        'webViewType': 'headless',
        'initialUrl': 'https://start.com',
      };

      final config = TestConfiguration.fromJson(json);
      expect(config.id, 'config_1');
      expect(config.name, 'Test Config');
      expect(config.customSteps, hasLength(1));
      expect(config.webViewType, TestWebViewType.headless);
      expect(config.initialUrl, 'https://start.com');
    });

    test('roundtrip JSON serialization', () {
      final original = TestConfiguration(
        id: 'config_1',
        name: 'Test Config',
        description: 'A test configuration',
        createdAt: DateTime(2024, 1, 1),
        modifiedAt: DateTime(2024, 1, 2),
        customSteps: [
          CustomTestStep(
            id: 'step_1',
            name: 'Load URL',
            description: 'Load a URL',
            category: TestCategory.navigation,
            action: CustomTestAction.controllerMethod(
              'loadUrl',
              parameters: {
                'url': 'https://example.com',
                'headers': {'Accept': 'text/html'},
              },
            ),
            expectedResult: 'success',
            expectedResultType: ExpectedResultType.contains,
          ),
        ],
        webViewType: TestWebViewType.headless,
        initialUrl: 'https://start.com',
      );

      final jsonString = original.toJsonString();
      final restored = TestConfiguration.fromJsonString(jsonString);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.description, original.description);
      expect(restored.customSteps.length, original.customSteps.length);
      expect(restored.customSteps[0].id, original.customSteps[0].id);
      expect(restored.customSteps[0].name, original.customSteps[0].name);
      expect(restored.webViewType, original.webViewType);
      expect(restored.initialUrl, original.initialUrl);
    });

    test('copyWith creates modified copy', () {
      final original = TestConfiguration.empty(name: 'Original');
      final modified = original.copyWith(
        name: 'Modified',
        webViewType: TestWebViewType.headless,
      );

      expect(modified.id, original.id);
      expect(modified.name, 'Modified');
      expect(modified.webViewType, TestWebViewType.headless);
    });
  });

  group('TestConfiguration bytes serialization', () {
    test('handles ParameterValueHint with Uint8List in roundtrip', () {
      // Simulate the scenario that caused the bug:
      // A config with ParameterValueHint<Uint8List?> should serialize properly
      final config = TestConfiguration(
        id: 'config_1',
        name: 'Test Config',
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
        customSteps: [
          CustomTestStep(
            id: 'step_1',
            name: 'Load URL with body',
            description: 'Test',
            category: TestCategory.navigation,
            action: CustomTestAction.controllerMethod(
              'loadUrl',
              parameters: {
                'url': 'https://example.com',
                'method': 'POST',
                'headers': <String, dynamic>{},
                // This was the problematic case - ParameterValueHint with null value
                'body': const ParameterValueHint<Uint8List?>(
                  null,
                  ParameterValueType.bytes,
                ),
              },
            ),
          ),
        ],
      );

      // Serialize and deserialize
      final jsonString = config.toJsonString();
      final restored = TestConfiguration.fromJsonString(jsonString);

      // The body parameter should be null, not a string representation
      final restoredBody =
          restored.customSteps[0].action.methodParameters?['body'];
      expect(restoredBody, isNull);
    });

    test('handles actual Uint8List data in roundtrip', () {
      final testData = Uint8List.fromList([72, 101, 108, 108, 111]); // "Hello"

      final config = TestConfiguration(
        id: 'config_1',
        name: 'Test Config',
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
        customSteps: [
          CustomTestStep(
            id: 'step_1',
            name: 'POST with data',
            description: 'Test',
            category: TestCategory.navigation,
            action: CustomTestAction.controllerMethod(
              'postUrl',
              parameters: {
                'url': 'https://httpbin.org/post',
                'postData': testData,
              },
            ),
          ),
        ],
      );

      // Serialize and deserialize
      final jsonString = config.toJsonString();
      final restored = TestConfiguration.fromJsonString(jsonString);

      // The postData should be restored as Uint8List
      final restoredData =
          restored.customSteps[0].action.methodParameters?['postData'];
      expect(restoredData, isA<Uint8List>());
      expect(restoredData, equals(testData));
    });

    test('preserves non-bytes parameters correctly', () {
      final config = TestConfiguration(
        id: 'config_1',
        name: 'Test Config',
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
        customSteps: [
          CustomTestStep(
            id: 'step_1',
            name: 'Load URL',
            description: 'Test',
            category: TestCategory.navigation,
            action: CustomTestAction.controllerMethod(
              'loadUrl',
              parameters: {
                'url': 'https://example.com',
                'method': 'GET',
                'headers': {'Accept': 'application/json'},
              },
            ),
          ),
        ],
      );

      final jsonString = config.toJsonString();
      final restored = TestConfiguration.fromJsonString(jsonString);

      expect(
        restored.customSteps[0].action.methodParameters?['url'],
        'https://example.com',
      );
      expect(restored.customSteps[0].action.methodParameters?['method'], 'GET');
      expect(
        restored.customSteps[0].action.methodParameters?['headers']['Accept'],
        'application/json',
      );
    });
  });
}
