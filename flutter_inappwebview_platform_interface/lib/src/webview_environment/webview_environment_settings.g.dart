// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webview_environment_settings.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///This class represents all the [PlatformWebViewEnvironment] settings available.
///
///The [browserExecutableFolder], [userDataFolder] and [additionalBrowserArguments]
///may be overridden by values either specified in environment variables or in the registry.
///
///**Officially Supported Platforms/Implementations**:
///- Windows WebView2
///- Linux WPE WebKit
class WebViewEnvironmentSettings {
  ///If there are multiple switches, there should be a space in between them.
  ///The one exception is if multiple features are being enabled/disabled for a single switch,
  ///in which case the features should be comma-seperated.
  ///Example: `"--disable-features=feature1,feature2 --some-other-switch --do-something"`
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - ICoreWebView2EnvironmentOptions.put_AdditionalBrowserArguments](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions?view=webview2-1.0.2210.55#put_additionalbrowserarguments))
  final String? additionalBrowserArguments;

  ///This property is used to enable single sign on with Azure Active Directory (AAD)
  ///and personal Microsoft Account (MSA) resources inside WebView.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - ICoreWebView2EnvironmentOptions.put_AllowSingleSignOnUsingOSPrimaryAccount](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions?view=webview2-1.0.2210.55#put_allowsinglesignonusingosprimaryaccount))
  final bool? allowSingleSignOnUsingOSPrimaryAccount;

  ///When this property is set to `true` new extensions can be added to user profile and used.
  ///
  ///[areBrowserExtensionsEnabled] is default to be `false`, in this case, new extensions can't be installed,
  ///and already installed extension won't be available to use in user profile.
  ///If connecting to an already running environment with a different value for
  ///[areBrowserExtensionsEnabled] property, it will fail with `HRESULT_FROM_WIN32(ERROR_INVALID_STATE)`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.2210.55+ ([Official API - ICoreWebView2EnvironmentOptions6.put_AreBrowserExtensionsEnabled](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions6?view=webview2-1.0.2849.39#put_arebrowserextensionsenabled))
  final bool? areBrowserExtensionsEnabled;

  ///Enable or disable automation mode in the WebContext.
  ///
  ///When automation is allowed, web pages can use the WebDriver API to automate
  ///interaction with the WebView. This is useful for testing and automation scenarios.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - webkit_web_context_set_automation_allowed](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebContext.set_automation_allowed.html))
  final bool? automationAllowed;

  ///Use [browserExecutableFolder] to specify whether WebView2 controls use a fixed
  ///or installed version of the WebView2 Runtime that exists on a user machine.
  ///To use a fixed version of the WebView2 Runtime, pass the folder path that contains
  ///the fixed version of the WebView2 Runtime to [browserExecutableFolder].
  ///BrowserExecutableFolder supports both relative (to the application's executable) and absolute files paths.
  ///To create WebView2 controls that use the installed version of the WebView2 Runtime that exists on user machines,
  ///pass a `null` or empty string to [browserExecutableFolder].
  ///In this scenario, the API tries to find a compatible version of the WebView2 Runtime
  ///that is installed on the user machine (first at the machine level, and then per user) using the selected channel preference.
  ///The path of fixed version of the WebView2 Runtime should not contain `\Edge\Application\`.
  ///When such a path is used, the API fails with `HRESULT_FROM_WIN32(ERROR_NOT_SUPPORTED)`.
  ///
  ///The default channel search order is the WebView2 Runtime, Beta, Dev, and Canary.
  ///When an override `WEBVIEW2_RELEASE_CHANNEL_PREFERENCE` environment variable or
  ///applicable `releaseChannelPreference` registry value is set to `1`, the channel search order is reversed.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - CreateCoreWebView2EnvironmentWithOptions.browserExecutableFolder](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#createcorewebview2environmentwithoptions))
  final String? browserExecutableFolder;

  ///Set the cache model for the WebContext.
  ///
  ///Specifies the caching behavior. Different models optimize for different
  ///use cases like web browsing, document viewing, etc.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - webkit_web_context_set_cache_model](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebContext.set_cache_model.html))
  final CacheModel? cacheModel;

  ///This property is [EnvironmentChannelSearchKind.MOST_STABLE] by default;
  ///environment creation searches for a release channel on the machine from
  ///most to least stable using the first channel found.
  ///
  ///The default search order is: WebView2 Runtime -> Beta -> Dev -> Canary.
  ///Set [channelSearchKind] to [EnvironmentChannelSearchKind.LEAST_STABLE] to reverse
  ///the search order so that environment creation searches for a channel from least to most stable.
  ///If [releaseChannels] has been provided, the loader will only search for channels in the set.
  ///See [EnvironmentReleaseChannels] for more details on channels.
  ///
  ///This property can be overridden by the corresponding registry key [channelSearchKind]
  ///or the environment variable `WEBVIEW2_CHANNEL_SEARCH_KIND`.
  ///Set the value to `1` to set the search kind to [EnvironmentChannelSearchKind.LEAST_STABLE].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.2478.35+ ([Official API - ICoreWebView2EnvironmentOptions7.put_ChannelSearchKind](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions7?view=webview2-1.0.2849.39#put_channelsearchkind))
  final EnvironmentChannelSearchKind? channelSearchKind;

  ///Set the array of custom scheme registrations to be used.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.1587.40+ ([Official API - ICoreWebView2EnvironmentOptions4.SetCustomSchemeRegistrations](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions4?view=webview2-1.0.2739.15#setcustomschemeregistrations))
  final List<CustomSchemeRegistration>? customSchemeRegistrations;

  ///This property is used to enable/disable tracking prevention feature in WebView2.
  ///
  ///This property enable/disable tracking prevention for all the WebView2's created in the same environment.
  ///By default this feature is enabled to block potentially harmful trackers and trackers from sites that aren't visited before.
  ///
  ///You can set this property to `false` to disable the tracking prevention feature if the app
  ///only renders content in the WebView2 that is known to be safe.
  ///Disabling this feature when creating environment also improves runtime performance by skipping related code.
  ///
  ///You shouldn't disable this property if WebView2 is being used as a "full browser"
  ///with arbitrary navigation and should protect end user privacy.
  ///
  ///Tracking prevention protects users from online tracking by restricting the ability
  ///of trackers to access browser-based storage as well as the network.
  ///See [Tracking prevention](https://learn.microsoft.com/en-us/microsoft-edge/web-platform/tracking-prevention).
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.1661.34+ ([Official API - ICoreWebView2EnvironmentOptions5.put_EnableTrackingPrevention](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions5?view=webview2-1.0.2849.39#put_enabletrackingprevention))
  final bool? enableTrackingPrevention;

  ///Whether other processes can create WebView2 from WebView2Environment created
  ///with the same user data folder and therefore sharing the same WebView browser process instance.
  ///
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.1185.39+ ([Official API - ICoreWebView2EnvironmentOptions2.put_ExclusiveUserDataFolderAccess](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions2?view=webview2-1.0.2849.39#put_exclusiveuserdatafolderaccess))
  final bool? exclusiveUserDataFolderAccess;

  ///When IsCustomCrashReportingEnabled is set to `true`,
  ///Windows won't send crash data to Microsoft endpoint.
  ///
  ///The default value is `false`.
  ///In this case, WebView will respect OS consent.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.1518.46+ ([Official API - ICoreWebView2EnvironmentOptions3.put_IsCustomCrashReportingEnabled](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions3?view=webview2-1.0.2849.39#put_iscustomcrashreportingenabled))
  final bool? isCustomCrashReportingEnabled;

  ///The default display language for WebView.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - ICoreWebView2EnvironmentOptions.put_Language](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions?view=webview2-1.0.2210.55#put_language))
  final String? language;

  ///Set the list of preferred languages for the WebContext.
  ///
  ///This will be used for the `Accept-Language` HTTP header and to set `navigator.language`.
  ///Languages should be specified in order of preference.
  ///For example, `["en-US", "en", "fr"]`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - webkit_web_context_set_preferred_languages](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebContext.set_preferred_languages.html))
  final List<String>? preferredLanguages;

  ///Sets the [releaseChannels], which is a mask of one or more [EnvironmentReleaseChannels]
  ///indicating which channels environment creation should search for.
  ///
  ///OR operation(s) can be applied to multiple [EnvironmentReleaseChannels] to create a mask.
  ///The default value is a a mask of all the channels.
  ///By default, environment creation searches for channels from most to least stable,
  ///using the first channel found on the device.
  ///When [releaseChannels] is provided, environment creation will only
  ///search for the channels specified in the set.
  ///Set [channelSearchKind] to [EnvironmentChannelSearchKind.LEAST_STABLE] to reverse
  ///the search order so environment creation searches for least stable build first.
  ///See [EnvironmentReleaseChannels] for descriptions of each channel.
  ///
  ///The [PlatformWebViewEnvironment] creation will fails with `HRESULT_FROM_WIN32(ERROR_FILE_NOT_FOUND)`
  ///if environment creation is unable to find any channel from the EnvironmentReleaseChannels installed on the device.
  ///Use [PlatformWebViewEnvironment.getAvailableVersion] to verify which channel is used when this option is set.
  ///
  ///Examples:
  ///
  ///| ReleaseChannels                                                                                                                       | Channel Search Kind: Most Stable (default)  | Channel Search Kind: Least Stable          |
  ///|--------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------|--------------------------------------------|
  ///| [EnvironmentReleaseChannels.BETA] | [EnvironmentReleaseChannels.STABLE]                                                                          | WebView2 Runtime -> Beta                    | Beta -> WebView2 Runtime                   |
  ///| [EnvironmentReleaseChannels.CANARY] | [EnvironmentReleaseChannels.DEV] | [EnvironmentReleaseChannels.BETA] | [EnvironmentReleaseChannels.STABLE] | WebView2 Runtime -> Beta -> Dev -> Canary   | Canary -> Dev -> Beta -> WebView2 Runtime  |
  ///| [EnvironmentReleaseChannels.CANARY]                                                                                                              | Canary                                      | Canary                                     |
  ///| [EnvironmentReleaseChannels.BETA] | [EnvironmentReleaseChannels.CANARY] | [EnvironmentReleaseChannels.STABLE]                                    | WebView2 Runtime -> Beta -> Canary          | Canary -> Beta -> WebView2 Runtime         |
  ///
  ///If both [browserExecutableFolder] and [releaseChannels] are provided, the [browserExecutableFolder] takes precedence,
  ///regardless of whether or not the channel of [browserExecutableFolder] is included in the [releaseChannels].
  ///[releaseChannels] can be overridden by the corresponding registry override EnvironmentReleaseChannels or the environment
  ///variable `WEBVIEW2_RELEASE_CHANNELS`. Set the value to a comma-separated string of integers, which map to
  ///the following release channel values: Stable (0), Beta (1), Dev (2), and Canary (3).
  ///For example, the values "0,2" and "2,0" indicate that environment creation should only search for
  ///Dev channel and the WebView2 Runtime, using the order indicated by [channelSearchKind].
  ///[PlatformWebViewEnvironment] creation attempts to interpret each integer and treats any invalid entry as Stable channel.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.2478.35+ ([Official API - ICoreWebView2EnvironmentOptions7.put_ReleaseChannels](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions7?view=webview2-1.0.2849.39#put_releasechannels))
  final EnvironmentReleaseChannels? releaseChannels;

  ///Set additional paths that should be accessible when running in sandbox mode.
  ///
  ///Each path will be added to the sandbox to allow web processes to access those directories.
  ///This is useful when the WebView needs access to specific local files or directories.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - webkit_web_context_add_path_to_sandbox](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebContext.add_path_to_sandbox.html))
  final List<String>? sandboxPaths;

  ///The ScrollBar style being set on the WebView2 Environment.
  ///
  ///The default value is [EnvironmentScrollbarStyle.DEFAULT] which specifies the default browser ScrollBar style.
  ///The `color-scheme` CSS property needs to be set on the corresponding
  ///page to allow ScrollBar to follow light or dark theme.
  ///Please see [color-scheme](https://developer.mozilla.org/docs/Web/CSS/color-scheme#declaring_color_scheme_preferences) for how `color-scheme` can be set.
  ///CSS styles that modify the ScrollBar applied on top of native ScrollBar styling that is selected with [scrollbarStyle].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.2535.41+ ([Official API - ICoreWebView2EnvironmentOptions8.put_ScrollBarStyle](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions8?view=webview2-1.0.2849.39#put_scrollbarstyle))
  final EnvironmentScrollbarStyle? scrollbarStyle;

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

  ///Specifies the version of the WebView2 Runtime binaries required to be compatible with your app.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - ICoreWebView2EnvironmentOptions.put_TargetCompatibleBrowserVersion](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions?view=webview2-1.0.2210.55#put_targetcompatiblebrowserversion))
  final String? targetCompatibleBrowserVersion;

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

  ///You may specify the [userDataFolder] to change the default user data folder location for WebView2.
  ///The path is either an absolute file path or a relative file path that is interpreted as relative
  ///to the compiled code for the current process.
  ///For UWP apps, the default user data folder is the app data folder for the package.
  ///For non-UWP apps, the default user data (`{Executable File Name}.WebView2`) folder
  ///is created in the same directory next to the compiled code for the app.
  ///WebView2 creation fails if the compiled code is running in a directory in which the
  ///process does not have permission to create a new directory.
  ///The app is responsible to clean up the associated user data folder when it is done.
  ///
  ///**NOTE**: As a browser process may be shared among WebViews,
  ///WebView creation fails with `HRESULT_FROM_WIN32(ERROR_INVALID_STATE)` if the specified
  ///options does not match the options of the WebViews that are currently
  ///running in the shared browser process.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - CreateCoreWebView2EnvironmentWithOptions.userDataFolder](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#createcorewebview2environmentwithoptions))
  final String? userDataFolder;

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
  ///- Windows WebView2
  ///- Linux WPE WebKit
  WebViewEnvironmentSettings({
    this.additionalBrowserArguments,
    this.allowSingleSignOnUsingOSPrimaryAccount,
    this.areBrowserExtensionsEnabled,
    this.automationAllowed,
    this.browserExecutableFolder,
    this.cacheModel,
    this.channelSearchKind,
    this.customSchemeRegistrations,
    this.enableTrackingPrevention,
    this.exclusiveUserDataFolderAccess,
    this.isCustomCrashReportingEnabled,
    this.language,
    this.preferredLanguages,
    this.releaseChannels,
    this.sandboxPaths,
    this.scrollbarStyle,
    this.spellCheckingEnabled,
    this.spellCheckingLanguages,
    this.targetCompatibleBrowserVersion,
    this.timeZoneOverride,
    this.userDataFolder,
    this.webProcessExtensionsDirectory,
  });

  ///Gets a possible [WebViewEnvironmentSettings] instance from a [Map] value.
  static WebViewEnvironmentSettings? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = WebViewEnvironmentSettings(
      additionalBrowserArguments: map['additionalBrowserArguments'],
      allowSingleSignOnUsingOSPrimaryAccount:
          map['allowSingleSignOnUsingOSPrimaryAccount'],
      areBrowserExtensionsEnabled: map['areBrowserExtensionsEnabled'],
      automationAllowed: map['automationAllowed'],
      browserExecutableFolder: map['browserExecutableFolder'],
      cacheModel: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => CacheModel.fromNativeValue(map['cacheModel']),
        EnumMethod.value => CacheModel.fromValue(map['cacheModel']),
        EnumMethod.name => CacheModel.byName(map['cacheModel']),
      },
      channelSearchKind: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => EnvironmentChannelSearchKind.fromNativeValue(
          map['channelSearchKind'],
        ),
        EnumMethod.value => EnvironmentChannelSearchKind.fromValue(
          map['channelSearchKind'],
        ),
        EnumMethod.name => EnvironmentChannelSearchKind.byName(
          map['channelSearchKind'],
        ),
      },
      customSchemeRegistrations: map['customSchemeRegistrations'] != null
          ? List<CustomSchemeRegistration>.from(
              map['customSchemeRegistrations'].map(
                (e) => CustomSchemeRegistration.fromMap(
                  e?.cast<String, dynamic>(),
                  enumMethod: enumMethod,
                )!,
              ),
            )
          : null,
      enableTrackingPrevention: map['enableTrackingPrevention'],
      exclusiveUserDataFolderAccess: map['exclusiveUserDataFolderAccess'],
      isCustomCrashReportingEnabled: map['isCustomCrashReportingEnabled'],
      language: map['language'],
      preferredLanguages: map['preferredLanguages'] != null
          ? List<String>.from(map['preferredLanguages']!.cast<String>())
          : null,
      releaseChannels: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => EnvironmentReleaseChannels.fromNativeValue(
          map['releaseChannels'],
        ),
        EnumMethod.value => EnvironmentReleaseChannels.fromValue(
          map['releaseChannels'],
        ),
        EnumMethod.name => EnvironmentReleaseChannels.byName(
          map['releaseChannels'],
        ),
      },
      sandboxPaths: map['sandboxPaths'] != null
          ? List<String>.from(map['sandboxPaths']!.cast<String>())
          : null,
      scrollbarStyle: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => EnvironmentScrollbarStyle.fromNativeValue(
          map['scrollbarStyle'],
        ),
        EnumMethod.value => EnvironmentScrollbarStyle.fromValue(
          map['scrollbarStyle'],
        ),
        EnumMethod.name => EnvironmentScrollbarStyle.byName(
          map['scrollbarStyle'],
        ),
      },
      spellCheckingEnabled: map['spellCheckingEnabled'],
      spellCheckingLanguages: map['spellCheckingLanguages'] != null
          ? List<String>.from(map['spellCheckingLanguages']!.cast<String>())
          : null,
      targetCompatibleBrowserVersion: map['targetCompatibleBrowserVersion'],
      timeZoneOverride: map['timeZoneOverride'],
      userDataFolder: map['userDataFolder'],
      webProcessExtensionsDirectory: map['webProcessExtensionsDirectory'],
    );
    return instance;
  }

  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isPropertySupported(
    WebViewEnvironmentSettingsProperty property, {
    TargetPlatform? platform,
  }) => _WebViewEnvironmentSettingsPropertySupported.isPropertySupported(
    property,
    platform: platform,
  );

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "additionalBrowserArguments": additionalBrowserArguments,
      "allowSingleSignOnUsingOSPrimaryAccount":
          allowSingleSignOnUsingOSPrimaryAccount,
      "areBrowserExtensionsEnabled": areBrowserExtensionsEnabled,
      "automationAllowed": automationAllowed,
      "browserExecutableFolder": browserExecutableFolder,
      "cacheModel": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => cacheModel?.toNativeValue(),
        EnumMethod.value => cacheModel?.toValue(),
        EnumMethod.name => cacheModel?.name(),
      },
      "channelSearchKind": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => channelSearchKind?.toNativeValue(),
        EnumMethod.value => channelSearchKind?.toValue(),
        EnumMethod.name => channelSearchKind?.name(),
      },
      "customSchemeRegistrations": customSchemeRegistrations
          ?.map((e) => e.toMap(enumMethod: enumMethod))
          .toList(),
      "enableTrackingPrevention": enableTrackingPrevention,
      "exclusiveUserDataFolderAccess": exclusiveUserDataFolderAccess,
      "isCustomCrashReportingEnabled": isCustomCrashReportingEnabled,
      "language": language,
      "preferredLanguages": preferredLanguages,
      "releaseChannels": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => releaseChannels?.toNativeValue(),
        EnumMethod.value => releaseChannels?.toValue(),
        EnumMethod.name => releaseChannels?.name(),
      },
      "sandboxPaths": sandboxPaths,
      "scrollbarStyle": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => scrollbarStyle?.toNativeValue(),
        EnumMethod.value => scrollbarStyle?.toValue(),
        EnumMethod.name => scrollbarStyle?.name(),
      },
      "spellCheckingEnabled": spellCheckingEnabled,
      "spellCheckingLanguages": spellCheckingLanguages,
      "targetCompatibleBrowserVersion": targetCompatibleBrowserVersion,
      "timeZoneOverride": timeZoneOverride,
      "userDataFolder": userDataFolder,
      "webProcessExtensionsDirectory": webProcessExtensionsDirectory,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  ///Returns a copy of WebViewEnvironmentSettings.
  WebViewEnvironmentSettings copy() {
    return WebViewEnvironmentSettings.fromMap(toMap()) ??
        WebViewEnvironmentSettings();
  }

  @override
  String toString() {
    return 'WebViewEnvironmentSettings{additionalBrowserArguments: $additionalBrowserArguments, allowSingleSignOnUsingOSPrimaryAccount: $allowSingleSignOnUsingOSPrimaryAccount, areBrowserExtensionsEnabled: $areBrowserExtensionsEnabled, automationAllowed: $automationAllowed, browserExecutableFolder: $browserExecutableFolder, cacheModel: $cacheModel, channelSearchKind: $channelSearchKind, customSchemeRegistrations: $customSchemeRegistrations, enableTrackingPrevention: $enableTrackingPrevention, exclusiveUserDataFolderAccess: $exclusiveUserDataFolderAccess, isCustomCrashReportingEnabled: $isCustomCrashReportingEnabled, language: $language, preferredLanguages: $preferredLanguages, releaseChannels: $releaseChannels, sandboxPaths: $sandboxPaths, scrollbarStyle: $scrollbarStyle, spellCheckingEnabled: $spellCheckingEnabled, spellCheckingLanguages: $spellCheckingLanguages, targetCompatibleBrowserVersion: $targetCompatibleBrowserVersion, timeZoneOverride: $timeZoneOverride, userDataFolder: $userDataFolder, webProcessExtensionsDirectory: $webProcessExtensionsDirectory}';
  }
}

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

