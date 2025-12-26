import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'in_app_webview/platform_inappwebview_controller.dart';
import 'inappwebview_platform.dart';
import 'platform_webview_feature.dart';
import 'types/enum_method.dart';

part 'platform_process_global_config.g.dart';

///{@template flutter_inappwebview_platform_interface.PlatformProcessGlobalConfigCreationParams}
/// Object specifying creation parameters for creating a [PlatformProcessGlobalConfig].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformProcessGlobalConfigCreationParams.supported_platforms}
@SupportedPlatforms(platforms: [
  AndroidPlatform(),
])
@immutable
class PlatformProcessGlobalConfigCreationParams {
  /// Used by the platform implementation to create a new [PlatformProcessGlobalConfig].
  const PlatformProcessGlobalConfigCreationParams();

  ///{@template flutter_inappwebview_platform_interface.PlatformProcessGlobalConfigCreationParams.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformProcessGlobalConfigCreationParamsClassSupported.isClassSupported(
          platform: platform);
}

///{@template flutter_inappwebview_platform_interface.PlatformProcessGlobalConfig}
///Process Global Configuration for `WebView`.
///WebView has some process-global configuration parameters
///that cannot be changed once WebView has been loaded.
///This class allows apps to set these parameters.
///
///If it is used, the configuration should be set and apply should
///be called prior to loading WebView into the calling process.
///Most of the methods in `android.webkit` and `androidx.webkit` packages load WebView,
///so the configuration should be applied before calling any of these methods.
///
///The following code configures the data directory suffix that WebView uses and
///then applies the configuration. WebView uses this configuration when it is loaded.
///
///[apply] can only be called once.
///
///Only a single thread should access this class at a given time.
///
///The configuration should be set up as early as possible during application startup,
///to ensure that it happens before any other thread can call a method that loads `WebView`.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformProcessGlobalConfig.supported_platforms}
@SupportedPlatforms(platforms: [
  AndroidPlatform(
      apiName: 'ProcessGlobalConfig',
      apiUrl:
          'https://developer.android.com/reference/androidx/webkit/ProcessGlobalConfig'),
])
abstract class PlatformProcessGlobalConfig extends PlatformInterface {
  /// Creates a new [PlatformProcessGlobalConfig]
  factory PlatformProcessGlobalConfig(
      PlatformProcessGlobalConfigCreationParams params) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`WebViewPlatform.instance` before use. For unit testing, '
      '`WebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformProcessGlobalConfig processGlobalConfig = InAppWebViewPlatform
        .instance!
        .createPlatformProcessGlobalConfig(params);
    PlatformInterface.verify(processGlobalConfig, _token);
    return processGlobalConfig;
  }

  /// Creates a new [PlatformProcessGlobalConfig] to access static methods.
  factory PlatformProcessGlobalConfig.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformProcessGlobalConfig processGlobalConfigStatic =
        InAppWebViewPlatform.instance!
            .createPlatformProcessGlobalConfigStatic();
    PlatformInterface.verify(processGlobalConfigStatic, _token);
    return processGlobalConfigStatic;
  }

  /// Used by the platform implementation to create a new
  /// [PlatformProcessGlobalConfig].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformProcessGlobalConfig.implementation(this.params)
      : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformProcessGlobalConfig].
  final PlatformProcessGlobalConfigCreationParams params;

  ///{@template flutter_inappwebview_platform_interface.PlatformProcessGlobalConfig.apply}
  ///Applies the configuration to be used by `WebView` on loading.
  ///This method can only be called once.
  ///
  ///Calling this method will not cause `WebView` to be loaded and will not block the calling thread.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformProcessGlobalConfig.apply.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
        apiName: 'ProcessGlobalConfig.apply',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/ProcessGlobalConfig#apply(androidx.webkit.ProcessGlobalConfig)'),
  ])
  Future<void> apply({required ProcessGlobalConfigSettings settings}) {
    throw UnimplementedError(
        'apply is not implemented on the current platform');
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformProcessGlobalConfigCreationParams.isClassSupported}
  bool isClassSupported({TargetPlatform? platform}) =>
      params.isClassSupported(platform: platform);

  ///{@template flutter_inappwebview_platform_interface.PlatformProcessGlobalConfig.isMethodSupported}
  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isMethodSupported(PlatformProcessGlobalConfigMethod method,
          {TargetPlatform? platform}) =>
      _PlatformProcessGlobalConfigMethodSupported.isMethodSupported(method,
          platform: platform);
}

