import 'dart:async';
import 'dart:js_interop';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import 'js_bridge.dart';

class PlatformUtil extends ChannelController {
  late BinaryMessenger _messenger;

  PlatformUtil({required BinaryMessenger messenger}) {
    this._messenger = messenger;

    channel = MethodChannel(
      'com.pichillilorenzo/flutter_inappwebview_platformutil',
      const StandardMethodCodec(),
      _messenger,
    );
    handler = _handleMethod;
    initMethodCallHandler();
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
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
    return flutterInAppWebView!.getCookieExpirationDate(timestamp).toDart;
  }

  @override
  void dispose() {
    disposeChannel();
  }
}
