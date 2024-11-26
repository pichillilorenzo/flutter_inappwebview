import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'platform_webview_environment.dart';
import '../types/custom_scheme_registration.dart';
import '../types/enum_method.dart';
import '../types/environment_channel_search_kind.dart';
import '../types/environment_release_channels.dart';
import '../types/environment_scrollbar_style.dart';

part 'webview_environment_settings.g.dart';

///This class represents all the [PlatformWebViewEnvironment] settings available.
///
///The [browserExecutableFolder], [userDataFolder] and [additionalBrowserArguments]
///may be overridden by values either specified in environment variables or in the registry.
@SupportedPlatforms(platforms: [WindowsPlatform()])
@ExchangeableObject(copyMethod: true)
class WebViewEnvironmentSettings_ {
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
  @SupportedPlatforms(platforms: [
    WindowsPlatform(
        apiName:
            'CreateCoreWebView2EnvironmentWithOptions.browserExecutableFolder',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#createcorewebview2environmentwithoptions')
  ])
  final String? browserExecutableFolder;

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
  @SupportedPlatforms(platforms: [
    WindowsPlatform(
        apiName: 'CreateCoreWebView2EnvironmentWithOptions.userDataFolder',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#createcorewebview2environmentwithoptions')
  ])
  final String? userDataFolder;

  ///If there are multiple switches, there should be a space in between them.
  ///The one exception is if multiple features are being enabled/disabled for a single switch,
  ///in which case the features should be comma-seperated.
  ///Example: `"--disable-features=feature1,feature2 --some-other-switch --do-something"`
  @SupportedPlatforms(platforms: [
    WindowsPlatform(
        apiName:
            'ICoreWebView2EnvironmentOptions.put_AdditionalBrowserArguments',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions?view=webview2-1.0.2210.55#put_additionalbrowserarguments')
  ])
  final String? additionalBrowserArguments;

  ///This property is used to enable single sign on with Azure Active Directory (AAD)
  ///and personal Microsoft Account (MSA) resources inside WebView.
  @SupportedPlatforms(platforms: [
    WindowsPlatform(
        apiName:
            'ICoreWebView2EnvironmentOptions.put_AllowSingleSignOnUsingOSPrimaryAccount',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions?view=webview2-1.0.2210.55#put_allowsinglesignonusingosprimaryaccount')
  ])
  final bool? allowSingleSignOnUsingOSPrimaryAccount;

  ///The default display language for WebView.
  @SupportedPlatforms(platforms: [
    WindowsPlatform(
        apiName: 'ICoreWebView2EnvironmentOptions.put_Language',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions?view=webview2-1.0.2210.55#put_language')
  ])
  final String? language;

  ///Specifies the version of the WebView2 Runtime binaries required to be compatible with your app.
  @SupportedPlatforms(platforms: [
    WindowsPlatform(
        apiName:
            'ICoreWebView2EnvironmentOptions.put_TargetCompatibleBrowserVersion',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions?view=webview2-1.0.2210.55#put_targetcompatiblebrowserversion')
  ])
  final String? targetCompatibleBrowserVersion;

  ///Set the array of custom scheme registrations to be used.
  @SupportedPlatforms(platforms: [
    WindowsPlatform(
        available: '1.0.1587.40',
        apiName:
            'ICoreWebView2EnvironmentOptions4.SetCustomSchemeRegistrations',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions4?view=webview2-1.0.2739.15#setcustomschemeregistrations')
  ])
  final List<CustomSchemeRegistration_>? customSchemeRegistrations;

  ///Whether other processes can create WebView2 from WebView2Environment created
  ///with the same user data folder and therefore sharing the same WebView browser process instance.
  ///
  ///The default value is `false`.
  @SupportedPlatforms(platforms: [
    WindowsPlatform(
        available: '1.0.1185.39',
        apiName:
            'ICoreWebView2EnvironmentOptions2.put_ExclusiveUserDataFolderAccess',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions2?view=webview2-1.0.2849.39#put_exclusiveuserdatafolderaccess')
  ])
  final bool? exclusiveUserDataFolderAccess;

  ///When IsCustomCrashReportingEnabled is set to `true`,
  ///Windows won't send crash data to Microsoft endpoint.
  ///
  ///The default value is `false`.
  ///In this case, WebView will respect OS consent.
  @SupportedPlatforms(platforms: [
    WindowsPlatform(
        available: '1.0.1518.46',
        apiName:
            'ICoreWebView2EnvironmentOptions3.put_IsCustomCrashReportingEnabled',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions3?view=webview2-1.0.2849.39#put_iscustomcrashreportingenabled')
  ])
  final bool? isCustomCrashReportingEnabled;

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
  @SupportedPlatforms(platforms: [
    WindowsPlatform(
        available: '1.0.1661.34',
        apiName:
            'ICoreWebView2EnvironmentOptions5.put_EnableTrackingPrevention',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions5?view=webview2-1.0.2849.39#put_enabletrackingprevention')
  ])
  final bool? enableTrackingPrevention;

  ///When this property is set to `true` new extensions can be added to user profile and used.
  ///
  ///[areBrowserExtensionsEnabled] is default to be `false`, in this case, new extensions can't be installed,
  ///and already installed extension won't be available to use in user profile.
  ///If connecting to an already running environment with a different value for
  ///[areBrowserExtensionsEnabled] property, it will fail with `HRESULT_FROM_WIN32(ERROR_INVALID_STATE)`.
  @SupportedPlatforms(platforms: [
    WindowsPlatform(
        available: '1.0.2210.55',
        apiName:
            'ICoreWebView2EnvironmentOptions6.put_AreBrowserExtensionsEnabled',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions6?view=webview2-1.0.2849.39#put_arebrowserextensionsenabled')
  ])
  final bool? areBrowserExtensionsEnabled;

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
  @SupportedPlatforms(platforms: [
    WindowsPlatform(
        available: '1.0.2478.35',
        apiName: 'ICoreWebView2EnvironmentOptions7.put_ChannelSearchKind',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions7?view=webview2-1.0.2849.39#put_channelsearchkind')
  ])
  final EnvironmentChannelSearchKind_? channelSearchKind;

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
  @SupportedPlatforms(platforms: [
    WindowsPlatform(
        available: '1.0.2478.35',
        apiName: 'ICoreWebView2EnvironmentOptions7.put_ReleaseChannels',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions7?view=webview2-1.0.2849.39#put_releasechannels')
  ])
  final EnvironmentReleaseChannels_? releaseChannels;

  ///The ScrollBar style being set on the WebView2 Environment.
  ///
  ///The default value is [EnvironmentScrollbarStyle.DEFAULT] which specifies the default browser ScrollBar style.
  ///The `color-scheme` CSS property needs to be set on the corresponding
  ///page to allow ScrollBar to follow light or dark theme.
  ///Please see [color-scheme](https://developer.mozilla.org/docs/Web/CSS/color-scheme#declaring_color_scheme_preferences) for how `color-scheme` can be set.
  ///CSS styles that modify the ScrollBar applied on top of native ScrollBar styling that is selected with [scrollbarStyle].
  @SupportedPlatforms(platforms: [
    WindowsPlatform(
        available: '1.0.2535.41',
        apiName: 'ICoreWebView2EnvironmentOptions8.put_ScrollBarStyle',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environmentoptions8?view=webview2-1.0.2849.39#put_scrollbarstyle')
  ])
  final EnvironmentScrollbarStyle_? scrollbarStyle;

  WebViewEnvironmentSettings_({
    this.browserExecutableFolder,
    this.userDataFolder,
    this.additionalBrowserArguments,
    this.allowSingleSignOnUsingOSPrimaryAccount,
    this.language,
    this.targetCompatibleBrowserVersion,
    this.customSchemeRegistrations,
    this.exclusiveUserDataFolderAccess,
    this.isCustomCrashReportingEnabled,
    this.enableTrackingPrevention,
    this.areBrowserExtensionsEnabled,
    this.channelSearchKind,
    this.releaseChannels,
    this.scrollbarStyle,
  });
}