///{@template flutter_inappwebview_platform_interface.ProcessGlobalConfigSettings}
///Class that represents the settings used to configure the [PlatformProcessGlobalConfig].
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.ProcessGlobalConfigSettings.supported_platforms}
@SupportedPlatforms(platforms: [
  AndroidPlatform(
      apiName: 'ProcessGlobalConfig.apply',
      apiUrl:
          'https://developer.android.com/reference/androidx/webkit/ProcessGlobalConfig#apply(androidx.webkit.ProcessGlobalConfig)'),
])
@ExchangeableObject(copyMethod: true)
class ProcessGlobalConfigSettings_ {
  ///The directory name suffix to be used for the current process.
  ///Must not contain a path separator and should not be empty.
  ///
  ///Define the directory used to store WebView data for the current process.
  ///The provided suffix will be used when constructing data and cache directory paths.
  ///If this API is not called, no suffix will be used.
  ///Each directory can be used by only one process in the application.
  ///If more than one process in an app wishes to use WebView,
  ///only one process can use the default directory,
  ///and other processes must call this API to define a unique suffix.
  ///
  ///This means that different processes in the same application cannot directly share `WebView`-related data,
  ///since the data directories must be distinct.
  ///Applications that use this API may have to explicitly pass data between processes.
  ///For example, login cookies may have to be copied from one process's cookie jar to the other using [PlatformCookieManager] if both processes' WebViews are intended to be logged in.
  ///
  ///Most applications should simply ensure that all components of the app that rely
  ///on WebView are in the same process, to avoid needing multiple data directories.
  ///The [PlatformInAppWebViewController.disableWebView] method can be used to ensure that the other processes do not use WebView by accident in this case.
  ///
  ///{@macro flutter_inappwebview_platform_interface.ProcessGlobalConfigSettings.dataDirectorySuffix.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
        note:
            'Available only if [WebViewFeature.STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX] feature is supported.'),
  ])
  String? dataDirectorySuffix;

  ///Set the base directories that `WebView` will use for the current process.
  ///If this method is not used, `WebView` uses the default base paths defined by the Android framework.
  ///
  ///WebView will create and use a subdirectory under each of the base paths supplied to this method.
  ///
  ///This method can be used in conjunction with setDataDirectorySuffix.
  ///A different subdirectory is created for each suffix.
  ///
  ///The base paths must be absolute paths.
  ///
  ///The data directory must not be under the Android cache directory,
  ///as Android may delete cache files when disk space is low and WebView may not function properly if this occurs.
  ///Refer to [this link](https://developer.android.com/training/data-storage/app-specific#internal-remove-cache).
  ///
  ///If the specified directories already exist then they must be readable and writable by the current process.
  ///If they do not already exist, `WebView` will attempt to create them during initialization, along with any missing parent directories.
  ///In such a case, the directory in which `WebView` creates missing directories must be readable and writable by the current process.
  ///
  ///{@macro flutter_inappwebview_platform_interface.ProcessGlobalConfigSettings.directoryBasePaths.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
        note:
            'Available only if [WebViewFeature.STARTUP_FEATURE_SET_DIRECTORY_BASE_PATHS] feature is supported.'),
  ])
  ProcessGlobalConfigDirectoryBasePaths_? directoryBasePaths;

  ProcessGlobalConfigSettings_(
      {this.dataDirectorySuffix, this.directoryBasePaths});

  ///{@template flutter_inappwebview_platform_interface.ProcessGlobalConfigSettings.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) =>
      _ProcessGlobalConfigSettingsClassSupported.isClassSupported(
          platform: platform);

  ///{@template flutter_inappwebview_platform_interface.ProcessGlobalConfigSettings.isPropertySupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  static bool isPropertySupported(ProcessGlobalConfigSettingsProperty property,
          {TargetPlatform? platform}) =>
      _ProcessGlobalConfigSettingsPropertySupported.isPropertySupported(
          property,
          platform: platform);
}

///Class that represents the settings used to configure the [ProcessGlobalConfigSettings.directoryBasePaths].
///
///**Officially Supported Platforms/Implementations**:
///- Android native WebView ([Official API - ProxyConfig](https://developer.android.com/reference/androidx/webkit/ProxyConfig))
@ExchangeableObject()
class ProcessGlobalConfigDirectoryBasePaths_ {
  ///The absolute base path for the WebView data directory.
  String dataDirectoryBasePath;

  ///The absolute base path for the WebView cache directory.
  String cacheDirectoryBasePath;

  ProcessGlobalConfigDirectoryBasePaths_(
      {required this.dataDirectoryBasePath,
      required this.cacheDirectoryBasePath});
}
