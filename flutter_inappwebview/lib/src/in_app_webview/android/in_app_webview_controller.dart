import 'dart:core';

import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../in_app_webview_controller.dart';

///Use [InAppWebViewController] instead.
@Deprecated("Use InAppWebViewController instead")
class AndroidInAppWebViewController {
  PlatformInAppWebViewController? _controller;

  AndroidInAppWebViewController({
    required PlatformInAppWebViewController controller,
  }) {
    this._controller = controller;
  }

  ///Use [InAppWebViewController.startSafeBrowsing] instead.
  @Deprecated("Use InAppWebViewController.startSafeBrowsing instead")
  Future<bool> startSafeBrowsing() async {
    return await _controller?.startSafeBrowsing() ?? false;
  }

  ///Use [InAppWebViewController.clearSslPreferences] instead.
  @Deprecated("Use InAppWebViewController.clearSslPreferences instead")
  Future<void> clearSslPreferences() async {
    await _controller?.clearSslPreferences();
  }

  ///Use [InAppWebViewController.pause] instead.
  @Deprecated("Use InAppWebViewController.pause instead")
  Future<void> pause() async {
    await _controller?.pause();
  }

  ///Use [InAppWebViewController.resume] instead.
  @Deprecated("Use InAppWebViewController.resume instead")
  Future<void> resume() async {
    await _controller?.resume();
  }

  ///Use [InAppWebViewController.pageDown] instead.
  @Deprecated("Use InAppWebViewController.pageDown instead")
  Future<bool> pageDown({required bool bottom}) async {
    return await _controller?.pageDown(bottom: bottom) ?? false;
  }

  ///Use [InAppWebViewController.pageUp] instead.
  @Deprecated("Use InAppWebViewController.pageUp instead")
  Future<bool> pageUp({required bool top}) async {
    return await _controller?.pageUp(top: top) ?? false;
  }

  ///Use [InAppWebViewController.zoomIn] instead.
  @Deprecated("Use InAppWebViewController.zoomIn instead")
  Future<bool> zoomIn() async {
    return await _controller?.zoomIn() ?? false;
  }

  ///Use [InAppWebViewController.zoomOut] instead.
  @Deprecated("Use InAppWebViewController.zoomOut instead")
  Future<bool> zoomOut() async {
    return await _controller?.zoomOut() ?? false;
  }

  ///Use [InAppWebViewController.clearHistory] instead.
  @Deprecated("Use InAppWebViewController.clearHistory instead")
  Future<void> clearHistory() async {
    await _controller?.clearHistory();
  }

  ///Use [InAppWebViewController.clearClientCertPreferences] instead.
  @Deprecated("Use InAppWebViewController.clearClientCertPreferences instead")
  static Future<void> clearClientCertPreferences() async {
    await InAppWebViewController.clearClientCertPreferences();
  }

  ///Use [InAppWebViewController.getSafeBrowsingPrivacyPolicyUrl] instead.
  @Deprecated(
    "Use InAppWebViewController.getSafeBrowsingPrivacyPolicyUrl instead",
  )
  static Future<Uri?> getSafeBrowsingPrivacyPolicyUrl() async {
    return await InAppWebViewController.getSafeBrowsingPrivacyPolicyUrl();
  }

  ///Use [InAppWebViewController.setSafeBrowsingWhitelist] instead.
  @Deprecated("Use InAppWebViewController.setSafeBrowsingAllowlist instead")
  static Future<bool> setSafeBrowsingWhitelist({
    required List<String> hosts,
  }) async {
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
    "Use InAppWebViewController.setWebContentsDebuggingEnabled instead",
  )
  static Future<void> setWebContentsDebuggingEnabled(
    bool debuggingEnabled,
  ) async {
    return await InAppWebViewController.setWebContentsDebuggingEnabled(
      debuggingEnabled,
    );
  }

  ///Use [InAppWebViewController.getOriginalUrl] instead.
  @Deprecated('Use InAppWebViewController.getOriginalUrl instead')
  Future<Uri?> getOriginalUrl() async {
    return await _controller?.getOriginalUrl();
  }

  void dispose() {
    _controller = null;
  }
}
