import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _readNativeSource(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

void main() {
  final webView = _readNativeSource(
    'windows/in_app_webview/in_app_webview.cpp',
  );
  final contentWorlds = _readNativeSource(
    'windows/in_app_webview/user_content_controller.cpp',
  );
  final cookies = _readNativeSource('windows/cookie_manager.cpp');

  String prepare() => webView.substring(
    webView.indexOf('void InAppWebView::prepare('),
    webView.indexOf('void InAppWebView::registerEventHandlers()'),
  );

  test('Network is never enabled up front', () {
    // Network.enable keeps response bodies in the renderer (134 MB more after
    // ten 7 MB fetches in the fork measurements).
    expect(prepare(), isNot(contains('Network.enable')));
  });

  test('Network is enabled before any Network command', () {
    final certificate = webView.substring(
      webView.indexOf('void InAppWebView::getCertificate'),
    );
    expect(
      certificate,
      contains(
        'ensureNetworkDomain();\n    auto hr = webView->CallDevToolsProtocolMethod(L"Network.getCertificate"',
      ),
    );
    final passThrough = webView.substring(
      webView.indexOf('void InAppWebView::callDevToolsProtocolMethod'),
    );
    expect(
      passThrough,
      contains(
        'else if (methodName.rfind("Network.", 0) == 0) {\n      ensureNetworkDomain();',
      ),
    );
    final eventListener = webView.substring(
      webView.indexOf('void InAppWebView::addDevToolsProtocolEventListener'),
    );
    expect(
      eventListener,
      contains(
        'if (eventName.rfind("Network.", 0) == 0) {\n      ensureNetworkDomain();',
      ),
    );
  });

  test('cookie commands do not enable Network', () {
    // Measured: set, get and delete work on a WebView whose Network domain was
    // never enabled, as they always did on the temporary WebView.
    expect(cookies, isNot(contains('ensureNetworkDomain')));
  });

  test('Runtime follows its users', () {
    expect(
      prepare(),
      contains(
        'if (hasConsoleMessageListener_) {\n      ensureRuntimeDomain();',
      ),
    );
    final receiver = webView.substring(
      webView.indexOf('void InAppWebView::registerConsoleMessageReceiver'),
      webView.indexOf('void InAppWebView::callDevToolsDomainMethod'),
    );
    expect(receiver, contains('if (consoleReceiverRegistered_ || !webView) {'));
    expect(
      receiver,
      contains('if (!channelDelegate || !hasConsoleMessageListener_) {'),
    );
    // A widget attached to a kept-alive WebView brings its own listener.
    expect(
      receiver,
      contains(
        'hasConsoleMessageListener_ = hasListener;\n'
        '    if (hasListener) {\n'
        '      ensureRuntimeDomain();\n'
        '      registerConsoleMessageReceiver();',
      ),
    );
    expect(
      _readNativeSource('windows/in_app_webview/in_app_webview_manager.cpp'),
      contains(
        'webView->setHasConsoleMessageListener(hasConsoleMessageListener);',
      ),
    );
    expect(
      'webView_->ensureRuntimeDomain();'.allMatches(contentWorlds).length,
      2,
    );
  });

  test('Fetch the app enabled is never replaced or disabled', () {
    final fetch = webView.substring(
      webView.indexOf('void InAppWebView::setFetchDomainEnabled'),
    );
    expect(fetch, contains('if (appEnabledFetch_) {\n      return;'));
    expect(
      webView,
      contains(
        'else if (methodName == "Fetch.enable") {\n      appEnabledFetch_ = true;',
      ),
    );
  });

  test('Fetch follows useShouldOverrideUrlLoading', () {
    expect(
      prepare(),
      contains('setFetchDomainEnabled(settings->useShouldOverrideUrlLoading);'),
    );
    expect(
      webView,
      contains(
        'if (settings->useShouldOverrideUrlLoading != newSettings->useShouldOverrideUrlLoading) {\n      setFetchDomainEnabled(newSettings->useShouldOverrideUrlLoading);',
      ),
    );
  });
}
