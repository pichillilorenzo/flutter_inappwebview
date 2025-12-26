// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_authenticate_session_settings.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the settings that can be used for a [PlatformWebAuthenticationSession].
///
///**Officially Supported Platforms/Implementations**:
///- iOS WKWebView 13.0+
///- macOS WKWebView 10.15+
class WebAuthenticationSessionSettings {
  ///A Boolean value that indicates whether the session should ask the browser for a private authentication session.
  ///
  ///Set [prefersEphemeralWebBrowserSession] to `true` to request that the browser
  ///doesn’t share cookies or other browsing data between the authentication session and the user’s normal browser session.
  ///Whether the request is honored depends on the user’s default web browser.
  ///Safari always honors the request.
  ///
  ///The value of this property is `false` by default.
  ///
  ///Set this property before you call [PlatformWebAuthenticationSession.start]. Otherwise it has no effect.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 13.0+
  ///- macOS WKWebView 10.15+
  bool? prefersEphemeralWebBrowserSession;

  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 13.0+
  ///- macOS WKWebView 10.15+
  WebAuthenticationSessionSettings(
      {this.prefersEphemeralWebBrowserSession = false});

  ///Gets a possible [WebAuthenticationSessionSettings] instance from a [Map] value.
  static WebAuthenticationSessionSettings? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = WebAuthenticationSessionSettings();
    instance.prefersEphemeralWebBrowserSession =
        map['prefersEphemeralWebBrowserSession'];
    return instance;
  }

  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isPropertySupported(
          WebAuthenticationSessionSettingsProperty property,
          {TargetPlatform? platform}) =>
      _WebAuthenticationSessionSettingsPropertySupported.isPropertySupported(
          property,
          platform: platform);

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "prefersEphemeralWebBrowserSession": prefersEphemeralWebBrowserSession,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  ///Returns a copy of WebAuthenticationSessionSettings.
  WebAuthenticationSessionSettings copy() {
    return WebAuthenticationSessionSettings.fromMap(toMap()) ??
        WebAuthenticationSessionSettings();
  }

  @override
  String toString() {
    return 'WebAuthenticationSessionSettings{prefersEphemeralWebBrowserSession: $prefersEphemeralWebBrowserSession}';
  }
}

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

///List of [WebAuthenticationSessionSettings]'s properties that can be used to check i they are supported or not by the current platform.
enum WebAuthenticationSessionSettingsProperty {
  ///Can be used to check if the [WebAuthenticationSessionSettings.prefersEphemeralWebBrowserSession] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.WebAuthenticationSessionSettings.prefersEphemeralWebBrowserSession.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 13.0+
  ///- macOS WKWebView 10.15+
  ///
  ///Use the [WebAuthenticationSessionSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  prefersEphemeralWebBrowserSession,
}

extension _WebAuthenticationSessionSettingsPropertySupported
    on WebAuthenticationSessionSettings {
  static bool isPropertySupported(
      WebAuthenticationSessionSettingsProperty property,
      {TargetPlatform? platform}) {
    switch (property) {
      case WebAuthenticationSessionSettingsProperty
            .prefersEphemeralWebBrowserSession:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
    }
  }
}
