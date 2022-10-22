import 'dart:core';

import 'package:flutter/services.dart';

import '../../types/main.dart';
import '../in_app_webview_controller.dart';

///Use [InAppWebViewController] instead.
@Deprecated("Use InAppWebViewController instead")
class AndroidInAppWebViewController {
  late MethodChannel _channel;

  AndroidInAppWebViewController({required MethodChannel channel}) {
    this._channel = channel;
  }

  ///Use [InAppWebViewController.startSafeBrowsing] instead.
  @Deprecated("Use InAppWebViewController.startSafeBrowsing instead")
  Future<bool> startSafeBrowsing() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('startSafeBrowsing', args);
  }

  ///Use [InAppWebViewController.clearSslPreferences] instead.
  @Deprecated("Use InAppWebViewController.clearSslPreferences instead")
  Future<void> clearSslPreferences() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod('clearSslPreferences', args);
  }

  ///Use [InAppWebViewController.pause] instead.
  @Deprecated("Use InAppWebViewController.pause instead")
  Future<void> pause() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod('pause', args);
  }

  ///Use [InAppWebViewController.resume] instead.
  @Deprecated("Use InAppWebViewController.resume instead")
  Future<void> resume() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod('resume', args);
  }

  ///Use [InAppWebViewController.pageDown] instead.
  @Deprecated("Use InAppWebViewController.pageDown instead")
  Future<bool> pageDown({required bool bottom}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("bottom", () => bottom);
    return await _channel.invokeMethod('pageDown', args);
  }

  ///Use [InAppWebViewController.pageUp] instead.
  @Deprecated("Use InAppWebViewController.pageUp instead")
  Future<bool> pageUp({required bool top}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("top", () => top);
    return await _channel.invokeMethod('pageUp', args);
  }

  ///Use [InAppWebViewController.zoomIn] instead.
  @Deprecated("Use InAppWebViewController.zoomIn instead")
  Future<bool> zoomIn() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('zoomIn', args);
  }

  ///Use [InAppWebViewController.zoomOut] instead.
  @Deprecated("Use InAppWebViewController.zoomOut instead")
  Future<bool> zoomOut() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('zoomOut', args);
  }

  ///Use [InAppWebViewController.clearHistory] instead.
  @Deprecated("Use InAppWebViewController.clearHistory instead")
  Future<void> clearHistory() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('clearHistory', args);
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
  @Deprecated("Use InAppWebViewController.setSafeBrowsingAllowlist instead")
  static Future<bool> setSafeBrowsingWhitelist(
      {required List<String> hosts}) async {
    return await InAppWebViewController.setSafeBrowsingAllowlist(hosts: hosts);
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
    return url != null ? Uri.tryParse(url) : null;
  }
}
