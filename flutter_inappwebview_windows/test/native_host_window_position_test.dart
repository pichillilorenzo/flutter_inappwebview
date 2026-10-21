import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The WebView host HWNDs are WS_CHILD of the Flutter window (see
/// native_host_window_style_test.dart), so SetWindowPos takes parent-client
/// coordinates. Positioning them with screen coordinates leaves every owned
/// popup - <select> dropdowns, the print preview pickers, context menus -
/// offset by the window origin.
void main() {
  final source =
      File('windows/in_app_webview/in_app_webview.cpp')
          .readAsStringSync()
          .replaceAll('\r\n', '\n');
  final setPosition = source.substring(
    source.indexOf('void InAppWebView::setPosition('),
    source.indexOf('void InAppWebView::setCursorPos('),
  );

  test('setPosition uses parent-client coordinates', () {
    expect(setPosition, contains('SetWindowPos'));
    expect(setPosition, contains('scaled_x,'));
    expect(setPosition, contains('scaled_y,'));
  });

  test('setPosition does not reintroduce screen-coordinate math', () {
    for (final banned in const [
      'GetWindowRect',
      'GetSystemMetrics',
      'SM_CYCAPTION',
      'SM_CXPADDEDBORDER',
      'ClientToScreen',
    ]) {
      expect(
        setPosition,
        isNot(contains(banned)),
        reason: '$banned belongs to screen-space positioning, which is wrong '
            'for a WS_CHILD host window',
      );
    }
  });
}
