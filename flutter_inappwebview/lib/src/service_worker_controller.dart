import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController}
///
///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.supported_platforms}
class ServiceWorkerController {
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController}
  ServiceWorkerController()
    : this.fromPlatformCreationParams(
        const PlatformServiceWorkerControllerCreationParams(),
      );

  /// Constructs a [ServiceWorkerController] from creation params for a specific
  /// platform.
  ServiceWorkerController.fromPlatformCreationParams(
    PlatformServiceWorkerControllerCreationParams params,
  ) : this.fromPlatform(PlatformServiceWorkerController(params));

  /// Constructs a [ServiceWorkerController] from a specific platform
  /// implementation.
  ServiceWorkerController.fromPlatform(this.platform);

  /// Implementation of [PlatformServiceWorkerController] for the current platform.
  final PlatformServiceWorkerController platform;

  static ServiceWorkerController? _instance;

  ///Gets the [ServiceWorkerController] shared instance.
  static ServiceWorkerController instance() {
    if (_instance == null) {
      _instance = ServiceWorkerController();
    }
    return _instance!;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.serviceWorkerClient}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.serviceWorkerClient.supported_platforms}
  ServiceWorkerClient? get serviceWorkerClient => platform.serviceWorkerClient;

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setServiceWorkerClient}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setServiceWorkerClient.supported_platforms}
  setServiceWorkerClient(ServiceWorkerClient? value) =>
      platform.setServiceWorkerClient(value);

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getAllowContentAccess}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getAllowContentAccess.supported_platforms}
  static Future<bool> getAllowContentAccess() =>
      PlatformServiceWorkerController.static().getAllowContentAccess();

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getAllowFileAccess}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getAllowFileAccess.supported_platforms}
  static Future<bool> getAllowFileAccess() =>
      PlatformServiceWorkerController.static().getAllowFileAccess();

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getBlockNetworkLoads}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getBlockNetworkLoads.supported_platforms}
  static Future<bool> getBlockNetworkLoads() =>
      PlatformServiceWorkerController.static().getBlockNetworkLoads();

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getCacheMode}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getCacheMode.supported_platforms}
  static Future<CacheMode?> getCacheMode() =>
      PlatformServiceWorkerController.static().getCacheMode();

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setAllowContentAccess}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setAllowContentAccess.supported_platforms}
  static Future<void> setAllowContentAccess(bool allow) =>
      PlatformServiceWorkerController.static().setAllowContentAccess(allow);

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setAllowFileAccess}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setAllowFileAccess.supported_platforms}
  static Future<void> setAllowFileAccess(bool allow) =>
      PlatformServiceWorkerController.static().setAllowFileAccess(allow);

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setBlockNetworkLoads}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setBlockNetworkLoads.supported_platforms}
  static Future<void> setBlockNetworkLoads(bool flag) =>
      PlatformServiceWorkerController.static().setBlockNetworkLoads(flag);

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setCacheMode}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setCacheMode.supported_platforms}
  static Future<void> setCacheMode(CacheMode mode) =>
      PlatformServiceWorkerController.static().setCacheMode(mode);

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerControllerCreationParams.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformServiceWorkerController.static().isClassSupported(
        platform: platform,
      );

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.isMethodSupported}
  static bool isMethodSupported(
    PlatformServiceWorkerControllerMethod method, {
    TargetPlatform? platform,
  }) => PlatformServiceWorkerController.static().isMethodSupported(
    method,
    platform: platform,
  );
}

///Class that represents an Android-specific class that manages Service Workers used by `WebView`.
///
///**NOTE**: available on Android 24+.
///
///**Official Android API**: https://developer.android.com/reference/androidx/webkit/ServiceWorkerControllerCompat
///
///Use [ServiceWorkerController] instead.
@Deprecated("Use ServiceWorkerController instead")
class AndroidServiceWorkerController {
  static AndroidServiceWorkerController? _instance;

  AndroidServiceWorkerClient? _serviceWorkerClient;

  AndroidServiceWorkerClient? get serviceWorkerClient => _serviceWorkerClient;

  ///Gets the [AndroidServiceWorkerController] shared instance.
  static AndroidServiceWorkerController instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static AndroidServiceWorkerController _init() {
    _instance = AndroidServiceWorkerController();
    return _instance!;
  }

  @Deprecated("Use setServiceWorkerClient instead")
  set serviceWorkerClient(AndroidServiceWorkerClient? value) {
    setServiceWorkerClient(value);
  }

