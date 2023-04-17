import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import '../in_app_webview/in_app_webview_controller.dart';
import '../in_app_webview/in_app_webview_settings.dart';
import 'proxy_controller.dart';
import 'service_worker_controller.dart';
import '../web_message/main.dart';
import '../types/user_script_injection_time.dart';

part 'webview_feature.g.dart';

///Class that represents an Android-specific utility class for checking which WebView Support Library features are supported on the device.
///
///**Supported Platforms/Implementations**:
///- Android native WebView
@ExchangeableEnum()
class WebViewFeature_ {
  @ExchangeableEnumCustomValue()
  static const MethodChannel _channel = const MethodChannel(
      'com.pichillilorenzo/flutter_inappwebview_webviewfeature');

  // ignore: unused_field
  final String _value;
  const WebViewFeature_._internal(this._value);

  @ExchangeableObjectMethod(ignore: true)
  String toNativeValue() => _value;

  ///This feature covers [InAppWebViewController.createWebMessageChannel].
  static const CREATE_WEB_MESSAGE_CHANNEL =
      const WebViewFeature_._internal("CREATE_WEB_MESSAGE_CHANNEL");

  ///This feature covers [InAppWebViewSettings.disabledActionModeMenuItems].
  static const DISABLED_ACTION_MODE_MENU_ITEMS =
      const WebViewFeature_._internal("DISABLED_ACTION_MODE_MENU_ITEMS");

  ///This feature covers [InAppWebViewSettings.forceDark].
  static const FORCE_DARK = const WebViewFeature_._internal("FORCE_DARK");

  ///This feature covers [InAppWebViewSettings.forceDarkStrategy].
  static const FORCE_DARK_STRATEGY =
      const WebViewFeature_._internal("FORCE_DARK_STRATEGY");

  ///
  static const GET_WEB_CHROME_CLIENT =
      const WebViewFeature_._internal("GET_WEB_CHROME_CLIENT");

  ///
  static const GET_WEB_VIEW_CLIENT =
      const WebViewFeature_._internal("GET_WEB_VIEW_CLIENT");

  ///
  static const GET_WEB_VIEW_RENDERER =
      const WebViewFeature_._internal("GET_WEB_VIEW_RENDERER");

  ///
  static const MULTI_PROCESS = const WebViewFeature_._internal("MULTI_PROCESS");

  ///This feature covers [InAppWebViewSettings.offscreenPreRaster].
  static const OFF_SCREEN_PRERASTER =
      const WebViewFeature_._internal("OFF_SCREEN_PRERASTER");

  ///This feature covers [InAppWebViewController.postWebMessage].
  static const POST_WEB_MESSAGE =
      const WebViewFeature_._internal("POST_WEB_MESSAGE");

  ///This feature covers [ProxyController.setProxyOverride] and [ProxyController.clearProxyOverride].
  static const PROXY_OVERRIDE =
      const WebViewFeature_._internal("PROXY_OVERRIDE");

  ///This feature covers [ProxySettings.reverseBypassEnabled].
  static const PROXY_OVERRIDE_REVERSE_BYPASS =
      const WebViewFeature_._internal("PROXY_OVERRIDE_REVERSE_BYPASS");

  ///
  static const RECEIVE_HTTP_ERROR =
      const WebViewFeature_._internal("RECEIVE_HTTP_ERROR");

  ///
  static const RECEIVE_WEB_RESOURCE_ERROR =
      const WebViewFeature_._internal("RECEIVE_WEB_RESOURCE_ERROR");

  ///This feature covers [InAppWebViewController.setSafeBrowsingAllowlist].
  static const SAFE_BROWSING_ALLOWLIST =
      const WebViewFeature_._internal("SAFE_BROWSING_ALLOWLIST");

  ///This feature covers [InAppWebViewSettings.safeBrowsingEnabled].
  static const SAFE_BROWSING_ENABLE =
      const WebViewFeature_._internal("SAFE_BROWSING_ENABLE");

  ///
  static const SAFE_BROWSING_HIT =
      const WebViewFeature_._internal("SAFE_BROWSING_HIT");

