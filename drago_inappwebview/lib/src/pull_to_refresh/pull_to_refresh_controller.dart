import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:drago_inappwebview/platform_interface/platform_interface.dart';

///{@macro drago_inappwebview.PlatformPullToRefreshController}
///
///{@macro drago_inappwebview.PlatformPullToRefreshController.supported_platforms}
class PullToRefreshController {
  ///{@macro drago_inappwebview.PlatformPullToRefreshController}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.supported_platforms}
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

  ///{@macro drago_inappwebview.PlatformPullToRefreshController.options}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.options.supported_platforms}
  @Deprecated("Use settings instead")
  PullToRefreshOptions get options => platform.options;

  ///{@macro drago_inappwebview.PlatformPullToRefreshController.settings}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.settings.supported_platforms}
  PullToRefreshSettings get settings => platform.settings;

  ///{@macro drago_inappwebview.PlatformPullToRefreshController.onRefresh}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.onRefresh.supported_platforms}
  void Function()? get onRefresh => platform.onRefresh;

  ///{@macro drago_inappwebview.PlatformPullToRefreshController.setEnabled}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.setEnabled.supported_platforms}
  Future<void> setEnabled(bool enabled) => platform.setEnabled(enabled);

  ///{@macro drago_inappwebview.PlatformPullToRefreshController.isEnabled}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.isEnabled.supported_platforms}
  Future<bool> isEnabled() => platform.isEnabled();

  ///{@macro drago_inappwebview.PlatformPullToRefreshController.beginRefreshing}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.beginRefreshing.supported_platforms}
  Future<void> beginRefreshing() => platform.beginRefreshing();

  ///{@macro drago_inappwebview.PlatformPullToRefreshController.endRefreshing}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.endRefreshing.supported_platforms}
  Future<void> endRefreshing() => platform.endRefreshing();

  ///{@macro drago_inappwebview.PlatformPullToRefreshController.isRefreshing}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.isRefreshing.supported_platforms}
  Future<bool> isRefreshing() => platform.isRefreshing();

  ///{@macro drago_inappwebview.PlatformPullToRefreshController.setColor}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.setColor.supported_platforms}
  Future<void> setColor(Color color) => platform.setColor(color);

  ///{@macro drago_inappwebview.PlatformPullToRefreshController.setBackgroundColor}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.setBackgroundColor.supported_platforms}
  Future<void> setBackgroundColor(Color color) =>
      platform.setBackgroundColor(color);

  ///{@macro drago_inappwebview.PlatformPullToRefreshController.setDistanceToTriggerSync}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.setDistanceToTriggerSync.supported_platforms}
  Future<void> setDistanceToTriggerSync(int distanceToTriggerSync) =>
      platform.setDistanceToTriggerSync(distanceToTriggerSync);

  ///{@macro drago_inappwebview.PlatformPullToRefreshController.setSlingshotDistance}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.setSlingshotDistance.supported_platforms}
  Future<void> setSlingshotDistance(int slingshotDistance) =>
      platform.setSlingshotDistance(slingshotDistance);

  ///{@macro drago_inappwebview.PlatformPullToRefreshController.getDefaultSlingshotDistance}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.getDefaultSlingshotDistance.supported_platforms}
  Future<int> getDefaultSlingshotDistance() =>
      platform.getDefaultSlingshotDistance();

  ///{@macro drago_inappwebview.PlatformPullToRefreshController.setSize}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.setSize.supported_platforms}
  @Deprecated("Use setIndicatorSize instead")
  Future<void> setSize(AndroidPullToRefreshSize size) => platform.setSize(size);

  ///{@macro drago_inappwebview.PlatformPullToRefreshController.setIndicatorSize}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.setIndicatorSize.supported_platforms}
  Future<void> setIndicatorSize(PullToRefreshSize size) =>
      platform.setIndicatorSize(size);

  ///{@macro drago_inappwebview.PlatformPullToRefreshController.setAttributedTitle}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.setAttributedTitle.supported_platforms}
  @Deprecated("Use setStyledTitle instead")
  Future<void> setAttributedTitle(IOSNSAttributedString attributedTitle) =>
      platform.setAttributedTitle(attributedTitle);

  ///{@macro drago_inappwebview.PlatformPullToRefreshController.setStyledTitle}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.setStyledTitle.supported_platforms}
  Future<void> setStyledTitle(AttributedString attributedTitle) =>
      platform.setStyledTitle(attributedTitle);

  ///{@macro drago_inappwebview.PlatformPullToRefreshController.dispose}
  ///
  ///{@macro drago_inappwebview.PlatformPullToRefreshController.dispose.supported_platforms}
  void dispose({bool isKeepAlive = false}) =>
      platform.dispose(isKeepAlive: isKeepAlive);

  ///{@macro drago_inappwebview.PlatformPullToRefreshController.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformPullToRefreshController.static().isClassSupported(
        platform: platform,
      );

  ///{@macro drago_inappwebview.PlatformPullToRefreshController.isPropertySupported}
  static bool isPropertySupported(
    PlatformPullToRefreshControllerCreationParamsProperty property, {
    TargetPlatform? platform,
  }) => PlatformPullToRefreshController.static().isPropertySupported(
    property,
    platform: platform,
  );

  ///{@macro drago_inappwebview.PlatformPullToRefreshController.isMethodSupported}
  static bool isMethodSupported(
    PlatformPullToRefreshControllerMethod method, {
    TargetPlatform? platform,
  }) => PlatformPullToRefreshController.static().isMethodSupported(
    method,
    platform: platform,
  );
}
