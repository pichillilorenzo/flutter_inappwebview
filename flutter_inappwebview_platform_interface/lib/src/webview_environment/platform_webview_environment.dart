import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../debug_logging_settings.dart';
import '../inappwebview_platform.dart';
import '../in_app_webview/platform_webview.dart';
import '../types/browser_process_info.dart';
import '../types/cache_model.dart';
import '../types/disposable.dart';
import '../types/browser_process_exited_detail.dart';
import '../types/browser_process_infos_changed_detail.dart';
import '../types/webview_interface.dart';
import 'webview_environment_settings.dart';

part 'platform_webview_environment.g.dart';

/// Object specifying creation parameters for creating a [PlatformWebViewEnvironment].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
@SupportedPlatforms(platforms: [WindowsPlatform(), LinuxPlatform()])
@immutable
class PlatformWebViewEnvironmentCreationParams {
  /// Used by the platform implementation to create a new [PlatformWebViewEnvironment].
  const PlatformWebViewEnvironmentCreationParams({this.settings});

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironmentCreationParams.settings}
  /// WebView Environment settings.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironmentCreationParams.settings.supported_platforms}
  @SupportedPlatforms(platforms: [WindowsPlatform()])
  final WebViewEnvironmentSettings? settings;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironmentCreationParams.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformWebViewEnvironmentCreationParamsClassSupported.isClassSupported(
        platform: platform,
      );

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironmentCreationParams.isPropertySupported}
  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isPropertySupported(
    PlatformWebViewEnvironmentCreationParamsProperty property, {
    TargetPlatform? platform,
  }) =>
      _PlatformWebViewEnvironmentCreationParamsPropertySupported.isPropertySupported(
        property,
        platform: platform,
      );
}

