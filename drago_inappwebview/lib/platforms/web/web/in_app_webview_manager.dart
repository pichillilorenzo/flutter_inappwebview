import 'dart:async';
import 'package:flutter/services.dart';
import 'package:drago_inappwebview/platform_interface/platform_interface.dart';
import 'package:web/web.dart';

class InAppWebViewManager extends ChannelController {
  static final Map<dynamic, dynamic> webViews = {};
  static final Map<int, CreateWindowAction?> windowActions = {};
  static int windowAutoincrementId = 0;
  static String javaScriptBridgeName = "drago_inappwebview";
  late BinaryMessenger _messenger;

  InAppWebViewManager({required BinaryMessenger messenger}) {
    _messenger = messenger;
    channel = MethodChannel(
      'com.pichillilorenzo/drago_inappwebview_manager',
      const StandardMethodCodec(),
      _messenger,
    );
    handler = _handleMethod;
    initMethodCallHandler();
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "getDefaultUserAgent":
        return getDefaultUserAgent();
      case "setJavaScriptBridgeName":
        javaScriptBridgeName = call.arguments["bridgeName"];
        break;
      case "getJavaScriptBridgeName":
        return javaScriptBridgeName;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
    return null;
  }

  String getDefaultUserAgent() {
    return window.navigator.userAgent;
  }

  @override
  void dispose() {
    disposeChannel();
  }
}
