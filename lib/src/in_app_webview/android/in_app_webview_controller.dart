import 'dart:core';

import 'package:flutter/services.dart';

import '../../types.dart';
import '../../android/webview_feature.dart';
import '../in_app_webview_controller.dart';

///Class mixin that contains only Android-specific methods for the WebView.
abstract class AndroidInAppWebViewControllerMixin {
  late MethodChannel _channel;

  ///Starts Safe Browsing initialization.
  ///
  ///URL loads are not guaranteed to be protected by Safe Browsing until after the this method returns true.
  ///Safe Browsing is not fully supported on all devices. For those devices this method will returns false.
  ///
  ///This should not be called if Safe Browsing has been disabled by manifest tag or [AndroidInAppWebViewOptions.safeBrowsingEnabled].
  ///This prepares resources used for Safe Browsing.
  ///
  ///This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.START_SAFE_BROWSING].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.startSafeBrowsing](https://developer.android.com/reference/android/webkit/WebView#startSafeBrowsing(android.content.Context,%20android.webkit.ValueCallback%3Cjava.lang.Boolean%3E)))
  Future<bool> startSafeBrowsing() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('startSafeBrowsing', args);
  }

  ///Clears the SSL preferences table stored in response to proceeding with SSL certificate errors.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.clearSslPreferences](https://developer.android.com/reference/android/webkit/WebView#clearSslPreferences()))
  Future<void> clearSslPreferences() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod('clearSslPreferences', args);
  }

  ///Does a best-effort attempt to pause any processing that can be paused safely, such as animations and geolocation. Note that this call does not pause JavaScript.
  ///To pause JavaScript globally, use [InAppWebViewController.pauseTimers]. To resume WebView, call [resume].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.onPause](https://developer.android.com/reference/android/webkit/WebView#onPause()))
  Future<void> pause() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod('pause', args);
  }

  ///Resumes a WebView after a previous call to [pause].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.onResume](https://developer.android.com/reference/android/webkit/WebView#onResume()))
  Future<void> resume() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod('resume', args);
  }

  ///Scrolls the contents of this WebView down by half the page size.
  ///Returns `true` if the page was scrolled.
  ///
  ///[bottom] `true` to jump to bottom of page.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.pageDown](https://developer.android.com/reference/android/webkit/WebView#pageDown(boolean)))
  Future<bool> pageDown({required bool bottom}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("bottom", () => bottom);
    return await _channel.invokeMethod('pageDown', args);
  }

  ///Scrolls the contents of this WebView up by half the view size.
  ///Returns `true` if the page was scrolled.
  ///
  ///[top] `true` to jump to the top of the page.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.pageUp](https://developer.android.com/reference/android/webkit/WebView#pageUp(boolean)))
  Future<bool> pageUp({required bool top}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("top", () => top);
    return await _channel.invokeMethod('pageUp', args);
  }

  ///Performs zoom in in this WebView.
  ///Returns `true` if zoom in succeeds, `false` if no zoom changes.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.zoomIn](https://developer.android.com/reference/android/webkit/WebView#zoomIn()))
  Future<bool> zoomIn() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('zoomIn', args);
  }

  ///Performs zoom out in this WebView.
  ///Returns `true` if zoom out succeeds, `false` if no zoom changes.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.zoomOut](https://developer.android.com/reference/android/webkit/WebView#zoomOut()))
  Future<bool> zoomOut() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('zoomOut', args);
  }

  ///Clears the internal back/forward list.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.clearHistory](https://developer.android.com/reference/android/webkit/WebView#clearHistory()))
  Future<void> clearHistory() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('clearHistory', args);
  }
}

///Use [InAppWebViewController] instead.
@Deprecated("Use InAppWebViewController instead")
class AndroidInAppWebViewController with AndroidInAppWebViewControllerMixin {
  late MethodChannel _channel;

  AndroidInAppWebViewController({required MethodChannel channel}) {
    this._channel = channel;
  }

  ///Use [InAppWebViewController.clearClientCertPreferences] instead.
  @Deprecated("Use InAppWebViewController.clearClientCertPreferences instead")
  static Future<void> clearClientCertPreferences() async {
    await InAppWebViewController.clearClientCertPreferences();
  }

  ///Use [InAppWebViewController.getSafeBrowsingPrivacyPolicyUrl] instead.
  @Deprecated(
      "Use InAppWebViewController.getSafeBrowsingPrivacyPolicyUrl instead")
  static Future<Uri?> getSafeBrowsingPrivacyPolicyUrl() async {
    return await InAppWebViewController.getSafeBrowsingPrivacyPolicyUrl();
  }

  ///Use [InAppWebViewController.setSafeBrowsingWhitelist] instead.
  @Deprecated("Use InAppWebViewController.setSafeBrowsingWhitelist instead")
  static Future<bool> setSafeBrowsingWhitelist(
      {required List<String> hosts}) async {
    return await InAppWebViewController.setSafeBrowsingWhitelist(hosts: hosts);
  }

  ///Use [InAppWebViewController.getCurrentWebViewPackage] instead.
  @Deprecated("Use InAppWebViewController.getCurrentWebViewPackage instead")
  static Future<AndroidWebViewPackageInfo?> getCurrentWebViewPackage() async {
    Map<String, dynamic>? packageInfo =
        (await InAppWebViewController.getCurrentWebViewPackage())?.toMap();
    return AndroidWebViewPackageInfo.fromMap(packageInfo);
  }

  ///Use [InAppWebViewController.setWebContentsDebuggingEnabled] instead.
  @Deprecated(
      "Use InAppWebViewController.setWebContentsDebuggingEnabled instead")
  static Future<void> setWebContentsDebuggingEnabled(
      bool debuggingEnabled) async {
    return await InAppWebViewController.setWebContentsDebuggingEnabled(
        debuggingEnabled);
  }

  ///Use [InAppWebViewController.getOriginalUrl] instead.
  @Deprecated('Use InAppWebViewController.getOriginalUrl instead')
  Future<Uri?> getOriginalUrl() async {
    Map<String, dynamic> args = <String, dynamic>{};
    String? url = await _channel.invokeMethod('getOriginalUrl', args);
    return url != null ? Uri.parse(url) : null;
  }
}
