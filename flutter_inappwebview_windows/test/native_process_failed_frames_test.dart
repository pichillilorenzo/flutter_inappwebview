import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final webView = File(
    'windows/in_app_webview/in_app_webview.cpp',
  ).readAsStringSync().replaceAll('\r\n', '\n');

  test('failed-process frames are read from the first one, each once', () {
    final start = webView.indexOf('get_FrameInfosForFailedProcess');
    final loop = webView.substring(
      start,
      webView.indexOf('}\n            }', start),
    );
    // The iterator starts on the first frame: test it, read it, then advance.
    expect(
      loop,
      contains(
        'while (SUCCEEDED(frameIterator->get_HasCurrent(&hasCurrent)) && hasCurrent)',
      ),
    );
    expect('MoveNext'.allMatches(loop).length, 1);
  });
}
