import 'package:flutter/services.dart';

class WebMessageChannel {
  String id;
  WebMessagePort port1;
  WebMessagePort port2;

  late MethodChannel _channel;

  WebMessageChannel({required this.id, required this.port1, required this.port2}) {
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
        port2: WebMessagePort(index: 1)
    );
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

class WebMessagePort {
  late final int _index;

  Function(String? message)? _onMessage;
  late WebMessageChannel _webMessageChannel;

  WebMessagePort({required int index}) {
    this._index = index;
  }

  Future<void> setWebMessageCallback(Function(String? message)? onMessage) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('index', () => this._index);
    await _webMessageChannel._channel.invokeMethod('setWebMessageCallback', args);
    this._onMessage = onMessage;
  }

  Future<void> postMessage(WebMessage message) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('index', () => this._index);
    args.putIfAbsent('message', () => message.toMap());
    await _webMessageChannel._channel.invokeMethod('postMessage', args);
  }

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

class WebMessage {
  String? data;
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