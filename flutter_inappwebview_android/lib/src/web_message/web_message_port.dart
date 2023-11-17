import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import 'web_message_channel.dart';

/// Object specifying creation parameters for creating a [AndroidWebMessagePort].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformWebMessagePortCreationParams] for
/// more information.
@immutable
class AndroidWebMessagePortCreationParams
    extends PlatformWebMessagePortCreationParams {
  /// Creates a new [AndroidWebMessagePortCreationParams] instance.
  const AndroidWebMessagePortCreationParams(
      {required super.index});

  /// Creates a [AndroidWebMessagePortCreationParams] instance based on [PlatformWebMessagePortCreationParams].
  factory AndroidWebMessagePortCreationParams.fromPlatformWebMessagePortCreationParams(
      // Recommended placeholder to prevent being broken by platform interface.
      // ignore: avoid_unused_constructor_parameters
      PlatformWebMessagePortCreationParams params) {
    return AndroidWebMessagePortCreationParams(
        index: params.index);
  }

  @override
  String toString() {
    return 'AndroidWebMessagePortCreationParams{index: $index}';
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
class AndroidWebMessagePort extends PlatformWebMessagePort {

  WebMessageCallback? _onMessage;
  late AndroidWebMessageChannel _webMessageChannel;

  /// Constructs a [AndroidWebMessagePort].
  AndroidWebMessagePort(
      PlatformWebMessagePortCreationParams params)
      : super.implementation(
    params is AndroidWebMessagePortCreationParams
        ? params
        : AndroidWebMessagePortCreationParams
        .fromPlatformWebMessagePortCreationParams(params),
  );

  ///Sets a callback to receive message events on the main thread.
  Future<void> setWebMessageCallback(WebMessageCallback? onMessage) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('index', () => params.index);
    await _webMessageChannel.internalChannel
        ?.invokeMethod('setWebMessageCallback', args);
    this._onMessage = onMessage;
  }

  ///Post a WebMessage to the entangled port.
  Future<void> postMessage(WebMessage message) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('index', () => params.index);
    args.putIfAbsent('message', () => message.toMap());
    await _webMessageChannel.internalChannel?.invokeMethod('postMessage', args);
  }

  ///Close the message port and free any resources associated with it.
  Future<void> close() async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('index', () => params.index);
    await _webMessageChannel.internalChannel?.invokeMethod('close', args);
  }

  Map<String, dynamic> toMap() {
    return {
      "index": params.index,
      "webMessageChannelId": this._webMessageChannel.params.id
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'AndroidWebMessagePort{index: ${params.index}}';
  }
}

extension InternalWebMessagePort on AndroidWebMessagePort {
  WebMessageCallback? get onMessage => _onMessage;
  void set onMessage(WebMessageCallback? value) => _onMessage = value;

  AndroidWebMessageChannel get webMessageChannel => _webMessageChannel;
  void set webMessageChannel(AndroidWebMessageChannel value) =>
      _webMessageChannel = value;
}
