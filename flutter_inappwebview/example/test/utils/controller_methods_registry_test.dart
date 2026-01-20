import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/utils/controller_methods_registry.dart';
import 'package:flutter_inappwebview_example/widgets/common/parameter_dialog.dart';

void main() {
  group('controller_methods_registry helpers', () {
    test('extractParam unwraps hinted values', () {
      const hint = ParameterValueHint<int>(7, ParameterValueType.number);

      expect(extractParam<int>(hint), 7);
      expect(extractParam<String>('value'), 'value');
      expect(extractParam<int>('value'), isNull);
      expect(extractParam<int>(null), isNull);
    });

    test('ControllerMethodEntry.toJson serializes hint and bytes', () {
      final entry = ControllerMethodEntry(
        methodEnum: PlatformInAppWebViewControllerMethod.loadUrl,
        description: 'test',
        parameters: {
          'count': const ParameterValueHint<int>(3, ParameterValueType.number),
          'bytes': Uint8List.fromList([1, 2, 3]),
        },
        requiredParameters: const ['count'],
        execute: (_, __) async => null,
      );

      final json = entry.toJson();
      final params = json['parameters'] as Map<String, dynamic>;

      expect(params['count'], {
        '_type': 'hint',
        'valueType': ParameterValueType.number.name,
        'value': 3,
      });
      expect(params['bytes'], {
        '_type': 'bytes',
        'value': base64.encode([1, 2, 3]),
      });
    });
  });
}
