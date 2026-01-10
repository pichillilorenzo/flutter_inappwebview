// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'linux_webview_environment_settings.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Linux-specific WebView environment settings based on WebKitWebContext APIs.
///
///These settings configure how the WebKitWebContext behaves on Linux.
///Use this to customize spell checking, language preferences, caching behavior,
///and other WebKit-specific options.
///
///**Officially Supported Platforms/Implementations**:
///- Linux WPE WebKit ([Official API - WebKitWebContext](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/class.WebContext.html))
class LinuxWebViewEnvironmentSettings {
  ///Enable or disable automation mode in the WebContext.
  ///
  ///When automation is allowed, web pages can use the WebDriver API to automate
  ///interaction with the WebView. This is useful for testing and automation scenarios.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - webkit_web_context_set_automation_allowed](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebContext.set_automation_allowed.html))
  final bool? automationAllowed;

  ///Set the cache model for the WebContext.
  ///
  ///Specifies the caching behavior. Different models optimize for different
  ///use cases like web browsing, document viewing, etc.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - webkit_web_context_set_cache_model](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebContext.set_cache_model.html))
  final LinuxCacheModel? cacheModel;

  ///Set the list of preferred languages for the WebContext.
  ///
  ///This will be used for the `Accept-Language` HTTP header and to set `navigator.language`.
  ///Languages should be specified in order of preference.
  ///For example, `["en-US", "en", "fr"]`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - webkit_web_context_set_preferred_languages](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebContext.set_preferred_languages.html))
  final List<String>? preferredLanguages;

  ///Set additional paths that should be accessible when running in sandbox mode.
  ///
  ///Each path will be added to the sandbox to allow web processes to access those directories.
  ///This is useful when the WebView needs access to specific local files or directories.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - webkit_web_context_add_path_to_sandbox](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebContext.add_path_to_sandbox.html))
  final List<String>? sandboxPaths;

  ///Enable or disable spell checking in the WebContext.
  ///
  ///When enabled, text entered by the user will be checked for spelling errors.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - webkit_web_context_set_spell_checking_enabled](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebContext.set_spell_checking_enabled.html))
  final bool? spellCheckingEnabled;

  ///Set the list of spell checking languages to use.
  ///
  ///The locale string typically has the form `lang_COUNTRY` where `lang` is an
  ///ISO-639 language code and `COUNTRY` is an ISO-3166 country code.
  ///For example, `"en_US"`, `"es_ES"`, or `"pt_BR"`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - webkit_web_context_set_spell_checking_languages](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebContext.set_spell_checking_languages.html))
  final List<String>? spellCheckingLanguages;

  ///Set a timezone override for web pages loaded in this WebContext.
  ///
  ///This allows overriding the system timezone for web content.
  ///The value should be a valid IANA timezone identifier like `"America/New_York"`,
  ///`"Europe/London"`, or `"Asia/Tokyo"`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - time-zone-override](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/class.WebContext.html)):
  ///    - This property must be set at WebContext construction time.
  final String? timeZoneOverride;

  ///Set the TLS errors policy for the WebContext.
  ///
  ///Determines how TLS certificate errors are handled.
  ///The default is [LinuxTLSErrorsPolicy.FAIL] which is the secure option.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - webkit_web_context_set_tls_errors_policy](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebContext.set_tls_errors_policy.html))
  final LinuxTLSErrorsPolicy? tlsErrorsPolicy;

  ///Set the directory where web process extension modules are located.
  ///
  ///Web process extensions allow extending the functionality of the web process
  ///with custom code. This is an advanced feature for specialized use cases.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - webkit_web_context_set_web_process_extensions_directory](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebContext.set_web_process_extensions_directory.html))
  final String? webProcessExtensionsDirectory;

  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - WebKitWebContext](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/class.WebContext.html))
  LinuxWebViewEnvironmentSettings({
    this.automationAllowed,
    this.cacheModel,
    this.preferredLanguages,
    this.sandboxPaths,
    this.spellCheckingEnabled,
    this.spellCheckingLanguages,
    this.timeZoneOverride,
    this.tlsErrorsPolicy,
    this.webProcessExtensionsDirectory,
  });

  ///Gets a possible [LinuxWebViewEnvironmentSettings] instance from a [Map] value.
  static LinuxWebViewEnvironmentSettings? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = LinuxWebViewEnvironmentSettings(
      automationAllowed: map['automationAllowed'],
      cacheModel: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => LinuxCacheModel.fromNativeValue(
          map['cacheModel'],
        ),
        EnumMethod.value => LinuxCacheModel.fromValue(map['cacheModel']),
        EnumMethod.name => LinuxCacheModel.byName(map['cacheModel']),
      },
      preferredLanguages: map['preferredLanguages'] != null
          ? List<String>.from(map['preferredLanguages']!.cast<String>())
          : null,
      sandboxPaths: map['sandboxPaths'] != null
          ? List<String>.from(map['sandboxPaths']!.cast<String>())
          : null,
      spellCheckingEnabled: map['spellCheckingEnabled'],
      spellCheckingLanguages: map['spellCheckingLanguages'] != null
          ? List<String>.from(map['spellCheckingLanguages']!.cast<String>())
          : null,
      timeZoneOverride: map['timeZoneOverride'],
      tlsErrorsPolicy: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => LinuxTLSErrorsPolicy.fromNativeValue(
          map['tlsErrorsPolicy'],
        ),
        EnumMethod.value => LinuxTLSErrorsPolicy.fromValue(
          map['tlsErrorsPolicy'],
        ),
        EnumMethod.name => LinuxTLSErrorsPolicy.byName(map['tlsErrorsPolicy']),
      },
      webProcessExtensionsDirectory: map['webProcessExtensionsDirectory'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "automationAllowed": automationAllowed,
      "cacheModel": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => cacheModel?.toNativeValue(),
        EnumMethod.value => cacheModel?.toValue(),
        EnumMethod.name => cacheModel?.name(),
      },
      "preferredLanguages": preferredLanguages,
      "sandboxPaths": sandboxPaths,
      "spellCheckingEnabled": spellCheckingEnabled,
      "spellCheckingLanguages": spellCheckingLanguages,
      "timeZoneOverride": timeZoneOverride,
      "tlsErrorsPolicy": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => tlsErrorsPolicy?.toNativeValue(),
        EnumMethod.value => tlsErrorsPolicy?.toValue(),
        EnumMethod.name => tlsErrorsPolicy?.name(),
      },
      "webProcessExtensionsDirectory": webProcessExtensionsDirectory,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  ///Returns a copy of LinuxWebViewEnvironmentSettings.
  LinuxWebViewEnvironmentSettings copy() {
    return LinuxWebViewEnvironmentSettings.fromMap(toMap()) ??
        LinuxWebViewEnvironmentSettings();
  }

  @override
  String toString() {
    return 'LinuxWebViewEnvironmentSettings{automationAllowed: $automationAllowed, cacheModel: $cacheModel, preferredLanguages: $preferredLanguages, sandboxPaths: $sandboxPaths, spellCheckingEnabled: $spellCheckingEnabled, spellCheckingLanguages: $spellCheckingLanguages, timeZoneOverride: $timeZoneOverride, tlsErrorsPolicy: $tlsErrorsPolicy, webProcessExtensionsDirectory: $webProcessExtensionsDirectory}';
  }
}
