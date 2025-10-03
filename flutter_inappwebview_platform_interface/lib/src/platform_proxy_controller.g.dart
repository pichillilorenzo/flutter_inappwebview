// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_proxy_controller.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///{@template flutter_inappwebview_platform_interface.ProxySettings}
///Class that represents the settings used to configure the [PlatformProxyController].
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.ProxySettings.supported_platforms}
///
///**Officially Supported Platforms/Implementations**:
///- Android WebView ([Official API - ProxyConfig](https://developer.android.com/reference/androidx/webkit/ProxyConfig))
///- iOS WKWebView 17.0+ ([Official API - ProxyConfiguration](https://developer.apple.com/documentation/network/proxyconfiguration))
///- macOS WKWebView 14.0+ ([Official API - ProxyConfiguration](https://developer.apple.com/documentation/network/proxyconfiguration))
class ProxySettings {
  ///List of bypass rules.
  ///
  ///A bypass rule describes URLs that should skip proxy override settings and make a direct connection instead. These can be URLs or IP addresses. Wildcards are accepted.
  ///For instance, the rule "*example.com" would mean that requests to "http://example.com" and "www.example.com" would not be directed to any proxy,
  ///instead, would be made directly to the origin specified by the URL.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  List<String> bypassRules;

  ///Hostnames without a period in them (and that are not IP literals) will skip proxy settings and be connected to directly instead. Examples: `"abc"`, `"local"`, `"some-domain"`.
  ///
  ///Hostnames with a trailing dot are not considered simple by this definition.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  bool? bypassSimpleHostnames;

  ///List of scheme filters.
  ///
  ///URLs that match these scheme filters are connected to directly instead of using a proxy server.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  List<String> directs;

  ///List of proxy rules to be used for all URLs. Additional rules have decreasing precedence.
  ///
  ///Proxy is a string in the format `[scheme://]host[:port]`.
  ///Scheme is optional, if present must be `HTTP`, `HTTPS` or [SOCKS](https://tools.ietf.org/html/rfc1928) and defaults to `HTTP`.
  ///Host is one of an IPv6 literal with brackets, an IPv4 literal or one or more labels separated by a period.
  ///Port number is optional and defaults to `80` for `HTTP`, `443` for `HTTPS` and `1080` for `SOCKS`.
  ///
  ///The correct syntax for hosts is defined by [RFC 3986](https://tools.ietf.org/html/rfc3986#section-3.2.2).
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  List<ProxyRule> proxyRules;

  ///By default, certain hostnames implicitly bypass the proxy if they are link-local IPs, or localhost addresses.
  ///For instance hostnames matching any of (non-exhaustive list):
  ///- localhost
  ///- *.localhost
  ///- [::1]
  ///- 127.0.0.1/8
  ///- 169.254/16
  ///- [FE80::]/10
  ///Set this to `true` to override the default behavior and force localhost and link-local URLs to be sent through the proxy.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
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
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  bool reverseBypassEnabled;

  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - ProxyConfig](https://developer.android.com/reference/androidx/webkit/ProxyConfig))
  ///- iOS WKWebView 17.0+ ([Official API - ProxyConfiguration](https://developer.apple.com/documentation/network/proxyconfiguration))
  ///- macOS WKWebView 14.0+ ([Official API - ProxyConfiguration](https://developer.apple.com/documentation/network/proxyconfiguration))
  ProxySettings(
      {this.bypassRules = const [],
      this.bypassSimpleHostnames,
      this.directs = const [],
      this.proxyRules = const [],
      this.removeImplicitRules,
      this.reverseBypassEnabled = false});

  ///Gets a possible [ProxySettings] instance from a [Map] value.
  static ProxySettings? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = ProxySettings(
      bypassSimpleHostnames: map['bypassSimpleHostnames'],
      removeImplicitRules: map['removeImplicitRules'],
    );
    if (map['bypassRules'] != null) {
      instance.bypassRules =
          List<String>.from(map['bypassRules']!.cast<String>());
    }
    if (map['directs'] != null) {
      instance.directs = List<String>.from(map['directs']!.cast<String>());
    }
    if (map['proxyRules'] != null) {
      instance.proxyRules = List<ProxyRule>.from(map['proxyRules'].map((e) =>
          ProxyRule.fromMap(e?.cast<String, dynamic>(),
              enumMethod: enumMethod)!));
    }
    if (map['reverseBypassEnabled'] != null) {
      instance.reverseBypassEnabled = map['reverseBypassEnabled'];
    }
    return instance;
  }

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

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "bypassRules": bypassRules,
      "bypassSimpleHostnames": bypassSimpleHostnames,
      "directs": directs,
      "proxyRules":
          proxyRules.map((e) => e.toMap(enumMethod: enumMethod)).toList(),
      "removeImplicitRules": removeImplicitRules,
      "reverseBypassEnabled": reverseBypassEnabled,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  ///Returns a copy of ProxySettings.
  ProxySettings copy() {
    return ProxySettings.fromMap(toMap()) ?? ProxySettings();
  }

  @override
  String toString() {
    return 'ProxySettings{bypassRules: $bypassRules, bypassSimpleHostnames: $bypassSimpleHostnames, directs: $directs, proxyRules: $proxyRules, removeImplicitRules: $removeImplicitRules, reverseBypassEnabled: $reverseBypassEnabled}';
  }
}

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

