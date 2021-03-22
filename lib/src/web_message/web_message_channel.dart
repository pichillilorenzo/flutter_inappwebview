import 'package:flutter/services.dart';
import '../types.dart';
import '../in_app_webview/in_app_webview_controller.dart';

///The representation of the [HTML5 message channels](https://html.spec.whatwg.org/multipage/web-messaging.html#message-channels).
class WebMessageChannel {
  ///Message Channel ID used internally.
  final String id;

  ///The first [WebMessagePort] object of the channel.
  final WebMessagePort port1;

  ///The second [WebMessagePort] object of the channel.
  final WebMessagePort port2;

  late MethodChannel _channel;

  WebMessageChannel(
      {required this.id, required this.port1, required this.port2}) {
    this._channel = MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_web_message_channel_$id');
    this._channel.setMethodCallHandler(handleMethod);
  }

  static WebMessageChannel? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    var webMessageChannel = WebMessageChannel(
        id: map["id"],
        port1: WebMessagePort(index: 0),
        port2: WebMessagePort(index: 1));
    webMessageChannel.port1._webMessageChannel = webMessageChannel;
    webMessageChannel.port2._webMessageChannel = webMessageChannel;
    return webMessageChannel;
  }

  Future<dynamic> handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onMessage":
        int index = call.arguments["index"];
        var port = index == 0 ? this.port1 : this.port2;
        if (port._onMessage != null) {
          String? message = call.arguments["message"];
          port._onMessage!(message);
        }
        break;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
    return null;
  }
}

///The representation of the [HTML5 message ports](https://html.spec.whatwg.org/multipage/comms.html#messageport).
///
///A Message port represents one endpoint of a Message Channel. In Android webview, there is no separate Message Channel object.
///When a message channel is created, both ports are tangled to each other and started.
///See [InAppWebViewController.createWebMessageChannel] for creating a message channel.
///
///When a message port is first created or received via transfer, it does not have a [WebMessageCallback] to receive web messages.
///On Android, the messages are queued until a [WebMessageCallback] is set.
///
///A message port should be closed when it is not used by the embedder application anymore.
///A closed port cannot be transferred or cannot be reopened to send messages.
///Close can be called multiple times.
///
///When a port is transferred to JavaScript, it cannot be used to send or receive messages at the Dart side anymore.
///Different from HTML5 Spec, a port cannot be transferred if one of these has ever happened: i. a message callback was set, ii. a message was posted on it.
///A transferred port cannot be closed by the application, since the ownership is also transferred.
///
///It is possible to transfer both ports of a channel to JavaScript, for example for communication between subframes.
class WebMessagePort {
  late final int _index;

  WebMessageCallback? _onMessage;
  late WebMessageChannel _webMessageChannel;

  WebMessagePort({required int index}) {
    this._index = index;
  }

  ///Sets a callback to receive message events on the main thread.
  Future<void> setWebMessageCallback(WebMessageCallback? onMessage) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('index', () => this._index);
    await _webMessageChannel._channel
        .invokeMethod('setWebMessageCallback', args);
    this._onMessage = onMessage;
  }

  ///Post a WebMessage to the entangled port.
  Future<void> postMessage(WebMessage message) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('index', () => this._index);
    args.putIfAbsent('message', () => message.toMap());
    await _webMessageChannel._channel.invokeMethod('postMessage', args);
  }

  ///Close the message port and free any resources associated with it.
  Future<void> close() async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('index', () => this._index);
    await _webMessageChannel._channel.invokeMethod('close', args);
  }

  Map<String, dynamic> toMap() {
    return {
      "index": this._index,
      "webMessageChannelId": this._webMessageChannel.id
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///The Dart representation of the HTML5 PostMessage event.
///See https://html.spec.whatwg.org/multipage/comms.html#the-messageevent-interfaces for definition of a MessageEvent in HTML5.
class WebMessage {
  ///The data of the message.
  String? data;

  ///The ports that are sent with the message.
  List<WebMessagePort>? ports;

  WebMessage({this.data, this.ports});

  Map<String, dynamic> toMap() {
    return {
      "data": this.data,
      "ports": this.ports?.map((e) => e.toMap()).toList(),
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
