// Run with: flutter test benchmark/javascript_handler_json_result_benchmark.dart
// Timings are reported, not asserted, to avoid machine-dependent test failures.
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('large stored JSON: Dart work including channel encoding', () {
    final raw = jsonEncode([
      for (var i = 0; i < 500000; i++) {'id': i, 'text': 'שורה $i'},
    ]);
    final result = JavaScriptHandlerJsonResult(raw);
    const codec = StandardMethodCodec();

    // Warm both branches before measuring identical payloads.
    codec.encodeSuccessEnvelope(jsonEncode(jsonDecode('[1,2,3]')));
    codec.encodeSuccessEnvelope(JavaScriptHandlerJsonResult.encode(result));
    for (var i = 0; i < 3; i++) {
      final oldTimer = Stopwatch()..start();
      final old = codec.encodeSuccessEnvelope(jsonEncode(jsonDecode(raw)));
      oldTimer.stop();
      final rawTimer = Stopwatch()..start();
      final encoded = JavaScriptHandlerJsonResult.encode(result);
      final next = codec.encodeSuccessEnvelope(encoded);
      rawTimer.stop();

      expect(identical(encoded, raw), isTrue);
      expect(next.buffer.asUint8List(), old.buffer.asUint8List());
      // ignore: avoid_print
      print(
        '${raw.length} characters: decode/encode/channel '
        '${oldTimer.elapsedMicroseconds / 1000} ms; '
        'raw/channel ${rawTimer.elapsedMicroseconds / 1000} ms',
      );
    }
  });
}
