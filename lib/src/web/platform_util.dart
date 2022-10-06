import 'dart:async';
import 'package:flutter/services.dart';

import 'dart:js' as js;

import 'web_platform_manager.dart';
import '../types/disposable.dart';

class PlatformUtil implements Disposable {
  late BinaryMessenger _messenger;
  late MethodChannel? _channel;

  PlatformUtil({required BinaryMessenger messenger}) {
    this._messenger = messenger;

    _channel = MethodChannel(
      'com.pichillilorenzo/flutter_inappwebview_platformutil',
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
      case "getWebCookieExpirationDate":
        int timestamp = call.arguments['date'];
        return getWebCookieExpirationDate(timestamp);
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details:
              'flutter_inappwebview for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  String getWebCookieExpirationDate(int timestamp) {
    var bridgeJsObject = js.JsObject.fromBrowserObject(
        js.context[WebPlatformManager.BRIDGE_JS_OBJECT_NAME]);
    return bridgeJsObject.callMethod("getCookieExpirationDate", [timestamp]);
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    _channel = null;
  }
}
