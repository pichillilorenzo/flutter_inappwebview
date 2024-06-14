// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_webview_feature.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///{@macro flutter_inappwebview_platform_interface.PlatformWebViewFeature}
class WebViewFeature {
  final String _value;
  final String _nativeValue;
  const WebViewFeature._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory WebViewFeature._internalMultiPlatform(String value, Function nativeValue) =>
      WebViewFeature._internal(value, nativeValue());

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewSettings.algorithmicDarkeningAllowed].
  static const ALGORITHMIC_DARKENING = WebViewFeature._internal('ALGORITHMIC_DARKENING', 'ALGORITHMIC_DARKENING');

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewController.createWebMessageChannel].
  static const CREATE_WEB_MESSAGE_CHANNEL =
      WebViewFeature._internal('CREATE_WEB_MESSAGE_CHANNEL', 'CREATE_WEB_MESSAGE_CHANNEL');

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewSettings.disabledActionModeMenuItems].
  static const DISABLED_ACTION_MODE_MENU_ITEMS =
      WebViewFeature._internal('DISABLED_ACTION_MODE_MENU_ITEMS', 'DISABLED_ACTION_MODE_MENU_ITEMS');

  ///Feature for [isFeatureSupported]. This feature covers [UserScriptInjectionTime.AT_DOCUMENT_START].
  static const DOCUMENT_START_SCRIPT = WebViewFeature._internal('DOCUMENT_START_SCRIPT', 'DOCUMENT_START_SCRIPT');

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewSettings.enterpriseAuthenticationAppLinkPolicyEnabled].
  static const ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY = WebViewFeature._internal(
      'ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY', 'ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY');

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewSettings.forceDark].
  static const FORCE_DARK = WebViewFeature._internal('FORCE_DARK', 'FORCE_DARK');

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewSettings.forceDarkStrategy].
  static const FORCE_DARK_STRATEGY = WebViewFeature._internal('FORCE_DARK_STRATEGY', 'FORCE_DARK_STRATEGY');

  ///Feature for [isFeatureSupported]. This feature covers cookie attributes of [CookieManager.getCookie] and [CookieManager.getCookies] methods.
  static const GET_COOKIE_INFO = WebViewFeature._internal('GET_COOKIE_INFO', 'GET_COOKIE_INFO');

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewController.getVariationsHeader].
  static const GET_VARIATIONS_HEADER = WebViewFeature._internal('GET_VARIATIONS_HEADER', 'GET_VARIATIONS_HEADER');

  ///
  static const GET_WEB_CHROME_CLIENT = WebViewFeature._internal('GET_WEB_CHROME_CLIENT', 'GET_WEB_CHROME_CLIENT');

  ///
  static const GET_WEB_VIEW_CLIENT = WebViewFeature._internal('GET_WEB_VIEW_CLIENT', 'GET_WEB_VIEW_CLIENT');

  ///
  static const GET_WEB_VIEW_RENDERER = WebViewFeature._internal('GET_WEB_VIEW_RENDERER', 'GET_WEB_VIEW_RENDERER');

  ///
  static const MULTI_PROCESS = WebViewFeature._internal('MULTI_PROCESS', 'MULTI_PROCESS');

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewSettings.offscreenPreRaster].
  static const OFF_SCREEN_PRERASTER = WebViewFeature._internal('OFF_SCREEN_PRERASTER', 'OFF_SCREEN_PRERASTER');

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewController.postWebMessage].
  static const POST_WEB_MESSAGE = WebViewFeature._internal('POST_WEB_MESSAGE', 'POST_WEB_MESSAGE');

  ///Feature for [isFeatureSupported]. This feature covers [ProxyController.setProxyOverride] and [ProxyController.clearProxyOverride].
  static const PROXY_OVERRIDE = WebViewFeature._internal('PROXY_OVERRIDE', 'PROXY_OVERRIDE');

  ///Feature for [isFeatureSupported]. This feature covers [ProxySettings.reverseBypassEnabled].
  static const PROXY_OVERRIDE_REVERSE_BYPASS =
      WebViewFeature._internal('PROXY_OVERRIDE_REVERSE_BYPASS', 'PROXY_OVERRIDE_REVERSE_BYPASS');

  ///
  static const RECEIVE_HTTP_ERROR = WebViewFeature._internal('RECEIVE_HTTP_ERROR', 'RECEIVE_HTTP_ERROR');

  ///
  static const RECEIVE_WEB_RESOURCE_ERROR =
      WebViewFeature._internal('RECEIVE_WEB_RESOURCE_ERROR', 'RECEIVE_WEB_RESOURCE_ERROR');

  ///Feature for [isFeatureSupported]. This feature covers cookie attributes of [CookieManager.getCookie] and [CookieManager.getCookies] methods.
  static const REQUESTED_WITH_HEADER_ALLOW_LIST =
      WebViewFeature._internal('REQUESTED_WITH_HEADER_ALLOW_LIST', 'REQUESTED_WITH_HEADER_ALLOW_LIST');

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewController.setSafeBrowsingAllowlist].
  static const SAFE_BROWSING_ALLOWLIST = WebViewFeature._internal('SAFE_BROWSING_ALLOWLIST', 'SAFE_BROWSING_ALLOWLIST');

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewSettings.safeBrowsingEnabled].
  static const SAFE_BROWSING_ENABLE = WebViewFeature._internal('SAFE_BROWSING_ENABLE', 'SAFE_BROWSING_ENABLE');

  ///
  static const SAFE_BROWSING_HIT = WebViewFeature._internal('SAFE_BROWSING_HIT', 'SAFE_BROWSING_HIT');

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewController.getSafeBrowsingPrivacyPolicyUrl].
  static const SAFE_BROWSING_PRIVACY_POLICY_URL =
      WebViewFeature._internal('SAFE_BROWSING_PRIVACY_POLICY_URL', 'SAFE_BROWSING_PRIVACY_POLICY_URL');

  ///
  static const SAFE_BROWSING_RESPONSE_BACK_TO_SAFETY =
      WebViewFeature._internal('SAFE_BROWSING_RESPONSE_BACK_TO_SAFETY', 'SAFE_BROWSING_RESPONSE_BACK_TO_SAFETY');

  ///
  static const SAFE_BROWSING_RESPONSE_PROCEED =
      WebViewFeature._internal('SAFE_BROWSING_RESPONSE_PROCEED', 'SAFE_BROWSING_RESPONSE_PROCEED');

  ///
  static const SAFE_BROWSING_RESPONSE_SHOW_INTERSTITIAL =
      WebViewFeature._internal('SAFE_BROWSING_RESPONSE_SHOW_INTERSTITIAL', 'SAFE_BROWSING_RESPONSE_SHOW_INTERSTITIAL');

  ///Use [SAFE_BROWSING_ALLOWLIST] instead.
  static const SAFE_BROWSING_WHITELIST = WebViewFeature._internal('SAFE_BROWSING_WHITELIST', 'SAFE_BROWSING_WHITELIST');

  ///Feature for [isFeatureSupported]. This feature covers [ServiceWorkerController].
  static const SERVICE_WORKER_BASIC_USAGE =
      WebViewFeature._internal('SERVICE_WORKER_BASIC_USAGE', 'SERVICE_WORKER_BASIC_USAGE');

  ///Feature for [isFeatureSupported]. This feature covers [ServiceWorkerController.setBlockNetworkLoads] and [ServiceWorkerController.getBlockNetworkLoads].
  static const SERVICE_WORKER_BLOCK_NETWORK_LOADS =
      WebViewFeature._internal('SERVICE_WORKER_BLOCK_NETWORK_LOADS', 'SERVICE_WORKER_BLOCK_NETWORK_LOADS');

  ///Feature for [isFeatureSupported]. This feature covers [ServiceWorkerController.setCacheMode] and [ServiceWorkerController.getCacheMode].
  static const SERVICE_WORKER_CACHE_MODE =
      WebViewFeature._internal('SERVICE_WORKER_CACHE_MODE', 'SERVICE_WORKER_CACHE_MODE');

  ///Feature for [isFeatureSupported]. This feature covers [ServiceWorkerController.setAllowContentAccess] and [ServiceWorkerController.getAllowContentAccess].
  static const SERVICE_WORKER_CONTENT_ACCESS =
      WebViewFeature._internal('SERVICE_WORKER_CONTENT_ACCESS', 'SERVICE_WORKER_CONTENT_ACCESS');

  ///Feature for [isFeatureSupported]. This feature covers [ServiceWorkerController.setAllowFileAccess] and [ServiceWorkerController.getAllowFileAccess].
  static const SERVICE_WORKER_FILE_ACCESS =
      WebViewFeature._internal('SERVICE_WORKER_FILE_ACCESS', 'SERVICE_WORKER_FILE_ACCESS');

  ///Feature for [isFeatureSupported]. This feature covers [ServiceWorkerClient.shouldInterceptRequest].
  static const SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST =
      WebViewFeature._internal('SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST', 'SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST');

  ///
  static const SHOULD_OVERRIDE_WITH_REDIRECTS =
      WebViewFeature._internal('SHOULD_OVERRIDE_WITH_REDIRECTS', 'SHOULD_OVERRIDE_WITH_REDIRECTS');

  ///Feature for [isStartupFeatureSupported]. This feature covers [ProcessGlobalConfigSettings.dataDirectorySuffix].
  static const STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX = WebViewFeature._internal(
      'STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX', 'STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX');

  ///Feature for [isStartupFeatureSupported]. This feature covers [ProcessGlobalConfigSettings.directoryBasePaths].
  static const STARTUP_FEATURE_SET_DIRECTORY_BASE_PATHS =
      WebViewFeature._internal('STARTUP_FEATURE_SET_DIRECTORY_BASE_PATHS', 'STARTUP_FEATURE_SET_DIRECTORY_BASE_PATHS');

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewController.startSafeBrowsing].
  static const START_SAFE_BROWSING = WebViewFeature._internal('START_SAFE_BROWSING', 'START_SAFE_BROWSING');

  ///
  static const TRACING_CONTROLLER_BASIC_USAGE =
      WebViewFeature._internal('TRACING_CONTROLLER_BASIC_USAGE', 'TRACING_CONTROLLER_BASIC_USAGE');

  ///
  static const VISUAL_STATE_CALLBACK = WebViewFeature._internal('VISUAL_STATE_CALLBACK', 'VISUAL_STATE_CALLBACK');

  ///Feature for [isFeatureSupported]. This feature covers [WebMessagePort.postMessage] with `ArrayBuffer` type,
  ///[InAppWebViewController.postWebMessage] with `ArrayBuffer` type, and [JavaScriptReplyProxy.postMessage] with `ArrayBuffer` type.
  static const WEB_MESSAGE_ARRAY_BUFFER =
      WebViewFeature._internal('WEB_MESSAGE_ARRAY_BUFFER', 'WEB_MESSAGE_ARRAY_BUFFER');

  ///
  static const WEB_MESSAGE_CALLBACK_ON_MESSAGE =
      WebViewFeature._internal('WEB_MESSAGE_CALLBACK_ON_MESSAGE', 'WEB_MESSAGE_CALLBACK_ON_MESSAGE');

  ///Feature for [isFeatureSupported]. This feature covers [WebMessageListener].
  static const WEB_MESSAGE_LISTENER = WebViewFeature._internal('WEB_MESSAGE_LISTENER', 'WEB_MESSAGE_LISTENER');

  ///
  static const WEB_MESSAGE_PORT_CLOSE = WebViewFeature._internal('WEB_MESSAGE_PORT_CLOSE', 'WEB_MESSAGE_PORT_CLOSE');

  ///
  static const WEB_MESSAGE_PORT_POST_MESSAGE =
      WebViewFeature._internal('WEB_MESSAGE_PORT_POST_MESSAGE', 'WEB_MESSAGE_PORT_POST_MESSAGE');

  ///
  static const WEB_MESSAGE_PORT_SET_MESSAGE_CALLBACK =
      WebViewFeature._internal('WEB_MESSAGE_PORT_SET_MESSAGE_CALLBACK', 'WEB_MESSAGE_PORT_SET_MESSAGE_CALLBACK');

  ///
  static const WEB_RESOURCE_ERROR_GET_CODE =
      WebViewFeature._internal('WEB_RESOURCE_ERROR_GET_CODE', 'WEB_RESOURCE_ERROR_GET_CODE');

  ///
  static const WEB_RESOURCE_ERROR_GET_DESCRIPTION =
      WebViewFeature._internal('WEB_RESOURCE_ERROR_GET_DESCRIPTION', 'WEB_RESOURCE_ERROR_GET_DESCRIPTION');

  ///
  static const WEB_RESOURCE_REQUEST_IS_REDIRECT =
      WebViewFeature._internal('WEB_RESOURCE_REQUEST_IS_REDIRECT', 'WEB_RESOURCE_REQUEST_IS_REDIRECT');

  ///
  static const WEB_VIEW_RENDERER_CLIENT_BASIC_USAGE =
      WebViewFeature._internal('WEB_VIEW_RENDERER_CLIENT_BASIC_USAGE', 'WEB_VIEW_RENDERER_CLIENT_BASIC_USAGE');

  ///
  static const WEB_VIEW_RENDERER_TERMINATE =
      WebViewFeature._internal('WEB_VIEW_RENDERER_TERMINATE', 'WEB_VIEW_RENDERER_TERMINATE');

  ///Set of all values of [WebViewFeature].
  static final Set<WebViewFeature> values = [
    WebViewFeature.ALGORITHMIC_DARKENING,
    WebViewFeature.CREATE_WEB_MESSAGE_CHANNEL,
    WebViewFeature.DISABLED_ACTION_MODE_MENU_ITEMS,
    WebViewFeature.DOCUMENT_START_SCRIPT,
    WebViewFeature.ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY,
    WebViewFeature.FORCE_DARK,
    WebViewFeature.FORCE_DARK_STRATEGY,
    WebViewFeature.GET_COOKIE_INFO,
    WebViewFeature.GET_VARIATIONS_HEADER,
    WebViewFeature.GET_WEB_CHROME_CLIENT,
    WebViewFeature.GET_WEB_VIEW_CLIENT,
    WebViewFeature.GET_WEB_VIEW_RENDERER,
    WebViewFeature.MULTI_PROCESS,
    WebViewFeature.OFF_SCREEN_PRERASTER,
    WebViewFeature.POST_WEB_MESSAGE,
    WebViewFeature.PROXY_OVERRIDE,
    WebViewFeature.PROXY_OVERRIDE_REVERSE_BYPASS,
    WebViewFeature.RECEIVE_HTTP_ERROR,
    WebViewFeature.RECEIVE_WEB_RESOURCE_ERROR,
    WebViewFeature.REQUESTED_WITH_HEADER_ALLOW_LIST,
    WebViewFeature.SAFE_BROWSING_ALLOWLIST,
    WebViewFeature.SAFE_BROWSING_ENABLE,
    WebViewFeature.SAFE_BROWSING_HIT,
    WebViewFeature.SAFE_BROWSING_PRIVACY_POLICY_URL,
    WebViewFeature.SAFE_BROWSING_RESPONSE_BACK_TO_SAFETY,
    WebViewFeature.SAFE_BROWSING_RESPONSE_PROCEED,
    WebViewFeature.SAFE_BROWSING_RESPONSE_SHOW_INTERSTITIAL,
    WebViewFeature.SAFE_BROWSING_WHITELIST,
    WebViewFeature.SERVICE_WORKER_BASIC_USAGE,
    WebViewFeature.SERVICE_WORKER_BLOCK_NETWORK_LOADS,
    WebViewFeature.SERVICE_WORKER_CACHE_MODE,
    WebViewFeature.SERVICE_WORKER_CONTENT_ACCESS,
    WebViewFeature.SERVICE_WORKER_FILE_ACCESS,
    WebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST,
    WebViewFeature.SHOULD_OVERRIDE_WITH_REDIRECTS,
    WebViewFeature.STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX,
    WebViewFeature.STARTUP_FEATURE_SET_DIRECTORY_BASE_PATHS,
    WebViewFeature.START_SAFE_BROWSING,
    WebViewFeature.TRACING_CONTROLLER_BASIC_USAGE,
    WebViewFeature.VISUAL_STATE_CALLBACK,
    WebViewFeature.WEB_MESSAGE_ARRAY_BUFFER,
    WebViewFeature.WEB_MESSAGE_CALLBACK_ON_MESSAGE,
    WebViewFeature.WEB_MESSAGE_LISTENER,
    WebViewFeature.WEB_MESSAGE_PORT_CLOSE,
    WebViewFeature.WEB_MESSAGE_PORT_POST_MESSAGE,
    WebViewFeature.WEB_MESSAGE_PORT_SET_MESSAGE_CALLBACK,
    WebViewFeature.WEB_RESOURCE_ERROR_GET_CODE,
    WebViewFeature.WEB_RESOURCE_ERROR_GET_DESCRIPTION,
    WebViewFeature.WEB_RESOURCE_REQUEST_IS_REDIRECT,
    WebViewFeature.WEB_VIEW_RENDERER_CLIENT_BASIC_USAGE,
    WebViewFeature.WEB_VIEW_RENDERER_TERMINATE,
  ].toSet();

  ///Gets a possible [WebViewFeature] instance from [String] value.
  static WebViewFeature? fromValue(String? value) {
    if (value != null) {
      try {
        return WebViewFeature.values.firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [WebViewFeature] instance from a native value.
  static WebViewFeature? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return WebViewFeature.values.firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewFeature.isFeatureSupported}
  static Future<bool> isFeatureSupported(WebViewFeature feature) =>
      PlatformWebViewFeature.static().isFeatureSupported(feature);

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewFeature.isStartupFeatureSupported}
  static Future<bool> isStartupFeatureSupported(WebViewFeature startupFeature) =>
      PlatformWebViewFeature.static().isStartupFeatureSupported(startupFeature);

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value.
  String toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    return _value;
  }
}

