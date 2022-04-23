import 'dart:async';
import 'package:flutter/services.dart';
import 'web_platform_manager.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'shims/dart_ui.dart' as ui;

import 'in_app_web_view_web_element.dart';

import 'package:js/js.dart';

/// Builds an iframe based WebView.
///
/// This is used as the default implementation for [WebView] on web.
class FlutterInAppWebViewWebPlatform {

  /// Constructs a new instance of [FlutterInAppWebViewWebPlatform].
  FlutterInAppWebViewWebPlatform(Registrar registrar) {
    ui.platformViewRegistry.registerViewFactory(
        'com.pichillilorenzo/flutter_inappwebview',
            (int viewId) {
          var webView = InAppWebViewWebElement(viewId: viewId, messenger: registrar);
          WebPlatformManager.webViews.putIfAbsent(viewId, () => webView);
          return webView.iframe;
        });
  }

  static void registerWith(Registrar registrar) {
    final pluginInstance = FlutterInAppWebViewWebPlatform(registrar);
    _nativeCommunication = allowInterop(_dartNativeCommunication);
  }

  /// Handles method calls over the MethodChannel of this plugin.
  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'flutter_inappwebview for web doesn\'t implement \'${call.method}\'',
        );
    }
  }
}

/// Allows assigning a function to be callable from `window.flutter_inappwebview.nativeCommunication()`
@JS('flutter_inappwebview.nativeCommunication')
external set _nativeCommunication(Future<dynamic> Function(String method, int viewId, [List? args]) f);

/// Allows calling the assigned function from Dart as well.
@JS()
external Future<dynamic> nativeCommunication(String method, int viewId, [List? args]);

Future<dynamic> _dartNativeCommunication(String method, int viewId, [List? args]) async {
  if (WebPlatformManager.webViews.containsKey(viewId)) {
    var webViewHtmlElement = WebPlatformManager.webViews[viewId] as InAppWebViewWebElement;
    switch (method) {
      case 'onLoadStart':
        var url = args![0] as String;
        webViewHtmlElement.onLoadStart(url);
        break;
      case 'onLoadStop':
        var url = args![0] as String;
        webViewHtmlElement.onLoadStop(url);
        break;
      case 'onUpdateVisitedHistory':
        var url = args![0] as String;
        webViewHtmlElement.onUpdateVisitedHistory(url);
        break;
      case 'onScrollChanged':
        var x = (args![0] as double).toInt();
        var y = (args[1] as double).toInt();
        webViewHtmlElement.onScrollChanged(x, y);
        break;
      case 'onConsoleMessage':
        var type = args![0] as String;
        var message = args[1] as String?;
        webViewHtmlElement.onConsoleMessage(type, message);
        break;
      case 'onCreateWindow':
        var windowId = args![0] as int;
        var url = args[1] as String? ?? 'about:blank';
        var target = args[2] as String?;
        var windowFeatures = args[3] as String?;
        return await webViewHtmlElement.onCreateWindow(windowId, url, target, windowFeatures);
      case 'onWindowFocus':
        webViewHtmlElement.onWindowFocus();
        break;
      case 'onWindowBlur':
        webViewHtmlElement.onWindowBlur();
        break;
      case 'onPrint':
        var  url = args![0] as String?;
        webViewHtmlElement.onPrint(url);
        break;
      case 'onEnterFullscreen':
        webViewHtmlElement.onEnterFullscreen();
        break;
      case 'onExitFullscreen':
        webViewHtmlElement.onExitFullscreen();
        break;
      case 'onTitleChanged':
        var title = args![0] as String?;
        webViewHtmlElement.onTitleChanged(title);
        break;
      case 'onZoomScaleChanged':
        var oldScale = args![0] as double;
        var newScale = args[1] as double;
        webViewHtmlElement.onZoomScaleChanged(oldScale, newScale);
        break;
    }
  }
}