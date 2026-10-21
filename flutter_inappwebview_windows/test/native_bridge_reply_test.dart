import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _readNativeSource(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

void main() {
  final webView = _readNativeSource(
    'windows/in_app_webview/in_app_webview.cpp',
  );
  final bridge = _readNativeSource(
    'windows/plugin_scripts_js/javascript_bridge_js.h',
  );

  test('replies use web messages only while the page can receive them', () {
    final settle = webView.substring(
      webView.indexOf('void InAppWebView::settleJavaScriptHandler'),
      webView.indexOf('HRESULT InAppWebView::onCallJsHandler'),
    );
    // A suspended page gets web messages only after resume, a navigated page
    // must not receive the reply, and a queued script must run first.
    expect(
      settle,
      contains(
        'if (webView && visibilityState_.shouldBeVisible() &&\n'
        '      documentGeneration == mainDocumentGeneration_ && '
        '*pendingScripts_ == 0) {',
      ),
    );
    expect(
      webView,
      contains('isLoading_ = true;\n          ++mainDocumentGeneration_;'),
    );
    for (final fn in ['evaluateJavascript', 'callAsyncJavaScript']) {
      final start = webView.indexOf('void InAppWebView::$fn(');
      final body = webView.substring(
        start,
        webView.indexOf('void InAppWebView::', start + 1),
      );
      expect(
        body,
        contains('const auto pendingScript = trackPendingScript();'),
      );
      expect(body, contains('[this, completionHandler, pendingScript]'));
    }
    expect(settle, contains('PostWebMessageAsJson'));
    expect(settle, contains('JavaScriptBridgeMessage::settleScript('));
  });

  test('every handler reply goes through the settle helper', () {
    final onCall = webView
        .substring(webView.indexOf('HRESULT InAppWebView::onCallJsHandler'))
        .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');
    expect(onCall, isNot(contains('].resolve(')));
    expect(onCall, isNot(contains('].reject(')));
    expect(
      'settleJavaScriptHandler(callHandlerID, documentGeneration'
          .allMatches(onCall)
          .length,
      3,
    );
  });

  test('the bridge listens for replies in the top frame before the page', () {
    expect(
      bridge,
      contains(
        "if (isMainFrame) {\\\n            window.chrome.webview.addEventListener('message'",
      ),
    );
    expect(bridge, contains('e.stopImmediatePropagation();'));
    expect(bridge, contains('}, true);'));
    expect(
      bridge,
      contains("_postMessage('\" + JavaScriptBridgeMessage::CALL_PREFIX"),
    );
  });
}
