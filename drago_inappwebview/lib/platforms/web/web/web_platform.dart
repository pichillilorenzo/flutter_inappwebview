import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/foundation.dart';
import 'package:drago_inappwebview/platform_interface/platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import '../src/inappwebview_platform.dart';
import 'headless_inappwebview_manager.dart';
import 'in_app_web_view_web_element.dart';
import 'in_app_webview_manager.dart';
import 'js_bridge.dart';
import 'platform_util.dart';

/// Builds an iframe based WebView.
///
/// This is used as the default implementation for `WebView` on web.
class InAppWebViewFlutterPlugin {
  /// Constructs a new instance of [InAppWebViewFlutterPlugin].
  InAppWebViewFlutterPlugin(Registrar registrar) {
    ui_web.platformViewRegistry.registerViewFactory(
      'com.pichillilorenzo/drago_inappwebview',
      (int viewId) {
        var webView = InAppWebViewWebElement(
          viewId: viewId,
          messenger: registrar,
        );
        InAppWebViewManager.webViews.putIfAbsent(viewId, () => webView);
        return webView.iframeContainer;
      },
    );
  }

  static void registerWith(Registrar registrar) {
    WebPlatformInAppWebViewPlatform.registerWith();
    // ignore: unused_local_variable
    final pluginInstance = InAppWebViewFlutterPlugin(registrar);
    // ignore: unused_local_variable
    final platformUtil = PlatformUtil(messenger: registrar);
    // ignore: unused_local_variable
    final inAppWebViewManager = InAppWebViewManager(messenger: registrar);
    // ignore: unused_local_variable
    final headlessManager = HeadlessInAppWebViewManager(messenger: registrar);
    if (dragoInAppWebView != null) {
      if (!Object_isFrozen(dragoInAppWebView!).toDart) {
        dragoInAppWebView!.nativeAsyncCommunication =
            ((JSString method, JSAny viewId, [JSArray? args]) {
              return _dartNativeAsyncCommunication(
                method.toDart,
                viewId,
                args?.toDart,
              ).then((value) => value?.toJS).toJS;
            }).toJS;
        dragoInAppWebView!.nativeSyncCommunication =
            ((JSString method, JSAny viewId, [JSArray? args]) =>
                    _dartNativeSyncCommunication(
                      method.toDart,
                      viewId,
                      args?.toDart,
                    )?.toJS)
                .toJS;
        Object_freeze(dragoInAppWebView!);
      }
    } else {
      if (kDebugMode) {
        print("Error: window.drago_inappwebview_plugin is not available!");
      }
    }
  }
}

Future<String?> _dartNativeAsyncCommunication(
  String method,
  dynamic viewId, [
  List? args,
]) async {
  if (InAppWebViewManager.webViews.containsKey(viewId)) {
    var webViewHtmlElement =
        InAppWebViewManager.webViews[viewId] as InAppWebViewWebElement;
    var result;
    try {
      switch (method) {
        case 'onCreateWindow':
          String url = args![0] ?? 'about:blank';
          String? target = args[1];
          String? windowFeatures = args[2];
          result = await webViewHtmlElement.onCreateWindow(
            url,
            target,
            windowFeatures,
          );
          break;
        case 'onCallJsHandler':
          String handlerName = args![0];
          Map<String, dynamic> data = jsonDecode(args[1]);
          result = await webViewHtmlElement.onCallJsHandler(handlerName, data);
          break;
        default:
          throw UnimplementedError("Method '$method' not implemented");
      }
      return result != null ? jsonEncode(result) : null;
    } catch (e, stacktrace) {
      if (e is! UnimplementedError && kDebugMode) {
        print("$e\n$stacktrace");
      }
      rethrow;
    }
  }
  return null;
}

String? _dartNativeSyncCommunication(
  String method,
  dynamic viewId, [
  List? args,
]) {
  if (InAppWebViewManager.webViews.containsKey(viewId)) {
    var webViewHtmlElement =
        InAppWebViewManager.webViews[viewId] as InAppWebViewWebElement;
    Object? result;

    try {
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
        case 'onWebMessageListenerPostMessage':
          String jsObjectName = args![0];
          String message = args[1];
          String sourceOrigin = args[2];
          webViewHtmlElement.onWebMessageListenerPostMessage(
            jsObjectName,
            message,
            sourceOrigin,
          );
          break;
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
        case 'onCloseWindow':
          webViewHtmlElement.onCloseWindow();
          break;
        case 'getUserOnlyScriptsAt':
          final injectionTime = UserScriptInjectionTime.fromNativeValue(
            args![0],
          );
          result = webViewHtmlElement.userContentController
              .getUserOnlyScriptsAt(injectionTime!);
          break;
        case 'getJavaScriptBridgeName':
          result = InAppWebViewManager.javaScriptBridgeName;
          break;
        default:
          throw UnimplementedError("Method '$method' not implemented");
      }
    } catch (e, stacktrace) {
      if (e is! UnimplementedError && kDebugMode) {
        print("$e\n$stacktrace");
      }
      rethrow;
    }

    return jsonEncode(result);
  }
  return null;
}
