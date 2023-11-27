import 'dart:async';
import 'dart:ui';
import 'package:flutter/services.dart';

import 'headless_inappwebview_manager.dart';
import 'in_app_web_view_web_element.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

class HeadlessInAppWebViewWebElement extends ChannelController {
  String id;
  late BinaryMessenger _messenger;
  InAppWebViewWebElement? webView;

  HeadlessInAppWebViewWebElement(
      {required this.id,
      required BinaryMessenger messenger,
      required this.webView}) {
    this._messenger = messenger;

    channel = MethodChannel(
      'com.pichillilorenzo/flutter_headless_inappwebview_${this.id}',
      const StandardMethodCodec(),
      _messenger,
    );
    handler = _handleMethod;
    initMethodCallHandler();
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
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
    await channel?.invokeMethod("onWebViewCreated");
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
    disposeChannel();
    HeadlessInAppWebViewManager.webViews.putIfAbsent(id, () => null);
    webView?.dispose();
    webView = null;
  }
}