///Class that represents an Android-specific utility class for checking which WebView Support Library features are supported on the device.
///Use [WebViewFeature] instead.
@Deprecated('Use WebViewFeature instead')
class AndroidWebViewFeature {
  final String _value;
  final String _nativeValue;
  const AndroidWebViewFeature._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory AndroidWebViewFeature._internalMultiPlatform(String value, Function nativeValue) =>
      AndroidWebViewFeature._internal(value, nativeValue());

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewSettings.algorithmicDarkeningAllowed].
  static const ALGORITHMIC_DARKENING =
      AndroidWebViewFeature._internal('ALGORITHMIC_DARKENING', 'ALGORITHMIC_DARKENING');

  ///
  static const CREATE_WEB_MESSAGE_CHANNEL =
      AndroidWebViewFeature._internal('CREATE_WEB_MESSAGE_CHANNEL', 'CREATE_WEB_MESSAGE_CHANNEL');

  ///
  static const DISABLED_ACTION_MODE_MENU_ITEMS =
      AndroidWebViewFeature._internal('DISABLED_ACTION_MODE_MENU_ITEMS', 'DISABLED_ACTION_MODE_MENU_ITEMS');

  ///Feature for [isFeatureSupported]. This feature covers [UserScriptInjectionTime.AT_DOCUMENT_START].
  static const DOCUMENT_START_SCRIPT =
      AndroidWebViewFeature._internal('DOCUMENT_START_SCRIPT', 'DOCUMENT_START_SCRIPT');

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewSettings.enterpriseAuthenticationAppLinkPolicyEnabled].
  static const ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY = AndroidWebViewFeature._internal(
      'ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY', 'ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY');

  ///
  static const FORCE_DARK = AndroidWebViewFeature._internal('FORCE_DARK', 'FORCE_DARK');

  ///
  static const FORCE_DARK_STRATEGY = AndroidWebViewFeature._internal('FORCE_DARK_STRATEGY', 'FORCE_DARK_STRATEGY');

  ///
  static const GET_WEB_CHROME_CLIENT =
      AndroidWebViewFeature._internal('GET_WEB_CHROME_CLIENT', 'GET_WEB_CHROME_CLIENT');

  ///
  static const GET_WEB_VIEW_CLIENT = AndroidWebViewFeature._internal('GET_WEB_VIEW_CLIENT', 'GET_WEB_VIEW_CLIENT');

  ///
  static const GET_WEB_VIEW_RENDERER =
      AndroidWebViewFeature._internal('GET_WEB_VIEW_RENDERER', 'GET_WEB_VIEW_RENDERER');

  ///
  static const MULTI_PROCESS = AndroidWebViewFeature._internal('MULTI_PROCESS', 'MULTI_PROCESS');

  ///
  static const OFF_SCREEN_PRERASTER = AndroidWebViewFeature._internal('OFF_SCREEN_PRERASTER', 'OFF_SCREEN_PRERASTER');

  ///
  static const POST_WEB_MESSAGE = AndroidWebViewFeature._internal('POST_WEB_MESSAGE', 'POST_WEB_MESSAGE');

  ///
  static const PROXY_OVERRIDE = AndroidWebViewFeature._internal('PROXY_OVERRIDE', 'PROXY_OVERRIDE');

  ///
  static const RECEIVE_HTTP_ERROR = AndroidWebViewFeature._internal('RECEIVE_HTTP_ERROR', 'RECEIVE_HTTP_ERROR');

  ///
  static const RECEIVE_WEB_RESOURCE_ERROR =
      AndroidWebViewFeature._internal('RECEIVE_WEB_RESOURCE_ERROR', 'RECEIVE_WEB_RESOURCE_ERROR');

  ///Feature for [isFeatureSupported]. This feature covers [InAppWebViewSettings.requestedWithHeaderMode].
  static const REQUESTED_WITH_HEADER_CONTROL =
      AndroidWebViewFeature._internal('REQUESTED_WITH_HEADER_CONTROL', 'REQUESTED_WITH_HEADER_CONTROL');

  ///
  static const SAFE_BROWSING_ALLOWLIST =
      AndroidWebViewFeature._internal('SAFE_BROWSING_ALLOWLIST', 'SAFE_BROWSING_ALLOWLIST');

  ///
  static const SAFE_BROWSING_ENABLE = AndroidWebViewFeature._internal('SAFE_BROWSING_ENABLE', 'SAFE_BROWSING_ENABLE');

  ///
  static const SAFE_BROWSING_HIT = AndroidWebViewFeature._internal('SAFE_BROWSING_HIT', 'SAFE_BROWSING_HIT');

  ///
  static const SAFE_BROWSING_PRIVACY_POLICY_URL =
      AndroidWebViewFeature._internal('SAFE_BROWSING_PRIVACY_POLICY_URL', 'SAFE_BROWSING_PRIVACY_POLICY_URL');

  ///
  static const SAFE_BROWSING_RESPONSE_BACK_TO_SAFETY =
      AndroidWebViewFeature._internal('SAFE_BROWSING_RESPONSE_BACK_TO_SAFETY', 'SAFE_BROWSING_RESPONSE_BACK_TO_SAFETY');

  ///
  static const SAFE_BROWSING_RESPONSE_PROCEED =
      AndroidWebViewFeature._internal('SAFE_BROWSING_RESPONSE_PROCEED', 'SAFE_BROWSING_RESPONSE_PROCEED');

  ///
  static const SAFE_BROWSING_RESPONSE_SHOW_INTERSTITIAL = AndroidWebViewFeature._internal(
      'SAFE_BROWSING_RESPONSE_SHOW_INTERSTITIAL', 'SAFE_BROWSING_RESPONSE_SHOW_INTERSTITIAL');

  ///Use [SAFE_BROWSING_ALLOWLIST] instead.
  static const SAFE_BROWSING_WHITELIST =
      AndroidWebViewFeature._internal('SAFE_BROWSING_WHITELIST', 'SAFE_BROWSING_WHITELIST');

  ///
  static const SERVICE_WORKER_BASIC_USAGE =
      AndroidWebViewFeature._internal('SERVICE_WORKER_BASIC_USAGE', 'SERVICE_WORKER_BASIC_USAGE');

  ///
  static const SERVICE_WORKER_BLOCK_NETWORK_LOADS =
      AndroidWebViewFeature._internal('SERVICE_WORKER_BLOCK_NETWORK_LOADS', 'SERVICE_WORKER_BLOCK_NETWORK_LOADS');

  ///
  static const SERVICE_WORKER_CACHE_MODE =
      AndroidWebViewFeature._internal('SERVICE_WORKER_CACHE_MODE', 'SERVICE_WORKER_CACHE_MODE');

  ///
  static const SERVICE_WORKER_CONTENT_ACCESS =
      AndroidWebViewFeature._internal('SERVICE_WORKER_CONTENT_ACCESS', 'SERVICE_WORKER_CONTENT_ACCESS');

  ///
  static const SERVICE_WORKER_FILE_ACCESS =
      AndroidWebViewFeature._internal('SERVICE_WORKER_FILE_ACCESS', 'SERVICE_WORKER_FILE_ACCESS');

  ///
  static const SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST = AndroidWebViewFeature._internal(
      'SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST', 'SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST');

  ///
  static const SHOULD_OVERRIDE_WITH_REDIRECTS =
      AndroidWebViewFeature._internal('SHOULD_OVERRIDE_WITH_REDIRECTS', 'SHOULD_OVERRIDE_WITH_REDIRECTS');

  ///
  static const START_SAFE_BROWSING = AndroidWebViewFeature._internal('START_SAFE_BROWSING', 'START_SAFE_BROWSING');

  ///
  static const TRACING_CONTROLLER_BASIC_USAGE =
      AndroidWebViewFeature._internal('TRACING_CONTROLLER_BASIC_USAGE', 'TRACING_CONTROLLER_BASIC_USAGE');

  ///
  static const VISUAL_STATE_CALLBACK =
      AndroidWebViewFeature._internal('VISUAL_STATE_CALLBACK', 'VISUAL_STATE_CALLBACK');

  ///
  static const WEB_MESSAGE_CALLBACK_ON_MESSAGE =
      AndroidWebViewFeature._internal('WEB_MESSAGE_CALLBACK_ON_MESSAGE', 'WEB_MESSAGE_CALLBACK_ON_MESSAGE');

  ///
  static const WEB_MESSAGE_LISTENER = AndroidWebViewFeature._internal('WEB_MESSAGE_LISTENER', 'WEB_MESSAGE_LISTENER');

  ///
  static const WEB_MESSAGE_PORT_CLOSE =
      AndroidWebViewFeature._internal('WEB_MESSAGE_PORT_CLOSE', 'WEB_MESSAGE_PORT_CLOSE');

  ///
  static const WEB_MESSAGE_PORT_POST_MESSAGE =
      AndroidWebViewFeature._internal('WEB_MESSAGE_PORT_POST_MESSAGE', 'WEB_MESSAGE_PORT_POST_MESSAGE');

  ///
  static const WEB_MESSAGE_PORT_SET_MESSAGE_CALLBACK =
      AndroidWebViewFeature._internal('WEB_MESSAGE_PORT_SET_MESSAGE_CALLBACK', 'WEB_MESSAGE_PORT_SET_MESSAGE_CALLBACK');

  ///
  static const WEB_RESOURCE_ERROR_GET_CODE =
      AndroidWebViewFeature._internal('WEB_RESOURCE_ERROR_GET_CODE', 'WEB_RESOURCE_ERROR_GET_CODE');

  ///
  static const WEB_RESOURCE_ERROR_GET_DESCRIPTION =
      AndroidWebViewFeature._internal('WEB_RESOURCE_ERROR_GET_DESCRIPTION', 'WEB_RESOURCE_ERROR_GET_DESCRIPTION');

  ///
  static const WEB_RESOURCE_REQUEST_IS_REDIRECT =
      AndroidWebViewFeature._internal('WEB_RESOURCE_REQUEST_IS_REDIRECT', 'WEB_RESOURCE_REQUEST_IS_REDIRECT');

  ///
  static const WEB_VIEW_RENDERER_CLIENT_BASIC_USAGE =
      AndroidWebViewFeature._internal('WEB_VIEW_RENDERER_CLIENT_BASIC_USAGE', 'WEB_VIEW_RENDERER_CLIENT_BASIC_USAGE');

  ///
  static const WEB_VIEW_RENDERER_TERMINATE =
      AndroidWebViewFeature._internal('WEB_VIEW_RENDERER_TERMINATE', 'WEB_VIEW_RENDERER_TERMINATE');

  ///Set of all values of [AndroidWebViewFeature].
  static final Set<AndroidWebViewFeature> values = [
    AndroidWebViewFeature.ALGORITHMIC_DARKENING,
    AndroidWebViewFeature.CREATE_WEB_MESSAGE_CHANNEL,
    AndroidWebViewFeature.DISABLED_ACTION_MODE_MENU_ITEMS,
    AndroidWebViewFeature.DOCUMENT_START_SCRIPT,
    AndroidWebViewFeature.ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY,
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
    AndroidWebViewFeature.REQUESTED_WITH_HEADER_CONTROL,
    AndroidWebViewFeature.SAFE_BROWSING_ALLOWLIST,
    AndroidWebViewFeature.SAFE_BROWSING_ENABLE,
    AndroidWebViewFeature.SAFE_BROWSING_HIT,
    AndroidWebViewFeature.SAFE_BROWSING_PRIVACY_POLICY_URL,
    AndroidWebViewFeature.SAFE_BROWSING_RESPONSE_BACK_TO_SAFETY,
    AndroidWebViewFeature.SAFE_BROWSING_RESPONSE_PROCEED,
    AndroidWebViewFeature.SAFE_BROWSING_RESPONSE_SHOW_INTERSTITIAL,
    AndroidWebViewFeature.SAFE_BROWSING_WHITELIST,
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

  ///Gets a possible [AndroidWebViewFeature] instance from [String] value.
  static AndroidWebViewFeature? fromValue(String? value) {
    if (value != null) {
      try {
        return AndroidWebViewFeature.values.firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [AndroidWebViewFeature] instance from a native value.
  static AndroidWebViewFeature? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return AndroidWebViewFeature.values.firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Return whether a feature is supported at run-time. On devices running Android version `Build.VERSION_CODES.LOLLIPOP` and higher,
  ///this will check whether a feature is supported, depending on the combination of the desired feature, the Android version of device,
  ///and the WebView APK on the device. If running on a device with a lower API level, this will always return `false`.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/WebViewFeature#isFeatureSupported(java.lang.String)
  static Future<bool> isFeatureSupported(AndroidWebViewFeature feature) =>
      PlatformWebViewFeature.static().isFeatureSupported(WebViewFeature.fromNativeValue(feature.toNativeValue())!);

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value.
  String toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    return _value;
  }
}
