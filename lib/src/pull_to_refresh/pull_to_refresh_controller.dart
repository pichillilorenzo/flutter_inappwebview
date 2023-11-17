import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import '../in_app_browser/in_app_browser.dart';

///A standard controller that can initiate the refreshing of a scroll view’s contents.
///This should be used whenever the user can refresh the contents of a WebView via a vertical swipe gesture.
///
///All the methods should be called only when the WebView has been created or is already running
///(for example [WebView.onWebViewCreated] or [InAppBrowser.onBrowserCreated]).
///
///**NOTE for Android**: to be able to use the "pull-to-refresh" feature, [InAppWebViewSettings.useHybridComposition] must be `true`.
///
///**Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
class PullToRefreshController {
  ///Debug settings.
  static DebugLoggingSettings debugLoggingSettings = DebugLoggingSettings();

  PullToRefreshController(
      {void Function()? onRefresh,
      @Deprecated("Use settings instead") PullToRefreshOptions? options,
      PullToRefreshSettings? settings})
      : this.fromPlatformCreationParams(
            params: PlatformPullToRefreshControllerCreationParams(
                onRefresh: onRefresh, options: options, settings: settings));

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

  @Deprecated("Use settings instead")
  PullToRefreshOptions get options => platform.options;
  PullToRefreshSettings get settings => platform.settings;

  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.onRefresh}
  void Function()? get onRefresh => platform.onRefresh;

  ///Sets whether the pull-to-refresh feature is enabled or not.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SwipeRefreshLayout.setEnabled](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setEnabled(boolean)))
  ///- iOS ([Official API - UIScrollView.refreshControl](https://developer.apple.com/documentation/uikit/uiscrollview/2127691-refreshcontrol))
  Future<void> setEnabled(bool enabled) => platform.setEnabled(enabled);

  ///Returns `true` is pull-to-refresh feature is enabled, otherwise `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - View.isEnabled](https://developer.android.com/reference/android/view/View#isEnabled()))
  ///- iOS ([Official API - UIScrollView.refreshControl](https://developer.apple.com/documentation/uikit/uiscrollview/2127691-refreshcontrol))
  Future<bool> isEnabled() => platform.isEnabled();

  ///Tells the controller that a refresh operation was started programmatically.
  ///
  ///Call this method when an external event source triggers a programmatic refresh of your scrolling view.
  ///This method updates the state of the refresh control to reflect the in-progress refresh operation.
  ///When the refresh operation ends, be sure to call the [endRefreshing] method to return the controller to its default state.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  Future<void> beginRefreshing() => platform.beginRefreshing();

  ///Tells the controller that a refresh operation has ended.
  ///
  ///Call this method at the end of any refresh operation (whether it was initiated programmatically or by the user)
  ///to return the refresh control to its default state.
  ///If the refresh control is at least partially visible, calling this method also hides it.
  ///If animations are also enabled, the control is hidden using an animation.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  Future<void> endRefreshing() => platform.endRefreshing();

  ///Returns whether a refresh operation has been triggered and is in progress.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SwipeRefreshLayout.isRefreshing](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#isRefreshing()))
  ///- iOS ([Official API - UIRefreshControl.isRefreshing](https://developer.apple.com/documentation/uikit/uirefreshcontrol/1624844-isrefreshing))
  Future<bool> isRefreshing() => platform.isRefreshing();

  ///Sets the color of the refresh control.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SwipeRefreshLayout.setColorSchemeColors](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setColorSchemeColors(int...)))
  ///- iOS ([Official API - UIRefreshControl.tintColor](https://developer.apple.com/documentation/uikit/uirefreshcontrol/1624847-tintcolor))
  Future<void> setColor(Color color) => platform.setColor(color);

  ///Sets the background color of the refresh control.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SwipeRefreshLayout.setProgressBackgroundColorSchemeColor](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setProgressBackgroundColorSchemeColor(int)))
  ///- iOS ([Official API - UIView.backgroundColor](https://developer.apple.com/documentation/uikit/uiview/1622591-backgroundcolor))
  Future<void> setBackgroundColor(Color color) =>
      platform.setBackgroundColor(color);

  ///Set the distance to trigger a sync in dips.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SwipeRefreshLayout.setDistanceToTriggerSync](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setDistanceToTriggerSync(int)))
  Future<void> setDistanceToTriggerSync(int distanceToTriggerSync) =>
      platform.setDistanceToTriggerSync(distanceToTriggerSync);

  ///Sets the distance that the refresh indicator can be pulled beyond its resting position during a swipe gesture.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SwipeRefreshLayout.setSlingshotDistance](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setSlingshotDistance(int)))
  Future<void> setSlingshotDistance(int slingshotDistance) =>
      platform.setSlingshotDistance(slingshotDistance);

  ///Gets the default distance that the refresh indicator can be pulled beyond its resting position during a swipe gesture.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SwipeRefreshLayout.DEFAULT_SLINGSHOT_DISTANCE](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#DEFAULT_SLINGSHOT_DISTANCE()))
  Future<int> getDefaultSlingshotDistance() =>
      platform.getDefaultSlingshotDistance();

  ///Use [setIndicatorSize] instead.
  @Deprecated("Use setIndicatorSize instead")
  Future<void> setSize(AndroidPullToRefreshSize size) => platform.setSize(size);

  ///Sets the size of the refresh indicator. One of [PullToRefreshSize.DEFAULT], or [PullToRefreshSize.LARGE].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SwipeRefreshLayout.setSize](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setSize(int)))
  Future<void> setIndicatorSize(PullToRefreshSize size) =>
      platform.setIndicatorSize(size);

  ///Use [setStyledTitle] instead.
  @Deprecated("Use setStyledTitle instead")
  Future<void> setAttributedTitle(IOSNSAttributedString attributedTitle) =>
      platform.setAttributedTitle(attributedTitle);

  ///Sets the styled title text to display in the refresh control.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - UIRefreshControl.attributedTitle](https://developer.apple.com/documentation/uikit/uirefreshcontrol/1624845-attributedtitle))
  Future<void> setStyledTitle(AttributedString attributedTitle) =>
      platform.setStyledTitle(attributedTitle);

  ///Disposes the controller.
  void dispose({bool isKeepAlive = false}) =>
      platform.dispose(isKeepAlive: isKeepAlive);
}