  ///This feature covers [InAppWebViewController.getSafeBrowsingPrivacyPolicyUrl].
  static const SAFE_BROWSING_PRIVACY_POLICY_URL =
      const WebViewFeature_._internal("SAFE_BROWSING_PRIVACY_POLICY_URL");

  ///
  static const SAFE_BROWSING_RESPONSE_BACK_TO_SAFETY =
      const WebViewFeature_._internal("SAFE_BROWSING_RESPONSE_BACK_TO_SAFETY");

  ///
  static const SAFE_BROWSING_RESPONSE_PROCEED =
      const WebViewFeature_._internal("SAFE_BROWSING_RESPONSE_PROCEED");

  ///
  static const SAFE_BROWSING_RESPONSE_SHOW_INTERSTITIAL =
      const WebViewFeature_._internal(
          "SAFE_BROWSING_RESPONSE_SHOW_INTERSTITIAL");

  ///Use [SAFE_BROWSING_ALLOWLIST] instead.
  @Deprecated('Use SAFE_BROWSING_ALLOWLIST instead')
  static const SAFE_BROWSING_WHITELIST =
      const WebViewFeature_._internal("SAFE_BROWSING_WHITELIST");

  ///This feature covers [ServiceWorkerController].
  static const SERVICE_WORKER_BASIC_USAGE =
      const WebViewFeature_._internal("SERVICE_WORKER_BASIC_USAGE");

  ///This feature covers [ServiceWorkerController.setBlockNetworkLoads] and [ServiceWorkerController.getBlockNetworkLoads].
  static const SERVICE_WORKER_BLOCK_NETWORK_LOADS =
      const WebViewFeature_._internal("SERVICE_WORKER_BLOCK_NETWORK_LOADS");

  ///This feature covers [ServiceWorkerController.setCacheMode] and [ServiceWorkerController.getCacheMode].
  static const SERVICE_WORKER_CACHE_MODE =
      const WebViewFeature_._internal("SERVICE_WORKER_CACHE_MODE");

  ///This feature covers [ServiceWorkerController.setAllowContentAccess] and [ServiceWorkerController.getAllowContentAccess].
  static const SERVICE_WORKER_CONTENT_ACCESS =
      const WebViewFeature_._internal("SERVICE_WORKER_CONTENT_ACCESS");

  ///This feature covers [ServiceWorkerController.setAllowFileAccess] and [ServiceWorkerController.getAllowFileAccess].
  static const SERVICE_WORKER_FILE_ACCESS =
      const WebViewFeature_._internal("SERVICE_WORKER_FILE_ACCESS");

  ///This feature covers [ServiceWorkerClient.shouldInterceptRequest].
  static const SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST =
      const WebViewFeature_._internal(
          "SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST");

  ///
  static const SHOULD_OVERRIDE_WITH_REDIRECTS =
      const WebViewFeature_._internal("SHOULD_OVERRIDE_WITH_REDIRECTS");

  ///This feature covers [InAppWebViewController.startSafeBrowsing].
  static const START_SAFE_BROWSING =
      const WebViewFeature_._internal("START_SAFE_BROWSING");

  ///
  static const TRACING_CONTROLLER_BASIC_USAGE =
      const WebViewFeature_._internal("TRACING_CONTROLLER_BASIC_USAGE");

  ///
  static const VISUAL_STATE_CALLBACK =
      const WebViewFeature_._internal("VISUAL_STATE_CALLBACK");

  ///
  static const WEB_MESSAGE_CALLBACK_ON_MESSAGE =
      const WebViewFeature_._internal("WEB_MESSAGE_CALLBACK_ON_MESSAGE");

  ///This feature covers [WebMessageListener].
  static const WEB_MESSAGE_LISTENER =
      const WebViewFeature_._internal("WEB_MESSAGE_LISTENER");

  ///
  static const WEB_MESSAGE_PORT_CLOSE =
      const WebViewFeature_._internal("WEB_MESSAGE_PORT_CLOSE");

  ///
  static const WEB_MESSAGE_PORT_POST_MESSAGE =
      const WebViewFeature_._internal("WEB_MESSAGE_PORT_POST_MESSAGE");

