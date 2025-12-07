import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'inappwebview_platform.dart';
import 'platform_webview_feature.dart';
import 'types/enum_method.dart';
import 'types/proxy_rule.dart';

part 'platform_proxy_controller.g.dart';

///{@template flutter_inappwebview_platform_interface.PlatformProxyControllerCreationParams}
/// Object specifying creation parameters for creating a [PlatformProxyController].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformProxyControllerCreationParams.supported_platforms}
@SupportedPlatforms(platforms: [
  AndroidPlatform(),
  IOSPlatform(),
  MacOSPlatform(),
])
@immutable
class PlatformProxyControllerCreationParams {
  /// Used by the platform implementation to create a new [PlatformProxyController].
  const PlatformProxyControllerCreationParams();

  ///{@template flutter_inappwebview_platform_interface.PlatformProxyControllerCreationParams.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformProxyControllerCreationParamsClassSupported.isClassSupported(
          platform: platform);
}

///{@template flutter_inappwebview_platform_interface.PlatformProxyController}
///Manages setting and clearing a process-specific override for the WebView system-wide proxy settings that govern network requests made by `WebView`.
///
///`WebView` may make network requests in order to fetch content that is not otherwise read from the file system or provided directly by application code.
///In this case by default the system-wide network proxy settings are used to redirect requests to appropriate proxy servers.
///
///In the rare case that it is necessary for an application to explicitly specify its proxy configuration,
///this API may be used to explicitly specify the proxy rules that govern WebView initiated network requests.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformProxyController.supported_platforms}
@SupportedPlatforms(platforms: [
  AndroidPlatform(
    apiName: 'ProxyController',
    apiUrl:
        'https://developer.android.com/reference/androidx/webkit/ProxyController',
  ),
  IOSPlatform(
      apiName: 'WKWebsiteDataStore.proxyConfigurations',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4264546-proxyconfigurations',
      available: '17.0'),
  MacOSPlatform(
      apiName: 'WKWebsiteDataStore.proxyConfigurations',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4264546-proxyconfigurations',
      available: '14.0'),
])
abstract class PlatformProxyController extends PlatformInterface {
  /// Creates a new [PlatformProxyController]
  factory PlatformProxyController(
      PlatformProxyControllerCreationParams params) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`WebViewPlatform.instance` before use. For unit testing, '
      '`WebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformProxyController proxyController =
        InAppWebViewPlatform.instance!.createPlatformProxyController(params);
    PlatformInterface.verify(proxyController, _token);
    return proxyController;
  }

  /// Creates a new [PlatformProxyController] to access static methods.
  factory PlatformProxyController.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformProxyController proxyControllerStatic =
        InAppWebViewPlatform.instance!.createPlatformProxyControllerStatic();
    PlatformInterface.verify(proxyControllerStatic, _token);
    return proxyControllerStatic;
  }

  /// Used by the platform implementation to create a new
  /// [PlatformProxyController].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformProxyController.implementation(this.params) : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformProxyController].
  final PlatformProxyControllerCreationParams params;

  ///{@template flutter_inappwebview_platform_interface.PlatformProxyController.setProxyOverride}
  ///Sets [ProxySettings] which will be used by all `WebView`s in the app.
  ///URLs that match patterns in the bypass list will not be directed to any proxy.
  ///Instead, the request will be made directly to the origin specified by the URL.
  ///Network connections are not guaranteed to immediately use the new proxy setting; wait for the method to return before loading a page.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformProxyController.setProxyOverride.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
        apiName: 'ProxyController.setProxyOverride',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/ProxyController#setProxyOverride(androidx.webkit.ProxyConfig,%20java.util.concurrent.Executor,%20java.lang.Runnable)'),
    IOSPlatform(
      apiName: 'WKWebsiteDataStore.proxyConfigurations',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4264546-proxyconfigurations',
      available: '17.0',
    ),
    MacOSPlatform(
      apiName: 'WKWebsiteDataStore.proxyConfigurations',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4264546-proxyconfigurations',
      available: '14.0',
    ),
  ])
  Future<void> setProxyOverride({required ProxySettings settings}) {
    throw UnimplementedError(
        'setProxyOverride is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformProxyController.clearProxyOverride}
  ///Clears the proxy settings.
  ///Network connections are not guaranteed to immediately use the new proxy setting;
  ///wait for the method to return before loading a page.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformProxyController.clearProxyOverride.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
        apiName: 'ProxyController.clearProxyOverride',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/ProxyController#clearProxyOverride(java.util.concurrent.Executor,%20java.lang.Runnable)'),
    IOSPlatform(
      apiName: 'WKWebsiteDataStore.proxyConfigurations',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4264546-proxyconfigurations',
      available: '17.0',
    ),
    MacOSPlatform(
      apiName: 'WKWebsiteDataStore.proxyConfigurations',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4264546-proxyconfigurations',
      available: '14.0',
    ),
  ])
  Future<void> clearProxyOverride() {
    throw UnimplementedError(
        'clearProxyOverride is not implemented on the current platform');
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformProxyControllerCreationParams.isClassSupported}
  bool isClassSupported({TargetPlatform? platform}) =>
      params.isClassSupported(platform: platform);

  ///{@template flutter_inappwebview_platform_interface.PlatformProxyController.isMethodSupported}
  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isMethodSupported(PlatformProxyControllerMethod method,
          {TargetPlatform? platform}) =>
      _PlatformProxyControllerMethodSupported.isMethodSupported(method,
          platform: platform);
}

