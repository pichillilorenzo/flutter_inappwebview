import 'dart:ui';

import 'package:flutter/services.dart';
import '../in_app_webview/webview.dart';
import '../in_app_browser/in_app_browser.dart';
import '../util.dart';
import '../types.dart';
import '../in_app_webview/android/in_app_webview_options.dart';
import 'pull_to_refresh_options.dart';

///A standard controller that can initiate the refreshing of a scroll view’s contents.
///This should be used whenever the user can refresh the contents of a WebView via a vertical swipe gesture.
///
///All the methods should be called only when the WebView has been created or is already running
///(for example [WebView.onWebViewCreated] or [InAppBrowser.onBrowserCreated]).
///
///**NOTE for Android**: to be able to use the "pull-to-refresh" feature, [AndroidInAppWebViewOptions.useHybridComposition] must be `true`.
class PullToRefreshController {
  late PullToRefreshOptions options;
  MethodChannel? _channel;

  ///Event called when a swipe gesture triggers a refresh.
  final void Function()? onRefresh;

  PullToRefreshController({PullToRefreshOptions? options, this.onRefresh}) {
    this.options = options ?? PullToRefreshOptions();
  }

  Future<dynamic> handleMethod(MethodCall call) async {
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
  Future<void> setEnabled(bool enabled) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('enabled', () => enabled);
    await _channel?.invokeMethod('setEnabled', args);
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
  Future<void> beginRefreshing() async {
    return await _setRefreshing(true);
  }

  ///Tells the controller that a refresh operation has ended.
  ///
  ///Call this method at the end of any refresh operation (whether it was initiated programmatically or by the user)
  ///to return the refresh control to its default state.
  ///If the refresh control is at least partially visible, calling this method also hides it.
  ///If animations are also enabled, the control is hidden using an animation.
  Future<void> endRefreshing() async {
    await _setRefreshing(false);
  }

  ///Returns whether a refresh operation has been triggered and is in progress.
  Future<bool> isRefreshing() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel?.invokeMethod('isRefreshing', args);
  }

  ///Sets the color of the refresh control.
  Future<void> setColor(Color color) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('color', () => color.toHex());
    await _channel?.invokeMethod('setColor', args);
  }

  ///Sets the background color of the refresh control.
  Future<void> setBackgroundColor(Color color) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('color', () => color.toHex());
    await _channel?.invokeMethod('setBackgroundColor', args);
  }

  ///Set the distance to trigger a sync in dips.
  ///
  ///**NOTE**: Available only on Android.
  Future<void> setDistanceToTriggerSync(int distanceToTriggerSync) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('distanceToTriggerSync', () => distanceToTriggerSync);
    await _channel?.invokeMethod('setDistanceToTriggerSync', args);
  }

  ///Sets the distance that the refresh indicator can be pulled beyond its resting position during a swipe gesture.
  ///
  ///**NOTE**: Available only on Android.
  Future<void> setSlingshotDistance(int slingshotDistance) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('slingshotDistance', () => slingshotDistance);
    await _channel?.invokeMethod('setSlingshotDistance', args);
  }

  ///Gets the default distance that the refresh indicator can be pulled beyond its resting position during a swipe gesture.
  ///
  ///**NOTE**: Available only on Android.
  Future<int> getDefaultSlingshotDistance() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel?.invokeMethod('getDefaultSlingshotDistance', args);
  }

  ///Sets the size of the refresh indicator. One of [AndroidPullToRefreshSize.DEFAULT], or [AndroidPullToRefreshSize.LARGE].
  ///
  ///**NOTE**: Available only on Android.
  Future<void> setSize(AndroidPullToRefreshSize size) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('size', () => size.toValue());
    await _channel?.invokeMethod('setSize', args);
  }

  ///Sets the styled title text to display in the refresh control.
  ///
  ///**NOTE**: Available only on iOS.
  Future<void> setAttributedTitle(IOSNSAttributedString attributedTitle) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('attributedTitle', () => attributedTitle.toMap());
    await _channel?.invokeMethod('setAttributedTitle', args);
  }

  void initMethodChannel(dynamic id) {
    this._channel = MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_pull_to_refresh_$id');
    this._channel?.setMethodCallHandler(handleMethod);
  }
}
