import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController}
///
///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.supported_platforms}
class PullToRefreshController {
  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.supported_platforms}
  PullToRefreshController({
    void Function()? onRefresh,
    @Deprecated("Use settings instead") PullToRefreshOptions? options,
    PullToRefreshSettings? settings,
  }) : this.fromPlatformCreationParams(
         params: PlatformPullToRefreshControllerCreationParams(
           onRefresh: onRefresh,
           options: options,
           settings: settings,
         ),
       );

  /// Constructs a [PullToRefreshController].
  ///
  /// See [PullToRefreshController.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  PullToRefreshController.fromPlatformCreationParams({
    required PlatformPullToRefreshControllerCreationParams params,
  }) : this.fromPlatform(platform: PlatformPullToRefreshController(params));

  /// Constructs a [PullToRefreshController] from a specific platform implementation.
  PullToRefreshController.fromPlatform({required this.platform});

  /// Implementation of [PlatformPullToRefreshController] for the current platform.
  final PlatformPullToRefreshController platform;

  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.options}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.options.supported_platforms}
  @Deprecated("Use settings instead")
  PullToRefreshOptions get options => platform.options;

  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.settings}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.settings.supported_platforms}
  PullToRefreshSettings get settings => platform.settings;

  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.onRefresh}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.onRefresh.supported_platforms}
  void Function()? get onRefresh => platform.onRefresh;

  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.setEnabled}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.setEnabled.supported_platforms}
  Future<void> setEnabled(bool enabled) => platform.setEnabled(enabled);

  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.isEnabled}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.isEnabled.supported_platforms}
  Future<bool> isEnabled() => platform.isEnabled();

  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.beginRefreshing}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.beginRefreshing.supported_platforms}
  Future<void> beginRefreshing() => platform.beginRefreshing();

  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.endRefreshing}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.endRefreshing.supported_platforms}
  Future<void> endRefreshing() => platform.endRefreshing();

  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.isRefreshing}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.isRefreshing.supported_platforms}
  Future<bool> isRefreshing() => platform.isRefreshing();

  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.setColor}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.setColor.supported_platforms}
  Future<void> setColor(Color color) => platform.setColor(color);

  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.setBackgroundColor}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.setBackgroundColor.supported_platforms}
  Future<void> setBackgroundColor(Color color) =>
      platform.setBackgroundColor(color);

  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.setDistanceToTriggerSync}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.setDistanceToTriggerSync.supported_platforms}
  Future<void> setDistanceToTriggerSync(int distanceToTriggerSync) =>
      platform.setDistanceToTriggerSync(distanceToTriggerSync);

  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.setSlingshotDistance}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.setSlingshotDistance.supported_platforms}
  Future<void> setSlingshotDistance(int slingshotDistance) =>
      platform.setSlingshotDistance(slingshotDistance);

  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.getDefaultSlingshotDistance}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.getDefaultSlingshotDistance.supported_platforms}
  Future<int> getDefaultSlingshotDistance() =>
      platform.getDefaultSlingshotDistance();

  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.setSize}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.setSize.supported_platforms}
  @Deprecated("Use setIndicatorSize instead")
  Future<void> setSize(AndroidPullToRefreshSize size) => platform.setSize(size);

  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.setIndicatorSize}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.setIndicatorSize.supported_platforms}
  Future<void> setIndicatorSize(PullToRefreshSize size) =>
      platform.setIndicatorSize(size);

  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.setAttributedTitle}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.setAttributedTitle.supported_platforms}
  @Deprecated("Use setStyledTitle instead")
  Future<void> setAttributedTitle(IOSNSAttributedString attributedTitle) =>
      platform.setAttributedTitle(attributedTitle);

  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.setStyledTitle}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.setStyledTitle.supported_platforms}
  Future<void> setStyledTitle(AttributedString attributedTitle) =>
      platform.setStyledTitle(attributedTitle);

  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.dispose}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.dispose.supported_platforms}
  void dispose({bool isKeepAlive = false}) =>
      platform.dispose(isKeepAlive: isKeepAlive);

  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformPullToRefreshController.static().isClassSupported(
        platform: platform,
      );

  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.isPropertySupported}
  static bool isPropertySupported(
    PlatformPullToRefreshControllerCreationParamsProperty property, {
    TargetPlatform? platform,
  }) => PlatformPullToRefreshController.static().isPropertySupported(
    property,
    platform: platform,
  );

  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.isMethodSupported}
  static bool isMethodSupported(
    PlatformPullToRefreshControllerMethod method, {
    TargetPlatform? platform,
  }) => PlatformPullToRefreshController.static().isMethodSupported(
    method,
    platform: platform,
  );
}
