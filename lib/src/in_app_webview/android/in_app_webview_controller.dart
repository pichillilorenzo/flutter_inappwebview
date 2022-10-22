import 'dart:core';

import 'package:flutter/services.dart';

import '../_static_channel.dart';

import '../../types.dart';
import '../../android/webview_feature.dart';
import '../in_app_webview_controller.dart';

///Class represents the Android controller that contains only android-specific methods for the WebView.
class AndroidInAppWebViewController {
  late MethodChannel _channel;
  static MethodChannel _staticChannel = IN_APP_WEBVIEW_STATIC_CHANNEL;

  AndroidInAppWebViewController({required MethodChannel channel}) {
    this._channel = channel;
  }

  ///Starts Safe Browsing initialization.
  ///
  ///URL loads are not guaranteed to be protected by Safe Browsing until after the this method returns true.
  ///Safe Browsing is not fully supported on all devices. For those devices this method will returns false.
  ///
  ///This should not be called if Safe Browsing has been disabled by manifest tag or [AndroidInAppWebViewOptions.safeBrowsingEnabled].
  ///This prepares resources used for Safe Browsing.
  ///
  ///This method should only be called if [AndroidWebViewFeature.isFeatureSupported] returns `true` for [AndroidWebViewFeature.START_SAFE_BROWSING].
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebView#startSafeBrowsing(android.content.Context,%20android.webkit.ValueCallback%3Cjava.lang.Boolean%3E)
  Future<bool> startSafeBrowsing() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('startSafeBrowsing', args);
  }

  ///Clears the SSL preferences table stored in response to proceeding with SSL certificate errors.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebView#clearSslPreferences()
  Future<void> clearSslPreferences() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod('clearSslPreferences', args);
  }

  ///Does a best-effort attempt to pause any processing that can be paused safely, such as animations and geolocation. Note that this call does not pause JavaScript.
  ///To pause JavaScript globally, use [InAppWebViewController.pauseTimers]. To resume WebView, call [resume].
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebView#onPause()
  Future<void> pause() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod('pause', args);
  }

  ///Resumes a WebView after a previous call to [pause].
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebView#onResume()
  Future<void> resume() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod('resume', args);
  }

  ///Use [InAppWebViewController.getOriginalUrl] instead.
  @Deprecated('Use `InAppWebViewController.getOriginalUrl` instead')
  Future<Uri?> getOriginalUrl() async {
    Map<String, dynamic> args = <String, dynamic>{};
    String? url = await _channel.invokeMethod('getOriginalUrl', args);
    return url != null ? Uri.tryParse(url) : null;
  }

  ///Scrolls the contents of this WebView down by half the page size.
  ///Returns `true` if the page was scrolled.
  ///
  ///[bottom] `true` to jump to bottom of page.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebView#pageDown(boolean)
  Future<bool> pageDown({required bool bottom}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("bottom", () => bottom);
    return await _channel.invokeMethod('pageDown', args);
  }

  ///Scrolls the contents of this WebView up by half the view size.
  ///Returns `true` if the page was scrolled.
  ///
  ///[bottom] `true` to jump to the top of the page.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebView#pageUp(boolean)
  Future<bool> pageUp({required bool top}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("top", () => top);
    return await _channel.invokeMethod('pageUp', args);
  }

  ///Performs zoom in in this WebView.
  ///Returns `true` if zoom in succeeds, `false` if no zoom changes.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebView#zoomIn()
  Future<bool> zoomIn() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('zoomIn', args);
  }

  ///Performs zoom out in this WebView.
  ///Returns `true` if zoom out succeeds, `false` if no zoom changes.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebView#zoomOut()
  Future<bool> zoomOut() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('zoomOut', args);
  }

  ///Clears the internal back/forward list.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.clearHistory](https://developer.android.com/reference/android/webkit/WebView#clearHistory())).
  Future<void> clearHistory() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('clearHistory', args);
  }

  ///Clears the client certificate preferences stored in response to proceeding/cancelling client cert requests.
  ///Note that WebView automatically clears these preferences when the system keychain is updated.
  ///The preferences are shared by all the WebViews that are created by the embedder application.
  ///
  ///**NOTE**: On iOS certificate-based credentials are never stored permanently.
  ///
  ///**NOTE**: available on Android 21+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebView#clearClientCertPreferences(java.lang.Runnable)
  static Future<void> clearClientCertPreferences() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _staticChannel.invokeMethod('clearClientCertPreferences', args);
  }

  ///Returns a URL pointing to the privacy policy for Safe Browsing reporting.
  ///
  ///This method should only be called if [AndroidWebViewFeature.isFeatureSupported] returns `true` for [AndroidWebViewFeature.SAFE_BROWSING_PRIVACY_POLICY_URL].
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/WebViewCompat#getSafeBrowsingPrivacyPolicyUrl()
  static Future<Uri?> getSafeBrowsingPrivacyPolicyUrl() async {
    Map<String, dynamic> args = <String, dynamic>{};
    String? url = await _staticChannel.invokeMethod(
        'getSafeBrowsingPrivacyPolicyUrl', args);
    return url != null ? Uri.tryParse(url) : null;
  }

  ///Sets the list of hosts (domain names/IP addresses) that are exempt from SafeBrowsing checks. The list is global for all the WebViews.
  ///
  /// Each rule should take one of these:
  ///| Rule | Example | Matches Subdomain |
  ///| -- | -- | -- |
  ///| HOSTNAME | example.com | Yes |
  ///| .HOSTNAME | .example.com | No |
  ///| IPV4_LITERAL | 192.168.1.1 | No |
  ///| IPV6_LITERAL_WITH_BRACKETS | [10:20:30:40:50:60:70:80] | No |
  ///
  ///All other rules, including wildcards, are invalid. The correct syntax for hosts is defined by [RFC 3986](https://tools.ietf.org/html/rfc3986#section-3.2.2).
  ///
  ///This method should only be called if [AndroidWebViewFeature.isFeatureSupported] returns `true` for [AndroidWebViewFeature.SAFE_BROWSING_ALLOWLIST].
  ///
  ///[hosts] represents the list of hosts. This value must never be `null`.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/WebViewCompat#setSafeBrowsingAllowlist(java.util.Set%3Cjava.lang.String%3E,%20android.webkit.ValueCallback%3Cjava.lang.Boolean%3E)
  static Future<bool> setSafeBrowsingWhitelist(
      {required List<String> hosts}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('hosts', () => hosts);
    return await _staticChannel.invokeMethod('setSafeBrowsingWhitelist', args);
  }

  ///If WebView has already been loaded into the current process this method will return the package that was used to load it.
  ///Otherwise, the package that would be used if the WebView was loaded right now will be returned;
  ///this does not cause WebView to be loaded, so this information may become outdated at any time.
  ///The WebView package changes either when the current WebView package is updated, disabled, or uninstalled.
  ///It can also be changed through a Developer Setting. If the WebView package changes, any app process that
  ///has loaded WebView will be killed.
  ///The next time the app starts and loads WebView it will use the new WebView package instead.
  ///
  ///**NOTE**: available only on Android 21+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/WebViewCompat#getCurrentWebViewPackage(android.content.Context)
  static Future<AndroidWebViewPackageInfo?> getCurrentWebViewPackage() async {
    Map<String, dynamic> args = <String, dynamic>{};
    Map<String, dynamic>? packageInfo =
        (await _staticChannel.invokeMethod('getCurrentWebViewPackage', args))
            ?.cast<String, dynamic>();
    return AndroidWebViewPackageInfo.fromMap(packageInfo);
  }

  ///Enables debugging of web contents (HTML / CSS / JavaScript) loaded into any WebViews of this application.
  ///This flag can be enabled in order to facilitate debugging of web layouts and JavaScript code running inside WebViews.
  ///Please refer to WebView documentation for the debugging guide. The default is `false`.
  ///
  ///[debuggingEnabled] whether to enable web contents debugging.
  ///
  ///**NOTE**: available only on Android 19+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/android/webkit/WebView#setWebContentsDebuggingEnabled(boolean)
  static Future<void> setWebContentsDebuggingEnabled(
      bool debuggingEnabled) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('debuggingEnabled', () => debuggingEnabled);
    return await _staticChannel.invokeMethod(
        'setWebContentsDebuggingEnabled', args);
  }
}
