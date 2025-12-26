import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

///{@macro flutter_inappwebview_platform_interface.PlatformTracingController}
class TracingController {
  ///{@macro flutter_inappwebview_platform_interface.PlatformTracingController}
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
    if (_instance == null) {
      _instance = TracingController();
    }
    return _instance!;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformTracingController.start}
  Future<void> start({required TracingSettings settings}) =>
      platform.start(settings: settings);

  ///{@macro flutter_inappwebview_platform_interface.PlatformTracingController.stop}
  Future<bool> stop({String? filePath}) => platform.stop(filePath: filePath);

  ///{@macro flutter_inappwebview_platform_interface.PlatformTracingController.isTracing}
  Future<bool> isTracing() => platform.isTracing();

  ///{@macro flutter_inappwebview_platform_interface.PlatformTracingControllerCreationParams.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformTracingController.static().isClassSupported(platform: platform);

  ///{@macro flutter_inappwebview_platform_interface.PlatformTracingController.isMethodSupported}
  static bool isMethodSupported(PlatformTracingControllerMethod method,
          {TargetPlatform? platform}) =>
      PlatformTracingController.static()
          .isMethodSupported(method, platform: platform);
}
