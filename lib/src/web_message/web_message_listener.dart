import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import '../in_app_webview/in_app_webview_controller.dart';

///This listener receives messages sent on the JavaScript object which was injected by [InAppWebViewController.addWebMessageListener].
///
///**Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- MacOS
class WebMessageListener {
  WebMessageListener(
      {required String jsObjectName,
      Set<String>? allowedOriginRules,
      OnPostMessageCallback? onPostMessage})
      : this.fromPlatformCreationParams(
            params: PlatformWebMessageListenerCreationParams(
                jsObjectName: jsObjectName,
                allowedOriginRules: allowedOriginRules,
                onPostMessage: onPostMessage));

  /// Constructs a [WebMessageListener].
  ///
  /// See [WebMessageListener.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  WebMessageListener.fromPlatformCreationParams({
    required PlatformWebMessageListenerCreationParams params,
  }) : this.fromPlatform(platform: PlatformWebMessageListener(params));

  /// Constructs a [WebMessageListener] from a specific platform implementation.
  WebMessageListener.fromPlatform({required this.platform});

  /// Implementation of [PlatformWebMessageListener] for the current platform.
  final PlatformWebMessageListener platform;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageListener.jsObjectName}
  String get jsObjectName => platform.jsObjectName;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageListener.allowedOriginRules}
  Set<String>? get allowedOriginRules => platform.allowedOriginRules;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageListener.onPostMessage}
  OnPostMessageCallback? get onPostMessage => platform.onPostMessage;

  void dispose() => platform.dispose();

  Map<String, dynamic> toMap() => platform.toMap();

  Map<String, dynamic> toJson() => platform.toJson();

  @override
  String toString() => platform.toString();
}

///This class represents the JavaScript object injected by [InAppWebViewController.addWebMessageListener].
///An instance will be given by [WebMessageListener.onPostMessage].
///The app can use `postMessage(String)` to talk to the JavaScript context.
///
///There is a 1:1 relationship between this object and the JavaScript object in a frame.
class JavaScriptReplyProxy {
  JavaScriptReplyProxy({required PlatformWebMessageListener webMessageListener})
      : this.fromPlatformCreationParams(
            params: PlatformJavaScriptReplyProxyCreationParams(
                webMessageListener: webMessageListener));

  /// Constructs a [JavaScriptReplyProxy].
  ///
  /// See [JavaScriptReplyProxy.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  JavaScriptReplyProxy.fromPlatformCreationParams({
    required PlatformJavaScriptReplyProxyCreationParams params,
  }) : this.fromPlatform(platform: PlatformJavaScriptReplyProxy(params));

  /// Constructs a [JavaScriptReplyProxy] from a specific platform implementation.
  JavaScriptReplyProxy.fromPlatform({required this.platform});

  /// Implementation of [PlatformJavaScriptReplyProxy] for the current platform.
  final PlatformJavaScriptReplyProxy platform;

  ///Post a [message] to the injected JavaScript object which sent this [JavaScriptReplyProxy].
  ///
  ///If [message] is of type [WebMessageType.ARRAY_BUFFER], be aware that large byte buffers can lead to out-of-memory crashes on low-end devices.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/JavaScriptReplyProxy#postMessage(java.lang.String)
  Future<void> postMessage(WebMessage message) => platform.postMessage(message);

  @override
  String toString() {
    return 'JavaScriptReplyProxy{}';
  }
}
