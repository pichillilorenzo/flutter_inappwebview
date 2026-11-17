import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _readNativeSource(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

/// Multi-window: hosts live under the requesting Flutter view, and per-window
/// state (minimize, drop targets) must not leak into other windows.
void main() {
  final manager = _readNativeSource(
    'windows/in_app_webview/in_app_webview_manager.cpp',
  );

  test('the host window is parented under the requested view', () {
    expect(manager, contains('"flutterViewId"'));
    expect(
      manager,
      contains('ResolveFlutterViewHwnd(plugin->registrar, flutterViewId)'),
    );
    expect(manager, isNot(contains('registrar->GetView()')));
  });

  test('keep-alive reuse moves the existing host instead of a new one', () {
    final keepAlive = manager.substring(
      manager.indexOf('if (keepAliveId.has_value() && map_contains('),
      manager.indexOf('const auto hwnd = createHostWindow(flutterViewHwnd);'),
    );
    expect(keepAlive, contains('webView->reparent(flutterViewHwnd)'));
    expect(keepAlive, isNot(contains('CreateWindowEx')));
    expect(keepAlive, isNot(contains('createHostWindow(')));
    expect(
      keepAlive,
      contains(
        'webView->setHasConsoleMessageListener(hasConsoleMessageListener)',
      ),
    );
  });

  test('minimize only touches webviews of that top-level window', () {
    expect(manager, contains('webView->topLevelWindow() == topLevelHwnd'));
    expect(
      manager,
      contains('if (!firstEvent && state->second == minimized) return;'),
    );
    expect(
      manager,
      contains(
        'windowMinimizedStates_.erase(GetAncestor(flutterViewHwnd, GA_ROOT))',
      ),
    );
    final plugin = _readNativeSource(
      'windows/flutter_inappwebview_windows_plugin.cpp',
    );
    expect(plugin, contains('setWindowMinimized(hWnd, true)'));
    expect(plugin, contains('setWindowMinimized(hWnd, false)'));
  });

  test('hosts are parked when their view window is destroyed', () {
    expect(manager, contains('message == WM_DESTROY'));
    expect(manager, contains('webView->park(parkingWindow())'));
    expect(manager, contains('pendingWebViewHosts_.insert(hwnd)'));
    expect(manager, contains('pendingWebViewHosts_.erase(hwnd)'));
    expect(manager, contains('ParkPendingWebViewHosts(pendingWebViewHosts_'));
    expect(manager, contains('GetParent(hwnd) == parkingWindow_'));
    expect(manager, contains('for (const auto host : pendingWebViewHosts_)'));
    expect(manager, contains('RemoveWindowSubclass'));
  });

  test('the drop target follows the host parent, not the implicit view', () {
    final webView = _readNativeSource(
      'windows/in_app_webview/in_app_webview.cpp',
    );
    expect(
      webView,
      contains('WebViewDropTarget::RegisterWebView(flutterViewHwnd, this)'),
    );
    expect(webView, isNot(contains('registrar->GetView()')));
  });

  test(
    'both controller modes reparent without enabling the native external drop target',
    () {
      final source = _readNativeSource(
        'windows/in_app_webview/in_app_webview.cpp',
      );
      final reparent = source.substring(
        source.indexOf('void InAppWebView::reparent('),
        source.indexOf('bool InAppWebView::isSslError('),
      );
      expect(
        reparent,
        contains('!host || !flutterViewHwnd || !webViewController'),
      );
      expect(reparent, contains('!host || !parkingHwnd || !webViewController'));
      expect(
        reparent,
        contains(
          'if (webViewCompositionController) {\n        WebViewDropTarget::RegisterWebView(flutterViewHwnd, this);',
        ),
      );
      expect(reparent, contains('setHostWindowMinimized(true)'));
      expect(
        reparent,
        contains(
          'setHostWindowMinimized(IsIconic(GetAncestor(flutterViewHwnd, GA_ROOT)) != FALSE)',
        ),
      );
    },
  );

  test('capture fallback preserves a parked host parent and pending ownership', () {
    final start = manager.indexOf('if (FAILED(captureHr))');
    final end = manager.indexOf('finish(std::move(inAppWebView)', start);
    final fallback = manager.substring(start, end);
    expect(
      fallback,
      contains(
        'const auto parent = GetParent(hwnd);\n            pendingWebViewHosts_.erase(hwnd);\n            inAppWebView.reset();\n            createInWindow(createHostWindow(parent), captureStage, captureHr);',
      ),
    );
    expect(manager, contains('if (hwnd) pendingWebViewHosts_.insert(hwnd);'));
    final finish = manager.substring(
      manager.indexOf('const auto finish ='),
      manager.indexOf('const auto createInWindow ='),
    );
    expect(
      finish,
      contains(
        'GetParent(hostWindow) == parkingWindow_ || isTopLevelMinimized(hostWindow)',
      ),
    );
    expect(finish, contains('pendingWebViewHosts_.erase(hostWindow)'));
    expect(finish, contains('flutterViewResolver()'));
  });
}
