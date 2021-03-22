import 'dart:async';
import 'package:flutter/services.dart';

///Class that represents an Android-specific utility class for checking which WebView Support Library features are supported on the device.
class AndroidWebViewFeature {
  static const MethodChannel _channel = const MethodChannel(
      'com.pichillilorenzo/flutter_inappwebview_android_webviewfeature');

  final String _value;

  const AndroidWebViewFeature._internal(this._value);

  static final Set<AndroidWebViewFeature> values = [
    AndroidWebViewFeature.CREATE_WEB_MESSAGE_CHANNEL,
    AndroidWebViewFeature.DISABLED_ACTION_MODE_MENU_ITEMS,
    AndroidWebViewFeature.FORCE_DARK,
    AndroidWebViewFeature.FORCE_DARK_STRATEGY,
    AndroidWebViewFeature.GET_WEB_CHROME_CLIENT,
    AndroidWebViewFeature.GET_WEB_VIEW_CLIENT,
    AndroidWebViewFeature.GET_WEB_VIEW_RENDERER,
    AndroidWebViewFeature.MULTI_PROCESS,
    AndroidWebViewFeature.OFF_SCREEN_PRERASTER,
    AndroidWebViewFeature.POST_WEB_MESSAGE,
    AndroidWebViewFeature.PROXY_OVERRIDE,
    AndroidWebViewFeature.RECEIVE_HTTP_ERROR,
    AndroidWebViewFeature.RECEIVE_WEB_RESOURCE_ERROR,
    AndroidWebViewFeature.SAFE_BROWSING_ALLOWLIST,
    AndroidWebViewFeature.SAFE_BROWSING_ENABLE,
    AndroidWebViewFeature.SAFE_BROWSING_HIT,
    AndroidWebViewFeature.SAFE_BROWSING_PRIVACY_POLICY_URL,
    AndroidWebViewFeature.SAFE_BROWSING_RESPONSE_BACK_TO_SAFETY,
    AndroidWebViewFeature.SAFE_BROWSING_RESPONSE_PROCEED,
    AndroidWebViewFeature.SAFE_BROWSING_RESPONSE_SHOW_INTERSTITIAL,
    AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE,
    AndroidWebViewFeature.SERVICE_WORKER_BLOCK_NETWORK_LOADS,
    AndroidWebViewFeature.SERVICE_WORKER_CACHE_MODE,
    AndroidWebViewFeature.SERVICE_WORKER_CONTENT_ACCESS,
    AndroidWebViewFeature.SERVICE_WORKER_FILE_ACCESS,
    AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST,
    AndroidWebViewFeature.SHOULD_OVERRIDE_WITH_REDIRECTS,
    AndroidWebViewFeature.START_SAFE_BROWSING,
    AndroidWebViewFeature.TRACING_CONTROLLER_BASIC_USAGE,
    AndroidWebViewFeature.VISUAL_STATE_CALLBACK,
    AndroidWebViewFeature.WEB_MESSAGE_CALLBACK_ON_MESSAGE,
    AndroidWebViewFeature.WEB_MESSAGE_LISTENER,
    AndroidWebViewFeature.WEB_MESSAGE_PORT_CLOSE,
    AndroidWebViewFeature.WEB_MESSAGE_PORT_POST_MESSAGE,
    AndroidWebViewFeature.WEB_MESSAGE_PORT_SET_MESSAGE_CALLBACK,
    AndroidWebViewFeature.WEB_RESOURCE_ERROR_GET_CODE,
    AndroidWebViewFeature.WEB_RESOURCE_ERROR_GET_DESCRIPTION,
    AndroidWebViewFeature.WEB_RESOURCE_REQUEST_IS_REDIRECT,
    AndroidWebViewFeature.WEB_VIEW_RENDERER_CLIENT_BASIC_USAGE,
    AndroidWebViewFeature.WEB_VIEW_RENDERER_TERMINATE,
  ].toSet();

