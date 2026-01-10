import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'linux_cache_model.dart';
import 'linux_tls_errors_policy.dart';

part 'linux_webview_environment_settings.g.dart';

///Linux-specific WebView environment settings based on WebKitWebContext APIs.
///
///These settings configure how the WebKitWebContext behaves on Linux.
///Use this to customize spell checking, language preferences, caching behavior,
///and other WebKit-specific options.
@SupportedPlatforms(
  platforms: [
    LinuxPlatform(
      apiName: 'WebKitWebContext',
      apiUrl:
          'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/class.WebContext.html',
    ),
  ],
)
@ExchangeableObject(copyMethod: true)
class LinuxWebViewEnvironmentSettings_ {
  ///Enable or disable spell checking in the WebContext.
  ///
  ///When enabled, text entered by the user will be checked for spelling errors.
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: 'webkit_web_context_set_spell_checking_enabled',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebContext.set_spell_checking_enabled.html',
      ),
    ],
  )
  final bool? spellCheckingEnabled;

  ///Set the list of spell checking languages to use.
  ///
  ///The locale string typically has the form `lang_COUNTRY` where `lang` is an
  ///ISO-639 language code and `COUNTRY` is an ISO-3166 country code.
  ///For example, `"en_US"`, `"es_ES"`, or `"pt_BR"`.
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: 'webkit_web_context_set_spell_checking_languages',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebContext.set_spell_checking_languages.html',
      ),
    ],
  )
  final List<String>? spellCheckingLanguages;

  ///Set the list of preferred languages for the WebContext.
  ///
  ///This will be used for the `Accept-Language` HTTP header and to set `navigator.language`.
  ///Languages should be specified in order of preference.
  ///For example, `["en-US", "en", "fr"]`.
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: 'webkit_web_context_set_preferred_languages',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebContext.set_preferred_languages.html',
      ),
    ],
  )
  final List<String>? preferredLanguages;

  ///Set the cache model for the WebContext.
  ///
  ///Specifies the caching behavior. Different models optimize for different
  ///use cases like web browsing, document viewing, etc.
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: 'webkit_web_context_set_cache_model',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebContext.set_cache_model.html',
      ),
    ],
  )
  final LinuxCacheModel_? cacheModel;

  ///Enable or disable automation mode in the WebContext.
  ///
  ///When automation is allowed, web pages can use the WebDriver API to automate
  ///interaction with the WebView. This is useful for testing and automation scenarios.
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: 'webkit_web_context_set_automation_allowed',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebContext.set_automation_allowed.html',
      ),
    ],
  )
  final bool? automationAllowed;

  ///Set the directory where web process extension modules are located.
  ///
  ///Web process extensions allow extending the functionality of the web process
  ///with custom code. This is an advanced feature for specialized use cases.
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: 'webkit_web_context_set_web_process_extensions_directory',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebContext.set_web_process_extensions_directory.html',
      ),
    ],
  )
  final String? webProcessExtensionsDirectory;

  ///Set additional paths that should be accessible when running in sandbox mode.
  ///
  ///Each path will be added to the sandbox to allow web processes to access those directories.
  ///This is useful when the WebView needs access to specific local files or directories.
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: 'webkit_web_context_add_path_to_sandbox',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebContext.add_path_to_sandbox.html',
      ),
    ],
  )
  final List<String>? sandboxPaths;

  ///Set the TLS errors policy for the WebContext.
  ///
  ///Determines how TLS certificate errors are handled.
  ///The default is [LinuxTLSErrorsPolicy.FAIL] which is the secure option.
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: 'webkit_web_context_set_tls_errors_policy',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebContext.set_tls_errors_policy.html',
      ),
    ],
  )
  final LinuxTLSErrorsPolicy_? tlsErrorsPolicy;

  ///Set a timezone override for web pages loaded in this WebContext.
  ///
  ///This allows overriding the system timezone for web content.
  ///The value should be a valid IANA timezone identifier like `"America/New_York"`,
  ///`"Europe/London"`, or `"Asia/Tokyo"`.
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: 'time-zone-override',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/class.WebContext.html',
        note: 'This property must be set at WebContext construction time.',
      ),
    ],
  )
  final String? timeZoneOverride;

  LinuxWebViewEnvironmentSettings_({
    this.spellCheckingEnabled,
    this.spellCheckingLanguages,
    this.preferredLanguages,
    this.cacheModel,
    this.automationAllowed,
    this.webProcessExtensionsDirectory,
    this.sandboxPaths,
    this.tlsErrorsPolicy,
    this.timeZoneOverride,
  });
}
