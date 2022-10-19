import 'dart:async';
import 'package:flutter/services.dart';
import 'webview_feature.dart';
import '../types.dart';

///Class that represents an Android-specific class that manages Service Workers used by [WebView].
///
///**NOTE**: available on Android 24+.
///
///**Official Android API**: https://developer.android.com/reference/androidx/webkit/ServiceWorkerControllerCompat
class AndroidServiceWorkerController {
  static AndroidServiceWorkerController? _instance;
  static const MethodChannel _channel = const MethodChannel(
      'com.pichillilorenzo/flutter_inappwebview_android_serviceworkercontroller');

  AndroidServiceWorkerController._();

  AndroidServiceWorkerClient? _serviceWorkerClient;

  AndroidServiceWorkerClient? get serviceWorkerClient => _serviceWorkerClient;

  @Deprecated("Use setServiceWorkerClient instead")
  set serviceWorkerClient(AndroidServiceWorkerClient? value) {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('isNull', () => value == null);
    _channel.invokeMethod("setServiceWorkerClient", args);
    _serviceWorkerClient = value;
  }

  ///Sets the service worker client
  setServiceWorkerClient(AndroidServiceWorkerClient? value) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('isNull', () => value == null);
    await _channel.invokeMethod("setServiceWorkerClient", args);
    _serviceWorkerClient = value;
  }

  ///Gets the [AndroidServiceWorkerController] shared instance.
  static AndroidServiceWorkerController instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static AndroidServiceWorkerController _init() {
    _channel.setMethodCallHandler(_handleMethod);
    _instance = AndroidServiceWorkerController._();
    return _instance!;
  }

  static Future<dynamic> _handleMethod(MethodCall call) async {
    AndroidServiceWorkerController controller =
        AndroidServiceWorkerController.instance();
    AndroidServiceWorkerClient? serviceWorkerClient =
        controller.serviceWorkerClient;

    switch (call.method) {
      case "shouldInterceptRequest":
        if (serviceWorkerClient != null &&
            serviceWorkerClient.shouldInterceptRequest != null) {
          Map<String, dynamic> arguments =
              call.arguments.cast<String, dynamic>();
          WebResourceRequest request = WebResourceRequest.fromMap(arguments)!;

          return (await serviceWorkerClient.shouldInterceptRequest!(request))
              ?.toMap();
        }
        break;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }

    return null;
  }

  ///Gets whether Service Workers support content URL access.
  ///This method should only be called if [AndroidWebViewFeature.isFeatureSupported] returns `true` for [AndroidWebViewFeature.SERVICE_WORKER_CONTENT_ACCESS].
  ///
  ///**NOTE**: available on Android 24+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#getAllowContentAccess()
  static Future<bool> getAllowContentAccess() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('getAllowContentAccess', args);
  }

  ///Gets whether Service Workers support file access.
  ///This method should only be called if [AndroidWebViewFeature.isFeatureSupported] returns `true` for [AndroidWebViewFeature.SERVICE_WORKER_FILE_ACCESS].
  ///
  ///**NOTE**: available on Android 24+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#getAllowFileAccess()
  static Future<bool> getAllowFileAccess() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('getAllowFileAccess', args);
  }

  ///Gets whether Service Workers are prohibited from loading any resources from the network.
  ///This method should only be called if [AndroidWebViewFeature.isFeatureSupported] returns `true` for [AndroidWebViewFeature.SERVICE_WORKER_BLOCK_NETWORK_LOADS].
  ///
  ///**NOTE**: available on Android 24+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#getBlockNetworkLoads()
  static Future<bool> getBlockNetworkLoads() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('getBlockNetworkLoads', args);
  }

  ///Gets the current setting for overriding the cache mode.
  ///This method should only be called if [AndroidWebViewFeature.isFeatureSupported] returns `true` for [AndroidWebViewFeature.SERVICE_WORKER_CACHE_MODE].
  ///
  ///**NOTE**: available on Android 24+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#getCacheMode()
  static Future<AndroidCacheMode?> getCacheMode() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return AndroidCacheMode.fromValue(
        await _channel.invokeMethod('getCacheMode', args));
  }

  ///Enables or disables content URL access from Service Workers.
  ///This method should only be called if [AndroidWebViewFeature.isFeatureSupported] returns `true` for [AndroidWebViewFeature.SERVICE_WORKER_CONTENT_ACCESS].
  ///
  ///**NOTE**: available on Android 24+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#setAllowContentAccess(boolean)
  static Future<void> setAllowContentAccess(bool allow) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("allow", () => allow);
    await _channel.invokeMethod('setAllowContentAccess', args);
  }

  ///Enables or disables file access within Service Workers.
  ///This method should only be called if [AndroidWebViewFeature.isFeatureSupported] returns `true` for [AndroidWebViewFeature.SERVICE_WORKER_FILE_ACCESS].
  ///
  ///**NOTE**: available on Android 24+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#setAllowFileAccess(boolean)
  static Future<void> setAllowFileAccess(bool allow) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("allow", () => allow);
    await _channel.invokeMethod('setAllowFileAccess', args);
  }

  ///Sets whether Service Workers should not load resources from the network.
  ///This method should only be called if [AndroidWebViewFeature.isFeatureSupported] returns `true` for [AndroidWebViewFeature.SERVICE_WORKER_BLOCK_NETWORK_LOADS].
  ///
  ///**NOTE**: available on Android 24+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#setBlockNetworkLoads(boolean)
  static Future<void> setBlockNetworkLoads(bool flag) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("flag", () => flag);
    await _channel.invokeMethod('setBlockNetworkLoads', args);
  }

  ///Overrides the way the cache is used.
  ///This method should only be called if [AndroidWebViewFeature.isFeatureSupported] returns `true` for [AndroidWebViewFeature.SERVICE_WORKER_CACHE_MODE].
  ///
  ///**NOTE**: available on Android 24+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#setCacheMode(int)
  static Future<void> setCacheMode(AndroidCacheMode mode) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("mode", () => mode.toValue());
    await _channel.invokeMethod('setCacheMode', args);
  }
}

///Class that represents an Android-specific class for clients to capture Service Worker related callbacks.
///
///**NOTE**: available on Android 24+.
///
///**Official Android API**: https://developer.android.com/reference/androidx/webkit/ServiceWorkerClientCompat
class AndroidServiceWorkerClient {
  ///Notify the host application of a resource request and allow the application to return the data.
  ///If the return value is `null`, the Service Worker will continue to load the resource as usual.
  ///Otherwise, the return response and data will be used.
  ///
  ///This method is called only if [AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST] is supported.
  ///You can check whether that flag is supported using [AndroidWebViewFeature.isFeatureSupported].
  ///
  ///[request] represents an object containing the details of the request.
  ///
  ///**NOTE**: available on Android 24+.
  final Future<WebResourceResponse?> Function(WebResourceRequest request)?
      shouldInterceptRequest;

  AndroidServiceWorkerClient({this.shouldInterceptRequest});
}
