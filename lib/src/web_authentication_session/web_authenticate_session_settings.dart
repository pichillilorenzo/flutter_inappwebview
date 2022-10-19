import 'package:flutter/foundation.dart';
import 'web_authenticate_session.dart';

///Class that represents the settings that can be used for a [WebAuthenticationSession].
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
  ///Set this property before you call [WebAuthenticationSession.start]. Otherwise it has no effect.
  ///
  ///**NOTE for iOS**: Available only on iOS 13.0+.
  ///
  ///**NOTE for MacOS**: Available only on iOS 10.15+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  bool prefersEphemeralWebBrowserSession;

  WebAuthenticationSessionSettings(
      {this.prefersEphemeralWebBrowserSession = false});

  Map<String, dynamic> toMap() {
    return {
      "prefersEphemeralWebBrowserSession": prefersEphemeralWebBrowserSession
    };
  }

  static WebAuthenticationSessionSettings fromMap(Map<String, dynamic> map) {
    WebAuthenticationSessionSettings settings =
        new WebAuthenticationSessionSettings();
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      settings.prefersEphemeralWebBrowserSession =
          map["prefersEphemeralWebBrowserSession"];
    }
    return settings;
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }

  WebAuthenticationSessionSettings copy() {
    return WebAuthenticationSessionSettings.fromMap(this.toMap());
  }
}