///List of [WebViewEnvironmentSettings]'s properties that can be used to check i they are supported or not by the current platform.
enum WebViewEnvironmentSettingsProperty {
  ///Can be used to check if the [WebViewEnvironmentSettings.additionalBrowserArguments] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.WebViewEnvironmentSettings.additionalBrowserArguments.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - ICoreWebView2EnvironmentOptions.put_AdditionalBrowserArguments](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions?view=webview2-1.0.2210.55#put_additionalbrowserarguments))
  ///
  ///Use the [WebViewEnvironmentSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  additionalBrowserArguments,

  ///Can be used to check if the [WebViewEnvironmentSettings.allowSingleSignOnUsingOSPrimaryAccount] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.WebViewEnvironmentSettings.allowSingleSignOnUsingOSPrimaryAccount.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - ICoreWebView2EnvironmentOptions.put_AllowSingleSignOnUsingOSPrimaryAccount](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions?view=webview2-1.0.2210.55#put_allowsinglesignonusingosprimaryaccount))
  ///
  ///Use the [WebViewEnvironmentSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  allowSingleSignOnUsingOSPrimaryAccount,

  ///Can be used to check if the [WebViewEnvironmentSettings.areBrowserExtensionsEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.WebViewEnvironmentSettings.areBrowserExtensionsEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.2210.55+ ([Official API - ICoreWebView2EnvironmentOptions6.put_AreBrowserExtensionsEnabled](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions6?view=webview2-1.0.2849.39#put_arebrowserextensionsenabled))
  ///
  ///Use the [WebViewEnvironmentSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  areBrowserExtensionsEnabled,