  ///
  static const WEB_MESSAGE_PORT_SET_MESSAGE_CALLBACK =
      const WebViewFeature_._internal("WEB_MESSAGE_PORT_SET_MESSAGE_CALLBACK");

  ///
  static const WEB_RESOURCE_ERROR_GET_CODE =
      const WebViewFeature_._internal("WEB_RESOURCE_ERROR_GET_CODE");

  ///
  static const WEB_RESOURCE_ERROR_GET_DESCRIPTION =
      const WebViewFeature_._internal("WEB_RESOURCE_ERROR_GET_DESCRIPTION");

  ///
  static const WEB_RESOURCE_REQUEST_IS_REDIRECT =
      const WebViewFeature_._internal("WEB_RESOURCE_REQUEST_IS_REDIRECT");

  ///
  static const WEB_VIEW_RENDERER_CLIENT_BASIC_USAGE =
      const WebViewFeature_._internal("WEB_VIEW_RENDERER_CLIENT_BASIC_USAGE");

  ///
  static const WEB_VIEW_RENDERER_TERMINATE =
      const WebViewFeature_._internal("WEB_VIEW_RENDERER_TERMINATE");

  ///This feature covers [UserScriptInjectionTime.AT_DOCUMENT_START].
  static const DOCUMENT_START_SCRIPT =
      const WebViewFeature_._internal("DOCUMENT_START_SCRIPT");

  ///This feature covers [InAppWebViewSettings.willSuppressErrorPage].
  static const SUPPRESS_ERROR_PAGE =
      const WebViewFeature_._internal("SUPPRESS_ERROR_PAGE");

  ///This feature covers [InAppWebViewSettings.algorithmicDarkeningAllowed].
  static const ALGORITHMIC_DARKENING =
      const WebViewFeature_._internal("ALGORITHMIC_DARKENING");

  ///This feature covers [InAppWebViewSettings.enterpriseAuthenticationAppLinkPolicyEnabled].
  static const ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY =
      const WebViewFeature_._internal(
          "ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY");

  ///This feature covers [InAppWebViewController.getVariationsHeader].
  static const GET_VARIATIONS_HEADER =
      const WebViewFeature_._internal("GET_VARIATIONS_HEADER");

  ///Return whether a feature is supported at run-time. On devices running Android version `Build.VERSION_CODES.LOLLIPOP` and higher,
  ///this will check whether a feature is supported, depending on the combination of the desired feature, the Android version of device,
  ///and the WebView APK on the device. If running on a device with a lower API level, this will always return `false`.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/WebViewFeature#isFeatureSupported(java.lang.String)
  static Future<bool> isFeatureSupported(WebViewFeature_ feature) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("feature", () => feature.toNativeValue());
    return await _channel.invokeMethod('isFeatureSupported', args);
  }
}

///Class that represents an Android-specific utility class for checking which WebView Support Library features are supported on the device.
///Use [WebViewFeature] instead.
@Deprecated("Use WebViewFeature instead")
@ExchangeableEnum()
class AndroidWebViewFeature_ {
  @ExchangeableEnumCustomValue()
  static const MethodChannel _channel = const MethodChannel(
      'com.pichillilorenzo/flutter_inappwebview_webviewfeature');

  // ignore: unused_field
  final String _value;
  const AndroidWebViewFeature_._internal(this._value);

  @ExchangeableObjectMethod(ignore: true)
  String toNativeValue() => _value;

  ///
  static const CREATE_WEB_MESSAGE_CHANNEL =
      const AndroidWebViewFeature_._internal("CREATE_WEB_MESSAGE_CHANNEL");

  ///
  static const DISABLED_ACTION_MODE_MENU_ITEMS =
      const AndroidWebViewFeature_._internal("DISABLED_ACTION_MODE_MENU_ITEMS");

  ///
  static const FORCE_DARK =
      const AndroidWebViewFeature_._internal("FORCE_DARK");

  ///
  static const FORCE_DARK_STRATEGY =
      const AndroidWebViewFeature_._internal("FORCE_DARK_STRATEGY");

