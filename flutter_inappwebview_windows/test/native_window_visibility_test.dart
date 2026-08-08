import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _readNativeSource(String path) => File(path).readAsStringSync();

void main() {
  test('async creation inherits the current minimized state', () {
    final source = _readNativeSource(
      'windows/in_app_webview/in_app_webview_manager.cpp',
    );

    expect(
      source,
      contains('std::move(webViewCompositionController), windowMinimized_)'),
    );
  });

  test('minimize state is applied to regular and keep-alive views', () {
    final source = _readNativeSource(
      'windows/in_app_webview/in_app_webview_manager.cpp',
    );

    expect(source, contains('for (const auto& [id, platformView] : webViews)'));
    expect(
      source,
      contains(
        'for (const auto& [keepAliveId, platformView] : keepAliveWebViews)',
      ),
    );
    expect(source, contains('webView->setHostWindowMinimized(minimized)'));
  });

  test('pause and host minimize use one effective visibility policy', () {
    final source = _readNativeSource(
      'windows/in_app_webview/in_app_webview.cpp',
    );

    expect(source, contains('visibilityState_.setPaused(true)'));
    expect(source, contains('visibilityState_.setPaused(false)'));
    expect(
      source,
      contains('visibilityState_.setHostWindowMinimized(minimized)'),
    );
    expect(
      source,
      contains('visibilityState_.shouldBeVisible() ? TRUE : FALSE'),
    );
  });

  test('top-level WM_SIZE routing covers minimize and both restore states', () {
    final pluginSource = _readNativeSource(
      'windows/flutter_inappwebview_windows_plugin.cpp',
    );
    final browserSource = _readNativeSource(
      'windows/in_app_browser/in_app_browser.cpp',
    );

    expect(pluginSource, contains('wParam == SIZE_MINIMIZED'));
    expect(pluginSource, contains('SIZE_RESTORED'));
    expect(pluginSource, contains('SIZE_MAXIMIZED'));
    expect(pluginSource, contains('setWindowMinimized'));

    expect(browserSource, contains('wparam == SIZE_MINIMIZED'));
    expect(browserSource, contains('SIZE_RESTORED'));
    expect(browserSource, contains('SIZE_MAXIMIZED'));
    expect(browserSource, contains('setHostWindowMinimized'));
    expect(browserSource, contains('hostWindowMinimized_ = true'));
    expect(browserSource, contains('hostWindowMinimized_ = false'));
    expect(browserSource, contains('hostWindowMinimized_);'));
  });
}