  ///Can be used to check if the [WebViewEnvironmentSettings.automationAllowed] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.WebViewEnvironmentSettings.automationAllowed.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - webkit_web_context_set_automation_allowed](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebContext.set_automation_allowed.html))
  ///
  ///Use the [WebViewEnvironmentSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  automationAllowed,

  ///Can be used to check if the [WebViewEnvironmentSettings.browserExecutableFolder] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.WebViewEnvironmentSettings.browserExecutableFolder.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - CreateCoreWebView2EnvironmentWithOptions.browserExecutableFolder](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#createcorewebview2environmentwithoptions))
  ///
  ///Use the [WebViewEnvironmentSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  browserExecutableFolder,

  ///Can be used to check if the [WebViewEnvironmentSettings.cacheModel] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.WebViewEnvironmentSettings.cacheModel.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - webkit_web_context_set_cache_model](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebContext.set_cache_model.html))
  ///
  ///Use the [WebViewEnvironmentSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  cacheModel,

  ///Can be used to check if the [WebViewEnvironmentSettings.channelSearchKind] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.WebViewEnvironmentSettings.channelSearchKind.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.2478.35+ ([Official API - ICoreWebView2EnvironmentOptions7.put_ChannelSearchKind](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions7?view=webview2-1.0.2849.39#put_channelsearchkind))
  ///
  ///Use the [WebViewEnvironmentSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  channelSearchKind,

