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
external set _nativeCommunication(void Function(String method, int viewId, [List? args]) f);

/// Allows calling the assigned function from Dart as well.
@JS()
external void nativeCommunication();

void _dartNativeCommunication(String method, int viewId, [List? args]) {
  if (WebPlatformManager.webViews.containsKey(viewId)) {
    var webViewHtmlElement = WebPlatformManager.webViews[viewId] as InAppWebViewWebElement;
    switch (method) {
      case 'iframeLoaded':
        String url = args![0] as String;
        webViewHtmlElement.onIFrameLoaded(url);
        break;
    }
  }
}