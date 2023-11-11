import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../types/web_message_callback.dart';
import 'web_message.dart';
import 'web_message_channel.dart';

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

  @ExchangeableObjectConstructor()
  WebMessagePort({required int index}) {
    this._index = index;
  }

  ///Sets a callback to receive message events on the main thread.
  Future<void> setWebMessageCallback(WebMessageCallback? onMessage) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('index', () => this._index);
    await _webMessageChannel.internalChannel
        ?.invokeMethod('setWebMessageCallback', args);
    this._onMessage = onMessage;
  }

  ///Post a WebMessage to the entangled port.
  Future<void> postMessage(WebMessage message) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('index', () => this._index);
    args.putIfAbsent('message', () => message.toMap());
    await _webMessageChannel.internalChannel?.invokeMethod('postMessage', args);
  }

  ///Close the message port and free any resources associated with it.
  Future<void> close() async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('index', () => this._index);
    await _webMessageChannel.internalChannel?.invokeMethod('close', args);
  }

  @ExchangeableObjectMethod(toMapMergeWith: true)
  // ignore: unused_element
  Map<String, dynamic> _toMapMergeWith() {
    return {"index": _index, "webMessageChannelId": _webMessageChannel.id};
  }

  Map<String, dynamic> toMap() {
    return {
      "index": this._index,
      "webMessageChannelId": this._webMessageChannel.id
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'WebMessagePort{index: $_index}';
  }
}

extension InternalWebMessagePort on WebMessagePort {
  WebMessageCallback? get onMessage => _onMessage;
  void set onMessage(WebMessageCallback? value) => _onMessage = value;

  WebMessageChannel get webMessageChannel => _webMessageChannel;
  void set webMessageChannel(WebMessageChannel value) =>
      _webMessageChannel = value;
}