  ///Can be used to check if the [WebViewEnvironmentSettings.customSchemeRegistrations] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.WebViewEnvironmentSettings.customSchemeRegistrations.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.1587.40+ ([Official API - ICoreWebView2EnvironmentOptions4.SetCustomSchemeRegistrations](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions4?view=webview2-1.0.2739.15#setcustomschemeregistrations))
  ///
  ///Use the [WebViewEnvironmentSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  customSchemeRegistrations,

  ///Can be used to check if the [WebViewEnvironmentSettings.enableTrackingPrevention] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.WebViewEnvironmentSettings.enableTrackingPrevention.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.1661.34+ ([Official API - ICoreWebView2EnvironmentOptions5.put_EnableTrackingPrevention](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions5?view=webview2-1.0.2849.39#put_enabletrackingprevention))
  ///
  ///Use the [WebViewEnvironmentSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  enableTrackingPrevention,

  ///Can be used to check if the [WebViewEnvironmentSettings.exclusiveUserDataFolderAccess] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.WebViewEnvironmentSettings.exclusiveUserDataFolderAccess.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.1185.39+ ([Official API - ICoreWebView2EnvironmentOptions2.put_ExclusiveUserDataFolderAccess](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions2?view=webview2-1.0.2849.39#put_exclusiveuserdatafolderaccess))
  ///
  ///Use the [WebViewEnvironmentSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  exclusiveUserDataFolderAccess,

