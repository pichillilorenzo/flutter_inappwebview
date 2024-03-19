import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../debug_logging_settings.dart';
import '../inappwebview_platform.dart';
import '../types/disposable.dart';
import 'webview_environment_settings.dart';

/// Object specifying creation parameters for creating a [PlatformWebViewEnvironment].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
@immutable
class PlatformWebViewEnvironmentCreationParams {
  /// Used by the platform implementation to create a new [PlatformWebViewEnvironment].
  const PlatformWebViewEnvironmentCreationParams({this.settings});

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.settings}
  final WebViewEnvironmentSettings? settings;
}

///Controls a WebView Environment used by WebView instances.
///Use [dispose] when not needed anymore to release references.
///
///**Officially Supported Platforms/Implementations**:
///- Windows
abstract class PlatformWebViewEnvironment extends PlatformInterface
    implements Disposable {
  ///Debug settings used by [PlatformWebViewEnvironment].
  static DebugLoggingSettings debugLoggingSettings =
      DebugLoggingSettings(maxLogMessageLength: 1000);

  /// Creates a new [PlatformInAppWebViewController]
  factory PlatformWebViewEnvironment(
      PlatformWebViewEnvironmentCreationParams params) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformWebViewEnvironment webViewEnvironment =
        InAppWebViewPlatform.instance!.createPlatformWebViewEnvironment(params);
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
    final PlatformWebViewEnvironment webViewEnvironment =
        InAppWebViewPlatform.instance!.createPlatformWebViewEnvironmentStatic();
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
  String get id =>
      throw UnimplementedError('id is not implemented on the current platform');

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.settings}
  /// WebView Environment settings.
  ///{@endtemplate}
  WebViewEnvironmentSettings? get settings => params.settings;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.create}
  ///Creates the [PlatformWebViewEnvironment] using [settings].
  ///
  ///Check https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#createcorewebview2environmentwithoptions
  ///for more info.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - CreateCoreWebView2EnvironmentWithOptions](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#createcorewebview2environmentwithoptions))
  ///{@endtemplate}
  Future<PlatformWebViewEnvironment> create(
      {WebViewEnvironmentSettings? settings}) {
    throw UnimplementedError(
        'create is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.getAvailableVersion}
  ///Get the browser version info including channel name if it is not the WebView2 Runtime.
  ///
  ///Channel names are Beta, Dev, and Canary.
  ///If an override exists for the browserExecutableFolder or the channel preference, the override is used.
  ///If an override is not specified, then the parameter value passed to [getAvailableVersion] is used.
  ///Returns `null` if it fails to find an installed WebView2 runtime or non-stable Microsoft Edge installation.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - GetAvailableCoreWebView2BrowserVersionString](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#comparebrowserversions))
  ///{@endtemplate}
  Future<String?> getAvailableVersion({String? browserExecutableFolder}) {
    throw UnimplementedError(
        'getAvailableVersion is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.compareBrowserVersions}
  ///This method is for anyone want to compare version correctly to determine which version is newer, older or same.
  ///
  ///Use it to determine whether to use webview2 or certain feature based upon version.
  ///Sets the value of result to `-1`, `0` or `1` if version1 is less than, equal or greater than version2 respectively.
  ///Returns `null` if it fails to parse any of the version strings.
  ///Directly use the version info obtained from [getAvailableVersion] with input, channel information is ignored.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows ([Official API - CompareBrowserVersions](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#comparebrowserversions))
  ///{@endtemplate}
  Future<int?> compareBrowserVersions(
      {required String version1, required String version2}) {
    throw UnimplementedError(
        'compareBrowserVersions is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.dispose}
  ///Disposes the WebView Environment reference.
  ///{@endtemplate}
  Future<void> dispose() {
    throw UnimplementedError(
        'dispose is not implemented on the current platform');
  }
}
