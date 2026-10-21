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
      manager.indexOf('RECT bounds;'),
    );
    expect(keepAlive, contains('webView->reparent(flutterViewHwnd)'));
    expect(keepAlive, isNot(contains('CreateWindowEx')));
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
}