  static AndroidWebViewFeature? fromValue(String? value) {
    if (value != null) {
      try {
        return AndroidWebViewFeature.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  String toValue() => _value;

  @override
  String toString() => _value;

  ///
  static const CREATE_WEB_MESSAGE_CHANNEL =
      const AndroidWebViewFeature._internal("CREATE_WEB_MESSAGE_CHANNEL");

  ///
  static const DISABLED_ACTION_MODE_MENU_ITEMS =
      const AndroidWebViewFeature._internal("DISABLED_ACTION_MODE_MENU_ITEMS");

  ///
  static const FORCE_DARK = const AndroidWebViewFeature._internal("FORCE_DARK");

  ///
  static const FORCE_DARK_STRATEGY =
      const AndroidWebViewFeature._internal("FORCE_DARK_STRATEGY");

  ///
  static const GET_WEB_CHROME_CLIENT =
      const AndroidWebViewFeature._internal("GET_WEB_CHROME_CLIENT");

  ///
  static const GET_WEB_VIEW_CLIENT =
      const AndroidWebViewFeature._internal("GET_WEB_VIEW_CLIENT");

  ///
  static const GET_WEB_VIEW_RENDERER =
      const AndroidWebViewFeature._internal("GET_WEB_VIEW_RENDERER");

  ///
  static const MULTI_PROCESS =
      const AndroidWebViewFeature._internal("MULTI_PROCESS");

  ///
  static const OFF_SCREEN_PRERASTER =
      const AndroidWebViewFeature._internal("OFF_SCREEN_PRERASTER");

  ///
  static const POST_WEB_MESSAGE =
      const AndroidWebViewFeature._internal("POST_WEB_MESSAGE");

  ///
  static const PROXY_OVERRIDE =
      const AndroidWebViewFeature._internal("PROXY_OVERRIDE");

  ///
  static const RECEIVE_HTTP_ERROR =
      const AndroidWebViewFeature._internal("RECEIVE_HTTP_ERROR");

  ///
  static const RECEIVE_WEB_RESOURCE_ERROR =
      const AndroidWebViewFeature._internal("RECEIVE_WEB_RESOURCE_ERROR");

  ///
  static const SAFE_BROWSING_ALLOWLIST =
      const AndroidWebViewFeature._internal("SAFE_BROWSING_ALLOWLIST");

  ///
  static const SAFE_BROWSING_ENABLE =
      const AndroidWebViewFeature._internal("SAFE_BROWSING_ENABLE");

  ///
  static const SAFE_BROWSING_HIT =
      const AndroidWebViewFeature._internal("SAFE_BROWSING_HIT");

  ///
  static const SAFE_BROWSING_PRIVACY_POLICY_URL =
      const AndroidWebViewFeature._internal("SAFE_BROWSING_PRIVACY_POLICY_URL");

  ///
  static const SAFE_BROWSING_RESPONSE_BACK_TO_SAFETY =
      const AndroidWebViewFeature._internal(
          "SAFE_BROWSING_RESPONSE_BACK_TO_SAFETY");

  ///
  static const SAFE_BROWSING_RESPONSE_PROCEED =
      const AndroidWebViewFeature._internal("SAFE_BROWSING_RESPONSE_PROCEED");

  ///
  static const SAFE_BROWSING_RESPONSE_SHOW_INTERSTITIAL =
      const AndroidWebViewFeature._internal(
          "SAFE_BROWSING_RESPONSE_SHOW_INTERSTITIAL");

  ///Use [SAFE_BROWSING_ALLOWLIST] instead.
  @Deprecated('Use `SAFE_BROWSING_ALLOWLIST` instead')
  static const SAFE_BROWSING_WHITELIST =
      const AndroidWebViewFeature._internal("SAFE_BROWSING_WHITELIST");

  ///
  static const SERVICE_WORKER_BASIC_USAGE =
      const AndroidWebViewFeature._internal("SERVICE_WORKER_BASIC_USAGE");

  ///
  static const SERVICE_WORKER_BLOCK_NETWORK_LOADS =
      const AndroidWebViewFeature._internal(
          "SERVICE_WORKER_BLOCK_NETWORK_LOADS");

  ///
  static const SERVICE_WORKER_CACHE_MODE =
      const AndroidWebViewFeature._internal("SERVICE_WORKER_CACHE_MODE");

  ///
  static const SERVICE_WORKER_CONTENT_ACCESS =
      const AndroidWebViewFeature._internal("SERVICE_WORKER_CONTENT_ACCESS");

  ///
  static const SERVICE_WORKER_FILE_ACCESS =
      const AndroidWebViewFeature._internal("SERVICE_WORKER_FILE_ACCESS");

  ///
  static const SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST =
      const AndroidWebViewFeature._internal(
          "SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST");

  ///
  static const SHOULD_OVERRIDE_WITH_REDIRECTS =
      const AndroidWebViewFeature._internal("SHOULD_OVERRIDE_WITH_REDIRECTS");

  ///
  static const START_SAFE_BROWSING =
      const AndroidWebViewFeature._internal("START_SAFE_BROWSING");

  ///
  static const TRACING_CONTROLLER_BASIC_USAGE =
      const AndroidWebViewFeature._internal("TRACING_CONTROLLER_BASIC_USAGE");

  ///
  static const VISUAL_STATE_CALLBACK =
      const AndroidWebViewFeature._internal("VISUAL_STATE_CALLBACK");

  ///
  static const WEB_MESSAGE_CALLBACK_ON_MESSAGE =
      const AndroidWebViewFeature._internal("WEB_MESSAGE_CALLBACK_ON_MESSAGE");

  ///
  static const WEB_MESSAGE_LISTENER =
      const AndroidWebViewFeature._internal("WEB_MESSAGE_LISTENER");

  ///
  static const WEB_MESSAGE_PORT_CLOSE =
      const AndroidWebViewFeature._internal("WEB_MESSAGE_PORT_CLOSE");

  ///
  static const WEB_MESSAGE_PORT_POST_MESSAGE =
      const AndroidWebViewFeature._internal("WEB_MESSAGE_PORT_POST_MESSAGE");

  ///
  static const WEB_MESSAGE_PORT_SET_MESSAGE_CALLBACK =
      const AndroidWebViewFeature._internal(
          "WEB_MESSAGE_PORT_SET_MESSAGE_CALLBACK");

  ///
  static const WEB_RESOURCE_ERROR_GET_CODE =
      const AndroidWebViewFeature._internal("WEB_RESOURCE_ERROR_GET_CODE");

  ///
  static const WEB_RESOURCE_ERROR_GET_DESCRIPTION =
      const AndroidWebViewFeature._internal(
          "WEB_RESOURCE_ERROR_GET_DESCRIPTION");

  ///
  static const WEB_RESOURCE_REQUEST_IS_REDIRECT =
      const AndroidWebViewFeature._internal("WEB_RESOURCE_REQUEST_IS_REDIRECT");

  ///
  static const WEB_VIEW_RENDERER_CLIENT_BASIC_USAGE =
      const AndroidWebViewFeature._internal(
          "WEB_VIEW_RENDERER_CLIENT_BASIC_USAGE");

  ///
  static const WEB_VIEW_RENDERER_TERMINATE =
      const AndroidWebViewFeature._internal("WEB_VIEW_RENDERER_TERMINATE");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;

  ///Return whether a feature is supported at run-time. On devices running Android version `Build.VERSION_CODES.LOLLIPOP` and higher,
  ///this will check whether a feature is supported, depending on the combination of the desired feature, the Android version of device,
  ///and the WebView APK on the device. If running on a device with a lower API level, this will always return `false`.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/WebViewFeature#isFeatureSupported(java.lang.String)
  static Future<bool> isFeatureSupported(AndroidWebViewFeature feature) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("feature", () => feature.toValue());
    return await _channel.invokeMethod('isFeatureSupported', args);
  }
}
