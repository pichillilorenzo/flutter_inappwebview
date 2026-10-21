import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _readJavaSource(String relativePath) => File(
  'android/src/main/java/com/pichillilorenzo/'
  'flutter_inappwebview_android/$relativePath',
).readAsStringSync().replaceAll('\r\n', '\n');

void main() {
  test('native background color survives transparent mode toggles', () {
    final webView = _readJavaSource('webview/in_app_webview/InAppWebView.java');
    final delegate = _readJavaSource('webview/WebViewChannelDelegate.java');

    expect(
      delegate,
      contains('webView.setCustomBackgroundColor(Color.parseColor(color))'),
    );
    expect(webView, contains('customBackgroundColor = color;'));
    expect(
      webView,
      contains(
        'setBackgroundColor(customBackgroundColor != null '
        '? customBackgroundColor : Color.WHITE);',
      ),
    );
  });
}
