// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_headless_in_app_webview.dart';

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

extension _PlatformHeadlessInAppWebViewCreationParamsClassSupported
    on PlatformHeadlessInAppWebViewCreationParams {
  ///{@template flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebViewCreationParams.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\>
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformHeadlessInAppWebViewCreationParams.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return kIsWeb && platform == null
        ? true
        : ((kIsWeb && platform != null) || !kIsWeb) &&
              [
                TargetPlatform.android,
                TargetPlatform.iOS,
                TargetPlatform.macOS,
                TargetPlatform.windows,
                TargetPlatform.linux,
              ].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformHeadlessInAppWebViewCreationParams]'s properties that can be used to check i they are supported or not by the current platform.
enum PlatformHeadlessInAppWebViewCreationParamsProperty {
  ///Can be used to check if the [PlatformHeadlessInAppWebViewCreationParams.initialSize] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebViewCreationParams.initialSize.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView:
  ///    - `Size` width and height values will be converted to `int` values because they cannot have `double` values.
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\>
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformHeadlessInAppWebViewCreationParams.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  initialSize,

  ///Can be used to check if the [PlatformHeadlessInAppWebViewCreationParams.webViewEnvironment] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebViewCreationParams.webViewEnvironment.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  ///- Linux WPE WebKit ([Official API - WebKitWebContext](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/class.WebContext.html))
  ///
  ///Use the [PlatformHeadlessInAppWebViewCreationParams.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  webViewEnvironment,
}

extension _PlatformHeadlessInAppWebViewCreationParamsPropertySupported
    on PlatformHeadlessInAppWebViewCreationParams {
  static bool isPropertySupported(
    PlatformHeadlessInAppWebViewCreationParamsProperty property, {
    TargetPlatform? platform,
  }) {
    switch (property) {
      case PlatformHeadlessInAppWebViewCreationParamsProperty.initialSize:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformHeadlessInAppWebViewCreationParamsProperty
          .webViewEnvironment:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
    }
  }
}

extension _PlatformHeadlessInAppWebViewClassSupported
    on PlatformHeadlessInAppWebView {
  ///{@template flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\>
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformHeadlessInAppWebView.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return kIsWeb && platform == null
        ? true
        : ((kIsWeb && platform != null) || !kIsWeb) &&
              [
                TargetPlatform.android,
                TargetPlatform.iOS,
                TargetPlatform.macOS,
                TargetPlatform.windows,
                TargetPlatform.linux,
              ].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformHeadlessInAppWebView]'s methods that can be used to check if they are supported or not by the current platform.
enum PlatformHeadlessInAppWebViewMethod {
  ///Can be used to check if the [PlatformHeadlessInAppWebView.dispose] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView.dispose.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\>
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformHeadlessInAppWebView.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  dispose,

  ///Can be used to check if the [PlatformHeadlessInAppWebView.getSize] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView.getSize.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\>
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformHeadlessInAppWebView.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getSize,

  ///Can be used to check if the [PlatformHeadlessInAppWebView.isRunning] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView.isRunning.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\>
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformHeadlessInAppWebView.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  isRunning,

  ///Can be used to check if the [PlatformHeadlessInAppWebView.run] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView.run.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\>:
  ///    - It will append a new `iframe` to the body.
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformHeadlessInAppWebView.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  run,

  ///Can be used to check if the [PlatformHeadlessInAppWebView.setSize] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformHeadlessInAppWebView.setSize.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView:
  ///    - `Size` width and height values will be converted to `int` values because they cannot have `double` values.
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\>
  ///- Linux WPE WebKit
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [size]: all platforms
  ///
  ///Use the [PlatformHeadlessInAppWebView.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setSize,
}

extension _PlatformHeadlessInAppWebViewMethodSupported
    on PlatformHeadlessInAppWebView {
  static bool isMethodSupported(
    PlatformHeadlessInAppWebViewMethod method, {
    TargetPlatform? platform,
  }) {
    switch (method) {
      case PlatformHeadlessInAppWebViewMethod.dispose:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformHeadlessInAppWebViewMethod.getSize:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformHeadlessInAppWebViewMethod.isRunning:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformHeadlessInAppWebViewMethod.run:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformHeadlessInAppWebViewMethod.setSize:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
    }
  }
}
