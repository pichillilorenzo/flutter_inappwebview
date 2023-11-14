import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import '../types/proxy_rule.dart';
import 'webview_feature.dart';
import '../in_app_webview/webview.dart';

part 'proxy_controller.g.dart';

///Manages setting and clearing a process-specific override for the Android system-wide proxy settings that govern network requests made by [WebView].
///
///[WebView] may make network requests in order to fetch content that is not otherwise read from the file system or provided directly by application code.
///In this case by default the system-wide Android network proxy settings are used to redirect requests to appropriate proxy servers.
///
///In the rare case that it is necessary for an application to explicitly specify its proxy configuration,
///this API may be used to explicitly specify the proxy rules that govern WebView initiated network requests.
///
///**Supported Platforms/Implementations**:
///- Android native WebView ([Official API - ProxyController](https://developer.android.com/reference/androidx/webkit/ProxyController))
class ProxyController {
  static ProxyController? _instance;
  static const MethodChannel _channel = const MethodChannel(
      'com.pichillilorenzo/flutter_inappwebview_proxycontroller');

  ProxyController._();

  ///Gets the [ProxyController] shared instance.
  ///
  ///This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.PROXY_OVERRIDE].
  static ProxyController instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static ProxyController _init() {
    _channel.setMethodCallHandler((call) async {
      try {
        return await _handleMethod(call);
      } on Error catch (e) {
        print(e);
        print(e.stackTrace);
      }
    });
    _instance = ProxyController._();
    return _instance!;
  }

  static Future<dynamic> _handleMethod(MethodCall call) async {
    // ProxyController controller = ProxyController.instance();
    switch (call.method) {
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
    // return null;
  }

  ///Sets [ProxySettings] which will be used by all [WebView]s in the app.
  ///URLs that match patterns in the bypass list will not be directed to any proxy.
  ///Instead, the request will be made directly to the origin specified by the URL.
  ///Network connections are not guaranteed to immediately use the new proxy setting; wait for the method to return before loading a page.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - ProxyController.setProxyOverride](https://developer.android.com/reference/androidx/webkit/ProxyController#setProxyOverride(androidx.webkit.ProxyConfig,%20java.util.concurrent.Executor,%20java.lang.Runnable)))
  Future<void> setProxyOverride({required ProxySettings settings}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("settings", () => settings.toMap());
    return await _channel.invokeMethod('setProxyOverride', args);
  }

  ///Clears the proxy settings.
  ///Network connections are not guaranteed to immediately use the new proxy setting; wait for the method to return before loading a page.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - ProxyController.clearProxyOverride](https://developer.android.com/reference/androidx/webkit/ProxyController#clearProxyOverride(java.util.concurrent.Executor,%20java.lang.Runnable)))
  Future<void> clearProxyOverride() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('clearProxyOverride', args);
  }
}

///Class that represents the settings used to configure the [ProxyController].
///
///**Supported Platforms/Implementations**:
///- Android native WebView ([Official API - ProxyConfig](https://developer.android.com/reference/androidx/webkit/ProxyConfig))
@ExchangeableObject(copyMethod: true)
class ProxySettings_ {
  ///List of bypass rules.
  ///
  ///A bypass rule describes URLs that should skip proxy override settings and make a direct connection instead. These can be URLs or IP addresses. Wildcards are accepted.
  ///For instance, the rule "*example.com" would mean that requests to "http://example.com" and "www.example.com" would not be directed to any proxy,
  ///instead, would be made directly to the origin specified by the URL.
  List<String> bypassRules;

  ///List of scheme filters.
  ///
  ///URLs that match these scheme filters are connected to directly instead of using a proxy server.
  List<String> directs;

  ///List of proxy rules to be used for all URLs. This method can be called multiple times to add multiple rules. Additional rules have decreasing precedence.
  ///
  ///Proxy is a string in the format `[scheme://]host[:port]`.
  ///Scheme is optional, if present must be `HTTP`, `HTTPS` or [SOCKS](https://tools.ietf.org/html/rfc1928) and defaults to `HTTP`.
  ///Host is one of an IPv6 literal with brackets, an IPv4 literal or one or more labels separated by a period.
  ///Port number is optional and defaults to `80` for `HTTP`, `443` for `HTTPS` and `1080` for `SOCKS`.
  ///
  ///The correct syntax for hosts is defined by [RFC 3986](https://tools.ietf.org/html/rfc3986#section-3.2.2).
  List<ProxyRule_> proxyRules;

  ///Hostnames without a period in them (and that are not IP literals) will skip proxy settings and be connected to directly instead. Examples: `"abc"`, `"local"`, `"some-domain"`.
  ///
  ///Hostnames with a trailing dot are not considered simple by this definition.
  bool? bypassSimpleHostnames;

  ///By default, certain hostnames implicitly bypass the proxy if they are link-local IPs, or localhost addresses.
  ///For instance hostnames matching any of (non-exhaustive list):
  ///- localhost
  ///- *.localhost
  ///- [::1]
  ///- 127.0.0.1/8
  ///- 169.254/16
  ///- [FE80::]/10
  ///Set this to `true` to override the default behavior and force localhost and link-local URLs to be sent through the proxy.
  bool? removeImplicitRules;

  ///Reverse the bypass list.
  ///
  ///The default value is `false`, in which case all URLs will use proxy settings except the ones in the bypass list, which will be connected to directly instead.
  ///
  ///If set to `true`, then only URLs in the bypass list will use these proxy settings, and all other URLs will be connected to directly.
  ///
  ///Use [bypassRules] to add bypass rules.
  ///
  ///**NOTE**: available only if [WebViewFeature.PROXY_OVERRIDE_REVERSE_BYPASS] feature is supported.
  bool reverseBypassEnabled;

  ProxySettings_(
      {this.bypassRules = const [],
      this.directs = const [],
      this.proxyRules = const [],
      this.bypassSimpleHostnames,
      this.removeImplicitRules,
      this.reverseBypassEnabled = false});
}
