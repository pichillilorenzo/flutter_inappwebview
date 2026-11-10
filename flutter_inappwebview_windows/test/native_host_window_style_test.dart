import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _readNativeSource(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

void main() {
  const requiredStyle =
      'const DWORD windowStyle = WS_CHILD | WS_CLIPSIBLINGS | WS_CLIPCHILDREN;';

  for (final sourcePath in [
    'windows/in_app_webview/in_app_webview_manager.cpp',
    'windows/headless_in_app_webview/headless_in_app_webview_manager.cpp',
    'windows/webview_environment/webview_environment_manager.cpp',
  ]) {
    test('$sourcePath creates a child host window', () {
      final source = _readNativeSource(sourcePath);

      expect(source, contains(requiredStyle));
      expect(
        source,
        contains(
          'CreateWindowEx(0, windowClass_.lpszClassName, L"", windowStyle, 0,',
        ),
      );
    });
  }
}
