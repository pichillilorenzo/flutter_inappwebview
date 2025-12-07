// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_web_message_listener.dart';

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

extension _PlatformWebMessageListenerCreationParamsClassSupported
    on PlatformWebMessageListenerCreationParams {
  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageListenerCreationParams.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [PlatformWebMessageListenerCreationParams.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
            .contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformWebMessageListenerCreationParams]'s properties that can be used to check i they are supported or not by the current platform.
enum PlatformWebMessageListenerCreationParamsProperty {
  ///Can be used to check if the [PlatformWebMessageListenerCreationParams.allowedOriginRules] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageListenerCreationParams.allowedOriginRules.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [PlatformWebMessageListenerCreationParams.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  allowedOriginRules,

  ///Can be used to check if the [PlatformWebMessageListenerCreationParams.jsObjectName] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageListenerCreationParams.jsObjectName.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [PlatformWebMessageListenerCreationParams.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  jsObjectName,

  ///Can be used to check if the [PlatformWebMessageListenerCreationParams.onPostMessage] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageListenerCreationParams.onPostMessage.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebViewCompat.WebMessageListener.onPostMessage](https://developer.android.com/reference/androidx/webkit/WebViewCompat.WebMessageListener#onPostMessage(android.webkit.WebView,%20androidx.webkit.WebMessageCompat,%20android.net.Uri,%20boolean,%20androidx.webkit.JavaScriptReplyProxy)))
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [message]: all platforms
  ///- [sourceOrigin]: all platforms
  ///- [isMainFrame]: all platforms
  ///- [replyProxy]: all platforms
  ///
  ///Use the [PlatformWebMessageListenerCreationParams.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  onPostMessage,
}

extension _PlatformWebMessageListenerCreationParamsPropertySupported
    on PlatformWebMessageListenerCreationParams {
  static bool isPropertySupported(
      PlatformWebMessageListenerCreationParamsProperty property,
      {TargetPlatform? platform}) {
    switch (property) {
      case PlatformWebMessageListenerCreationParamsProperty.allowedOriginRules:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformWebMessageListenerCreationParamsProperty.jsObjectName:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformWebMessageListenerCreationParamsProperty.onPostMessage:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
    }
  }
}

extension _PlatformWebMessageListenerClassSupported
    on PlatformWebMessageListener {
  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageListener.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [PlatformWebMessageListener.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
            .contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformWebMessageListener]'s methods that can be used to check if they are supported or not by the current platform.
enum PlatformWebMessageListenerMethod {
  ///Can be used to check if the [PlatformWebMessageListener.dispose] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageListener.dispose.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [PlatformWebMessageListener.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  dispose,
}

extension _PlatformWebMessageListenerMethodSupported
    on PlatformWebMessageListener {
  static bool isMethodSupported(PlatformWebMessageListenerMethod method,
      {TargetPlatform? platform}) {
    switch (method) {
      case PlatformWebMessageListenerMethod.dispose:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
    }
  }
}
