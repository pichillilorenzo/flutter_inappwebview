import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

///{@macro flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession}
///
///{@macro flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.supported_platforms}
class WebAuthenticationSession {
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.supported_platforms}
  WebAuthenticationSession()
    : this.fromPlatformCreationParams(
        params: PlatformWebAuthenticationSessionCreationParams(),
      );

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
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.id.supported_platforms}
  String get id => platform.id;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.url}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.url.supported_platforms}
  WebUri get url => platform.url;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.callbackURLScheme}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.callbackURLScheme.supported_platforms}
  String? get callbackURLScheme => platform.callbackURLScheme;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.initialSettings}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.initialSettings.supported_platforms}
  WebAuthenticationSessionSettings? get initialSettings =>
      platform.initialSettings;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.onComplete}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.onComplete.supported_platforms}
  WebAuthenticationSessionCompletionHandler get onComplete =>
      platform.onComplete;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.create}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.create.supported_platforms}
  static Future<WebAuthenticationSession> create({
    required WebUri url,
    String? callbackURLScheme,
    WebAuthenticationSessionCompletionHandler onComplete,
    WebAuthenticationSessionSettings? initialSettings,
  }) async {
    return WebAuthenticationSession.fromPlatform(
      platform: await PlatformWebAuthenticationSession.static().create(
        url: url,
        callbackURLScheme: callbackURLScheme,
        onComplete: onComplete,
        initialSettings: initialSettings,
      ),
    );
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.canStart}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.canStart.supported_platforms}
  Future<bool> canStart() => platform.canStart();

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.start}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.start.supported_platforms}
  Future<bool> start() => platform.start();

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.cancel}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.cancel.supported_platforms}
  Future<void> cancel() => platform.cancel();

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.dispose}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.dispose.supported_platforms}
  Future<void> dispose() => platform.dispose();

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.isAvailable}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebAuthenticationSession.isAvailable.supported_platforms}
  static Future<bool> isAvailable() =>
      PlatformWebAuthenticationSession.static().isAvailable();

  ///{@template flutter_inappwebview.WebAuthenticationSession.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformWebAuthenticationSession.static().isClassSupported(
        platform: platform,
      );

  ///{@template flutter_inappwebview.WebAuthenticationSession.isPropertySupported}
  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///The property should be one of the [PlatformWebAuthenticationSessionProperty] or [PlatformWebAuthenticationSessionCreationParamsProperty] values.
  ///{@endtemplate}
  static bool isPropertySupported(
    dynamic property, {
    TargetPlatform? platform,
  }) => PlatformWebAuthenticationSession.static().isPropertySupported(
    property,
    platform: platform,
  );

  ///{@template flutter_inappwebview.WebAuthenticationSession.isMethodSupported}
  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  static bool isMethodSupported(
    PlatformWebAuthenticationSessionMethod method, {
    TargetPlatform? platform,
  }) => PlatformWebAuthenticationSession.static().isMethodSupported(
    method,
    platform: platform,
  );
}
