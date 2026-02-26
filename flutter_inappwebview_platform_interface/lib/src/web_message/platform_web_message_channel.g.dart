// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_web_message_channel.dart';

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

extension _PlatformWebMessageChannelCreationParamsClassSupported
    on PlatformWebMessageChannelCreationParams {
  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageChannelCreationParams.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Linux WPE WebKit:
  ///    - Implemented via JavaScript MessageChannel API.
  ///- Windows WebView2:
  ///    - Implemented via JavaScript MessageChannel API.
  ///
  ///Use the [PlatformWebMessageChannelCreationParams.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
          TargetPlatform.linux,
          TargetPlatform.windows,
        ].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformWebMessageChannelCreationParams]'s properties that can be used to check i they are supported or not by the current platform.
enum PlatformWebMessageChannelCreationParamsProperty {
  ///Can be used to check if the [PlatformWebMessageChannelCreationParams.id] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageChannelCreationParams.id.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Linux WPE WebKit:
  ///    - Implemented via JavaScript MessageChannel API.
  ///- Windows WebView2:
  ///    - Implemented via JavaScript MessageChannel API.
  ///
  ///Use the [PlatformWebMessageChannelCreationParams.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  id,

  ///Can be used to check if the [PlatformWebMessageChannelCreationParams.port1] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageChannelCreationParams.port1.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Linux WPE WebKit:
  ///    - Implemented via JavaScript MessageChannel API.
  ///- Windows WebView2:
  ///    - Implemented via JavaScript MessageChannel API.
  ///
  ///Use the [PlatformWebMessageChannelCreationParams.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  port1,

  ///Can be used to check if the [PlatformWebMessageChannelCreationParams.port2] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageChannelCreationParams.port2.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Linux WPE WebKit:
  ///    - Implemented via JavaScript MessageChannel API.
  ///- Windows WebView2:
  ///    - Implemented via JavaScript MessageChannel API.
  ///
  ///Use the [PlatformWebMessageChannelCreationParams.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  port2,
}

extension _PlatformWebMessageChannelCreationParamsPropertySupported
    on PlatformWebMessageChannelCreationParams {
  static bool isPropertySupported(
    PlatformWebMessageChannelCreationParamsProperty property, {
    TargetPlatform? platform,
  }) {
    switch (property) {
      case PlatformWebMessageChannelCreationParamsProperty.id:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformWebMessageChannelCreationParamsProperty.port1:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformWebMessageChannelCreationParamsProperty.port2:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
    }
  }
}

extension _PlatformWebMessageChannelClassSupported
    on PlatformWebMessageChannel {
  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageChannel.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Linux WPE WebKit:
  ///    - Implemented via JavaScript MessageChannel API.
  ///- Windows WebView2:
  ///    - Implemented via JavaScript MessageChannel API.
  ///
  ///Use the [PlatformWebMessageChannel.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
          TargetPlatform.linux,
          TargetPlatform.windows,
        ].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformWebMessageChannel]'s methods that can be used to check if they are supported or not by the current platform.
enum PlatformWebMessageChannelMethod {
  ///Can be used to check if the [PlatformWebMessageChannel.dispose] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageChannel.dispose.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Linux WPE WebKit:
  ///    - Implemented via JavaScript MessageChannel API.
  ///- Windows WebView2:
  ///    - Implemented via JavaScript MessageChannel API.
  ///
  ///Use the [PlatformWebMessageChannel.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  dispose,
}

extension _PlatformWebMessageChannelMethodSupported
    on PlatformWebMessageChannel {
  static bool isMethodSupported(
    PlatformWebMessageChannelMethod method, {
    TargetPlatform? platform,
  }) {
    switch (method) {
      case PlatformWebMessageChannelMethod.dispose:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
    }
  }
}
