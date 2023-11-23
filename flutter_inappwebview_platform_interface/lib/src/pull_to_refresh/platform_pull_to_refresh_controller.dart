import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/src/types/disposable.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import '../in_app_webview/in_app_webview_settings.dart';
import '../debug_logging_settings.dart';
import '../inappwebview_platform.dart';
import '../types/main.dart';
import 'pull_to_refresh_settings.dart';

/// Object specifying creation parameters for creating a [PlatformPullToRefreshController].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
class PlatformPullToRefreshControllerCreationParams {
  /// Used by the platform implementation to create a new [PlatformPullToRefreshController].
  PlatformPullToRefreshControllerCreationParams(
      {@Deprecated("Use settings instead") PullToRefreshOptions? options,
      PullToRefreshSettings? settings,
      this.onRefresh})
      : this.options = options ?? PullToRefreshOptions(),
        this.settings = settings ?? PullToRefreshSettings();

  @Deprecated("Use settings instead")
  late PullToRefreshOptions options;
  late PullToRefreshSettings settings;

  ///{@macro flutter_inappwebview_platform_interface.PlatformPullToRefreshController.onRefresh}
  final void Function()? onRefresh;
}

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
abstract class PlatformPullToRefreshController extends PlatformInterface
    implements Disposable {
  ///Debug settings.
  static DebugLoggingSettings debugLoggingSettings = DebugLoggingSettings();

  /// Creates a new [PlatformPullToRefreshController]
  factory PlatformPullToRefreshController(
      PlatformPullToRefreshControllerCreationParams params) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformPullToRefreshController webViewControllerDelegate =
        InAppWebViewPlatform.instance!
            .createPlatformPullToRefreshController(params);
    PlatformInterface.verify(webViewControllerDelegate, _token);
    return webViewControllerDelegate;
  }

  /// Used by the platform implementation to create a new [PlatformPullToRefreshController].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformPullToRefreshController.implementation(this.params)
      : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformPullToRefreshController].
  final PlatformPullToRefreshControllerCreationParams params;

  @Deprecated("Use settings instead")
  PullToRefreshOptions get options => params.options;
  PullToRefreshSettings get settings => params.settings;

  ///{@template flutter_inappwebview_platform_interface.PlatformPullToRefreshController.onRefresh}
  ///Event called when a swipe gesture triggers a refresh.
  ///{@endtemplate}
  void Function()? get onRefresh => params.onRefresh;

  ///Sets whether the pull-to-refresh feature is enabled or not.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SwipeRefreshLayout.setEnabled](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setEnabled(boolean)))
  ///- iOS ([Official API - UIScrollView.refreshControl](https://developer.apple.com/documentation/uikit/uiscrollview/2127691-refreshcontrol))
  Future<void> setEnabled(bool enabled) {
    throw UnimplementedError(
        'setEnabled is not implemented on the current platform');
  }

  ///Returns `true` is pull-to-refresh feature is enabled, otherwise `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - View.isEnabled](https://developer.android.com/reference/android/view/View#isEnabled()))
  ///- iOS ([Official API - UIScrollView.refreshControl](https://developer.apple.com/documentation/uikit/uiscrollview/2127691-refreshcontrol))
  Future<bool> isEnabled() {
    throw UnimplementedError(
        'isEnabled is not implemented on the current platform');
  }

  ///Tells the controller that a refresh operation was started programmatically.
  ///
  ///Call this method when an external event source triggers a programmatic refresh of your scrolling view.
  ///This method updates the state of the refresh control to reflect the in-progress refresh operation.
  ///When the refresh operation ends, be sure to call the [endRefreshing] method to return the controller to its default state.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  Future<void> beginRefreshing() {
    throw UnimplementedError(
        'beginRefreshing is not implemented on the current platform');
  }

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
  Future<void> endRefreshing() {
    throw UnimplementedError(
        'endRefreshing is not implemented on the current platform');
  }

  ///Returns whether a refresh operation has been triggered and is in progress.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SwipeRefreshLayout.isRefreshing](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#isRefreshing()))
  ///- iOS ([Official API - UIRefreshControl.isRefreshing](https://developer.apple.com/documentation/uikit/uirefreshcontrol/1624844-isrefreshing))
  Future<bool> isRefreshing() {
    throw UnimplementedError(
        'isRefreshing is not implemented on the current platform');
  }

  ///Sets the color of the refresh control.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SwipeRefreshLayout.setColorSchemeColors](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setColorSchemeColors(int...)))
  ///- iOS ([Official API - UIRefreshControl.tintColor](https://developer.apple.com/documentation/uikit/uirefreshcontrol/1624847-tintcolor))
  Future<void> setColor(Color color) {
    throw UnimplementedError(
        'setColor is not implemented on the current platform');
  }

  ///Sets the background color of the refresh control.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SwipeRefreshLayout.setProgressBackgroundColorSchemeColor](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setProgressBackgroundColorSchemeColor(int)))
  ///- iOS ([Official API - UIView.backgroundColor](https://developer.apple.com/documentation/uikit/uiview/1622591-backgroundcolor))
  Future<void> setBackgroundColor(Color color) {
    throw UnimplementedError(
        'setBackgroundColor is not implemented on the current platform');
  }

  ///Set the distance to trigger a sync in dips.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SwipeRefreshLayout.setDistanceToTriggerSync](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setDistanceToTriggerSync(int)))
  Future<void> setDistanceToTriggerSync(int distanceToTriggerSync) {
    throw UnimplementedError(
        'setDistanceToTriggerSync is not implemented on the current platform');
  }

  ///Sets the distance that the refresh indicator can be pulled beyond its resting position during a swipe gesture.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SwipeRefreshLayout.setSlingshotDistance](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setSlingshotDistance(int)))
  Future<void> setSlingshotDistance(int slingshotDistance) {
    throw UnimplementedError(
        'setSlingshotDistance is not implemented on the current platform');
  }

  ///Gets the default distance that the refresh indicator can be pulled beyond its resting position during a swipe gesture.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SwipeRefreshLayout.DEFAULT_SLINGSHOT_DISTANCE](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#DEFAULT_SLINGSHOT_DISTANCE()))
  Future<int> getDefaultSlingshotDistance() {
    throw UnimplementedError(
        'getDefaultSlingshotDistance is not implemented on the current platform');
  }

  ///Use [setIndicatorSize] instead.
  @Deprecated("Use setIndicatorSize instead")
  Future<void> setSize(AndroidPullToRefreshSize size) {
    throw UnimplementedError(
        'setSize is not implemented on the current platform');
  }

  ///Sets the size of the refresh indicator. One of [PullToRefreshSize.DEFAULT], or [PullToRefreshSize.LARGE].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SwipeRefreshLayout.setSize](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setSize(int)))
  Future<void> setIndicatorSize(PullToRefreshSize size) {
    throw UnimplementedError(
        'setIndicatorSize is not implemented on the current platform');
  }

  ///Use [setStyledTitle] instead.
  @Deprecated("Use setStyledTitle instead")
  Future<void> setAttributedTitle(IOSNSAttributedString attributedTitle) {
    throw UnimplementedError(
        'setAttributedTitle is not implemented on the current platform');
  }

  ///Sets the styled title text to display in the refresh control.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - UIRefreshControl.attributedTitle](https://developer.apple.com/documentation/uikit/uirefreshcontrol/1624845-attributedtitle))
  Future<void> setStyledTitle(AttributedString attributedTitle) {
    throw UnimplementedError(
        'setStyledTitle is not implemented on the current platform');
  }

  @override
  void dispose({bool isKeepAlive = false}) {
    throw UnimplementedError(
        'dispose is not implemented on the current platform');
  }
}
