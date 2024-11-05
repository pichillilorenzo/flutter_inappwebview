import 'dart:async';
import 'dart:io';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer}
class InAppLocalhostServer {
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer}
  InAppLocalhostServer({
    int port = 8080,
    String directoryIndex = 'index.html',
    String documentRoot = './',
    bool shared = false,
    Future<bool> Function(HttpRequest request)? onData,
  }) : this.fromPlatformCreationParams(
          PlatformInAppLocalhostServerCreationParams(
              port: port,
              directoryIndex: directoryIndex,
              documentRoot: documentRoot,
              shared: shared,
              onData: onData),
        );

  /// Constructs a [InAppLocalhostServer] from creation params for a specific
  /// platform.
  InAppLocalhostServer.fromPlatformCreationParams(
    PlatformInAppLocalhostServerCreationParams params,
  ) : this.fromPlatform(PlatformInAppLocalhostServer(params));

  /// Constructs a [InAppLocalhostServer] from a specific platform
  /// implementation.
  InAppLocalhostServer.fromPlatform(this.platform);

  /// Implementation of [PlatformInAppLocalhostServer] for the current platform.
  final PlatformInAppLocalhostServer platform;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.port}
  int get port => platform.port;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.directoryIndex}
  String get directoryIndex => platform.directoryIndex;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.documentRoot}
  String get documentRoot => platform.documentRoot;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.shared}
  bool get shared => platform.shared;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.onData}
  Future<bool> Function(HttpRequest request)? get onData => platform.onData;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.start}
  Future<void> start() => platform.start();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.close}
  Future<void> close() => platform.close();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.isRunning}
  bool isRunning() => platform.isRunning();
}