  ///Can be used to check if the [WebViewEnvironmentSettings.isCustomCrashReportingEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.WebViewEnvironmentSettings.isCustomCrashReportingEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.1518.46+ ([Official API - ICoreWebView2EnvironmentOptions3.put_IsCustomCrashReportingEnabled](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions3?view=webview2-1.0.2849.39#put_iscustomcrashreportingenabled))
  ///
  ///Use the [WebViewEnvironmentSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  isCustomCrashReportingEnabled,

  ///Can be used to check if the [WebViewEnvironmentSettings.language] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.WebViewEnvironmentSettings.language.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - ICoreWebView2EnvironmentOptions.put_Language](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions?view=webview2-1.0.2210.55#put_language))
  ///
  ///Use the [WebViewEnvironmentSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  language,

  ///Can be used to check if the [WebViewEnvironmentSettings.preferredLanguages] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.WebViewEnvironmentSettings.preferredLanguages.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - webkit_web_context_set_preferred_languages](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebContext.set_preferred_languages.html))
  ///
  ///Use the [WebViewEnvironmentSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  preferredLanguages,

  ///Can be used to check if the [WebViewEnvironmentSettings.releaseChannels] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.WebViewEnvironmentSettings.releaseChannels.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.2478.35+ ([Official API - ICoreWebView2EnvironmentOptions7.put_ReleaseChannels](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions7?view=webview2-1.0.2849.39#put_releasechannels))
  ///
  ///Use the [WebViewEnvironmentSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  releaseChannels,

