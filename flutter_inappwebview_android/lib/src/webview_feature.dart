import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

/// Object specifying creation parameters for creating a [AndroidWebViewFeature].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformWebViewFeatureCreationParams] for
/// more information.
@immutable
class AndroidWebViewFeatureCreationParams
    extends PlatformWebViewFeatureCreationParams {
  /// Creates a new [AndroidWebViewFeatureCreationParams] instance.
  const AndroidWebViewFeatureCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformWebViewFeatureCreationParams params,
  ) : super();

  /// Creates a [AndroidWebViewFeatureCreationParams] instance based on [PlatformWebViewFeatureCreationParams].
  factory AndroidWebViewFeatureCreationParams.fromPlatformWebViewFeatureCreationParams(
      PlatformWebViewFeatureCreationParams params) {
    return AndroidWebViewFeatureCreationParams(params);
  }
}

///Class that represents an Android-specific utility class for checking which WebView Support Library features are supported on the device.
///
///**Supported Platforms/Implementations**:
///- Android native WebView
class AndroidWebViewFeature extends PlatformWebViewFeature
    with ChannelController {
  /// Creates a new [AndroidWebViewFeature].
  AndroidWebViewFeature(PlatformWebViewFeatureCreationParams params)
      : super.implementation(
          params is AndroidWebViewFeatureCreationParams
              ? params
              : AndroidWebViewFeatureCreationParams
                  .fromPlatformWebViewFeatureCreationParams(params),
        ) {
    channel = const MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_webviewfeature');
    handler = handleMethod;
    initMethodCallHandler();
  }

  factory AndroidWebViewFeature.static() {
    return instance();
  }

  static AndroidWebViewFeature? _instance;

  ///Gets the [AndroidWebViewFeature] shared instance.
  static AndroidWebViewFeature instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static AndroidWebViewFeature _init() {
    _instance = AndroidWebViewFeature(AndroidWebViewFeatureCreationParams(
        const PlatformWebViewFeatureCreationParams()));
    return _instance!;
  }

  Future<dynamic> _handleMethod(MethodCall call) async {}

  ///Return whether a feature is supported at run-time. On devices running Android version `Build.VERSION_CODES.LOLLIPOP` and higher,
  ///this will check whether a feature is supported, depending on the combination of the desired feature, the Android version of device,
  ///and the WebView APK on the device. If running on a device with a lower API level, this will always return `false`.
  ///
  ///**Note**: This method is different from [isStartupFeatureSupported] and this
  ///method only accepts certain features.
  ///Please verify that the correct feature checking method is used for a particular feature.
  ///
  ///**Note**: If this method returns `false`, it is not safe to invoke the methods
  ///requiring the desired feature.
  ///Furthermore, if this method returns `false` for a particular feature, any callback guarded by that feature will not be invoked.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/WebViewFeature#isFeatureSupported(java.lang.String)
  Future<bool> isFeatureSupported(WebViewFeature feature) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("feature", () => feature.toNativeValue());
    return await channel?.invokeMethod<bool>('isFeatureSupported', args) ??
        false;
  }

  ///Return whether a startup feature is supported at run-time.
  ///On devices running Android version `Build.VERSION_CODES.LOLLIPOP` and higher,
  ///this will check whether a startup feature is supported,
  ///depending on the combination of the desired feature,
  ///the Android version of device, and the WebView APK on the device.
  ///If running on a device with a lower API level, this will always return `false`.
  ///
  ///**Note**: This method is different from [isFeatureSupported] and this method only accepts startup features.
  ///Please verify that the correct feature checking method is used for a particular feature.
  ///
  ///**Note**: If this method returns `false`, it is not safe to invoke the methods requiring the desired feature.
  ///Furthermore, if this method returns `false` for a particular feature,
  ///any callback guarded by that feature will not be invoked.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/WebViewFeature#isFeatureSupported(java.lang.String)
  Future<bool> isStartupFeatureSupported(WebViewFeature startupFeature) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("startupFeature", () => startupFeature.toNativeValue());
    return await channel?.invokeMethod<bool>(
            'isStartupFeatureSupported', args) ??
        false;
  }

  @override
  void dispose() {
    // empty
  }
}

extension InternalWebViewFeature on AndroidWebViewFeature {
  get handleMethod => _handleMethod;
}
