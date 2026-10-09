import 'package:flutter/foundation.dart';
import 'package:drago_inappwebview/platform_interface/platform_interface.dart';

///{@macro drago_inappwebview.PlatformWebMessageListener}
///
///{@macro drago_inappwebview.PlatformWebMessageListener.supported_platforms}
class WebMessageListener {
  ///{@macro drago_inappwebview.PlatformWebMessageListener}
  WebMessageListener({
    required String jsObjectName,
    Set<String>? allowedOriginRules,
    OnPostMessageCallback? onPostMessage,
  }) : this.fromPlatformCreationParams(
         params: PlatformWebMessageListenerCreationParams(
           jsObjectName: jsObjectName,
           allowedOriginRules: allowedOriginRules,
           onPostMessage: onPostMessage,
         ),
       );

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

  /// Provide static access.
  static WebMessageListener static() {
    return WebMessageListener.fromPlatform(
      platform: PlatformWebMessageListener.static(),
    );
  }

  ///{@macro drago_inappwebview.PlatformWebMessageListenerCreationParams.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformWebMessageListener.static().isClassSupported(platform: platform);

  ///{@macro drago_inappwebview.PlatformWebMessageListener.isPropertySupported}
  static bool isPropertySupported(
    PlatformWebMessageListenerCreationParamsProperty property, {
    TargetPlatform? platform,
  }) => PlatformWebMessageListener.static().isPropertySupported(
    property,
    platform: platform,
  );

  ///{@macro drago_inappwebview.PlatformWebMessageListener.isMethodSupported}
  static bool isMethodSupported(
    PlatformWebMessageListenerMethod method, {
    TargetPlatform? platform,
  }) => PlatformWebMessageListener.static().isMethodSupported(
    method,
    platform: platform,
  );

  ///{@macro drago_inappwebview.PlatformWebMessageListener.jsObjectName}
  ///
  ///{@macro drago_inappwebview.PlatformWebMessageListener.jsObjectName.supported_platforms}
  String get jsObjectName => platform.jsObjectName;

  ///{@macro drago_inappwebview.PlatformWebMessageListener.allowedOriginRules}
  ///
  ///{@macro drago_inappwebview.PlatformWebMessageListener.allowedOriginRules.supported_platforms}
  Set<String>? get allowedOriginRules => platform.allowedOriginRules;

  ///{@macro drago_inappwebview.PlatformWebMessageListener.onPostMessage}
  ///
  ///{@macro drago_inappwebview.PlatformWebMessageListener.onPostMessage.supported_platforms}
  OnPostMessageCallback? get onPostMessage => platform.onPostMessage;

  ///{@macro drago_inappwebview.PlatformWebMessageListener.dispose}
  ///
  ///{@macro drago_inappwebview.PlatformWebMessageListener.dispose.supported_platforms}
  void dispose() => platform.dispose();

  Map<String, dynamic> toMap() => platform.toMap();

  Map<String, dynamic> toJson() => platform.toJson();

  @override
  String toString() => platform.toString();
}

///{@macro drago_inappwebview.PlatformJavaScriptReplyProxy}
///
///{@macro drago_inappwebview.PlatformJavaScriptReplyProxy.supported_platforms}
class JavaScriptReplyProxy {
  ///{@macro drago_inappwebview.PlatformJavaScriptReplyProxy}
  JavaScriptReplyProxy({required PlatformWebMessageListener webMessageListener})
    : this.fromPlatformCreationParams(
        params: PlatformJavaScriptReplyProxyCreationParams(
          webMessageListener: webMessageListener,
        ),
      );

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

  ///{@macro drago_inappwebview.PlatformJavaScriptReplyProxy.postMessage}
  ///
  ///{@macro drago_inappwebview.PlatformJavaScriptReplyProxy.postMessage.supported_platforms}
  Future<void> postMessage(WebMessage message) => platform.postMessage(message);

  @override
  String toString() {
    return 'JavaScriptReplyProxy{}';
  }
}
