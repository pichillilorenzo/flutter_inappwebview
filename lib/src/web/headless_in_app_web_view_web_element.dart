import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'in_app_web_view_web_element.dart';
import '../util.dart';

class HeadlessInAppWebViewWebElement {
  String id;
  late BinaryMessenger _messenger;
  InAppWebViewWebElement? webView;
  late MethodChannel? _channel;

  HeadlessInAppWebViewWebElement({required this.id, required BinaryMessenger messenger,
    required this.webView}) {
    this._messenger = messenger;
    
    _channel = MethodChannel(
      'com.pichillilorenzo/flutter_headless_inappwebview_${this.id}',
      const StandardMethodCodec(),
      _messenger,
    );

    this._channel?.setMethodCallHandler(handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case "dispose":
        dispose();
        break;
      case "setSize":
        Size size = MapSize.fromMap(call.arguments['size'])!;
        setSize(size);
        break;
      case "getSize":
        return getSize().toMap();
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'flutter_inappwebview for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  void onWebViewCreated() async {
    await _channel?.invokeMethod("onWebViewCreated");
  }

  void setSize(Size size) {
    webView?.iframe.style.width = size.width.toString() + "px";
    webView?.iframe.style.height = size.height.toString() + "px";
  }

  Size getSize() {
    var width = webView?.iframe.getBoundingClientRect().width.toDouble() ?? 0.0;
    var height = webView?.iframe.getBoundingClientRect().height.toDouble() ?? 0.0;
    return Size(width, height);
  }

  void dispose() {
    _channel?.setMethodCallHandler(null);
    _channel = null;
    webView?.dispose();
    webView = null;
  }
}