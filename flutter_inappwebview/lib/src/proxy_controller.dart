import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

///{@macro flutter_inappwebview_platform_interface.PlatformProxyController}
class ProxyController {
  ///{@macro flutter_inappwebview_platform_interface.PlatformProxyController}
  ProxyController()
      : this.fromPlatformCreationParams(
          const PlatformProxyControllerCreationParams(),
        );

  /// Constructs a [ProxyController] from creation params for a specific
  /// platform.
  ProxyController.fromPlatformCreationParams(
    PlatformProxyControllerCreationParams params,
  ) : this.fromPlatform(PlatformProxyController(params));

  /// Constructs a [ProxyController] from a specific platform
  /// implementation.
  ProxyController.fromPlatform(this.platform);

  /// Implementation of [PlatformProxyController] for the current platform.
  final PlatformProxyController platform;

  static ProxyController? _instance;

  ///Gets the [ProxyController] shared instance.
  static ProxyController instance() {
    if (_instance == null) {
      _instance = ProxyController();
    }
    return _instance!;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformProxyController.setProxyOverride}
  Future<void> setProxyOverride({required ProxySettings settings}) =>
      platform.setProxyOverride(settings: settings);

  ///{@macro flutter_inappwebview_platform_interface.PlatformProxyController.clearProxyOverride}
  Future<void> clearProxyOverride() => platform.clearProxyOverride();

  ///{@macro flutter_inappwebview_platform_interface.PlatformProxyControllerCreationParams.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformProxyController.static().isClassSupported(platform: platform);

  ///{@macro flutter_inappwebview_platform_interface.PlatformProxyController.isMethodSupported}
  static bool isMethodSupported(PlatformProxyControllerMethod method,
          {TargetPlatform? platform}) =>
      PlatformProxyController.static()
          .isMethodSupported(method, platform: platform);
}
