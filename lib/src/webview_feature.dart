import 'dart:async';

import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

extension WebViewFeatureMethods on WebViewFeature {
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
  static Future<bool> isFeatureSupported(WebViewFeature feature) =>
      PlatformWebViewFeature.static().isFeatureSupported(feature);

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
  static Future<bool> isStartupFeatureSupported(
          WebViewFeature startupFeature) =>
      PlatformWebViewFeature.static().isStartupFeatureSupported(startupFeature);
}

@Deprecated("Use WebViewFeature instead")
extension AndroidWebViewFeatureMethods on AndroidWebViewFeature {
  ///Return whether a feature is supported at run-time. On devices running Android version `Build.VERSION_CODES.LOLLIPOP` and higher,
  ///this will check whether a feature is supported, depending on the combination of the desired feature, the Android version of device,
  ///and the WebView APK on the device. If running on a device with a lower API level, this will always return `false`.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/WebViewFeature#isFeatureSupported(java.lang.String)
  static Future<bool> isFeatureSupported(AndroidWebViewFeature feature) =>
      PlatformWebViewFeature.static().isFeatureSupported(
          WebViewFeature.fromNativeValue(feature.toNativeValue())!);
}
