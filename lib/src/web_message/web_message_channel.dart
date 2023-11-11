import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/src/util.dart';
import 'web_message_port.dart';

///The representation of the [HTML5 message channels](https://html.spec.whatwg.org/multipage/web-messaging.html#message-channels).
///
///**Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- MacOS
class WebMessageChannel extends ChannelController {
  ///Message Channel ID used internally.
  final String id;

  ///The first [WebMessagePort] object of the channel.
  final WebMessagePort port1;

  ///The second [WebMessagePort] object of the channel.
  final WebMessagePort port2;

  WebMessageChannel(
      {required this.id, required this.port1, required this.port2}) {
    channel = MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_web_message_channel_$id');
    handler = _handleMethod;
    initMethodCallHandler();
  }

  static WebMessageChannel? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    var webMessageChannel = WebMessageChannel(
        id: map["id"],
        port1: WebMessagePort(index: 0),
        port2: WebMessagePort(index: 1));
    webMessageChannel.port1.webMessageChannel = webMessageChannel;
    webMessageChannel.port2.webMessageChannel = webMessageChannel;
    return webMessageChannel;
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onMessage":
        int index = call.arguments["index"];
        var port = index == 0 ? this.port1 : this.port2;
        if (port.onMessage != null) {
          String? message = call.arguments["message"];
          port.onMessage!(message);
        }
        break;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
    return null;
  }

  ///Disposes the web message channel.
  @override
  void dispose() {
    disposeChannel();
  }

  @override
  String toString() {
    return 'WebMessageChannel{id: $id, port1: $port1, port2: $port2}';
  }
}

extension InternalWebMessageChannel on WebMessageChannel {
  MethodChannel? get internalChannel => channel;
}
