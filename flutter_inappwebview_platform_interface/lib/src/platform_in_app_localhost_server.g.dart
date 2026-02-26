// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_in_app_localhost_server.dart';

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

extension _PlatformInAppLocalhostServerCreationParamsClassSupported
    on PlatformInAppLocalhostServerCreationParams {
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppLocalhostServerCreationParams.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformInAppLocalhostServerCreationParams.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
          TargetPlatform.windows,
          TargetPlatform.linux,
        ].contains(platform ?? defaultTargetPlatform);
  }
}

extension _PlatformInAppLocalhostServerClassSupported
    on PlatformInAppLocalhostServer {
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformInAppLocalhostServer.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
          TargetPlatform.windows,
          TargetPlatform.linux,
        ].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformInAppLocalhostServer]'s methods that can be used to check if they are supported or not by the current platform.
enum PlatformInAppLocalhostServerMethod {
  ///Can be used to check if the [PlatformInAppLocalhostServer.close] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.close.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformInAppLocalhostServer.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  close,

  ///Can be used to check if the [PlatformInAppLocalhostServer.isRunning] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.isRunning.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformInAppLocalhostServer.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  isRunning,

  ///Can be used to check if the [PlatformInAppLocalhostServer.start] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.start.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformInAppLocalhostServer.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  start,
}

extension _PlatformInAppLocalhostServerMethodSupported
    on PlatformInAppLocalhostServer {
  static bool isMethodSupported(
    PlatformInAppLocalhostServerMethod method, {
    TargetPlatform? platform,
  }) {
    switch (method) {
      case PlatformInAppLocalhostServerMethod.close:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppLocalhostServerMethod.isRunning:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppLocalhostServerMethod.start:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
    }
  }
}
