import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Object specifying creation parameters for creating a [PlatformInAppLocalhostServer].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
@immutable
class PlatformInAppLocalhostServerCreationParams {
  /// Used by the platform implementation to create a new [PlatformInAppLocalhostServer].
  const PlatformInAppLocalhostServerCreationParams({
    this.port = 8080,
    this.directoryIndex = 'index.html',
    this.documentRoot = './',
    this.shared = false,
    this.onData = null,
  });

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.port}
  final int port;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.directoryIndex}
  final String directoryIndex;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.documentRoot}
  final String documentRoot;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.shared}
  final bool shared;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.onData}
  final Future<bool> Function(HttpRequest request)? onData;
}

///{@template flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer}
///This class allows you to create a simple server on `http://localhost:[port]/`
///in order to be able to load your assets file on a local server.
///The default `port` value is `8080`.
///
///**Officially Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- MacOS
///- Windows
///{@endtemplate}
abstract class PlatformInAppLocalhostServer extends PlatformInterface {
  /// Creates a new [PlatformInAppLocalhostServer]
  factory PlatformInAppLocalhostServer(
      PlatformInAppLocalhostServerCreationParams params) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`WebViewPlatform.instance` before use. For unit testing, '
      '`WebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformInAppLocalhostServer inAppLocalhostServer =
        InAppWebViewPlatform.instance!
            .createPlatformInAppLocalhostServer(params);
    PlatformInterface.verify(inAppLocalhostServer, _token);
    return inAppLocalhostServer;
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

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.port}
  ///Represents the port of the server. The default value is `8080`.
  ///{@endtemplate}
  int get port => params.port;

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.directoryIndex}
  ///represents the index file to use. The default value is `index.html`.
  ///{@endtemplate}
  String get directoryIndex => params.directoryIndex;

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.documentRoot}
  ///Represents the document root path to serve. The default value is `./`.
  ///{@endtemplate}
  String get documentRoot => params.documentRoot;

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.shared}
  ///Specifies whether additional `HttpServer`
  /// objects can bind to the same combination of `address`, `port` and `v6Only`.
  /// If `shared` is `true` and more `HttpServer`s from this isolate or other
  /// isolates are bound to the port, then the incoming connections will be
  /// distributed among all the bound `HttpServer`s. Connections can be
  /// distributed over multiple isolates this way.
  ///{@endtemplate}
  bool get shared => params.shared;

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.onData}
  ///A custom callback that is called when a new request is received by the server
  ///that can be used to send or modify the response, for example adding custom headers.
  ///If this callback returns `true`, it means that the request has been handled by this callback.
  ///Otherwise, if this callback returns `false`, the server will continue to process the request using the default implementation.
  ///{@endtemplate}
  Future<bool> Function(HttpRequest request)? get onData => params.onData;

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.start}
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
  Future<void> start() {
    throw UnimplementedError(
        'start is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.close}
  ///Closes the server.
  ///{@endtemplate}
  Future<void> close() {
    throw UnimplementedError(
        'close is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.isRunning}
  ///Indicates if the server is running or not.
  ///{@endtemplate}
  bool isRunning() {
    throw UnimplementedError(
        'isRunning is not implemented on the current platform');
  }
}
