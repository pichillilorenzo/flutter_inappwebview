import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

/// Object specifying creation parameters for creating a [LinuxWebViewEnvironment].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
@immutable
class LinuxWebViewEnvironmentCreationParams
    extends PlatformWebViewEnvironmentCreationParams {
  /// Creates a new [LinuxWebViewEnvironmentCreationParams] instance.
  const LinuxWebViewEnvironmentCreationParams({super.settings});

  /// Creates a [LinuxWebViewEnvironmentCreationParams] instance based on [PlatformWebViewEnvironmentCreationParams].
  factory LinuxWebViewEnvironmentCreationParams.fromPlatformWebViewEnvironmentCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformWebViewEnvironmentCreationParams params,
  ) {
    return LinuxWebViewEnvironmentCreationParams(settings: params.settings);
  }
}

/// Linux implementation of [PlatformWebViewEnvironment].
///
/// This class provides access to WPE WebKit version information on Linux.
///
///**Officially Supported Platforms/Implementations**:
///- Linux
class LinuxWebViewEnvironment extends PlatformWebViewEnvironment {
  /// Static method channel for WebViewEnvironment operations.
  static final MethodChannel _staticChannel = MethodChannel(
    'com.pichillilorenzo/flutter_webview_environment',
  );

  /// Creates a new [LinuxWebViewEnvironment].
  LinuxWebViewEnvironment(PlatformWebViewEnvironmentCreationParams params)
    : super.implementation(
        params is LinuxWebViewEnvironmentCreationParams
            ? params
            : LinuxWebViewEnvironmentCreationParams.fromPlatformWebViewEnvironmentCreationParams(
                params,
              ),
      );

  /// Static instance for accessing static methods.
  static final LinuxWebViewEnvironment _staticValue = LinuxWebViewEnvironment(
    LinuxWebViewEnvironmentCreationParams(),
  );

  /// Factory constructor for accessing static methods.
  factory LinuxWebViewEnvironment.static() {
    return _staticValue;
  }

  /// {@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.getAvailableVersion}
  ///
  /// On Linux, this returns the WPE WebKit version (e.g., "2.42.0").
  ///
  /// The [browserExecutableFolder] parameter is ignored on Linux as WPE WebKit
  /// is a system library.
  @override
  Future<String?> getAvailableVersion({String? browserExecutableFolder}) async {
    return await _staticChannel.invokeMethod<String>('getAvailableVersion');
  }

  @override
  Future<void> dispose() async {
    // No-op on Linux - there's no environment instance to dispose
  }
}
