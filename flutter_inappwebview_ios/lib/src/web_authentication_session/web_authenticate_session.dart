import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

/// Object specifying creation parameters for creating a [IOSWebAuthenticationSession].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformWebAuthenticationSessionCreationParams] for
/// more information.
class IOSWebAuthenticationSessionCreationParams
    extends PlatformWebAuthenticationSessionCreationParams {
  /// Creates a new [IOSWebAuthenticationSessionCreationParams] instance.
  const IOSWebAuthenticationSessionCreationParams();

  /// Creates a [IOSWebAuthenticationSessionCreationParams] instance based on [PlatformWebAuthenticationSessionCreationParams].
  factory IOSWebAuthenticationSessionCreationParams.fromPlatformWebAuthenticationSessionCreationParams(
      // Recommended placeholder to prevent being broken by platform interface.
      // ignore: avoid_unused_constructor_parameters
      PlatformWebAuthenticationSessionCreationParams params) {
    return IOSWebAuthenticationSessionCreationParams();
  }
}

///A session that an app uses to authenticate a user through a web service.
///
///It is implemented using [ASWebAuthenticationSession](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession) on iOS 12.0+ and MacOS 10.15+
///and [SFAuthenticationSession](https://developer.apple.com/documentation/safariservices/sfauthenticationsession) on iOS 11.0.
///
///Use an [IOSWebAuthenticationSession] instance to authenticate a user through a web service, including one run by a third party.
///Initialize the session with a URL that points to the authentication webpage.
///A browser loads and displays the page, from which the user can authenticate.
///In iOS, the browser is a secure, embedded web view.
///In macOS, the system opens the user’s default browser if it supports web authentication sessions, or Safari otherwise.
///
///On completion, the service sends a callback URL to the session with an authentication token, and the session passes this URL back to the app through a completion handler.
///[IOSWebAuthenticationSession] ensures that only the calling app’s session receives the authentication callback, even when more than one app registers the same callback URL scheme.
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
class IOSWebAuthenticationSession extends PlatformWebAuthenticationSession
    with ChannelController {
  /// Constructs a [IOSWebAuthenticationSession].
  IOSWebAuthenticationSession(
      PlatformWebAuthenticationSessionCreationParams params)
      : super.implementation(
          params is IOSWebAuthenticationSessionCreationParams
              ? params
              : IOSWebAuthenticationSessionCreationParams
                  .fromPlatformWebAuthenticationSessionCreationParams(params),
        );

  static final IOSWebAuthenticationSession _staticValue =
      IOSWebAuthenticationSession(IOSWebAuthenticationSessionCreationParams());

  /// Provide static access.
  factory IOSWebAuthenticationSession.static() {
    return _staticValue;
  }

  @override
  final String id = IdGenerator.generate();

  @override
  late final WebUri url;

  @override
  late final String? callbackURLScheme;

  @override
  late final WebAuthenticationSessionSettings? initialSettings;

  @override
  late final WebAuthenticationSessionCompletionHandler onComplete;

  static const MethodChannel _staticChannel = const MethodChannel(
      'com.pichillilorenzo/flutter_webauthenticationsession');

  @override
  Future<IOSWebAuthenticationSession> create(
      {required WebUri url,
      String? callbackURLScheme,
      WebAuthenticationSessionCompletionHandler onComplete,
      WebAuthenticationSessionSettings? initialSettings}) async {
    var session = IOSWebAuthenticationSession._create(
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
    await _staticChannel.invokeMethod('create', args);
    return session;
  }

  IOSWebAuthenticationSession._create(
      {required this.url,
      this.callbackURLScheme,
      this.onComplete,
      WebAuthenticationSessionSettings? initialSettings})
      : super.implementation(IOSWebAuthenticationSessionCreationParams()) {
    assert(url.toString().isNotEmpty);
    if (Util.isIOS || Util.isMacOS) {
      assert(['http', 'https'].contains(url.scheme),
          'The specified URL has an unsupported scheme. Only HTTP and HTTPS URLs are supported on iOS.');
    }

    this.initialSettings =
        initialSettings ?? WebAuthenticationSessionSettings();
    channel = MethodChannel(
        'com.pichillilorenzo/flutter_webauthenticationsession_$id');
    handler = _handleMethod;
    initMethodCallHandler();
  }

  _debugLog(String method, dynamic args) {
    debugLog(
        className: this.runtimeType.toString(),
        debugLoggingSettings:
            PlatformWebAuthenticationSession.debugLoggingSettings,
        id: id,
        method: method,
        args: args);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    _debugLog(call.method, call.arguments);

    switch (call.method) {
      case "onComplete":
        String? url = call.arguments["url"];
        WebUri? uri = url != null ? WebUri(url) : null;
        var error = WebAuthenticationSessionError.fromNativeValue(
            call.arguments["errorCode"]);
        if (onComplete != null) {
          onComplete!(uri, error);
        }
        break;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
  }

  @override
  Future<bool> canStart() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool>('canStart', args) ?? false;
  }

  @override
  Future<bool> start() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool>('start', args) ?? false;
  }

  @override
  Future<void> cancel() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod("cancel", args);
  }

  @override
  Future<void> dispose() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod("dispose", args);
    disposeChannel();
  }

  @override
  Future<bool> isAvailable() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _staticChannel.invokeMethod<bool>("isAvailable", args) ??
        false;
  }
}
