import 'dart:convert';

import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('encode passes pre-encoded JSON through unchanged', () {
    const json = '{"a":[1,{"b":"\\"x\\""}]}';

    final encoded = JavaScriptHandlerJsonResult.encode(
      const JavaScriptHandlerJsonResult(json),
    );

    expect(identical(encoded, json), isTrue);
  });

  test('encode keeps jsonEncode for other results', () {
    expect(JavaScriptHandlerJsonResult.encode({'a': 1}), '{"a":1}');
    expect(JavaScriptHandlerJsonResult.encode(null), 'null');
  });

  test('raw JSON preserves duplicate keys and formatting until received', () {
    const json = ' \n{"__proto__":1,"__proto__":2}\t';
    final result = JavaScriptHandlerJsonResult(json);

    expect(identical(JavaScriptHandlerJsonResult.encode(result), json), isTrue);
    expect(result.toJson(), {'__proto__': 2});
  });

  test('large replies retain the original string without decoding', () {
    final json = '[${List.filled(1000000, '"עברית"').join(',')}]';
    final result = JavaScriptHandlerJsonResult(json);

    expect(identical(JavaScriptHandlerJsonResult.encode(result), json), isTrue);
  });

  test('jsonEncode embeds the value when nested or used directly', () {
    const result = JavaScriptHandlerJsonResult('{"a":[1,2]}');

    expect(jsonEncode(result), '{"a":[1,2]}');
    expect(jsonEncode({'data': result}), '{"data":{"a":[1,2]}}');
  });
}
