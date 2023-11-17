import 'dart:async';

import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

///A session that an app uses to authenticate a user through a web service.
///
///It is implemented using [ASWebAuthenticationSession](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession) on iOS 12.0+ and MacOS 10.15+
///and [SFAuthenticationSession](https://developer.apple.com/documentation/safariservices/sfauthenticationsession) on iOS 11.0.
///
///Use an [WebAuthenticationSession] instance to authenticate a user through a web service, including one run by a third party.
///Initialize the session with a URL that points to the authentication webpage.
///A browser loads and displays the page, from which the user can authenticate.
///In iOS, the browser is a secure, embedded web view.
///In macOS, the system opens the user’s default browser if it supports web authentication sessions, or Safari otherwise.
///
///On completion, the service sends a callback URL to the session with an authentication token, and the session passes this URL back to the app through a completion handler.
///[WebAuthenticationSession] ensures that only the calling app’s session receives the authentication callback, even when more than one app registers the same callback URL scheme.
///
///**NOTE**: Remember to dispose it when you don't need it anymore.
///
///**NOTE for iOS**: Available only on iOS 11.0+.
///
///**NOTE for MacOS**: Available only on MacOS 10.15+.
///
///**Supported Platforms/Implementations**:
///- iOS
///- MacOS
class WebAuthenticationSession {
  ///Debug settings.
  static DebugLoggingSettings debugLoggingSettings = DebugLoggingSettings();

  WebAuthenticationSession(
      {required WebUri url,
      String? callbackURLScheme,
      WebAuthenticationSessionSettings? initialSettings,
      WebAuthenticationSessionCompletionHandler onComplete})
      : this.fromPlatformCreationParams(
            params: PlatformWebAuthenticationSessionCreationParams(
                url: url,
                callbackURLScheme: callbackURLScheme,
                initialSettings: initialSettings,
                onComplete: onComplete));

  /// Constructs a [WebAuthenticationSession].
  ///
  /// See [WebAuthenticationSession.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  WebAuthenticationSession.fromPlatformCreationParams({
    required PlatformWebAuthenticationSessionCreationParams params,
  }) : this.fromPlatform(platform: PlatformWebAuthenticationSession(params));

  /// Constructs a [WebAuthenticationSession] from a specific platform implementation.
  WebAuthenticationSession.fromPlatform({required this.platform});

  /// Implementation of [PlatformWebAuthenticationSession] for the current platform.
  final PlatformWebAuthenticationSession platform;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.id}
  String get id => platform.id;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.url}
  WebUri get url => platform.url;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.callbackURLScheme}
  String? get callbackURLScheme => platform.callbackURLScheme;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.initialSettings}
  WebAuthenticationSessionSettings? get initialSettings => platform.initialSettings;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.onComplete}
  WebAuthenticationSessionCompletionHandler get onComplete => platform.onComplete;

  ///Used to create and initialize a session.
  ///
  ///[url] represents a URL with the `http` or `https` scheme pointing to the authentication webpage.
  ///
  ///[callbackURLScheme] represents the custom URL scheme that the app expects in the callback URL.
  ///
  ///[onComplete] represents a completion handler the session calls when it completes successfully, or when the user cancels the session.
  static Future<PlatformWebAuthenticationSession> create(
      {required WebUri url,
      String? callbackURLScheme,
      WebAuthenticationSessionCompletionHandler onComplete,
      WebAuthenticationSessionSettings? initialSettings}) async {
    return await PlatformWebAuthenticationSession.static().create(
        url: url,
        callbackURLScheme: callbackURLScheme,
        onComplete: onComplete,
        initialSettings: initialSettings);
  }

  ///Indicates whether the session can begin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - ASWebAuthenticationSession.canStart](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession/3516277-canstart))
  Future<bool> canStart() => platform.canStart();

  ///Starts the web authentication session.
  ///
  ///Returns a boolean value indicating whether the web authentication session started successfully.
  ///
  ///Only call this method once for a given [WebAuthenticationSession] instance after initialization.
  ///Calling the [start] method on a canceled session results in a failure.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - ASWebAuthenticationSession.start](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession/2990953-start))
  Future<bool> start() => platform.start();

  ///Cancels the web authentication session.
  ///
  ///If the session has already presented a view with the authentication webpage, calling this method dismisses that view.
  ///Calling [cancel] on an already canceled session has no effect.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - ASWebAuthenticationSession.cancel](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession/2990951-cancel))
  Future<void> cancel() => platform.cancel();

  ///Disposes the web authentication session.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  Future<void> dispose() => platform.dispose();

  ///Returns `true` if [ASWebAuthenticationSession](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession)
  ///or [SFAuthenticationSession](https://developer.apple.com/documentation/safariservices/sfauthenticationsession) is available.
  ///Otherwise returns `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  static Future<bool> isAvailable() async {
    return await PlatformWebAuthenticationSession.static().isAvailable();
  }
}
