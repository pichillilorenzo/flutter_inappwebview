import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

/// Object specifying creation parameters for creating a [AndroidPullToRefreshController].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformPullToRefreshControllerCreationParams] for
/// more information.
class AndroidPullToRefreshControllerCreationParams
    extends PlatformPullToRefreshControllerCreationParams {
  /// Creates a new [AndroidPullToRefreshControllerCreationParams] instance.
  AndroidPullToRefreshControllerCreationParams(
      {super.onRefresh, super.options, super.settings});

  /// Creates a [AndroidPullToRefreshControllerCreationParams] instance based on [PlatformPullToRefreshControllerCreationParams].
  factory AndroidPullToRefreshControllerCreationParams.fromPlatformPullToRefreshControllerCreationParams(
      // Recommended placeholder to prevent being broken by platform interface.
      // ignore: avoid_unused_constructor_parameters
      PlatformPullToRefreshControllerCreationParams params) {
    return AndroidPullToRefreshControllerCreationParams(
        onRefresh: params.onRefresh,
        options: params.options,
        settings: params.settings);
  }
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
class AndroidPullToRefreshController extends PlatformPullToRefreshController
    with ChannelController {
  /// Constructs a [AndroidPullToRefreshController].
  AndroidPullToRefreshController(
      PlatformPullToRefreshControllerCreationParams params)
      : super.implementation(
          params is AndroidPullToRefreshControllerCreationParams
              ? params
              : AndroidPullToRefreshControllerCreationParams
                  .fromPlatformPullToRefreshControllerCreationParams(params),
        );

  _debugLog(String method, dynamic args) {
    debugLog(
        className: this.runtimeType.toString(),
        debugLoggingSettings:
            PlatformPullToRefreshController.debugLoggingSettings,
        method: method,
        args: args);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    _debugLog(call.method, call.arguments);

    switch (call.method) {
      case "onRefresh":
        if (params.onRefresh != null) params.onRefresh!();
        break;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
    return null;
  }

  ///Sets whether the pull-to-refresh feature is enabled or not.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SwipeRefreshLayout.setEnabled](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setEnabled(boolean)))
  ///- iOS ([Official API - UIScrollView.refreshControl](https://developer.apple.com/documentation/uikit/uiscrollview/2127691-refreshcontrol))
  @override
  Future<void> setEnabled(bool enabled) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('enabled', () => enabled);
    await channel?.invokeMethod('setEnabled', args);
  }

  ///Returns `true` is pull-to-refresh feature is enabled, otherwise `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - View.isEnabled](https://developer.android.com/reference/android/view/View#isEnabled()))
  ///- iOS ([Official API - UIScrollView.refreshControl](https://developer.apple.com/documentation/uikit/uiscrollview/2127691-refreshcontrol))
  @override
  Future<bool> isEnabled() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool>('isEnabled', args) ?? false;
  }

  Future<void> _setRefreshing(bool refreshing) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('refreshing', () => refreshing);
    await channel?.invokeMethod('setRefreshing', args);
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
  @override
  Future<void> beginRefreshing() async {
    return await _setRefreshing(true);
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
  @override
  Future<void> endRefreshing() async {
    await _setRefreshing(false);
  }

  ///Returns whether a refresh operation has been triggered and is in progress.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SwipeRefreshLayout.isRefreshing](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#isRefreshing()))
  ///- iOS ([Official API - UIRefreshControl.isRefreshing](https://developer.apple.com/documentation/uikit/uirefreshcontrol/1624844-isrefreshing))
  @override
  Future<bool> isRefreshing() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool>('isRefreshing', args) ?? false;
  }

  ///Sets the color of the refresh control.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SwipeRefreshLayout.setColorSchemeColors](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setColorSchemeColors(int...)))
  ///- iOS ([Official API - UIRefreshControl.tintColor](https://developer.apple.com/documentation/uikit/uirefreshcontrol/1624847-tintcolor))
  @override
  Future<void> setColor(Color color) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('color', () => color.toHex());
    await channel?.invokeMethod('setColor', args);
  }

  ///Sets the background color of the refresh control.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SwipeRefreshLayout.setProgressBackgroundColorSchemeColor](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setProgressBackgroundColorSchemeColor(int)))
  ///- iOS ([Official API - UIView.backgroundColor](https://developer.apple.com/documentation/uikit/uiview/1622591-backgroundcolor))
  @override
  Future<void> setBackgroundColor(Color color) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('color', () => color.toHex());
    await channel?.invokeMethod('setBackgroundColor', args);
  }

  ///Set the distance to trigger a sync in dips.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SwipeRefreshLayout.setDistanceToTriggerSync](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setDistanceToTriggerSync(int)))
  @override
  Future<void> setDistanceToTriggerSync(int distanceToTriggerSync) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('distanceToTriggerSync', () => distanceToTriggerSync);
    await channel?.invokeMethod('setDistanceToTriggerSync', args);
  }

  ///Sets the distance that the refresh indicator can be pulled beyond its resting position during a swipe gesture.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SwipeRefreshLayout.setSlingshotDistance](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setSlingshotDistance(int)))
  @override
  Future<void> setSlingshotDistance(int slingshotDistance) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('slingshotDistance', () => slingshotDistance);
    await channel?.invokeMethod('setSlingshotDistance', args);
  }

  ///Gets the default distance that the refresh indicator can be pulled beyond its resting position during a swipe gesture.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SwipeRefreshLayout.DEFAULT_SLINGSHOT_DISTANCE](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#DEFAULT_SLINGSHOT_DISTANCE()))
  @override
  Future<int> getDefaultSlingshotDistance() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<int>(
            'getDefaultSlingshotDistance', args) ??
        0;
  }

  ///Use [setIndicatorSize] instead.
  @Deprecated("Use setIndicatorSize instead")
  @override
  Future<void> setSize(AndroidPullToRefreshSize size) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('size', () => size.toNativeValue());
    await channel?.invokeMethod('setSize', args);
  }

  ///Sets the size of the refresh indicator. One of [PullToRefreshSize.DEFAULT], or [PullToRefreshSize.LARGE].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SwipeRefreshLayout.setSize](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setSize(int)))
  @override
  Future<void> setIndicatorSize(PullToRefreshSize size) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('size', () => size.toNativeValue());
    await channel?.invokeMethod('setSize', args);
  }

  ///Use [setStyledTitle] instead.
  @Deprecated("Use setStyledTitle instead")
  @override
  Future<void> setAttributedTitle(IOSNSAttributedString attributedTitle) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('attributedTitle', () => attributedTitle.toMap());
    await channel?.invokeMethod('setStyledTitle', args);
  }

  ///Sets the styled title text to display in the refresh control.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - UIRefreshControl.attributedTitle](https://developer.apple.com/documentation/uikit/uirefreshcontrol/1624845-attributedtitle))
  @override
  Future<void> setStyledTitle(AttributedString attributedTitle) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('attributedTitle', () => attributedTitle.toMap());
    await channel?.invokeMethod('setStyledTitle', args);
  }

  ///Disposes the controller.
  @override
  void dispose({bool isKeepAlive = false}) {
    disposeChannel(removeMethodCallHandler: !isKeepAlive);
  }
}

extension InternalPullToRefreshController on AndroidPullToRefreshController {
  void init(dynamic id) {
    channel = MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_pull_to_refresh_$id');
    handler = _handleMethod;
    initMethodCallHandler();
  }
}
