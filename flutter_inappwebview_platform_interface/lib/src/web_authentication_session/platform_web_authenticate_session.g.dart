// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_web_authenticate_session.dart';

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

extension _PlatformWebAuthenticationSessionCreationParamsClassSupported
    on PlatformWebAuthenticationSessionCreationParams {
  ///{@template flutter_inappwebview_platform_interface.PlatformWebAuthenticationSessionCreationParams.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 11.0+
  ///- macOS WKWebView 10.15+
  ///
  ///Use the [PlatformWebAuthenticationSessionCreationParams.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.iOS, TargetPlatform.macOS]
            .contains(platform ?? defaultTargetPlatform);
  }
}

extension _PlatformWebAuthenticationSessionClassSupported
    on PlatformWebAuthenticationSession {
  ///{@template flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 11.0+
  ///- macOS WKWebView 10.15+
  ///
  ///Use the [PlatformWebAuthenticationSession.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.iOS, TargetPlatform.macOS]
            .contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformWebAuthenticationSession]'s properties that can be used to check i they are supported or not by the current platform.
enum PlatformWebAuthenticationSessionProperty {
  ///Can be used to check if the [PlatformWebAuthenticationSession.callbackURLScheme] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.callbackURLScheme.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [PlatformWebAuthenticationSession.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  callbackURLScheme,

  ///Can be used to check if the [PlatformWebAuthenticationSession.id] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.id.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [PlatformWebAuthenticationSession.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  id,

  ///Can be used to check if the [PlatformWebAuthenticationSession.initialSettings] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.initialSettings.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [PlatformWebAuthenticationSession.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  initialSettings,

  ///Can be used to check if the [PlatformWebAuthenticationSession.onComplete] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.onComplete.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [url]: all platforms
  ///- [error]: all platforms
  ///
  ///Use the [PlatformWebAuthenticationSession.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  onComplete,

  ///Can be used to check if the [PlatformWebAuthenticationSession.url] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.url.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [PlatformWebAuthenticationSession.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  url,
}

extension _PlatformWebAuthenticationSessionPropertySupported
    on PlatformWebAuthenticationSession {
  static bool isPropertySupported(
      PlatformWebAuthenticationSessionProperty property,
      {TargetPlatform? platform}) {
    switch (property) {
      case PlatformWebAuthenticationSessionProperty.callbackURLScheme:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformWebAuthenticationSessionProperty.id:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformWebAuthenticationSessionProperty.initialSettings:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformWebAuthenticationSessionProperty.onComplete:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformWebAuthenticationSessionProperty.url:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
    }
  }
}

///List of [PlatformWebAuthenticationSession]'s methods that can be used to check if they are supported or not by the current platform.
enum PlatformWebAuthenticationSessionMethod {
  ///Can be used to check if the [PlatformWebAuthenticationSession.canStart] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.canStart.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - ASWebAuthenticationSession.canStart](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession/3516277-canstart))
  ///- macOS WKWebView ([Official API - ASWebAuthenticationSession.canStart](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession/3516277-canstart))
  ///
  ///Use the [PlatformWebAuthenticationSession.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  canStart,

  ///Can be used to check if the [PlatformWebAuthenticationSession.cancel] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.cancel.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - ASWebAuthenticationSession.cancel](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession/2990951-cancel))
  ///- macOS WKWebView ([Official API - ASWebAuthenticationSession.cancel](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession/2990951-cancel))
  ///
  ///Use the [PlatformWebAuthenticationSession.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  cancel,

  ///Can be used to check if the [PlatformWebAuthenticationSession.create] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.create.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [url]: all platforms
  ///- [callbackURLScheme]: all platforms
  ///- [onComplete]: all platforms
  ///- [initialSettings]: all platforms
  ///
  ///Use the [PlatformWebAuthenticationSession.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  create,

  ///Can be used to check if the [PlatformWebAuthenticationSession.dispose] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.dispose.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [PlatformWebAuthenticationSession.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  dispose,

  ///Can be used to check if the [PlatformWebAuthenticationSession.isAvailable] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.isAvailable.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [PlatformWebAuthenticationSession.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  isAvailable,

  ///Can be used to check if the [PlatformWebAuthenticationSession.start] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.start.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - ASWebAuthenticationSession.start](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession/2990953-start))
  ///- macOS WKWebView ([Official API - ASWebAuthenticationSession.start](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession/2990953-start))
  ///
  ///Use the [PlatformWebAuthenticationSession.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  start,
}

extension _PlatformWebAuthenticationSessionMethodSupported
    on PlatformWebAuthenticationSession {
  static bool isMethodSupported(PlatformWebAuthenticationSessionMethod method,
      {TargetPlatform? platform}) {
    switch (method) {
      case PlatformWebAuthenticationSessionMethod.canStart:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformWebAuthenticationSessionMethod.cancel:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformWebAuthenticationSessionMethod.create:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformWebAuthenticationSessionMethod.dispose:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformWebAuthenticationSessionMethod.isAvailable:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformWebAuthenticationSessionMethod.start:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
    }
  }
}