  ///Sets the service worker client
  setServiceWorkerClient(AndroidServiceWorkerClient? value) async {
    await ServiceWorkerController.instance().setServiceWorkerClient(
      value != null
          ? ServiceWorkerClient(
              shouldInterceptRequest: value.shouldInterceptRequest,
            )
          : null,
    );
    _serviceWorkerClient = value;
  }

  ///Gets whether Service Workers support content URL access.
  ///This method should only be called if [AndroidWebViewFeature.isFeatureSupported] returns `true` for [AndroidWebViewFeature.SERVICE_WORKER_CONTENT_ACCESS].
  ///
  ///**NOTE**: available on Android 24+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#getAllowContentAccess()
  static Future<bool> getAllowContentAccess() async {
    return await ServiceWorkerController.getAllowContentAccess();
  }

  ///Gets whether Service Workers support file access.
  ///This method should only be called if [AndroidWebViewFeature.isFeatureSupported] returns `true` for [AndroidWebViewFeature.SERVICE_WORKER_FILE_ACCESS].
  ///
  ///**NOTE**: available on Android 24+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#getAllowFileAccess()
  static Future<bool> getAllowFileAccess() async {
    return await ServiceWorkerController.getAllowFileAccess();
  }

  ///Gets whether Service Workers are prohibited from loading any resources from the network.
  ///This method should only be called if [AndroidWebViewFeature.isFeatureSupported] returns `true` for [AndroidWebViewFeature.SERVICE_WORKER_BLOCK_NETWORK_LOADS].
  ///
  ///**NOTE**: available on Android 24+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#getBlockNetworkLoads()
  static Future<bool> getBlockNetworkLoads() async {
    return await ServiceWorkerController.getBlockNetworkLoads();
  }

  ///Gets the current setting for overriding the cache mode.
  ///This method should only be called if [AndroidWebViewFeature.isFeatureSupported] returns `true` for [AndroidWebViewFeature.SERVICE_WORKER_CACHE_MODE].
  ///
  ///**NOTE**: available on Android 24+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#getCacheMode()
  static Future<AndroidCacheMode?> getCacheMode() async {
    return AndroidCacheMode.fromNativeValue(
      (await ServiceWorkerController.getCacheMode())?.toNativeValue(),
    );
  }

  ///Enables or disables content URL access from Service Workers.
  ///This method should only be called if [AndroidWebViewFeature.isFeatureSupported] returns `true` for [AndroidWebViewFeature.SERVICE_WORKER_CONTENT_ACCESS].
  ///
  ///**NOTE**: available on Android 24+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#setAllowContentAccess(boolean)
  static Future<void> setAllowContentAccess(bool allow) async {
    await ServiceWorkerController.setAllowContentAccess(allow);
  }

  ///Enables or disables file access within Service Workers.
  ///This method should only be called if [AndroidWebViewFeature.isFeatureSupported] returns `true` for [AndroidWebViewFeature.SERVICE_WORKER_FILE_ACCESS].
  ///
  ///**NOTE**: available on Android 24+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#setAllowFileAccess(boolean)
  static Future<void> setAllowFileAccess(bool allow) async {
    await ServiceWorkerController.setAllowFileAccess(allow);
  }

  ///Sets whether Service Workers should not load resources from the network.
  ///This method should only be called if [AndroidWebViewFeature.isFeatureSupported] returns `true` for [AndroidWebViewFeature.SERVICE_WORKER_BLOCK_NETWORK_LOADS].
  ///
  ///**NOTE**: available on Android 24+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#setBlockNetworkLoads(boolean)
  static Future<void> setBlockNetworkLoads(bool flag) async {
    await ServiceWorkerController.setBlockNetworkLoads(flag);
  }

  ///Overrides the way the cache is used.
  ///This method should only be called if [AndroidWebViewFeature.isFeatureSupported] returns `true` for [AndroidWebViewFeature.SERVICE_WORKER_CACHE_MODE].
  ///
  ///**NOTE**: available on Android 24+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#setCacheMode(int)
  static Future<void> setCacheMode(AndroidCacheMode mode) async {
    await ServiceWorkerController.setCacheMode(
      CacheMode.fromNativeValue(mode.toNativeValue())!,
    );
  }
}

///Class that represents an Android-specific class for clients to capture Service Worker related callbacks.
///
///**NOTE**: available on Android 24+.
///
///**Official Android API**: https://developer.android.com/reference/androidx/webkit/ServiceWorkerClientCompat
///Use [ServiceWorkerClient] instead.
@Deprecated("Use ServiceWorkerClient instead")
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
