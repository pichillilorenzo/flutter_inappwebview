import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _readNativeSource(String path) => File(path).readAsStringSync();

void main() {
  test('visible webview creation failure destroys its host window', () {
    final source = _readNativeSource(
      'windows/in_app_webview/in_app_webview_manager.cpp',
    );

    expect(
      source,
      contains(
        'DestroyWindow(hwnd);\n'
        '          result_->Error("0", "Cannot create the InAppWebView instance!");',
      ),
    );
  });

  test('headless webview creation failure destroys its host window', () {
    final source = _readNativeSource(
      'windows/headless_in_app_webview/headless_in_app_webview_manager.cpp',
    );

    expect(
      source,
      contains(
        'DestroyWindow(hwnd);\n'
        '          result_->Error("0", "Cannot create the HeadlessInAppWebView instance!");',
      ),
    );
  });

  test('invalid composition surface is returned as a creation error', () {
    final source = _readNativeSource(
      'windows/in_app_webview/in_app_webview_manager.cpp',
    );

    expect(
      source,
      contains('if (!inAppWebView->webView || !inAppWebView->surface())'),
    );
    expect(
      source,
      contains(
        'result_->Error("0", "Cannot create the InAppWebView surface!")',
      ),
    );
  });
}
