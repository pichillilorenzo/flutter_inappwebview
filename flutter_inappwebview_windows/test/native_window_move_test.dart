import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _readNativeSource(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

void main() {
  final plugin = _readNativeSource(
    'windows/flutter_inappwebview_windows_plugin.cpp',
  );
  final manager = _readNativeSource(
    'windows/in_app_webview/in_app_webview_manager.cpp',
  );
  final webView = _readNativeSource(
    'windows/in_app_webview/in_app_webview.cpp',
  );

  // A move without WM_MOVING (snap, restored bounds, a programmatic move)
  // otherwise leaves <select> popups at the old screen position.
  test('a top-level move is reported only to its own WebViews', () {
    expect(
      plugin,
      contains(
        'if (message == WM_MOVE && inAppWebViewManager) {\n'
        '      inAppWebViewManager->notifyWindowMoved(hWnd);',
      ),
    );
    final notify = manager.substring(
      manager.indexOf('void InAppWebViewManager::notifyWindowMoved'),
    );
    expect(notify, contains('webViews'));
    expect(notify, contains('keepAliveWebViews'));
    expect(
      'platformView->view->topLevelWindow() == topLevelHwnd'.allMatches(notify),
      hasLength(2),
    );
  });

  test('moving the widget inside the window is reported too', () {
    final setPosition = webView.substring(
      webView.indexOf('void InAppWebView::setPosition'),
      webView.indexOf('void InAppWebView::notifyParentWindowMoved'),
    );
    expect(
      setPosition,
      contains('if (moved) {\n      notifyParentWindowMoved();'),
    );
  });

  test('reparenting keeps position notification behind the browser gate', () {
    final reparent = webView.substring(
      webView.indexOf('void InAppWebView::reparent('),
      webView.indexOf('void InAppWebView::park('),
    );
    expect(reparent, contains('notifyParentWindowMoved();'));
    expect(reparent, isNot(contains('NotifyParentWindowPositionChanged()')));
  });

  test('a hidden or paused WebView keeps the move behind the browser gate', () {
    final apply = webView.substring(
      webView.indexOf('void InAppWebView::applyPendingBrowserState'),
      webView.indexOf('void InAppWebView::notifyVisibilityChanged'),
    );
    expect(apply, contains('browserGate().tryAcquire(browserPid, this)'));
    expect(
      apply,
      contains(
        'if (pendingParentMoved_ && visibilityState_.shouldBeVisible()) {\n'
        '        pendingParentMoved_ = false;\n'
        '        failedLog(webViewController->NotifyParentWindowPositionChanged());',
      ),
    );
  });
}
