import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import '../debug_logging_settings.dart';
import '../inappwebview_platform.dart';
import '../types/main.dart';
import '../web_uri.dart';
import 'web_authenticate_session_settings.dart';

///A completion handler for the [PlatformWebAuthenticationSession].
typedef WebAuthenticationSessionCompletionHandler = Future<void> Function(
    WebUri? url, WebAuthenticationSessionError? error)?;

/// Object specifying creation parameters for creating a [PlatformWebAuthenticationSession].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
class PlatformWebAuthenticationSessionCreationParams {
  /// Used by the platform implementation to create a new [PlatformWebAuthenticationSession].
  const PlatformWebAuthenticationSessionCreationParams();
}

///{@template flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession}
///A session that an app uses to authenticate a user through a web service.
///
///It is implemented using [ASWebAuthenticationSession](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession) on iOS 12.0+ and MacOS 10.15+
///and [SFAuthenticationSession](https://developer.apple.com/documentation/safariservices/sfauthenticationsession) on iOS 11.0.
///
///Use an [PlatformWebAuthenticationSession] instance to authenticate a user through a web service, including one run by a third party.
///Initialize the session with a URL that points to the authentication webpage.
///A browser loads and displays the page, from which the user can authenticate.
///In iOS, the browser is a secure, embedded web view.
///In macOS, the system opens the user’s default browser if it supports web authentication sessions, or Safari otherwise.
///
///On completion, the service sends a callback URL to the session with an authentication token, and the session passes this URL back to the app through a completion handler.
///[PlatformWebAuthenticationSession] ensures that only the calling app’s session receives the authentication callback, even when more than one app registers the same callback URL scheme.
///
///**NOTE**: Remember to dispose it when you don't need it anymore.
///
///**NOTE for iOS**: Available only on iOS 11.0+.
///
///**NOTE for MacOS**: Available only on MacOS 10.15+.
///
///**Officially Supported Platforms/Implementations**:
///- iOS
///- MacOS
///{@endtemplate}
abstract class PlatformWebAuthenticationSession extends PlatformInterface
    implements Disposable {
  ///Debug settings.
  static DebugLoggingSettings debugLoggingSettings = DebugLoggingSettings();

  /// Creates a new [PlatformWebAuthenticationSession]
  factory PlatformWebAuthenticationSession(
      PlatformWebAuthenticationSessionCreationParams params) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformWebAuthenticationSession webAuthenticationSession =
        InAppWebViewPlatform.instance!
            .createPlatformWebAuthenticationSession(params);
    PlatformInterface.verify(webAuthenticationSession, _token);
    return webAuthenticationSession;
  }

  /// Creates a new [PlatformWebAuthenticationSession] to access static methods.
  factory PlatformWebAuthenticationSession.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformWebAuthenticationSession webAuthenticationSessionStatic =
        InAppWebViewPlatform.instance!
            .createPlatformWebAuthenticationSessionStatic();
    PlatformInterface.verify(webAuthenticationSessionStatic, _token);
    return webAuthenticationSessionStatic;
  }

  /// Used by the platform implementation to create a new [PlatformWebAuthenticationSession].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformWebAuthenticationSession.implementation(this.params)
      : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformWebAuthenticationSession].
  final PlatformWebAuthenticationSessionCreationParams params;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.id}
  ///ID used internally.
  ///{@endtemplate}
  String get id =>
      throw UnimplementedError('id is not implemented on the current platform');

  ///{@template flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.url}
  ///A URL with the `http` or `https` scheme pointing to the authentication webpage.
  ///{@endtemplate}
  WebUri get url => throw UnimplementedError(
      'url is not implemented on the current platform');

  ///{@template flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.callbackURLScheme}
  ///The custom URL scheme that the app expects in the callback URL.
  ///{@endtemplate}
  String? get callbackURLScheme => throw UnimplementedError(
      'callbackURLScheme is not implemented on the current platform');

  ///{@template flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.initialSettings}
  ///Initial settings.
  ///{@endtemplate}
  WebAuthenticationSessionSettings? get initialSettings =>
      throw UnimplementedError(
          'initialSettings is not implemented on the current platform');

  ///{@template flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.onComplete}
  ///A completion handler the session calls when it completes successfully, or when the user cancels the session.
  ///{@endtemplate}
  WebAuthenticationSessionCompletionHandler get onComplete =>
      throw UnimplementedError(
          'onComplete is not implemented on the current platform');

  ///{@template flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.create}
  ///Used to create and initialize a session.
  ///
  ///[url] represents a URL with the `http` or `https` scheme pointing to the authentication webpage.
  ///
  ///[callbackURLScheme] represents the custom URL scheme that the app expects in the callback URL.
  ///
  ///[onComplete] represents a completion handler the session calls when it completes successfully, or when the user cancels the session.
  ///
  ///[initialSettings] represents initial settings.
  ///{@endtemplate}
  Future<PlatformWebAuthenticationSession> create(
      {required WebUri url,
      String? callbackURLScheme,
      WebAuthenticationSessionCompletionHandler onComplete,
      WebAuthenticationSessionSettings? initialSettings}) {
    throw UnimplementedError(
        'create is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.canStart}
  ///Indicates whether the session can begin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - ASWebAuthenticationSession.canStart](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession/3516277-canstart))
  ///- MacOS ([Official API - ASWebAuthenticationSession.canStart](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession/3516277-canstart))
  ///{@endtemplate}
  Future<bool> canStart() {
    throw UnimplementedError(
        'canStart is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.start}
  ///Starts the web authentication session.
  ///
  ///Returns a boolean value indicating whether the web authentication session started successfully.
  ///
  ///Only call this method once for a given [PlatformWebAuthenticationSession] instance after initialization.
  ///Calling the [start] method on a canceled session results in a failure.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - ASWebAuthenticationSession.start](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession/2990953-start))
  ///- MacOS ([Official API - ASWebAuthenticationSession.start](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession/2990953-start))
  ///{@endtemplate}
  Future<bool> start() {
    throw UnimplementedError(
        'start is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.cancel}
  ///Cancels the web authentication session.
  ///
  ///If the session has already presented a view with the authentication webpage, calling this method dismisses that view.
  ///Calling [cancel] on an already canceled session has no effect.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - ASWebAuthenticationSession.cancel](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession/2990951-cancel))
  ///- MacOS ([Official API - ASWebAuthenticationSession.cancel](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession/2990951-cancel))
  ///{@endtemplate}
  Future<void> cancel() {
    throw UnimplementedError(
        'cancel is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.dispose}
  ///Disposes the web authentication session.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  ///{@endtemplate}
  @override
  Future<void> dispose() {
    throw UnimplementedError(
        'cancel is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.isAvailable}
  ///Returns `true` if [ASWebAuthenticationSession](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession)
  ///or [SFAuthenticationSession](https://developer.apple.com/documentation/safariservices/sfauthenticationsession) is available.
  ///Otherwise returns `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  ///{@endtemplate}
  Future<bool> isAvailable() {
    throw UnimplementedError(
        'isAvailable is not implemented on the current platform');
  }
}
