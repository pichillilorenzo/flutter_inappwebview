import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'platform_webview_environment.dart';

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

  WebViewEnvironmentSettings_(
      {this.browserExecutableFolder,
      this.userDataFolder,
      this.additionalBrowserArguments,
      this.allowSingleSignOnUsingOSPrimaryAccount,
      this.language,
      this.targetCompatibleBrowserVersion});
}
