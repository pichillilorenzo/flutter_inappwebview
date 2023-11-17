import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

/// Object specifying creation parameters for creating a [AndroidProcessGlobalConfig].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformProcessGlobalConfigCreationParams] for
/// more information.
@immutable
class AndroidProcessGlobalConfigCreationParams
    extends PlatformProcessGlobalConfigCreationParams {
  /// Creates a new [AndroidProcessGlobalConfigCreationParams] instance.
  const AndroidProcessGlobalConfigCreationParams(
      // This parameter prevents breaking changes later.
      // ignore: avoid_unused_constructor_parameters
      PlatformProcessGlobalConfigCreationParams params,
      ) : super();

  /// Creates a [AndroidProcessGlobalConfigCreationParams] instance based on [PlatformProcessGlobalConfigCreationParams].
  factory AndroidProcessGlobalConfigCreationParams.fromPlatformProcessGlobalConfigCreationParams(
      PlatformProcessGlobalConfigCreationParams params) {
    return AndroidProcessGlobalConfigCreationParams(params);
  }
}

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
class AndroidProcessGlobalConfig extends PlatformProcessGlobalConfig with ChannelController {
  /// Creates a new [AndroidProcessGlobalConfig].
  AndroidProcessGlobalConfig(PlatformProcessGlobalConfigCreationParams params)
      : super.implementation(
    params is AndroidProcessGlobalConfigCreationParams
        ? params
        : AndroidProcessGlobalConfigCreationParams
        .fromPlatformProcessGlobalConfigCreationParams(params),
  ) {
    channel = const MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_processglobalconfig');
    handler = handleMethod;
    initMethodCallHandler();
  }

  static AndroidProcessGlobalConfig? _instance;

  ///Gets the [AndroidProcessGlobalConfig] shared instance.
  static AndroidProcessGlobalConfig instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static AndroidProcessGlobalConfig _init() {
    _instance = AndroidProcessGlobalConfig(AndroidProcessGlobalConfigCreationParams(
        const PlatformProcessGlobalConfigCreationParams()));
    return _instance!;
  }

  Future<dynamic> _handleMethod(MethodCall call) async {}

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
    await channel?.invokeMethod('apply', args);
  }

  @override
  void dispose() {
    // empty
  }
}

extension InternalProcessGlobalConfig on AndroidProcessGlobalConfig {
  get handleMethod => _handleMethod;
}

