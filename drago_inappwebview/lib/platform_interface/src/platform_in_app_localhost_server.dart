import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:drago_inappwebview/src/internal_annotations/internal_annotations.dart';
import 'package:drago_inappwebview/platform_interface/platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

part 'platform_in_app_localhost_server.g.dart';

///{@template drago_inappwebview.PlatformInAppLocalhostServerCreationParams}
/// Object specifying creation parameters for creating a [PlatformInAppLocalhostServer].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///{@endtemplate}
///
///{@macro drago_inappwebview.PlatformInAppLocalhostServerCreationParams.supported_platforms}
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WindowsPlatform(),
    LinuxPlatform(),
  ],
)
@immutable
class PlatformInAppLocalhostServerCreationParams {
  /// Used by the platform implementation to create a new [PlatformInAppLocalhostServer].
  const PlatformInAppLocalhostServerCreationParams({
    this.port = 8080,
    this.directoryIndex = 'index.html',
    this.documentRoot = './',
    this.shared = false,
    this.onData,
  });

  ///{@macro drago_inappwebview.PlatformInAppLocalhostServer.port}
  final int port;

  ///{@macro drago_inappwebview.PlatformInAppLocalhostServer.directoryIndex}
  final String directoryIndex;

  ///{@macro drago_inappwebview.PlatformInAppLocalhostServer.documentRoot}
  final String documentRoot;

  ///{@macro drago_inappwebview.PlatformInAppLocalhostServer.shared}
  final bool shared;

  ///{@macro drago_inappwebview.PlatformInAppLocalhostServer.onData}
  final Future<bool> Function(HttpRequest request)? onData;

  ///{@template drago_inappwebview.PlatformInAppLocalhostServerCreationParams.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformInAppLocalhostServerCreationParamsClassSupported.isClassSupported(
        platform: platform,
      );
}

///{@template drago_inappwebview.PlatformInAppLocalhostServer}
///This class allows you to create a simple server on `http://localhost:[port]/`
///in order to be able to load your assets file on a local server.
///The default `port` value is `8080`.
///{@endtemplate}
///
///{@macro drago_inappwebview.PlatformInAppLocalhostServer.supported_platforms}
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WindowsPlatform(),
    LinuxPlatform(),
  ],
)
abstract class PlatformInAppLocalhostServer extends PlatformInterface {
  /// Creates a new [PlatformInAppLocalhostServer]
  factory PlatformInAppLocalhostServer(
    PlatformInAppLocalhostServerCreationParams params,
  ) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `drago_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`WebViewPlatform.instance` before use. For unit testing, '
      '`WebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformInAppLocalhostServer inAppLocalhostServer =
        InAppWebViewPlatform.instance!.createPlatformInAppLocalhostServer(
          params,
        );
    PlatformInterface.verify(inAppLocalhostServer, _token);
    return inAppLocalhostServer;
  }

  /// Creates a new empty [PlatformInAppLocalhostServer] to access static methods.
  factory PlatformInAppLocalhostServer.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `drago_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformInAppLocalhostServer inAppLocalhostServerStatic =
        InAppWebViewPlatform.instance!
            .createPlatformInAppLocalhostServerStatic();
    PlatformInterface.verify(inAppLocalhostServerStatic, _token);
    return inAppLocalhostServerStatic;
  }

  /// Used by the platform implementation to create a new
  /// [PlatformInAppLocalhostServer].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformInAppLocalhostServer.implementation(this.params)
    : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformInAppLocalhostServer].
  final PlatformInAppLocalhostServerCreationParams params;

  ///{@template drago_inappwebview.PlatformInAppLocalhostServer.port}
  ///Represents the port of the server. The default value is `8080`.
  ///{@endtemplate}
  int get port => params.port;

  ///{@template drago_inappwebview.PlatformInAppLocalhostServer.directoryIndex}
  ///represents the index file to use. The default value is `index.html`.
  ///{@endtemplate}
  String get directoryIndex => params.directoryIndex;

  ///{@template drago_inappwebview.PlatformInAppLocalhostServer.documentRoot}
  ///Represents the document root path to serve. The default value is `./`.
  ///{@endtemplate}
  String get documentRoot => params.documentRoot;

  ///{@template drago_inappwebview.PlatformInAppLocalhostServer.shared}
  ///Specifies whether additional `HttpServer`
  /// objects can bind to the same combination of `address`, `port` and `v6Only`.
  /// If `shared` is `true` and more `HttpServer`s from this isolate or other
  /// isolates are bound to the port, then the incoming connections will be
  /// distributed among all the bound `HttpServer`s. Connections can be
  /// distributed over multiple isolates this way.
  ///{@endtemplate}
  bool get shared => params.shared;

  ///{@template drago_inappwebview.PlatformInAppLocalhostServer.onData}
  ///A custom callback that is called when a new request is received by the server
  ///that can be used to send or modify the response, for example adding custom headers.
  ///If this callback returns `true`, it means that the request has been handled by this callback.
  ///Otherwise, if this callback returns `false`, the server will continue to process the request using the default implementation.
  ///{@endtemplate}
  Future<bool> Function(HttpRequest request)? get onData => params.onData;

  ///{@template drago_inappwebview.PlatformInAppLocalhostServer.start}
  ///Starts the server on `http://localhost:[port]/`.
  ///
  ///**NOTE for iOS**: For the iOS Platform, you need to add the `NSAllowsLocalNetworking` key with `true` in the `Info.plist` file
  ///(See [ATS Configuration Basics](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW35)):
  ///```xml
  ///<key>NSAppTransportSecurity</key>
  ///<dict>
  ///    <key>NSAllowsLocalNetworking</key>
  ///    <true/>
  ///</dict>
  ///```
  ///The `NSAllowsLocalNetworking` key is available since **iOS 10**.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformInAppLocalhostServer.start.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<void> start() {
    throw UnimplementedError(
      'start is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformInAppLocalhostServer.close}
  ///Closes the server.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformInAppLocalhostServer.close.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<void> close() {
    throw UnimplementedError(
      'close is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformInAppLocalhostServer.isRunning}
  ///Indicates if the server is running or not.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformInAppLocalhostServer.isRunning.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  bool isRunning() {
    throw UnimplementedError(
      'isRunning is not implemented on the current platform',
    );
  }

  ///{@macro drago_inappwebview.PlatformInAppLocalhostServerCreationParams.isClassSupported}
  bool isClassSupported({TargetPlatform? platform}) =>
      params.isClassSupported(platform: platform);

  ///{@template drago_inappwebview.PlatformInAppLocalhostServer.isMethodSupported}
  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isMethodSupported(
    PlatformInAppLocalhostServerMethod method, {
    TargetPlatform? platform,
  }) => _PlatformInAppLocalhostServerMethodSupported.isMethodSupported(
    method,
    platform: platform,
  );
}