  ///Can be used to check if the [WebViewEnvironmentSettings.sandboxPaths] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.WebViewEnvironmentSettings.sandboxPaths.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - webkit_web_context_add_path_to_sandbox](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebContext.add_path_to_sandbox.html))
  ///
  ///Use the [WebViewEnvironmentSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  sandboxPaths,

  ///Can be used to check if the [WebViewEnvironmentSettings.scrollbarStyle] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.WebViewEnvironmentSettings.scrollbarStyle.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.2535.41+ ([Official API - ICoreWebView2EnvironmentOptions8.put_ScrollBarStyle](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions8?view=webview2-1.0.2849.39#put_scrollbarstyle))
  ///
  ///Use the [WebViewEnvironmentSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  scrollbarStyle,

  ///Can be used to check if the [WebViewEnvironmentSettings.spellCheckingEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.WebViewEnvironmentSettings.spellCheckingEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - webkit_web_context_set_spell_checking_enabled](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebContext.set_spell_checking_enabled.html))
  ///
  ///Use the [WebViewEnvironmentSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  spellCheckingEnabled,

  ///Can be used to check if the [WebViewEnvironmentSettings.spellCheckingLanguages] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.WebViewEnvironmentSettings.spellCheckingLanguages.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - webkit_web_context_set_spell_checking_languages](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebContext.set_spell_checking_languages.html))
  ///
  ///Use the [WebViewEnvironmentSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  spellCheckingLanguages,

