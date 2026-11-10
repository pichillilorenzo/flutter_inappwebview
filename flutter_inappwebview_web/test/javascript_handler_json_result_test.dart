import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_web/flutter_inappwebview_web.dart';
import 'package:flutter_inappwebview_web/src/in_app_webview/in_app_webview_controller.dart'
    show InternalInAppWebViewController;
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final controller = WebPlatformInAppWebViewController(
    const PlatformInAppWebViewControllerCreationParams(id: 'json-result'),
  );
  final cases = <String, dynamic>{
    'duplicate keys': const JavaScriptHandlerJsonResult(
      '{"__proto__":1,"__proto__":2}',
    ),
    'raw string': const JavaScriptHandlerJsonResult(r'"עברית\n"'),
    'raw null': const JavaScriptHandlerJsonResult('null'),
    'ordinary object': {
      'a': [1, true, null],
    },
    'ordinary string': 'text',
    'ordinary null': null,
    'nested compatibility': {
      'data': const JavaScriptHandlerJsonResult('[1,2]'),
    },
  };
  for (final entry in cases.entries) {
    test('browser handler reply: ${entry.key}', () async {
      controller.addJavaScriptHandler(
        handlerName: 'jsonResult',
        callback: (JavaScriptHandlerFunctionData data) async => entry.value,
      );
      final encoded = await controller.handleMethod(
        MethodCall('onCallJsHandler', {
          'handlerName': 'jsonResult',
          'data': {
            'args': '[]',
            'origin': 'https://example.com',
            'requestUrl': 'https://example.com',
            'isMainFrame': true,
          },
        }),
      );
      final result = entry.value;
      expect(
        encoded,
        result is JavaScriptHandlerJsonResult
            ? result.json
            : jsonEncode(result),
      );
      expect(jsonDecode(encoded as String), jsonDecode(jsonEncode(result)));
    });
  }
}
