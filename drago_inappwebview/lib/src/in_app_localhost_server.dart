import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:drago_inappwebview/platform_interface/platform_interface.dart';

///{@macro drago_inappwebview.PlatformInAppLocalhostServer}
///
///{@macro drago_inappwebview.PlatformInAppLocalhostServer.supported_platforms}
class InAppLocalhostServer {
  ///{@macro drago_inappwebview.PlatformInAppLocalhostServer}
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

  ///{@macro drago_inappwebview.PlatformInAppLocalhostServer.port}
  ///
  ///{@macro drago_inappwebview.PlatformInAppLocalhostServer.port.supported_platforms}
  int get port => platform.port;

  ///{@macro drago_inappwebview.PlatformInAppLocalhostServer.directoryIndex}
  ///
  ///{@macro drago_inappwebview.PlatformInAppLocalhostServer.directoryIndex.supported_platforms}
  String get directoryIndex => platform.directoryIndex;

  ///{@macro drago_inappwebview.PlatformInAppLocalhostServer.documentRoot}
  ///
  ///{@macro drago_inappwebview.PlatformInAppLocalhostServer.documentRoot.supported_platforms}
  String get documentRoot => platform.documentRoot;

  ///{@macro drago_inappwebview.PlatformInAppLocalhostServer.shared}
  ///
  ///{@macro drago_inappwebview.PlatformInAppLocalhostServer.shared.supported_platforms}
  bool get shared => platform.shared;

  ///{@macro drago_inappwebview.PlatformInAppLocalhostServer.onData}
  ///
  ///{@macro drago_inappwebview.PlatformInAppLocalhostServer.onData.supported_platforms}
  Future<bool> Function(HttpRequest request)? get onData => platform.onData;

  ///{@macro drago_inappwebview.PlatformInAppLocalhostServer.start}
  ///
  ///{@macro drago_inappwebview.PlatformInAppLocalhostServer.start.supported_platforms}
  Future<void> start() => platform.start();

  ///{@macro drago_inappwebview.PlatformInAppLocalhostServer.close}
  ///
  ///{@macro drago_inappwebview.PlatformInAppLocalhostServer.close.supported_platforms}
  Future<void> close() => platform.close();

  ///{@macro drago_inappwebview.PlatformInAppLocalhostServer.isRunning}
  ///
  ///{@macro drago_inappwebview.PlatformInAppLocalhostServer.isRunning.supported_platforms}
  bool isRunning() => platform.isRunning();

  ///{@macro drago_inappwebview.PlatformInAppLocalhostServerCreationParams.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformInAppLocalhostServer.static().isClassSupported(
        platform: platform,
      );

  ///{@macro drago_inappwebview.PlatformInAppLocalhostServer.isMethodSupported}
  static bool isMethodSupported(
    PlatformInAppLocalhostServerMethod method, {
    TargetPlatform? platform,
  }) => PlatformInAppLocalhostServer.static().isMethodSupported(
    method,
    platform: platform,
  );
}
