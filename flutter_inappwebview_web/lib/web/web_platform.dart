import 'dart:async';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import '../src/inappwebview_platform.dart';
import 'headless_inappwebview_manager.dart';
import 'js_bridge.dart';
import 'web_platform_manager.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'in_app_web_view_web_element.dart';
import 'platform_util.dart';

/// Builds an iframe based WebView.
///
/// This is used as the default implementation for `WebView` on web.
class InAppWebViewFlutterPlugin {
  /// Constructs a new instance of [InAppWebViewFlutterPlugin].
  InAppWebViewFlutterPlugin(Registrar registrar) {
    ui_web.platformViewRegistry.registerViewFactory(
        'com.pichillilorenzo/flutter_inappwebview', (int viewId) {
      var webView =
          InAppWebViewWebElement(viewId: viewId, messenger: registrar);
      WebPlatformManager.webViews.putIfAbsent(viewId, () => webView);
      return webView.iframeContainer;
    });
  }

  static void registerWith(Registrar registrar) {
    WebPlatformInAppWebViewPlatform.registerWith();
    // ignore: unused_local_variable
    final pluginInstance = InAppWebViewFlutterPlugin(registrar);
    // ignore: unused_local_variable
    final platformUtil = PlatformUtil(messenger: registrar);
    // ignore: unused_local_variable
    final headlessManager = HeadlessInAppWebViewManager(messenger: registrar);
    flutterInAppWebView?.nativeCommunication = (
      (String method, JSAny viewId, [JSArray? args]) => _dartNativeCommunication(method, viewId, args?.toDart).toJS
    ).toJS;
  }
}

Future<JSAny?> _dartNativeCommunication(String method, dynamic viewId,
    [List? args]) async {
  if (WebPlatformManager.webViews.containsKey(viewId)) {
    var webViewHtmlElement =
        WebPlatformManager.webViews[viewId] as InAppWebViewWebElement;
    switch (method) {
      case 'onLoadStart':
        String url = args![0];
        webViewHtmlElement.onLoadStart(url);
        break;
      case 'onLoadStop':
        String url = args![0];
        webViewHtmlElement.onLoadStop(url);
        break;
      case 'onUpdateVisitedHistory':
        String url = args![0];
        webViewHtmlElement.onUpdateVisitedHistory(url);
        break;
      case 'onScrollChanged':
        int x = (args![0] as double).toInt();
        int y = (args[1] as double).toInt();
        webViewHtmlElement.onScrollChanged(x, y);
        break;
      case 'onConsoleMessage':
        String type = args![0];
        String? message = args[1];
        webViewHtmlElement.onConsoleMessage(type, message);
        break;
      case 'onCreateWindow':
        int windowId = args![0];
        String url = args[1] ?? 'about:blank';
        String? target = args[2];
        String? windowFeatures = args[3];
        return (await webViewHtmlElement.onCreateWindow(
            windowId, url, target, windowFeatures))?.toJS;
      case 'onWindowFocus':
        webViewHtmlElement.onWindowFocus();
        break;
      case 'onWindowBlur':
        webViewHtmlElement.onWindowBlur();
        break;
      case 'onPrintRequest':
        String? url = args![0];
        webViewHtmlElement.onPrintRequest(url);
        break;
      case 'onEnterFullscreen':
        webViewHtmlElement.onEnterFullscreen();
        break;
      case 'onExitFullscreen':
        webViewHtmlElement.onExitFullscreen();
        break;
      case 'onTitleChanged':
        String? title = args![0];
        webViewHtmlElement.onTitleChanged(title);
        break;
      case 'onZoomScaleChanged':
        double oldScale = args![0];
        double newScale = args[1];
        webViewHtmlElement.onZoomScaleChanged(oldScale, newScale);
        break;
      case 'onInjectedScriptLoaded':
        String id = args![0];
        webViewHtmlElement.onInjectedScriptLoaded(id);
        break;
      case 'onInjectedScriptError':
        String id = args![0];
        webViewHtmlElement.onInjectedScriptError(id);
        break;
    }
  }
  return null;
}
