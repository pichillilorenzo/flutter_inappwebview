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
///- Windows
class WebViewEnvironmentSettings {
  ///If there are multiple switches, there should be a space in between them.
  ///The one exception is if multiple features are being enabled/disabled for a single switch,
  ///in which case the features should be comma-seperated.
  ///Example: `"--disable-features=feature1,feature2 --some-other-switch --do-something"`
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - ICoreWebView2EnvironmentOptions.put_AdditionalBrowserArguments](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions?view=webview2-1.0.2210.55#put_additionalbrowserarguments))
  final String? additionalBrowserArguments;

  ///This property is used to enable single sign on with Azure Active Directory (AAD)
  ///and personal Microsoft Account (MSA) resources inside WebView.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - ICoreWebView2EnvironmentOptions.put_AllowSingleSignOnUsingOSPrimaryAccount](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions?view=webview2-1.0.2210.55#put_allowsinglesignonusingosprimaryaccount))
  final bool? allowSingleSignOnUsingOSPrimaryAccount;

  ///When this property is set to `true` new extensions can be added to user profile and used.
  ///
  ///[areBrowserExtensionsEnabled] is default to be `false`, in this case, new extensions can't be installed,
  ///and already installed extension won't be available to use in user profile.
  ///If connecting to an already running environment with a different value for
  ///[areBrowserExtensionsEnabled] property, it will fail with `HRESULT_FROM_WIN32(ERROR_INVALID_STATE)`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows 1.0.2210.55+ ([Official API - ICoreWebView2EnvironmentOptions6.put_AreBrowserExtensionsEnabled](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions6?view=webview2-1.0.2849.39#put_arebrowserextensionsenabled))
  final bool? areBrowserExtensionsEnabled;

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
  ///- Windows ([Official API - CreateCoreWebView2EnvironmentWithOptions.browserExecutableFolder](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#createcorewebview2environmentwithoptions))
  final String? browserExecutableFolder;

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
  ///- Windows 1.0.2478.35+ ([Official API - ICoreWebView2EnvironmentOptions7.put_ChannelSearchKind](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions7?view=webview2-1.0.2849.39#put_channelsearchkind))
  final EnvironmentChannelSearchKind? channelSearchKind;

  ///Set the array of custom scheme registrations to be used.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows 1.0.1587.40+ ([Official API - ICoreWebView2EnvironmentOptions4.SetCustomSchemeRegistrations](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions4?view=webview2-1.0.2739.15#setcustomschemeregistrations))
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
  ///- Windows 1.0.1661.34+ ([Official API - ICoreWebView2EnvironmentOptions5.put_EnableTrackingPrevention](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions5?view=webview2-1.0.2849.39#put_enabletrackingprevention))
  final bool? enableTrackingPrevention;

  ///Whether other processes can create WebView2 from WebView2Environment created
  ///with the same user data folder and therefore sharing the same WebView browser process instance.
  ///
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows 1.0.1185.39+ ([Official API - ICoreWebView2EnvironmentOptions2.put_ExclusiveUserDataFolderAccess](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions2?view=webview2-1.0.2849.39#put_exclusiveuserdatafolderaccess))
  final bool? exclusiveUserDataFolderAccess;

  ///When IsCustomCrashReportingEnabled is set to `true`,
  ///Windows won't send crash data to Microsoft endpoint.
  ///
  ///The default value is `false`.
  ///In this case, WebView will respect OS consent.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows 1.0.1518.46+ ([Official API - ICoreWebView2EnvironmentOptions3.put_IsCustomCrashReportingEnabled](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions3?view=webview2-1.0.2849.39#put_iscustomcrashreportingenabled))
  final bool? isCustomCrashReportingEnabled;

  ///The default display language for WebView.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - ICoreWebView2EnvironmentOptions.put_Language](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions?view=webview2-1.0.2210.55#put_language))
  final String? language;

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
  ///- Windows 1.0.2478.35+ ([Official API - ICoreWebView2EnvironmentOptions7.put_ReleaseChannels](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions7?view=webview2-1.0.2849.39#put_releasechannels))
  final EnvironmentReleaseChannels? releaseChannels;

  ///The ScrollBar style being set on the WebView2 Environment.
  ///
  ///The default value is [EnvironmentScrollbarStyle.DEFAULT] which specifies the default browser ScrollBar style.
  ///The `color-scheme` CSS property needs to be set on the corresponding
  ///page to allow ScrollBar to follow light or dark theme.
  ///Please see [color-scheme](https://developer.mozilla.org/docs/Web/CSS/color-scheme#declaring_color_scheme_preferences) for how `color-scheme` can be set.
  ///CSS styles that modify the ScrollBar applied on top of native ScrollBar styling that is selected with [scrollbarStyle].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows 1.0.2535.41+ ([Official API - ICoreWebView2EnvironmentOptions8.put_ScrollBarStyle](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions8?view=webview2-1.0.2849.39#put_scrollbarstyle))
  final EnvironmentScrollbarStyle? scrollbarStyle;

  ///Specifies the version of the WebView2 Runtime binaries required to be compatible with your app.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - ICoreWebView2EnvironmentOptions.put_TargetCompatibleBrowserVersion](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions?view=webview2-1.0.2210.55#put_targetcompatiblebrowserversion))
  final String? targetCompatibleBrowserVersion;

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
  ///- Windows ([Official API - CreateCoreWebView2EnvironmentWithOptions.userDataFolder](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#createcorewebview2environmentwithoptions))
  final String? userDataFolder;

  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows
  WebViewEnvironmentSettings(
      {this.additionalBrowserArguments,
      this.allowSingleSignOnUsingOSPrimaryAccount,
      this.areBrowserExtensionsEnabled,
      this.browserExecutableFolder,
      this.channelSearchKind,
      this.customSchemeRegistrations,
      this.enableTrackingPrevention,
      this.exclusiveUserDataFolderAccess,
      this.isCustomCrashReportingEnabled,
      this.language,
      this.releaseChannels,
      this.scrollbarStyle,
      this.targetCompatibleBrowserVersion,
      this.userDataFolder});

  ///Gets a possible [WebViewEnvironmentSettings] instance from a [Map] value.
  static WebViewEnvironmentSettings? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = WebViewEnvironmentSettings(
      additionalBrowserArguments: map['additionalBrowserArguments'],
      allowSingleSignOnUsingOSPrimaryAccount:
          map['allowSingleSignOnUsingOSPrimaryAccount'],
      areBrowserExtensionsEnabled: map['areBrowserExtensionsEnabled'],
      browserExecutableFolder: map['browserExecutableFolder'],
      channelSearchKind: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => EnvironmentChannelSearchKind.fromNativeValue(
            map['channelSearchKind']),
        EnumMethod.value =>
          EnvironmentChannelSearchKind.fromValue(map['channelSearchKind']),
        EnumMethod.name =>
          EnvironmentChannelSearchKind.byName(map['channelSearchKind'])
      },
      customSchemeRegistrations: map['customSchemeRegistrations'] != null
          ? List<CustomSchemeRegistration>.from(map['customSchemeRegistrations']
              .map((e) => CustomSchemeRegistration.fromMap(
                  e?.cast<String, dynamic>(),
                  enumMethod: enumMethod)!))
          : null,
      enableTrackingPrevention: map['enableTrackingPrevention'],
      exclusiveUserDataFolderAccess: map['exclusiveUserDataFolderAccess'],
      isCustomCrashReportingEnabled: map['isCustomCrashReportingEnabled'],
      language: map['language'],
      releaseChannels: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          EnvironmentReleaseChannels.fromNativeValue(map['releaseChannels']),
        EnumMethod.value =>
          EnvironmentReleaseChannels.fromValue(map['releaseChannels']),
        EnumMethod.name =>
          EnvironmentReleaseChannels.byName(map['releaseChannels'])
      },
      scrollbarStyle: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          EnvironmentScrollbarStyle.fromNativeValue(map['scrollbarStyle']),
        EnumMethod.value =>
          EnvironmentScrollbarStyle.fromValue(map['scrollbarStyle']),
        EnumMethod.name =>
          EnvironmentScrollbarStyle.byName(map['scrollbarStyle'])
      },
      targetCompatibleBrowserVersion: map['targetCompatibleBrowserVersion'],
      userDataFolder: map['userDataFolder'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "additionalBrowserArguments": additionalBrowserArguments,
      "allowSingleSignOnUsingOSPrimaryAccount":
          allowSingleSignOnUsingOSPrimaryAccount,
      "areBrowserExtensionsEnabled": areBrowserExtensionsEnabled,
      "browserExecutableFolder": browserExecutableFolder,
      "channelSearchKind": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => channelSearchKind?.toNativeValue(),
        EnumMethod.value => channelSearchKind?.toValue(),
        EnumMethod.name => channelSearchKind?.name()
      },
      "customSchemeRegistrations": customSchemeRegistrations
          ?.map((e) => e.toMap(enumMethod: enumMethod))
          .toList(),
      "enableTrackingPrevention": enableTrackingPrevention,
      "exclusiveUserDataFolderAccess": exclusiveUserDataFolderAccess,
      "isCustomCrashReportingEnabled": isCustomCrashReportingEnabled,
      "language": language,
      "releaseChannels": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => releaseChannels?.toNativeValue(),
        EnumMethod.value => releaseChannels?.toValue(),
        EnumMethod.name => releaseChannels?.name()
      },
      "scrollbarStyle": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => scrollbarStyle?.toNativeValue(),
        EnumMethod.value => scrollbarStyle?.toValue(),
        EnumMethod.name => scrollbarStyle?.name()
      },
      "targetCompatibleBrowserVersion": targetCompatibleBrowserVersion,
      "userDataFolder": userDataFolder,
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
    return 'WebViewEnvironmentSettings{additionalBrowserArguments: $additionalBrowserArguments, allowSingleSignOnUsingOSPrimaryAccount: $allowSingleSignOnUsingOSPrimaryAccount, areBrowserExtensionsEnabled: $areBrowserExtensionsEnabled, browserExecutableFolder: $browserExecutableFolder, channelSearchKind: $channelSearchKind, customSchemeRegistrations: $customSchemeRegistrations, enableTrackingPrevention: $enableTrackingPrevention, exclusiveUserDataFolderAccess: $exclusiveUserDataFolderAccess, isCustomCrashReportingEnabled: $isCustomCrashReportingEnabled, language: $language, releaseChannels: $releaseChannels, scrollbarStyle: $scrollbarStyle, targetCompatibleBrowserVersion: $targetCompatibleBrowserVersion, userDataFolder: $userDataFolder}';
  }
}
