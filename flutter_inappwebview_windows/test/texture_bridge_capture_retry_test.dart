import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _readNativeSource(String path) => File(path).readAsStringSync();

String _functionBody(String source, String signature, String nextSignature) {
  final start = source.indexOf(signature);
  final end = source.indexOf(nextSignature, start);
  expect(start, greaterThanOrEqualTo(0), reason: 'Could not find $signature');
  expect(end, greaterThan(start), reason: 'Could not find $nextSignature');
  return source.substring(start, end);
}

void main() {
  test(
    'a failed visible resume preserves capture intent and the last frame',
    () {
      final source = _readNativeSource(
        'windows/custom_platform_view/texture_bridge.cc',
      );
      final body = _functionBody(
        source,
        'void TextureBridge::SetCaptureSuspended(bool suspended)',
        'bool TextureBridge::StartCapture()',
      );
      final resumeBranch = body.substring(
        body.indexOf('else if (!StartCapture())'),
      );

      expect(resumeBranch, isNot(contains('StopInternal()')));
      expect(resumeBranch, isNot(contains('last_frame_ = nullptr')));
    },
  );

  test('an explicit stop still ends capture and clears the running state', () {
    final source = _readNativeSource(
      'windows/custom_platform_view/texture_bridge.cc',
    );
    final body = _functionBody(
      source,
      'void TextureBridge::Stop()',
      'void TextureBridge::StopInternal()',
    );

    expect(body, contains('StopInternal()'));
    expect(source, contains('is_running_ = false;'));
  });

  test('capture activation factories use scoped COM ownership', () {
    final source = _readNativeSource(
      'windows/custom_platform_view/graphics_context.cc',
    );

    expect(
      RegExp(r'\*\s*capture_(item|frame_pool)_statics\s*;').hasMatch(source),
      isFalse,
    );
    expect(source, contains('capture_item_statics.put_void()'));
    expect(source, contains('capture_frame_pool_statics.put_void()'));
    expect('.put_void()'.allMatches(source).length, greaterThanOrEqualTo(4));
  });
}
