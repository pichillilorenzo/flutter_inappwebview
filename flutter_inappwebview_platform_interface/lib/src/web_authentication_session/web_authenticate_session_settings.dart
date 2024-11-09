import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'platform_web_authenticate_session.dart';
import '../types/enum_method.dart';

part 'web_authenticate_session_settings.g.dart';

///Class that represents the settings that can be used for a [PlatformWebAuthenticationSession].
@ExchangeableObject(copyMethod: true)
class WebAuthenticationSessionSettings_ {
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

  WebAuthenticationSessionSettings_(
      {this.prefersEphemeralWebBrowserSession = false});

  Map<String, dynamic> toMap() {
    return {
      "prefersEphemeralWebBrowserSession": prefersEphemeralWebBrowserSession
    };
  }
}