///{@template flutter_inappwebview_platform_interface.ProxySettings}
///Class that represents the settings used to configure the [PlatformProxyController].
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.ProxySettings.supported_platforms}
@SupportedPlatforms(platforms: [
  AndroidPlatform(
      apiName: 'ProxyConfig',
      apiUrl:
          'https://developer.android.com/reference/androidx/webkit/ProxyConfig'),
  IOSPlatform(
    apiName: 'ProxyConfiguration',
    apiUrl:
        'https://developer.apple.com/documentation/network/proxyconfiguration',
    available: '17.0',
  ),
  MacOSPlatform(
    apiName: 'ProxyConfiguration',
    apiUrl:
        'https://developer.apple.com/documentation/network/proxyconfiguration',
    available: '14.0',
  ),
])
@ExchangeableObject(copyMethod: true)
class ProxySettings_ {
  ///List of bypass rules.
  ///
  ///A bypass rule describes URLs that should skip proxy override settings and make a direct connection instead. These can be URLs or IP addresses. Wildcards are accepted.
  ///For instance, the rule "*example.com" would mean that requests to "http://example.com" and "www.example.com" would not be directed to any proxy,
  ///instead, would be made directly to the origin specified by the URL.
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
  ])
  List<String> bypassRules;

  ///List of scheme filters.
  ///
  ///URLs that match these scheme filters are connected to directly instead of using a proxy server.
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
  ])
  List<String> directs;

  ///List of proxy rules to be used for all URLs. Additional rules have decreasing precedence.
  ///
  ///Proxy is a string in the format `[scheme://]host[:port]`.
  ///Scheme is optional, if present must be `HTTP`, `HTTPS` or [SOCKS](https://tools.ietf.org/html/rfc1928) and defaults to `HTTP`.
  ///Host is one of an IPv6 literal with brackets, an IPv4 literal or one or more labels separated by a period.
  ///Port number is optional and defaults to `80` for `HTTP`, `443` for `HTTPS` and `1080` for `SOCKS`.
  ///
  ///The correct syntax for hosts is defined by [RFC 3986](https://tools.ietf.org/html/rfc3986#section-3.2.2).
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
  ])
  List<ProxyRule_> proxyRules;

  ///Hostnames without a period in them (and that are not IP literals) will skip proxy settings and be connected to directly instead. Examples: `"abc"`, `"local"`, `"some-domain"`.
  ///
  ///Hostnames with a trailing dot are not considered simple by this definition.
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
  ])
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
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
  ])
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
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
  ])
  bool reverseBypassEnabled;

  ProxySettings_(
      {this.bypassRules = const [],
      this.directs = const [],
      this.proxyRules = const [],
      this.bypassSimpleHostnames,
      this.removeImplicitRules,
      this.reverseBypassEnabled = false});

  ///{@template flutter_inappwebview_platform_interface.ProxySettings.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) =>
      _ProxySettingsClassSupported.isClassSupported(platform: platform);

  ///{@template flutter_inappwebview_platform_interface.ProxySettings.isPropertySupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  static bool isPropertySupported(ProxySettingsProperty property,
          {TargetPlatform? platform}) =>
      _ProxySettingsPropertySupported.isPropertySupported(property,
          platform: platform);
}
