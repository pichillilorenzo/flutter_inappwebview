import 'dart:async';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

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
  /// Constructs a [ProcessGlobalConfig].
  ///
  /// See [ProcessGlobalConfig.fromPlatformCreationParams] for setting
  /// parameters for a specific platform.
  ProcessGlobalConfig()
      : this.fromPlatformCreationParams(
    const PlatformProcessGlobalConfigCreationParams(),
  );

  /// Constructs a [ProcessGlobalConfig] from creation params for a specific
  /// platform.
  ProcessGlobalConfig.fromPlatformCreationParams(
      PlatformProcessGlobalConfigCreationParams params,
      ) : this.fromPlatform(PlatformProcessGlobalConfig(params));

  /// Constructs a [ProcessGlobalConfig] from a specific platform
  /// implementation.
  ProcessGlobalConfig.fromPlatform(this.platform);

  /// Implementation of [PlatformWebViewProcessGlobalConfig] for the current platform.
  final PlatformProcessGlobalConfig platform;

  static ProcessGlobalConfig? _instance;

  ///Gets the [ProcessGlobalConfig] shared instance.
  static ProcessGlobalConfig instance() {
    if (_instance == null) {
      _instance = ProcessGlobalConfig();
    }
    return _instance!;
  }

  ///Applies the configuration to be used by [WebView] on loading.
  ///This method can only be called once.
  ///
  ///Calling this method will not cause [WebView] to be loaded and will not block the calling thread.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - ProcessGlobalConfig.apply](https://developer.android.com/reference/androidx/webkit/ProcessGlobalConfig#apply(androidx.webkit.ProcessGlobalConfig)))
  Future<void> apply({required ProcessGlobalConfigSettings settings}) => platform.apply(settings: settings);
}

