import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'webview_feature.dart';
import '../in_app_webview/webview.dart';
import '../in_app_webview/in_app_webview_controller.dart';
import '../cookie_manager.dart';

part 'process_global_config.g.dart';

///Process Global Configuration for [WebView].
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
///to ensure that it happens before any other thread can call a method that loads [WebView].
///
///**Supported Platforms/Implementations**:
///- Android native WebView ([Official API - ProcessGlobalConfig](https://developer.android.com/reference/androidx/webkit/ProcessGlobalConfig))
class ProcessGlobalConfig {
  static ProcessGlobalConfig? _instance;
  static const MethodChannel _channel = const MethodChannel(
      'com.pichillilorenzo/flutter_inappwebview_processglobalconfig');

  ProcessGlobalConfig._();

  ///Gets the [ProcessGlobalConfig] shared instance.
  static ProcessGlobalConfig instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static ProcessGlobalConfig _init() {
    _channel.setMethodCallHandler((call) async {
      try {
        return await _handleMethod(call);
      } on Error catch (e) {
        print(e);
        print(e.stackTrace);
      }
    });
    _instance = ProcessGlobalConfig._();
    return _instance!;
  }

  static Future<dynamic> _handleMethod(MethodCall call) async {
    // ProcessGlobalConfig controller = ProcessGlobalConfig.instance();
    switch (call.method) {
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
    // return null;
  }

  ///Applies the configuration to be used by [WebView] on loading.
  ///This method can only be called once.
  ///
  ///Calling this method will not cause [WebView] to be loaded and will not block the calling thread.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - ProcessGlobalConfig.apply](https://developer.android.com/reference/androidx/webkit/ProcessGlobalConfig#apply(androidx.webkit.ProcessGlobalConfig)))
  Future<void> apply({required ProcessGlobalConfigSettings settings}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("settings", () => settings.toMap());
    return await _channel.invokeMethod('apply', args);
  }
}

///Class that represents the settings used to configure the [ProcessGlobalConfig].
///
///**Supported Platforms/Implementations**:
///- Android native WebView
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
  ///This means that different processes in the same application cannot directly share [WebView]-related data,
  ///since the data directories must be distinct.
  ///Applications that use this API may have to explicitly pass data between processes.
  ///For example, login cookies may have to be copied from one process's cookie jar to the other using [CookieManager] if both processes' WebViews are intended to be logged in.
  ///
  ///Most applications should simply ensure that all components of the app that rely
  ///on WebView are in the same process, to avoid needing multiple data directories.
  ///The [InAppWebViewController.disableWebView] method can be used to ensure that the other processes do not use WebView by accident in this case.
  ///
  ///**NOTE**: available only if [WebViewFeature.STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX] feature is supported.
  String? dataDirectorySuffix;

  ///Set the base directories that [WebView] will use for the current process.
  ///If this method is not used, [WebView] uses the default base paths defined by the Android framework.
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
  ///If they do not already exist, [WebView] will attempt to create them during initialization, along with any missing parent directories.
  ///In such a case, the directory in which [WebView] creates missing directories must be readable and writable by the current process.
  ///
  ///**NOTE**: available only if [WebViewFeature.STARTUP_FEATURE_SET_DIRECTORY_BASE_PATHS] feature is supported.
  ProcessGlobalConfigDirectoryBasePaths_? directoryBasePaths;

  ProcessGlobalConfigSettings_(
      {this.dataDirectorySuffix, this.directoryBasePaths});
}

///Class that represents the settings used to configure the [ProcessGlobalConfigSettings.directoryBasePaths].
///
///**Supported Platforms/Implementations**:
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