///Controls a WebView Environment used by WebView instances.
///Use [dispose] when not needed anymore to release references.
///
///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.supported_platforms}
@SupportedPlatforms(platforms: [WindowsPlatform(), LinuxPlatform()])
abstract class PlatformWebViewEnvironment extends PlatformInterface
    implements Disposable {
  ///Debug settings used by [PlatformWebViewEnvironment].
  static DebugLoggingSettings debugLoggingSettings = DebugLoggingSettings(
    maxLogMessageLength: 1000,
  );

  /// Creates a new [PlatformInAppWebViewController]
  factory PlatformWebViewEnvironment(
    PlatformWebViewEnvironmentCreationParams params,
  ) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformWebViewEnvironment webViewEnvironment = InAppWebViewPlatform
        .instance!
        .createPlatformWebViewEnvironment(params);
    PlatformInterface.verify(webViewEnvironment, _token);
    return webViewEnvironment;
  }

  /// Creates a new [PlatformWebViewEnvironment] to access static methods.
  factory PlatformWebViewEnvironment.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformWebViewEnvironment webViewEnvironment = InAppWebViewPlatform
        .instance!
        .createPlatformWebViewEnvironmentStatic();
    PlatformInterface.verify(webViewEnvironment, _token);
    return webViewEnvironment;
  }

  /// Used by the platform implementation to create a new [PlatformWebViewEnvironment].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformWebViewEnvironment.implementation(this.params) : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformWebViewEnvironment].
  final PlatformWebViewEnvironmentCreationParams params;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.id}
  /// WebView Environment ID.
  ///{@endtemplate}
  @SupportedPlatforms(platforms: [WindowsPlatform(), LinuxPlatform()])
  String get id =>
      throw UnimplementedError('id is not implemented on the current platform');

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironmentCreationParams.settings}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironmentCreationParams.settings.supported_platforms}
  WebViewEnvironmentSettings? get settings => params.settings;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.isInterfaceSupported}
  ///Returns `true` if the WebView Environment supports the specified [interface], otherwise `false`.
  ///Only the ones related to [WebViewInterface.ICoreWebView2Environment] are valid interfaces to check;
  ///otherwise, it will always return `false`.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.isInterfaceSupported.supported_platforms}
  @SupportedPlatforms(platforms: [WindowsPlatform()])
  Future<bool> isInterfaceSupported(WebViewInterface interface) async {
    throw UnimplementedError(
      'isInterfaceSupported is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.getProcessInfos}
  ///Returns a list of all process using same user data folder except for crashpad process.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.getProcessInfos.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        available: '1.0.1108.44+',
        apiName: 'ICoreWebView2Environment8.GetProcessInfos',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environment8?view=webview2-1.0.2849.39#getprocessinfos',
      ),
    ],
  )
  Future<List<BrowserProcessInfo>> getProcessInfos() async {
    throw UnimplementedError(
      'getProcessInfos is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.getProcessInfos}
  ///Returns the path of the folder where minidump files are written.
  ///
  ///Whenever a WebView2 process crashes, a crash dump file will be created in the crash dump folder.
  ///The crash dump format is minidump files.
  ///Please see [Minidump Files documentation](https://learn.microsoft.com/en-us/windows/win32/debug/minidump-files) for detailed information.
  ///Normally when a single child process fails, a minidump will be generated and written to disk,
  ///then the [PlatformWebViewCreationParams.onProcessFailed] event is raised.
  ///But for unexpected crashes, a minidump file might
  ///not be generated at all, despite whether [PlatformWebViewCreationParams.onProcessFailed] event is raised.
  ///If there are multiple process failures at once, multiple minidump files could be generated.
  ///Thus [getFailureReportFolderPath] could contain old minidump files that are
  ///not associated with a specific [PlatformWebViewCreationParams.onProcessFailed] event.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.getFailureReportFolderPath.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        available: '1.0.1518.46+',
        apiName: 'ICoreWebView2Environment11.get_FailureReportFolderPath',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environment11?view=webview2-1.0.2849.39#get_failurereportfolderpath',
      ),
    ],
  )
  Future<String?> getFailureReportFolderPath() async {
    throw UnimplementedError(
      'getFailureReportFolderPath is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.create}
  ///Creates the [PlatformWebViewEnvironment] using [settings].
  ///
  ///Check https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#createcorewebview2environmentwithoptions
  ///for more info.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.create.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        apiName: 'CreateCoreWebView2EnvironmentWithOptions',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#createcorewebview2environmentwithoptions',
      ),
      LinuxPlatform(
        apiName: 'WebKitWebContext',
        apiUrl:
            'https://webkitgtk.org/reference/webkit2gtk/stable/class.WebContext.html',
        note:
            'Creates a new WebKitWebContext for shared WebView configuration.',
      ),
    ],
  )
  Future<PlatformWebViewEnvironment> create({
    WebViewEnvironmentSettings? settings,
  }) {
    throw UnimplementedError(
      'create is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.getAvailableVersion}
  ///Get the browser version info including channel name if it is not the WebView2 Runtime.
  ///
  ///Channel names are Beta, Dev, and Canary.
  ///If an override exists for the browserExecutableFolder or the channel preference, the override is used.
  ///If an override is not specified, then the parameter value passed to [getAvailableVersion] is used.
  ///Returns `null` if it fails to find an installed WebView2 runtime or non-stable Microsoft Edge installation.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.getAvailableVersion.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        apiName: 'GetAvailableCoreWebView2BrowserVersionString',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#getavailablecorewebview2browserversionstring',
      ),
      LinuxPlatform(
        apiName: 'webkit_get_major_version',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/func.get_major_version.html',
        note:
            'Returns WPE WebKit version string composed of major.minor.micro versions.',
      ),
    ],
  )
  Future<String?> getAvailableVersion({String? browserExecutableFolder}) {
    throw UnimplementedError(
      'getAvailableVersion is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.compareBrowserVersions}
  ///This method is for anyone want to compare version correctly to determine which version is newer, older or same.
  ///
  ///Use it to determine whether to use webview2 or certain feature based upon version.
  ///Sets the value of result to `-1`, `0` or `1` if version1 is less than, equal or greater than version2 respectively.
  ///Returns `null` if it fails to parse any of the version strings.
  ///Directly use the version info obtained from [getAvailableVersion] with input, channel information is ignored.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.compareBrowserVersions.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        apiName: 'CompareBrowserVersions',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#comparebrowserversions',
      ),
    ],
  )
  Future<int?> compareBrowserVersions({
    required String version1,
    required String version2,
  }) {
    throw UnimplementedError(
      'compareBrowserVersions is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.onNewBrowserVersionAvailable}
  ///[onNewBrowserVersionAvailable] runs when a newer version of the WebView2 Runtime
  ///is installed and available using WebView2.
  ///To use the newer version of the browser you must create a new [PlatformWebViewEnvironment] and WebView.
  ///The event only runs for new version from the same WebView2 Runtime from which the code is running.
  ///When not running with installed WebView2 Runtime, no event is run.
  ///
  ///Because a user data folder is only able to be used by one browser process at a time,
  ///if you want to use the same user data folder in the WebView using the new version of the browser,
  ///you must close the environment and instance of WebView that are using the older version of the browser first.
  ///Or simply prompt the user to restart the app.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.onNewBrowserVersionAvailable.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        apiName: 'ICoreWebView2Environment.add_NewBrowserVersionAvailable',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environment?view=webview2-1.0.2849.39#add_newbrowserversionavailable',
      ),
    ],
  )
  void Function()? onNewBrowserVersionAvailable;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.onBrowserProcessExited}
  ///The [onBrowserProcessExited] event is raised when the collection of WebView2 Runtime
  ///processes for the browser process of this environment terminate due to browser process failure
  ///or normal shutdown (for example, when all associated WebViews are closed),
  ///after all resources have been released (including the user data folder).
  ///To learn about what these processes are, go to [Process model](https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/process-model).
  ///
  ///Multiple app processes can share a browser process by creating their webviews
  ///from a [PlatformWebViewEnvironment] with the same user data folder.
  ///When the entire collection of WebView2Runtime processes for the browser process exit,
  ///all associated [PlatformWebViewEnvironment] objects receive the [onBrowserProcessExited] event.
  ///Multiple processes sharing the same browser process need to coordinate their
  ///use of the shared user data folder to avoid race conditions and unnecessary waits.
  ///For example, one process should not clear the user data folder at the same
  ///time that another process recovers from a crash by recreating its WebView controls;
  ///one process should not block waiting for the event if other app processes
  ///are using the same browser process (the browser process will not exit
  ///until those other processes have closed their webviews too).
  ///
  ///The difference between [onBrowserProcessExited] and [PlatformWebViewCreationParams.onProcessFailed] is that
  ///[onBrowserProcessExited] is raised for any browser process exit
  ///(expected or unexpected, after all associated processes have exited too),
  ///while [PlatformWebViewCreationParams.onProcessFailed] is raised for
  ///unexpected process exits of any kind (browser, render, GPU, and all other types),
  ///or for main frame render process unresponsiveness.
  ///To learn more about the WebView2 Process Model, go to
  ///[Process model](https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/process-model).
  ///
  ///In the case the browser process crashes, both [onBrowserProcessExited] and
  ///[PlatformWebViewCreationParams.onProcessFailed] events are raised, but the order is not guaranteed.
  ///These events are intended for different scenarios.
  ///It is up to the app to coordinate the handlers so they do not try to perform
  ///reliability recovery while also trying to move to a new WebView2 Runtime version
  ///or remove the user data folder.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.onBrowserProcessExited.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        available: '1.0.992.28+',
        apiName: 'ICoreWebView2Environment5.add_BrowserProcessExited',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environment5?view=webview2-1.0.2849.39#add_browserprocessexited',
      ),
    ],
  )
  void Function(BrowserProcessExitedDetail detail)? onBrowserProcessExited;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.onProcessInfosChanged}
  ///Event fired with a list of all process using same user data folder except for crashpad process.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.onProcessInfosChanged.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        available: '1.0.1108.44+',
        apiName: 'ICoreWebView2Environment8.add_ProcessInfosChanged',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environment8?view=webview2-1.0.2849.39#add_processinfoschanged',
      ),
    ],
  )
  void Function(BrowserProcessInfosChangedDetail detail)? onProcessInfosChanged;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.isSpellCheckingEnabled}
  ///Returns whether spell checking is enabled for this WebContext.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.isSpellCheckingEnabled.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: 'webkit_web_context_get_spell_checking_enabled',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebContext.get_spell_checking_enabled.html',
      ),
    ],
  )
  Future<bool> isSpellCheckingEnabled() {
    throw UnimplementedError(
      'isSpellCheckingEnabled is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.getSpellCheckingLanguages}
  ///Returns the list of spell checking languages currently configured for this WebContext.
  ///
  ///The locale strings are in the form `lang_COUNTRY` where `lang` is an
  ///ISO-639 language code and `COUNTRY` is an ISO-3166 country code.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.getSpellCheckingLanguages.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: 'webkit_web_context_get_spell_checking_languages',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebContext.get_spell_checking_languages.html',
      ),
    ],
  )
  Future<List<String>> getSpellCheckingLanguages() {
    throw UnimplementedError(
      'getSpellCheckingLanguages is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.getCacheModel}
  ///Returns the current cache model for this WebContext.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.getCacheModel.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: 'webkit_web_context_get_cache_model',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebContext.get_cache_model.html',
      ),
    ],
  )
  Future<CacheModel?> getCacheModel() {
    throw UnimplementedError(
      'getCacheModel is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.isAutomationAllowed}
  ///Returns whether automation is allowed for this WebContext.
  ///
  ///When automation is allowed, web pages can use the WebDriver API.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.isAutomationAllowed.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      LinuxPlatform(
        apiName: 'webkit_web_context_is_automation_allowed',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebContext.is_automation_allowed.html',
      ),
    ],
  )
  Future<bool> isAutomationAllowed() {
    throw UnimplementedError(
      'isAutomationAllowed is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.dispose}
  ///Disposes the WebView Environment reference.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.dispose.supported_platforms}
  @SupportedPlatforms(platforms: [WindowsPlatform(), LinuxPlatform()])
  Future<void> dispose() {
    throw UnimplementedError(
      'dispose is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformWebViewEnvironmentClassSupported.isClassSupported(
        platform: platform,
      );

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.isPropertySupported}
  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///The property should be one of the [PlatformWebViewEnvironmentProperty] or [PlatformWebViewEnvironmentCreationParamsProperty] values.
  ///{@endtemplate}
  bool isPropertySupported(dynamic property, {TargetPlatform? platform}) =>
      property is PlatformWebViewEnvironmentCreationParamsProperty
      ? params.isPropertySupported(property, platform: platform)
      : _PlatformWebViewEnvironmentPropertySupported.isPropertySupported(
          property,
          platform: platform,
        );

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.isMethodSupported}
  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isMethodSupported(
    PlatformWebViewEnvironmentMethod method, {
    TargetPlatform? platform,
  }) => _PlatformWebViewEnvironmentMethodSupported.isMethodSupported(
    method,
    platform: platform,
  );
}