  ///
  static const GET_WEB_CHROME_CLIENT =
      const AndroidWebViewFeature_._internal("GET_WEB_CHROME_CLIENT");

  ///
  static const GET_WEB_VIEW_CLIENT =
      const AndroidWebViewFeature_._internal("GET_WEB_VIEW_CLIENT");

  ///
  static const GET_WEB_VIEW_RENDERER =
      const AndroidWebViewFeature_._internal("GET_WEB_VIEW_RENDERER");

  ///
  static const MULTI_PROCESS =
      const AndroidWebViewFeature_._internal("MULTI_PROCESS");

  ///
  static const OFF_SCREEN_PRERASTER =
      const AndroidWebViewFeature_._internal("OFF_SCREEN_PRERASTER");

  ///
  static const POST_WEB_MESSAGE =
      const AndroidWebViewFeature_._internal("POST_WEB_MESSAGE");

  ///
  static const PROXY_OVERRIDE =
      const AndroidWebViewFeature_._internal("PROXY_OVERRIDE");

  ///
  static const RECEIVE_HTTP_ERROR =
      const AndroidWebViewFeature_._internal("RECEIVE_HTTP_ERROR");

  ///
  static const RECEIVE_WEB_RESOURCE_ERROR =
      const AndroidWebViewFeature_._internal("RECEIVE_WEB_RESOURCE_ERROR");

  ///
  static const SAFE_BROWSING_ALLOWLIST =
      const AndroidWebViewFeature_._internal("SAFE_BROWSING_ALLOWLIST");

  ///
  static const SAFE_BROWSING_ENABLE =
      const AndroidWebViewFeature_._internal("SAFE_BROWSING_ENABLE");

  ///
  static const SAFE_BROWSING_HIT =
      const AndroidWebViewFeature_._internal("SAFE_BROWSING_HIT");

  ///
  static const SAFE_BROWSING_PRIVACY_POLICY_URL =
      const AndroidWebViewFeature_._internal(
          "SAFE_BROWSING_PRIVACY_POLICY_URL");

  ///
  static const SAFE_BROWSING_RESPONSE_BACK_TO_SAFETY =
      const AndroidWebViewFeature_._internal(
          "SAFE_BROWSING_RESPONSE_BACK_TO_SAFETY");

  ///
  static const SAFE_BROWSING_RESPONSE_PROCEED =
      const AndroidWebViewFeature_._internal("SAFE_BROWSING_RESPONSE_PROCEED");

  ///
  static const SAFE_BROWSING_RESPONSE_SHOW_INTERSTITIAL =
      const AndroidWebViewFeature_._internal(
          "SAFE_BROWSING_RESPONSE_SHOW_INTERSTITIAL");

  ///Use [SAFE_BROWSING_ALLOWLIST] instead.
  @Deprecated('Use SAFE_BROWSING_ALLOWLIST instead')
  static const SAFE_BROWSING_WHITELIST =
      const AndroidWebViewFeature_._internal("SAFE_BROWSING_WHITELIST");

  ///
  static const SERVICE_WORKER_BASIC_USAGE =
      const AndroidWebViewFeature_._internal("SERVICE_WORKER_BASIC_USAGE");

  ///
  static const SERVICE_WORKER_BLOCK_NETWORK_LOADS =
      const AndroidWebViewFeature_._internal(
          "SERVICE_WORKER_BLOCK_NETWORK_LOADS");

  ///
  static const SERVICE_WORKER_CACHE_MODE =
      const AndroidWebViewFeature_._internal("SERVICE_WORKER_CACHE_MODE");

  ///
  static const SERVICE_WORKER_CONTENT_ACCESS =
      const AndroidWebViewFeature_._internal("SERVICE_WORKER_CONTENT_ACCESS");

  ///
  static const SERVICE_WORKER_FILE_ACCESS =
      const AndroidWebViewFeature_._internal("SERVICE_WORKER_FILE_ACCESS");

  ///
  static const SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST =
      const AndroidWebViewFeature_._internal(
          "SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST");

