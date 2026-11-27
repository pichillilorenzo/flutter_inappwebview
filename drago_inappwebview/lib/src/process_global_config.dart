import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:drago_inappwebview/platform_interface/platform_interface.dart';

///{@macro drago_inappwebview.PlatformProcessGlobalConfig}
///
///{@macro drago_inappwebview.PlatformProcessGlobalConfig.supported_platforms}
class ProcessGlobalConfig {
  ///{@macro drago_inappwebview.PlatformProcessGlobalConfig}
  ProcessGlobalConfig()
    : this.fromPlatformCreationParams(
        const PlatformProcessGlobalConfigCreationParams(),
      );

  /// Constructs a [ProcessGlobalConfig] from creation params for a specific
  /// platform.
  ProcessGlobalConfig.fromPlatformCreationParams(
    PlatformProcessGlobalConfigCreationParams params,
  ) : this.fromPlatform(PlatformProcessGlobalConfig(params));

  /// Constructs a [ProcessGlobalConfig] from a specific platform
  /// implementation.
  ProcessGlobalConfig.fromPlatform(this.platform);

  /// Implementation of [PlatformProcessGlobalConfig] for the current platform.
  final PlatformProcessGlobalConfig platform;

  static ProcessGlobalConfig? _instance;

  ///Gets the [ProcessGlobalConfig] shared instance.
  static ProcessGlobalConfig instance() {
    _instance ??= ProcessGlobalConfig();
    return _instance!;
  }

  ///{@macro drago_inappwebview.PlatformProcessGlobalConfig.apply}
  ///
  ///{@macro drago_inappwebview.PlatformProcessGlobalConfig.apply.supported_platforms}
  Future<void> apply({required ProcessGlobalConfigSettings settings}) =>
      platform.apply(settings: settings);

  ///{@macro drago_inappwebview.PlatformProcessGlobalConfigCreationParams.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformProcessGlobalConfig.static().isClassSupported(platform: platform);

  ///{@macro drago_inappwebview.PlatformProcessGlobalConfig.isMethodSupported}
  static bool isMethodSupported(
    PlatformProcessGlobalConfigMethod method, {
    TargetPlatform? platform,
  }) => PlatformProcessGlobalConfig.static().isMethodSupported(
    method,
    platform: platform,
  );
}
