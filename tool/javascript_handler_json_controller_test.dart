import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

// Shared channel regression tests for the five native platform packages.
void testJavaScriptHandlerJsonController(
  PlatformInAppWebViewController Function() create,
) {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final controller = create();
  const codec = StandardMethodCodec();
  final cases = <String, dynamic>{
    'raw duplicate keys': const JavaScriptHandlerJsonResult(
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
    test('handler reply: ${entry.key}', () async {
      controller.addJavaScriptHandler(
        handlerName: 'jsonResult',
        callback: (JavaScriptHandlerFunctionData data) async => entry.value,
      );
      final response = Completer<ByteData?>();
      // Exercise the platform channel handler, rather than calling encode alone.
      // ignore: deprecated_member_use
      binding.defaultBinaryMessenger.handlePlatformMessage(
        'com.pichillilorenzo/flutter_inappwebview_json-result',
        codec.encodeMethodCall(
          MethodCall('onCallJsHandler', {
            'handlerName': 'jsonResult',
            'data': {
              'args': '[]',
              'origin': 'https://example.com',
              'requestUrl': 'https://example.com',
              'isMainFrame': true,
            },
          }),
        ),
        response.complete,
      );
      final encoded = codec.decodeEnvelope((await response.future)!);
      final result = entry.value;
      expect(
        encoded,
        result is JavaScriptHandlerJsonResult
            ? result.json
            : jsonEncode(result),
      );
    });
  }
}
