// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_authenticate_session_settings.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the settings that can be used for a [PlatformWebAuthenticationSession].
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
  ///**NOTE for iOS**: Available only on iOS 13.0+.
  ///
  ///**NOTE for MacOS**: Available only on iOS 10.15+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  bool? prefersEphemeralWebBrowserSession;
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

  Map<String, dynamic> toMap() {
    return {
      "prefersEphemeralWebBrowserSession": prefersEphemeralWebBrowserSession
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
