import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:drago_inappwebview/platform_interface/platform_interface.dart';

///{@macro drago_inappwebview.PlatformProxyController}
///
///{@macro drago_inappwebview.PlatformProxyController.supported_platforms}
class ProxyController {
  ///{@macro drago_inappwebview.PlatformProxyController}
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
    _instance ??= ProxyController();
    return _instance!;
  }

  ///{@macro drago_inappwebview.PlatformProxyController.setProxyOverride}
  ///
  ///{@macro drago_inappwebview.PlatformProxyController.setProxyOverride.supported_platforms}
  Future<void> setProxyOverride({required ProxySettings settings}) =>
      platform.setProxyOverride(settings: settings);

  ///{@macro drago_inappwebview.PlatformProxyController.clearProxyOverride}
  ///
  ///{@macro drago_inappwebview.PlatformProxyController.clearProxyOverride.supported_platforms}
  Future<void> clearProxyOverride() => platform.clearProxyOverride();

  ///{@macro drago_inappwebview.PlatformProxyControllerCreationParams.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformProxyController.static().isClassSupported(platform: platform);

  ///{@macro drago_inappwebview.PlatformProxyController.isMethodSupported}
  static bool isMethodSupported(
    PlatformProxyControllerMethod method, {
    TargetPlatform? platform,
  }) => PlatformProxyController.static().isMethodSupported(
    method,
    platform: platform,
  );
}