  ///Can be used to check if the [WebViewEnvironmentSettings.targetCompatibleBrowserVersion] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.WebViewEnvironmentSettings.targetCompatibleBrowserVersion.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - ICoreWebView2EnvironmentOptions.put_TargetCompatibleBrowserVersion](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions?view=webview2-1.0.2210.55#put_targetcompatiblebrowserversion))
  ///
  ///Use the [WebViewEnvironmentSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  targetCompatibleBrowserVersion,

  ///Can be used to check if the [WebViewEnvironmentSettings.timeZoneOverride] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.WebViewEnvironmentSettings.timeZoneOverride.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - time-zone-override](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/class.WebContext.html)):
  ///    - This property must be set at WebContext construction time.
  ///
  ///Use the [WebViewEnvironmentSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  timeZoneOverride,

  ///Can be used to check if the [WebViewEnvironmentSettings.userDataFolder] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.WebViewEnvironmentSettings.userDataFolder.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - CreateCoreWebView2EnvironmentWithOptions.userDataFolder](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#createcorewebview2environmentwithoptions))
  ///
  ///Use the [WebViewEnvironmentSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  userDataFolder,

  ///Can be used to check if the [WebViewEnvironmentSettings.webProcessExtensionsDirectory] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.WebViewEnvironmentSettings.webProcessExtensionsDirectory.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - webkit_web_context_set_web_process_extensions_directory](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebContext.set_web_process_extensions_directory.html))
  ///
  ///Use the [WebViewEnvironmentSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  webProcessExtensionsDirectory,
}

