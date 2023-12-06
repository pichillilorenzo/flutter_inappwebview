import 'dart:async';
import '../src/inappwebview_platform.dart';
import 'headless_inappwebview_manager.dart';
import 'web_platform_manager.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'in_app_web_view_web_element.dart';
import 'platform_util.dart';
import 'package:js/js.dart';

import 'shims/platform_view_registry.dart' show platformViewRegistry;

/// Builds an iframe based WebView.
///
/// This is used as the default implementation for `WebView` on web.
class InAppWebViewFlutterPlugin {
  /// Constructs a new instance of [InAppWebViewFlutterPlugin].
  InAppWebViewFlutterPlugin(Registrar registrar) {
    platformViewRegistry.registerViewFactory(
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
    _nativeCommunication = allowInterop(_dartNativeCommunication);
  }
}

/// Allows assigning a function to be callable from `window.flutter_inappwebview.nativeCommunication()`
@JS('flutter_inappwebview.nativeCommunication')
external set _nativeCommunication(
    Future<dynamic> Function(String method, dynamic viewId, [List? args]) f);

/// Allows calling the assigned function from Dart as well.
@JS()
external Future<dynamic> nativeCommunication(String method, dynamic viewId,
    [List? args]);

Future<dynamic> _dartNativeCommunication(String method, dynamic viewId,
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
        return await webViewHtmlElement.onCreateWindow(
            windowId, url, target, windowFeatures);
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
}
