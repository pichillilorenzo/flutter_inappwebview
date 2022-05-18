import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../util.dart';
import '../debug_logging_settings.dart';
import '../types/main.dart';
import '../types/disposable.dart';

import 'web_authenticate_session_settings.dart';

///A completion handler for the [WebAuthenticationSession].
typedef WebAuthenticationSessionCompletionHandler = Future<void> Function(Uri? url, WebAuthenticationSessionError? error)?;

///A session that an app uses to authenticate a user through a web service.
///
///It is implemented using [ASWebAuthenticationSession](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession) on iOS 12.0+
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
///**Supported Platforms/Implementations**:
///- iOS
class WebAuthenticationSession implements Disposable {
  ///Debug settings.
  static DebugLoggingSettings debugLoggingSettings = DebugLoggingSettings();

  ///ID used internally.
  late final String id;

  ///A URL with the `http` or `https` scheme pointing to the authentication webpage.
  final Uri url;

  ///The custom URL scheme that the app expects in the callback URL.
  final String? callbackURLScheme;

  ///Initial settings.
  late final WebAuthenticationSessionSettings? initialSettings;

  ///A completion handler the session calls when it completes successfully, or when the user cancels the session.
  WebAuthenticationSessionCompletionHandler onComplete;

  late MethodChannel _channel;
  static const MethodChannel _sharedChannel = const MethodChannel(
      'com.pichillilorenzo/flutter_webauthenticationsession');

  ///Used to create and initialize a session.
  static Future<WebAuthenticationSession> create(
      {required Uri url,
      String? callbackURLScheme,
      WebAuthenticationSessionCompletionHandler onComplete,
      WebAuthenticationSessionSettings? initialSettings}) async {
    var session = WebAuthenticationSession._create(
        url: url,
        callbackURLScheme: callbackURLScheme,
        onComplete: onComplete,
        initialSettings: initialSettings);
    initialSettings =
        session.initialSettings ?? WebAuthenticationSessionSettings();
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("id", () => session.id);
    args.putIfAbsent("url", () => session.url.toString());
    args.putIfAbsent("callbackURLScheme", () => session.callbackURLScheme);
    args.putIfAbsent("initialSettings", () => initialSettings?.toMap());
    await _sharedChannel.invokeMethod('create', args);
    return session;
  }

  WebAuthenticationSession._create(
      {required this.url,
      this.callbackURLScheme,
      this.onComplete,
      WebAuthenticationSessionSettings? initialSettings}) {
    assert(url.toString().isNotEmpty);
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      assert(['http', 'https'].contains(url.scheme),
          'The specified URL has an unsupported scheme. Only HTTP and HTTPS URLs are supported on iOS.');
    }

    id = IdGenerator.generate();
    this.initialSettings =
        initialSettings ?? WebAuthenticationSessionSettings();
    this._channel = MethodChannel(
        'com.pichillilorenzo/flutter_webauthenticationsession_$id');
    this._channel.setMethodCallHandler(_handleMethod);
  }

  _debugLog(String method, dynamic args) {
    if (WebAuthenticationSession.debugLoggingSettings.enabled) {
      for (var regExp
          in WebAuthenticationSession.debugLoggingSettings.excludeFilter) {
        if (regExp.hasMatch(method)) return;
      }
      var maxLogMessageLength =
          WebAuthenticationSession.debugLoggingSettings.maxLogMessageLength;
      String message = "WebAuthenticationSession ID " +
          id +
          " calling \"" +
          method.toString() +
          "\" using " +
          args.toString();
      if (maxLogMessageLength >= 0 && message.length > maxLogMessageLength) {
        message = message.substring(0, maxLogMessageLength) + "...";
      }
      developer.log(message, name: this.runtimeType.toString());
    }
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    _debugLog(call.method, call.arguments);

    switch (call.method) {
      case "onComplete":
        String? url = call.arguments["url"];
        Uri? uri = url != null ? Uri.parse(url) : null;
        var error = WebAuthenticationSessionError.fromValue(
            call.arguments["errorCode"]);
        if (onComplete != null) {
          onComplete!(uri, error);
        }
        break;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
  }

  ///Indicates whether the session can begin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - ASWebAuthenticationSession.canStart](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession/3516277-canstart))
  Future<bool> canStart() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('canStart', args);
  }

  ///Starts a web authentication session.
  ///
  ///Returns a boolean value indicating whether the web authentication session started successfully.
  ///
  ///Only call this method once for a given [WebAuthenticationSession] instance after initialization.
  ///Calling the [start] method on a canceled session results in a failure.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - ASWebAuthenticationSession.start](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession/2990953-start))
  Future<bool> start() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('start', args);
  }

  ///Cancels a web authentication session.
  ///
  ///If the session has already presented a view with the authentication webpage, calling this method dismisses that view.
  ///Calling [cancel] on an already canceled session has no effect.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - ASWebAuthenticationSession.cancel](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession/2990951-cancel))
  Future<void> cancel() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod("cancel", args);
  }

  ///Disposes a web authentication session.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  @override
  Future<void> dispose() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod("dispose", args);
  }

  ///Returns `true` if [ASWebAuthenticationSession](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession)
  ///or [SFAuthenticationSession](https://developer.apple.com/documentation/safariservices/sfauthenticationsession) is available.
  ///Otherwise returns `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  static Future<bool> isAvailable() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _sharedChannel.invokeMethod("isAvailable", args);
  }
}