extension _WebViewEnvironmentSettingsPropertySupported
    on WebViewEnvironmentSettings {
  static bool isPropertySupported(
    WebViewEnvironmentSettingsProperty property, {
    TargetPlatform? platform,
  }) {
    switch (property) {
      case WebViewEnvironmentSettingsProperty.additionalBrowserArguments:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case WebViewEnvironmentSettingsProperty
          .allowSingleSignOnUsingOSPrimaryAccount:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case WebViewEnvironmentSettingsProperty.areBrowserExtensionsEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case WebViewEnvironmentSettingsProperty.automationAllowed:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.linux].contains(platform ?? defaultTargetPlatform);
      case WebViewEnvironmentSettingsProperty.browserExecutableFolder:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case WebViewEnvironmentSettingsProperty.cacheModel:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.linux].contains(platform ?? defaultTargetPlatform);
      case WebViewEnvironmentSettingsProperty.channelSearchKind:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case WebViewEnvironmentSettingsProperty.customSchemeRegistrations:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case WebViewEnvironmentSettingsProperty.enableTrackingPrevention:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case WebViewEnvironmentSettingsProperty.exclusiveUserDataFolderAccess:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case WebViewEnvironmentSettingsProperty.isCustomCrashReportingEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case WebViewEnvironmentSettingsProperty.language:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case WebViewEnvironmentSettingsProperty.preferredLanguages:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.linux].contains(platform ?? defaultTargetPlatform);
      case WebViewEnvironmentSettingsProperty.releaseChannels:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case WebViewEnvironmentSettingsProperty.sandboxPaths:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.linux].contains(platform ?? defaultTargetPlatform);
      case WebViewEnvironmentSettingsProperty.scrollbarStyle:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case WebViewEnvironmentSettingsProperty.spellCheckingEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.linux].contains(platform ?? defaultTargetPlatform);
      case WebViewEnvironmentSettingsProperty.spellCheckingLanguages:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.linux].contains(platform ?? defaultTargetPlatform);
      case WebViewEnvironmentSettingsProperty.targetCompatibleBrowserVersion:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case WebViewEnvironmentSettingsProperty.timeZoneOverride:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.linux].contains(platform ?? defaultTargetPlatform);
      case WebViewEnvironmentSettingsProperty.userDataFolder:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case WebViewEnvironmentSettingsProperty.webProcessExtensionsDirectory:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.linux].contains(platform ?? defaultTargetPlatform);
    }
  }
}
