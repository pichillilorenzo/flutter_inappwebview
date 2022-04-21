import 'dart:async';
import 'package:flutter/services.dart';
import 'web_platform_manager.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'shims/dart_ui.dart' as ui;

import 'in_app_web_view_web_element.dart';

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