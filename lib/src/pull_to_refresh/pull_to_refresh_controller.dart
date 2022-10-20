import 'dart:ui';

import 'package:flutter/services.dart';
import '../in_app_webview/webview.dart';
import '../in_app_browser/in_app_browser.dart';
import '../util.dart';
import '../types/main.dart';
import '../in_app_webview/in_app_webview_settings.dart';
import 'pull_to_refresh_settings.dart';
import '../debug_logging_settings.dart';

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
  @Deprecated("Use settings instead")
  // ignore: deprecated_member_use_from_same_package
  late PullToRefreshOptions options;
  late PullToRefreshSettings settings;
  MethodChannel? _channel;

  ///Debug settings.
  static DebugLoggingSettings debugLoggingSettings = DebugLoggingSettings();

  ///Event called when a swipe gesture triggers a refresh.
  final void Function()? onRefresh;

  PullToRefreshController(
      {
      // ignore: deprecated_member_use_from_same_package
      @Deprecated("Use settings instead") PullToRefreshOptions? options,
      PullToRefreshSettings? settings,
      this.onRefresh}) {
    // ignore: deprecated_member_use_from_same_package
    this.options = options ?? PullToRefreshOptions();
    this.settings = settings ?? PullToRefreshSettings();
  }

  void initMethodChannel(dynamic id) {
    this._channel = MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_pull_to_refresh_$id');
    this._channel?.setMethodCallHandler((call) async {
      try {
        return await _handleMethod(call);
      } on Error catch (e) {
        print(e);
        print(e.stackTrace);
      }
    });
  }

  _debugLog(String method, dynamic args) {
    debugLog(
        className: this.runtimeType.toString(),
        debugLoggingSettings: PullToRefreshController.debugLoggingSettings,
        method: method,
        args: args);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    _debugLog(call.method, call.arguments);

    switch (call.method) {
      case "onRefresh":
        if (onRefresh != null) onRefresh!();
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
  Future<void> setEnabled(bool enabled) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('enabled', () => enabled);
    await _channel?.invokeMethod('setEnabled', args);
  }

  ///Returns `true` is pull-to-refresh feature is enabled, otherwise `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - View.isEnabled](https://developer.android.com/reference/android/view/View#isEnabled()))
  ///- iOS ([Official API - UIScrollView.refreshControl](https://developer.apple.com/documentation/uikit/uiscrollview/2127691-refreshcontrol))
  Future<bool> isEnabled() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel?.invokeMethod('isEnabled', args);
  }

  Future<void> _setRefreshing(bool refreshing) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('refreshing', () => refreshing);
    await _channel?.invokeMethod('setRefreshing', args);
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
  Future<void> endRefreshing() async {
    await _setRefreshing(false);
  }

  ///Returns whether a refresh operation has been triggered and is in progress.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SwipeRefreshLayout.isRefreshing](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#isRefreshing()))
  ///- iOS ([Official API - UIRefreshControl.isRefreshing](https://developer.apple.com/documentation/uikit/uirefreshcontrol/1624844-isrefreshing))
  Future<bool> isRefreshing() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel?.invokeMethod('isRefreshing', args);
  }

  ///Sets the color of the refresh control.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SwipeRefreshLayout.setColorSchemeColors](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setColorSchemeColors(int...)))
  ///- iOS ([Official API - UIRefreshControl.tintColor](https://developer.apple.com/documentation/uikit/uirefreshcontrol/1624847-tintcolor))
  Future<void> setColor(Color color) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('color', () => color.toHex());
    await _channel?.invokeMethod('setColor', args);
  }

  ///Sets the background color of the refresh control.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SwipeRefreshLayout.setProgressBackgroundColorSchemeColor](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setProgressBackgroundColorSchemeColor(int)))
  ///- iOS ([Official API - UIView.backgroundColor](https://developer.apple.com/documentation/uikit/uiview/1622591-backgroundcolor))
  Future<void> setBackgroundColor(Color color) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('color', () => color.toHex());
    await _channel?.invokeMethod('setBackgroundColor', args);
  }

  ///Set the distance to trigger a sync in dips.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SwipeRefreshLayout.setDistanceToTriggerSync](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setDistanceToTriggerSync(int)))
  Future<void> setDistanceToTriggerSync(int distanceToTriggerSync) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('distanceToTriggerSync', () => distanceToTriggerSync);
    await _channel?.invokeMethod('setDistanceToTriggerSync', args);
  }

  ///Sets the distance that the refresh indicator can be pulled beyond its resting position during a swipe gesture.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SwipeRefreshLayout.setSlingshotDistance](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setSlingshotDistance(int)))
  Future<void> setSlingshotDistance(int slingshotDistance) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('slingshotDistance', () => slingshotDistance);
    await _channel?.invokeMethod('setSlingshotDistance', args);
  }

  ///Gets the default distance that the refresh indicator can be pulled beyond its resting position during a swipe gesture.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SwipeRefreshLayout.DEFAULT_SLINGSHOT_DISTANCE](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#DEFAULT_SLINGSHOT_DISTANCE()))
  Future<int> getDefaultSlingshotDistance() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel?.invokeMethod('getDefaultSlingshotDistance', args);
  }

  ///Use [setIndicatorSize] instead.
  @Deprecated("Use setIndicatorSize instead")
  Future<void> setSize(AndroidPullToRefreshSize size) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('size', () => size.toNativeValue());
    await _channel?.invokeMethod('setSize', args);
  }

  ///Sets the size of the refresh indicator. One of [PullToRefreshSize.DEFAULT], or [PullToRefreshSize.LARGE].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SwipeRefreshLayout.setSize](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setSize(int)))
  Future<void> setIndicatorSize(PullToRefreshSize size) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('size', () => size.toNativeValue());
    await _channel?.invokeMethod('setSize', args);
  }

  ///Use [setStyledTitle] instead.
  @Deprecated("Use setStyledTitle instead")
  Future<void> setAttributedTitle(IOSNSAttributedString attributedTitle) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('attributedTitle', () => attributedTitle.toMap());
    await _channel?.invokeMethod('setStyledTitle', args);
  }

  ///Sets the styled title text to display in the refresh control.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - UIRefreshControl.attributedTitle](https://developer.apple.com/documentation/uikit/uirefreshcontrol/1624845-attributedtitle))
  Future<void> setStyledTitle(AttributedString attributedTitle) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('attributedTitle', () => attributedTitle.toMap());
    await _channel?.invokeMethod('setStyledTitle', args);
  }
}
