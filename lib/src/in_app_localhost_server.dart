import 'dart:async';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

///This class allows you to create a simple server on `http://localhost:[port]/`
///in order to be able to load your assets file on a local server.
///The default `port` value is `8080`.
///
///**Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- MacOS
class InAppLocalhostServer {
  /// Constructs a [InAppLocalhostServer].
  ///
  /// See [InAppLocalhostServer.fromPlatformCreationParams] for setting
  /// parameters for a specific platform.
  InAppLocalhostServer({
    int port = 8080,
    String directoryIndex = 'index.html',
    String documentRoot = './',
    bool shared = false,
  }) : this.fromPlatformCreationParams(
          PlatformInAppLocalhostServerCreationParams(
              port: port,
              directoryIndex: directoryIndex,
              documentRoot: documentRoot,
              shared: shared),
        );

  /// Constructs a [InAppLocalhostServer] from creation params for a specific
  /// platform.
  InAppLocalhostServer.fromPlatformCreationParams(
    PlatformInAppLocalhostServerCreationParams params,
  ) : this.fromPlatform(PlatformInAppLocalhostServer(params));

  /// Constructs a [InAppLocalhostServer] from a specific platform
  /// implementation.
  InAppLocalhostServer.fromPlatform(this.platform);

  /// Implementation of [PlatformWebViewInAppLocalhostServer] for the current platform.
  final PlatformInAppLocalhostServer platform;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.port}
  int get port => platform.port;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.directoryIndex}
  String get directoryIndex => platform.directoryIndex;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.documentRoot}
  String get documentRoot => platform.documentRoot;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.shared}
  bool get shared => platform.shared;

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
  Future<void> start() => platform.start();

  ///Closes the server.
  Future<void> close() => platform.close();

  ///Indicates if the server is running or not.
  bool isRunning() => platform.isRunning();
}
