// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_inappwebview_widget.dart';

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

extension _PlatformInAppWebViewWidgetCreationParamsClassSupported
    on PlatformInAppWebViewWidgetCreationParams {
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewWidgetCreationParams.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\>
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [PlatformInAppWebViewWidgetCreationParams.isClassSupported] method to check if this class is supported at runtime.
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

///List of [PlatformInAppWebViewWidgetCreationParams]'s properties that can be used to check i they are supported or not by the current platform.
enum PlatformInAppWebViewWidgetCreationParamsProperty {
  ///Can be used to check if the [PlatformInAppWebViewWidgetCreationParams.headlessWebView] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewWidgetCreationParams.headlessWebView.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Web \<iframe\>
  ///- Windows WebView2
  ///
  ///Use the [PlatformInAppWebViewWidgetCreationParams.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  headlessWebView,

  ///Can be used to check if the [PlatformInAppWebViewWidgetCreationParams.keepAlive] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewWidgetCreationParams.keepAlive.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  ///
  ///Use the [PlatformInAppWebViewWidgetCreationParams.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  keepAlive,

  ///Can be used to check if the [PlatformInAppWebViewWidgetCreationParams.preventGestureDelay] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewWidgetCreationParams.preventGestureDelay.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [PlatformInAppWebViewWidgetCreationParams.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  preventGestureDelay,

  ///Can be used to check if the [PlatformInAppWebViewWidgetCreationParams.webViewEnvironment] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformInAppWebViewWidgetCreationParams.webViewEnvironment.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  ///- Linux WPE WebKit ([Official API - WebKitWebContext](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/class.WebContext.html))
  ///
  ///Use the [PlatformInAppWebViewWidgetCreationParams.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  webViewEnvironment,
}

extension _PlatformInAppWebViewWidgetCreationParamsPropertySupported
    on PlatformInAppWebViewWidgetCreationParams {
  static bool isPropertySupported(
    PlatformInAppWebViewWidgetCreationParamsProperty property, {
    TargetPlatform? platform,
  }) {
    switch (property) {
      case PlatformInAppWebViewWidgetCreationParamsProperty.headlessWebView:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewWidgetCreationParamsProperty.keepAlive:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewWidgetCreationParamsProperty.preventGestureDelay:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case PlatformInAppWebViewWidgetCreationParamsProperty.webViewEnvironment:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
    }
  }
}
