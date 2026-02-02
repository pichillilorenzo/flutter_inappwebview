import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer}
///
///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.supported_platforms}
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
           onData: onData,
         ),
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
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.port.supported_platforms}
  int get port => platform.port;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.directoryIndex}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.directoryIndex.supported_platforms}
  String get directoryIndex => platform.directoryIndex;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.documentRoot}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.documentRoot.supported_platforms}
  String get documentRoot => platform.documentRoot;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.shared}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.shared.supported_platforms}
  bool get shared => platform.shared;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.onData}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.onData.supported_platforms}
  Future<bool> Function(HttpRequest request)? get onData => platform.onData;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.start}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.start.supported_platforms}
  Future<void> start() => platform.start();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.close}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.close.supported_platforms}
  Future<void> close() => platform.close();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.isRunning}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.isRunning.supported_platforms}
  bool isRunning() => platform.isRunning();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServerCreationParams.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformInAppLocalhostServer.static().isClassSupported(
        platform: platform,
      );

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppLocalhostServer.isMethodSupported}
  static bool isMethodSupported(
    PlatformInAppLocalhostServerMethod method, {
    TargetPlatform? platform,
  }) => PlatformInAppLocalhostServer.static().isMethodSupported(
    method,
    platform: platform,
  );
}
