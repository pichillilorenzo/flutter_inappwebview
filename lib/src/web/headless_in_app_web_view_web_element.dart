import 'dart:async';
import 'dart:ui';
import 'package:flutter/services.dart';

import 'headless_inappwebview_manager.dart';
import 'in_app_web_view_web_element.dart';
import '../util.dart';
import '../types/disposable.dart';

class HeadlessInAppWebViewWebElement implements Disposable {
  String id;
  late BinaryMessenger _messenger;
  InAppWebViewWebElement? webView;
  late MethodChannel? _channel;

  HeadlessInAppWebViewWebElement(
      {required this.id,
      required BinaryMessenger messenger,
      required this.webView}) {
    this._messenger = messenger;

    _channel = MethodChannel(
      'com.pichillilorenzo/flutter_headless_inappwebview_${this.id}',
      const StandardMethodCodec(),
      _messenger,
    );

    this._channel?.setMethodCallHandler((call) async {
      try {
        return await handleMethodCall(call);
      } on Error catch (e) {
        print(e);
        print(e.stackTrace);
      }
    });
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case "dispose":
        dispose();
        break;
      case "setSize":
        Size size =
            MapSize.fromMap(call.arguments['size'].cast<String, dynamic>())!;
        setSize(size);
        break;
      case "getSize":
        return webView?.getSize().toMap();
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details:
              'flutter_inappwebview for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  void onWebViewCreated() async {
    await _channel?.invokeMethod("onWebViewCreated");
  }

  void setSize(Size size) {
    webView?.iframeContainer.style.width = size.width.toString() + "px";
    webView?.iframeContainer.style.height = size.height.toString() + "px";
  }

  InAppWebViewWebElement? disposeAndGetFlutterWebView() {
    InAppWebViewWebElement? newFlutterWebView = webView;
    dispose();
    return newFlutterWebView;
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    _channel = null;
    HeadlessInAppWebViewManager.webViews.putIfAbsent(id, () => null);
    webView?.dispose();
    webView = null;
  }
}
