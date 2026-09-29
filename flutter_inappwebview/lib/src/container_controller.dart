import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

///{@macro flutter_inappwebview_platform_interface.PlatformContainerController}
///
///{@macro flutter_inappwebview_platform_interface.PlatformContainerController.supported_platforms}
class ContainerController {
  ///{@macro flutter_inappwebview_platform_interface.PlatformContainerController}
  ContainerController()
    : this.fromPlatformCreationParams(
        const PlatformContainerControllerCreationParams(),
      );

  /// Constructs a [ContainerController] from creation params for a specific
  /// platform.
  ContainerController.fromPlatformCreationParams(
    PlatformContainerControllerCreationParams params,
  ) : this.fromPlatform(PlatformContainerController(params));

  /// Constructs a [ContainerController] from a specific platform
  /// implementation.
  ContainerController.fromPlatform(this.platform);

  /// Implementation of [PlatformContainerController] for the current platform.
  final PlatformContainerController platform;

  static ContainerController? _instance;

  ///Gets the [ContainerController] shared instance.
  static ContainerController instance() {
    return _instance ??= ContainerController();
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformContainerController.getAllContainerNames}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformContainerController.getAllContainerNames.supported_platforms}
  Future<List<String>> getAllContainerNames() =>
      platform.getAllContainerNames();

  ///{@macro flutter_inappwebview_platform_interface.PlatformContainerController.hasContainer}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformContainerController.hasContainer.supported_platforms}
  Future<bool> hasContainer(String containerId) =>
      platform.hasContainer(containerId);

  ///{@macro flutter_inappwebview_platform_interface.PlatformContainerController.deleteContainer}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformContainerController.deleteContainer.supported_platforms}
  Future<bool> deleteContainer(String containerId) =>
      platform.deleteContainer(containerId);

  ///{@macro flutter_inappwebview_platform_interface.PlatformContainerController.clearContainerData}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformContainerController.clearContainerData.supported_platforms}
  Future<bool> clearContainerData(String containerId) =>
      platform.clearContainerData(containerId);

  ///{@macro flutter_inappwebview_platform_interface.PlatformContainerControllerCreationParams.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformContainerController.static().isClassSupported(platform: platform);

  ///{@macro flutter_inappwebview_platform_interface.PlatformContainerController.isMethodSupported}
  static bool isMethodSupported(
    PlatformContainerControllerMethod method, {
    TargetPlatform? platform,
  }) => PlatformContainerController.static().isMethodSupported(
    method,
    platform: platform,
  );
}
