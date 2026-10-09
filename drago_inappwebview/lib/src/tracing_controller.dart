import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:drago_inappwebview/platform_interface/platform_interface.dart';

///{@macro drago_inappwebview.PlatformTracingController}
///
///{@macro drago_inappwebview.PlatformTracingController.supported_platforms}
class TracingController {
  ///{@macro drago_inappwebview.PlatformTracingController}
  TracingController()
    : this.fromPlatformCreationParams(
        const PlatformTracingControllerCreationParams(),
      );

  /// Constructs a [TracingController] from creation params for a specific
  /// platform.
  TracingController.fromPlatformCreationParams(
    PlatformTracingControllerCreationParams params,
  ) : this.fromPlatform(PlatformTracingController(params));

  /// Constructs a [TracingController] from a specific platform
  /// implementation.
  TracingController.fromPlatform(this.platform);

  /// Implementation of [PlatformTracingController] for the current platform.
  final PlatformTracingController platform;

  static TracingController? _instance;

  ///Gets the [TracingController] shared instance.
  static TracingController instance() {
    _instance ??= TracingController();
    return _instance!;
  }

  ///{@macro drago_inappwebview.PlatformTracingController.start}
  ///
  ///{@macro drago_inappwebview.PlatformTracingController.start.supported_platforms}
  Future<void> start({required TracingSettings settings}) =>
      platform.start(settings: settings);

  ///{@macro drago_inappwebview.PlatformTracingController.stop}
  ///
  ///{@macro drago_inappwebview.PlatformTracingController.stop.supported_platforms}
  Future<bool> stop({String? filePath}) => platform.stop(filePath: filePath);

  ///{@macro drago_inappwebview.PlatformTracingController.isTracing}
  ///
  ///{@macro drago_inappwebview.PlatformTracingController.isTracing.supported_platforms}
  Future<bool> isTracing() => platform.isTracing();

  ///{@macro drago_inappwebview.PlatformTracingControllerCreationParams.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformTracingController.static().isClassSupported(platform: platform);

  ///{@macro drago_inappwebview.PlatformTracingController.isMethodSupported}
  static bool isMethodSupported(
    PlatformTracingControllerMethod method, {
    TargetPlatform? platform,
  }) => PlatformTracingController.static().isMethodSupported(
    method,
    platform: platform,
  );
}