extension _PlatformProxyControllerCreationParamsClassSupported
    on PlatformProxyControllerCreationParams {
  ///{@template flutter_inappwebview_platform_interface.PlatformProxyControllerCreationParams.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [PlatformProxyControllerCreationParams.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
            .contains(platform ?? defaultTargetPlatform);
  }
}

extension _PlatformProxyControllerClassSupported on PlatformProxyController {
  ///{@template flutter_inappwebview_platform_interface.PlatformProxyController.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - ProxyController](https://developer.android.com/reference/androidx/webkit/ProxyController))
  ///- iOS WKWebView 17.0+ ([Official API - WKWebsiteDataStore.proxyConfigurations](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4264546-proxyconfigurations))
  ///- macOS WKWebView 14.0+ ([Official API - WKWebsiteDataStore.proxyConfigurations](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4264546-proxyconfigurations))
  ///
  ///Use the [PlatformProxyController.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
            .contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformProxyController]'s methods that can be used to check if they are supported or not by the current platform.
enum PlatformProxyControllerMethod {
  ///Can be used to check if the [PlatformProxyController.clearProxyOverride] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformProxyController.clearProxyOverride.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - ProxyController.clearProxyOverride](https://developer.android.com/reference/androidx/webkit/ProxyController#clearProxyOverride(java.util.concurrent.Executor,%20java.lang.Runnable)))
  ///- iOS WKWebView 17.0+ ([Official API - WKWebsiteDataStore.proxyConfigurations](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4264546-proxyconfigurations))
  ///- macOS WKWebView 14.0+ ([Official API - WKWebsiteDataStore.proxyConfigurations](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4264546-proxyconfigurations))
  ///
  ///Use the [PlatformProxyController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  clearProxyOverride,

  ///Can be used to check if the [PlatformProxyController.setProxyOverride] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformProxyController.setProxyOverride.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - ProxyController.setProxyOverride](https://developer.android.com/reference/androidx/webkit/ProxyController#setProxyOverride(androidx.webkit.ProxyConfig,%20java.util.concurrent.Executor,%20java.lang.Runnable)))
  ///- iOS WKWebView 17.0+ ([Official API - WKWebsiteDataStore.proxyConfigurations](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4264546-proxyconfigurations))
  ///- macOS WKWebView 14.0+ ([Official API - WKWebsiteDataStore.proxyConfigurations](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4264546-proxyconfigurations))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [settings]: all platforms
  ///
  ///Use the [PlatformProxyController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setProxyOverride,
}

extension _PlatformProxyControllerMethodSupported on PlatformProxyController {
  static bool isMethodSupported(PlatformProxyControllerMethod method,
      {TargetPlatform? platform}) {
    switch (method) {
      case PlatformProxyControllerMethod.clearProxyOverride:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformProxyControllerMethod.setProxyOverride:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
    }
  }
}

extension _ProxySettingsClassSupported on ProxySettings {
  ///{@template flutter_inappwebview_platform_interface.ProxySettings.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - ProxyConfig](https://developer.android.com/reference/androidx/webkit/ProxyConfig))
  ///- iOS WKWebView 17.0+ ([Official API - ProxyConfiguration](https://developer.apple.com/documentation/network/proxyconfiguration))
  ///- macOS WKWebView 14.0+ ([Official API - ProxyConfiguration](https://developer.apple.com/documentation/network/proxyconfiguration))
  ///
  ///Use the [ProxySettings.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
            .contains(platform ?? defaultTargetPlatform);
  }
}

///List of [ProxySettings]'s properties that can be used to check i they are supported or not by the current platform.
enum ProxySettingsProperty {
  ///Can be used to check if the [ProxySettings.bypassRules] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ProxySettings.bypassRules.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [ProxySettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  bypassRules,

  ///Can be used to check if the [ProxySettings.bypassSimpleHostnames] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ProxySettings.bypassSimpleHostnames.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [ProxySettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  bypassSimpleHostnames,

  ///Can be used to check if the [ProxySettings.directs] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ProxySettings.directs.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [ProxySettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  directs,

  ///Can be used to check if the [ProxySettings.proxyRules] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ProxySettings.proxyRules.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [ProxySettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  proxyRules,

  ///Can be used to check if the [ProxySettings.removeImplicitRules] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ProxySettings.removeImplicitRules.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [ProxySettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  removeImplicitRules,

  ///Can be used to check if the [ProxySettings.reverseBypassEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ProxySettings.reverseBypassEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [ProxySettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  reverseBypassEnabled,
}

extension _ProxySettingsPropertySupported on ProxySettings {
  static bool isPropertySupported(ProxySettingsProperty property,
      {TargetPlatform? platform}) {
    switch (property) {
      case ProxySettingsProperty.bypassRules:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case ProxySettingsProperty.bypassSimpleHostnames:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case ProxySettingsProperty.directs:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case ProxySettingsProperty.proxyRules:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case ProxySettingsProperty.removeImplicitRules:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case ProxySettingsProperty.reverseBypassEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
    }
  }
}
