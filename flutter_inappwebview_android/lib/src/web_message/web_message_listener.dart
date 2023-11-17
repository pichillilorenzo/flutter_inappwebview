import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

/// Object specifying creation parameters for creating a [AndroidWebMessageListener].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformWebMessageListenerCreationParams] for
/// more information.
@immutable
class AndroidWebMessageListenerCreationParams
    extends PlatformWebMessageListenerCreationParams {
  /// Creates a new [AndroidWebMessageListenerCreationParams] instance.
  const AndroidWebMessageListenerCreationParams(
      {required this.allowedOriginRules,
      required super.jsObjectName,
      super.onPostMessage});

  /// Creates a [AndroidWebMessageListenerCreationParams] instance based on [PlatformWebMessageListenerCreationParams].
  factory AndroidWebMessageListenerCreationParams.fromPlatformWebMessageListenerCreationParams(
      // Recommended placeholder to prevent being broken by platform interface.
      // ignore: avoid_unused_constructor_parameters
      PlatformWebMessageListenerCreationParams params) {
    return AndroidWebMessageListenerCreationParams(
        allowedOriginRules: params.allowedOriginRules ?? Set.from(["*"]),
        jsObjectName: params.jsObjectName,
        onPostMessage: params.onPostMessage);
  }

  @override
  final Set<String> allowedOriginRules;

  @override
  String toString() {
    return 'AndroidWebMessageListenerCreationParams{jsObjectName: $jsObjectName, allowedOriginRules: $allowedOriginRules, onPostMessage: $onPostMessage}';
  }
}

///This listener receives messages sent on the JavaScript object which was injected by [InAppWebViewController.addWebMessageListener].
///
///**Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- MacOS
class AndroidWebMessageListener extends PlatformWebMessageListener
    with ChannelController {
  /// Constructs a [AndroidWebMessageListener].
  AndroidWebMessageListener(PlatformWebMessageListenerCreationParams params)
      : super.implementation(
          params is AndroidWebMessageListenerCreationParams
              ? params
              : AndroidWebMessageListenerCreationParams
                  .fromPlatformWebMessageListenerCreationParams(params),
        ) {
    assert(!this._androidParams.allowedOriginRules.contains(""),
        "allowedOriginRules cannot contain empty strings");
    channel = MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_web_message_listener_${_id}_${params.jsObjectName}');
    handler = _handleMethod;
    initMethodCallHandler();
  }

  ///Message Listener ID used internally.
  final String _id = IdGenerator.generate();

  AndroidJavaScriptReplyProxy? _replyProxy;

  AndroidWebMessageListenerCreationParams get _androidParams =>
      params as AndroidWebMessageListenerCreationParams;

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onPostMessage":
        if (_replyProxy == null) {
          _replyProxy = AndroidJavaScriptReplyProxy(
              PlatformJavaScriptReplyProxyCreationParams(
                  webMessageListener: this));
        }
        if (onPostMessage != null) {
          WebMessage? message = call.arguments["message"] != null
              ? WebMessage.fromMap(
                  call.arguments["message"].cast<String, dynamic>())
              : null;
          WebUri? sourceOrigin = call.arguments["sourceOrigin"] != null
              ? WebUri(call.arguments["sourceOrigin"])
              : null;
          bool isMainFrame = call.arguments["isMainFrame"];
          onPostMessage!(
              message, sourceOrigin, isMainFrame, _replyProxy!);
        }
        break;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
    return null;
  }

  @override
  void dispose() {
    disposeChannel();
  }

  Map<String, dynamic> toMap() {
    return {
      "id": _id,
      "jsObjectName": params.jsObjectName,
      "allowedOriginRules": _androidParams.allowedOriginRules.toList(),
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return 'AndroidWebMessageListener{id: ${_id}, jsObjectName: ${params.jsObjectName}, allowedOriginRules: ${params.allowedOriginRules}, replyProxy: $_replyProxy}';
  }
}

/// Object specifying creation parameters for creating a [AndroidJavaScriptReplyProxy].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformJavaScriptReplyProxyCreationParams] for
/// more information.
@immutable
class AndroidJavaScriptReplyProxyCreationParams
    extends PlatformJavaScriptReplyProxyCreationParams {
  /// Creates a new [AndroidJavaScriptReplyProxyCreationParams] instance.
  const AndroidJavaScriptReplyProxyCreationParams(
      {required super.webMessageListener});

  /// Creates a [AndroidJavaScriptReplyProxyCreationParams] instance based on [PlatformJavaScriptReplyProxyCreationParams].
  factory AndroidJavaScriptReplyProxyCreationParams.fromPlatformJavaScriptReplyProxyCreationParams(
      // Recommended placeholder to prevent being broken by platform interface.
      // ignore: avoid_unused_constructor_parameters
      PlatformJavaScriptReplyProxyCreationParams params) {
    return AndroidJavaScriptReplyProxyCreationParams(
        webMessageListener: params.webMessageListener);
  }
}

///This class represents the JavaScript object injected by [InAppWebViewController.addWebMessageListener].
///An instance will be given by [AndroidWebMessageListener.onPostMessage].
///The app can use `postMessage(String)` to talk to the JavaScript context.
///
///There is a 1:1 relationship between this object and the JavaScript object in a frame.
class AndroidJavaScriptReplyProxy extends PlatformJavaScriptReplyProxy {
  /// Constructs a [AndroidWebMessageListener].
  AndroidJavaScriptReplyProxy(PlatformJavaScriptReplyProxyCreationParams params)
      : super.implementation(
          params is AndroidJavaScriptReplyProxyCreationParams
              ? params
              : AndroidJavaScriptReplyProxyCreationParams
                  .fromPlatformJavaScriptReplyProxyCreationParams(params),
        );

  AndroidWebMessageListener get _androidWebMessageListener =>
      params.webMessageListener as AndroidWebMessageListener;

  ///Post a [message] to the injected JavaScript object which sent this [AndroidJavaScriptReplyProxy].
  ///
  ///If [message] is of type [WebMessageType.ARRAY_BUFFER], be aware that large byte buffers can lead to out-of-memory crashes on low-end devices.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/JavaScriptReplyProxy#postMessage(java.lang.String)
  Future<void> postMessage(WebMessage message) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('message', () => message.toMap());
    await _androidWebMessageListener.channel?.invokeMethod('postMessage', args);
  }

  @override
  String toString() {
    return 'AndroidJavaScriptReplyProxy{}';
  }
}