  ///
  static const SHOULD_OVERRIDE_WITH_REDIRECTS =
      const AndroidWebViewFeature_._internal("SHOULD_OVERRIDE_WITH_REDIRECTS");

  ///
  static const START_SAFE_BROWSING =
      const AndroidWebViewFeature_._internal("START_SAFE_BROWSING");

  ///
  static const TRACING_CONTROLLER_BASIC_USAGE =
      const AndroidWebViewFeature_._internal("TRACING_CONTROLLER_BASIC_USAGE");

  ///
  static const VISUAL_STATE_CALLBACK =
      const AndroidWebViewFeature_._internal("VISUAL_STATE_CALLBACK");

  ///
  static const WEB_MESSAGE_CALLBACK_ON_MESSAGE =
      const AndroidWebViewFeature_._internal("WEB_MESSAGE_CALLBACK_ON_MESSAGE");

  ///
  static const WEB_MESSAGE_LISTENER =
      const AndroidWebViewFeature_._internal("WEB_MESSAGE_LISTENER");

  ///
  static const WEB_MESSAGE_PORT_CLOSE =
      const AndroidWebViewFeature_._internal("WEB_MESSAGE_PORT_CLOSE");

  ///
  static const WEB_MESSAGE_PORT_POST_MESSAGE =
      const AndroidWebViewFeature_._internal("WEB_MESSAGE_PORT_POST_MESSAGE");

  ///
  static const WEB_MESSAGE_PORT_SET_MESSAGE_CALLBACK =
      const AndroidWebViewFeature_._internal(
          "WEB_MESSAGE_PORT_SET_MESSAGE_CALLBACK");

  ///
  static const WEB_RESOURCE_ERROR_GET_CODE =
      const AndroidWebViewFeature_._internal("WEB_RESOURCE_ERROR_GET_CODE");

  ///
  static const WEB_RESOURCE_ERROR_GET_DESCRIPTION =
      const AndroidWebViewFeature_._internal(
          "WEB_RESOURCE_ERROR_GET_DESCRIPTION");

  ///
  static const WEB_RESOURCE_REQUEST_IS_REDIRECT =
      const AndroidWebViewFeature_._internal(
          "WEB_RESOURCE_REQUEST_IS_REDIRECT");

  ///
  static const WEB_VIEW_RENDERER_CLIENT_BASIC_USAGE =
      const AndroidWebViewFeature_._internal(
          "WEB_VIEW_RENDERER_CLIENT_BASIC_USAGE");

  ///
  static const WEB_VIEW_RENDERER_TERMINATE =
      const AndroidWebViewFeature_._internal("WEB_VIEW_RENDERER_TERMINATE");

  ///This feature covers [UserScriptInjectionTime.AT_DOCUMENT_START].
  static const DOCUMENT_START_SCRIPT =
      const AndroidWebViewFeature_._internal("DOCUMENT_START_SCRIPT");

  ///This feature covers [InAppWebViewSettings.willSuppressErrorPage].
  static const SUPPRESS_ERROR_PAGE =
      const AndroidWebViewFeature_._internal("SUPPRESS_ERROR_PAGE");

  ///This feature covers [InAppWebViewSettings.algorithmicDarkeningAllowed].
  static const ALGORITHMIC_DARKENING =
      const AndroidWebViewFeature_._internal("ALGORITHMIC_DARKENING");

  ///This feature covers [InAppWebViewSettings.enterpriseAuthenticationAppLinkPolicyEnabled].
  static const ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY =
      const AndroidWebViewFeature_._internal(
          "ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY");

  ///Return whether a feature is supported at run-time. On devices running Android version `Build.VERSION_CODES.LOLLIPOP` and higher,
  ///this will check whether a feature is supported, depending on the combination of the desired feature, the Android version of device,
  ///and the WebView APK on the device. If running on a device with a lower API level, this will always return `false`.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/WebViewFeature#isFeatureSupported(java.lang.String)
  static Future<bool> isFeatureSupported(AndroidWebViewFeature_ feature) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("feature", () => feature.toNativeValue());
    return await _channel.invokeMethod('isFeatureSupported', args);
  }
}
