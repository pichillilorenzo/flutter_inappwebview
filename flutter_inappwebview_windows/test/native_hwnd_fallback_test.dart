import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _readNativeSource(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

void main() {
  final manager = _readNativeSource(
    'windows/in_app_webview/in_app_webview_manager.cpp',
  );
  final webView = _readNativeSource(
    'windows/in_app_webview/in_app_webview.cpp',
  );

  test('every composition failure point falls back to the HWND controller', () {
    // CreateCoreWebView2CompositionController, sync or in its callback.
    expect(
      manager,
      contains(
        'failureStage->find("CompositionController") != std::string::npos) {\n'
        '          createInWindow(hwnd, *failureStage, errorCode);',
      ),
    );
    // No Windows.Graphics.Capture, or no graphics context at all.
    expect(
      manager,
      contains(
        'compositionUnavailableStage_ = "isGraphicsCaptureSessionSupported"',
      ),
    );
    expect(
      manager,
      contains(
        'createInWindow(hwnd, compositionUnavailableStage_, '
        'HRESULT_FROM_WIN32(ERROR_NOT_SUPPORTED));',
      ),
    );
    // createSurface, and a capture session that cannot be opened.
    expect(manager, contains('const char* captureStage = "createSurface";'));
    expect(manager, contains('TextureBridge::ProbeCapture('));
    expect(
      manager,
      contains(
        'createInWindow(createHostWindow(parent), captureStage, captureHr);',
      ),
    );
  });

  test('the HWND attempt uses the regular windowed controller', () {
    expect(
      manager,
      contains(
        'InAppWebView::createInAppWebViewEnv(hostWindow, false, environment(), '
        'initialSettings,',
      ),
    );
    expect(manager, contains('inAppWebView->setHostWindow(hostWindow);'));
  });

  test('the HWND mode can be forced only through the environment', () {
    expect(manager, contains('L"FLUTTER_INAPPWEBVIEW_WINDOWS_FORCE_HWND"'));
    expect(manager, contains('createInWindow(hwnd, "forced", S_OK);'));
  });

  test(
    'a composition failure after a failed HWND attempt is still reported',
    () {
      expect(manager, contains('"HWND fallback after "'));
    },
  );

  test('the host window is shown only when placed, sized and not hidden', () {
    expect(
      webView,
      contains(
        'const bool show = visibilityState_.shouldBeVisible() && '
        '!hostWindowHidden_ &&',
      ),
    );
    expect(webView, contains('hostWindowPlaced_ && surfaceSize_.cx > 0'));
    expect(
      webView,
      contains('ShowWindow(hostWindow_, show ? SW_SHOWNOACTIVATE : SW_HIDE);'),
    );
    // Pause, resume and minimize all end in notifyVisibilityChanged.
    expect(
      webView,
      contains(
        'void InAppWebView::notifyVisibilityChanged(const bool wasVisible)\n'
        '  {\n'
        '    syncHostWindowVisibility();',
      ),
    );
  });

  test('the host window follows the surface size and is destroyed with it', () {
    expect(
      webView,
      contains('::SetWindowPos(hostWindow_, nullptr, 0, 0, size.cx, size.cy,'),
    );
    expect(
      webView,
      contains('if (hostWindow_) {\n      DestroyWindow(hostWindow_);'),
    );
  });

  test('composition input paths tolerate a missing composition controller', () {
    final dropTarget = _readNativeSource(
      'windows/custom_platform_view/webview_drop_target.cc',
    );
    expect(
      'webView && webView->webViewCompositionController'
          .allMatches(dropTarget)
          .length,
      2,
    );
    for (final method in [
      'setCursorPos',
      'setPointerButtonState',
      'sendScroll',
      'setScrollDelta',
    ]) {
      final body = webView.substring(
        webView.indexOf('void InAppWebView::$method('),
      );
      expect(
        body.substring(0, body.indexOf('}')),
        contains('if (!webViewCompositionController) {'),
        reason: method,
      );
    }
  });

  test('HWND mode registers no texture bridge', () {
    final view = _readNativeSource(
      'windows/custom_platform_view/custom_platform_view.cc',
    );
    expect(view, contains('if (view->isHostedInWindow()) {'));
    expect(
      view,
      contains('if (texture_bridge_) {\n          texture_bridge_->Start();'),
    );
  });
}
