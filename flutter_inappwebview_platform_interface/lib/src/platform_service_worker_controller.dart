import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'inappwebview_platform.dart';
import 'types/main.dart';

/// Object specifying creation parameters for creating a [PlatformServiceWorkerController].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
@immutable
class PlatformServiceWorkerControllerCreationParams {
  /// Used by the platform implementation to create a new [PlatformServiceWorkerController].
  const PlatformServiceWorkerControllerCreationParams();
}

///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerController}
///Class that manages Service Workers used by `WebView`.
///
///**NOTE**: available on Android 24+.
///
///**Officially Supported Platforms/Implementations**:
///- Android native WebView ([Official API - ServiceWorkerControllerCompat](https://developer.android.com/reference/androidx/webkit/ServiceWorkerControllerCompat))
///{@endtemplate}
abstract class PlatformServiceWorkerController extends PlatformInterface {
  /// Creates a new [PlatformServiceWorkerController]
  factory PlatformServiceWorkerController(
      PlatformServiceWorkerControllerCreationParams params) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`WebViewPlatform.instance` before use. For unit testing, '
      '`WebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformServiceWorkerController serviceWorkerController =
        InAppWebViewPlatform.instance!
            .createPlatformServiceWorkerController(params);
    PlatformInterface.verify(serviceWorkerController, _token);
    return serviceWorkerController;
  }

  /// Creates a new [PlatformServiceWorkerController]
  factory PlatformServiceWorkerController.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`WebViewPlatform.instance` before use. For unit testing, '
      '`WebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformServiceWorkerController serviceWorkerControllerStatic =
        InAppWebViewPlatform.instance!
            .createPlatformServiceWorkerControllerStatic();
    PlatformInterface.verify(serviceWorkerControllerStatic, _token);
    return serviceWorkerControllerStatic;
  }

  /// Used by the platform implementation to create a new
  /// [PlatformServiceWorkerController].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformServiceWorkerController.implementation(this.params)
      : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformServiceWorkerController].
  final PlatformServiceWorkerControllerCreationParams params;

  ///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerController.serviceWorkerClient}
  ///Service Worker client.
  ///{@endtemplate}
  ServiceWorkerClient? get serviceWorkerClient;

  ///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setServiceWorkerClient}
  ///Sets the client to capture service worker related callbacks.
  ///A [ServiceWorkerClient] should be set before any service workers are active, e.g. a safe place is before any WebView instances are created or pages loaded.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - ServiceWorkerControllerCompat.setServiceWorkerClient](https://developer.android.com/reference/androidx/webkit/ServiceWorkerControllerCompat#setServiceWorkerClient(androidx.webkit.ServiceWorkerClientCompat)))
  ///{@endtemplate}
  Future<void> setServiceWorkerClient(ServiceWorkerClient? value) {
    throw UnimplementedError(
        'setServiceWorkerClient is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getAllowContentAccess}
  ///Gets whether Service Workers support content URL access.
  ///This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.SERVICE_WORKER_CONTENT_ACCESS].
  ///
  ///**NOTE**: available on Android 24+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#getAllowContentAccess()
  ///{@endtemplate}
  Future<bool> getAllowContentAccess() {
    throw UnimplementedError(
        'getAllowContentAccess is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getAllowFileAccess}
  ///Gets whether Service Workers support file access.
  ///This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.SERVICE_WORKER_FILE_ACCESS].
  ///
  ///**NOTE**: available on Android 24+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#getAllowFileAccess()
  ///{@endtemplate}
  Future<bool> getAllowFileAccess() {
    throw UnimplementedError(
        'getAllowFileAccess is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getBlockNetworkLoads}
  ///Gets whether Service Workers are prohibited from loading any resources from the network.
  ///This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.SERVICE_WORKER_BLOCK_NETWORK_LOADS].
  ///
  ///**NOTE**: available on Android 24+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#getBlockNetworkLoads()
  ///{@endtemplate}
  Future<bool> getBlockNetworkLoads() {
    throw UnimplementedError(
        'getBlockNetworkLoads is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getCacheMode}
  ///Gets the current setting for overriding the cache mode.
  ///This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.SERVICE_WORKER_CACHE_MODE].
  ///
  ///**NOTE**: available on Android 24+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#getCacheMode()
  ///{@endtemplate}
  Future<CacheMode?> getCacheMode() {
    throw UnimplementedError(
        'getCacheMode is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setAllowContentAccess}
  ///Enables or disables content URL access from Service Workers.
  ///This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.SERVICE_WORKER_CONTENT_ACCESS].
  ///
  ///**NOTE**: available on Android 24+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#setAllowContentAccess(boolean)
  ///{@endtemplate}
  Future<void> setAllowContentAccess(bool allow) {
    throw UnimplementedError(
        'setAllowContentAccess is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setAllowFileAccess}
  ///Enables or disables file access within Service Workers.
  ///This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.SERVICE_WORKER_FILE_ACCESS].
  ///
  ///**NOTE**: available on Android 24+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#setAllowFileAccess(boolean)
  ///{@endtemplate}
  Future<void> setAllowFileAccess(bool allow) {
    throw UnimplementedError(
        'setAllowFileAccess is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setBlockNetworkLoads}
  ///Sets whether Service Workers should not load resources from the network.
  ///This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.SERVICE_WORKER_BLOCK_NETWORK_LOADS].
  ///
  ///**NOTE**: available on Android 24+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#setBlockNetworkLoads(boolean)
  ///{@endtemplate}
  Future<void> setBlockNetworkLoads(bool flag) {
    throw UnimplementedError(
        'setBlockNetworkLoads is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setCacheMode}
  ///Overrides the way the cache is used.
  ///This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.SERVICE_WORKER_CACHE_MODE].
  ///
  ///**NOTE**: available on Android 24+.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#setCacheMode(int)
  ///{@endtemplate}
  Future<void> setCacheMode(CacheMode mode) {
    throw UnimplementedError(
        'setCacheMode is not implemented on the current platform');
  }
}

///{@template flutter_inappwebview_platform_interface.ServiceWorkerClient}
///Class used by clients to capture Service Worker related callbacks.
///
///**NOTE**: available on Android 24+.
///
///**Officially Supported Platforms/Implementations**:
///- Android native WebView ([Official API - ServiceWorkerClientCompat](https://developer.android.com/reference/androidx/webkit/ServiceWorkerClientCompat))
///{@endtemplate}
class ServiceWorkerClient {
  ///{@template flutter_inappwebview_platform_interface.ServiceWorkerClient.shouldInterceptRequest}
  ///Notify the host application of a resource request and allow the application to return the data.
  ///If the return value is `null`, the Service Worker will continue to load the resource as usual.
  ///Otherwise, the return response and data will be used.
  ///
  ///This method is called only if [WebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST] is supported.
  ///You can check whether that flag is supported using [WebViewFeature.isFeatureSupported].
  ///
  ///[request] represents an object containing the details of the request.
  ///
  ///**NOTE**: available on Android 24+.
  ///{@endtemplate}
  final Future<WebResourceResponse?> Function(WebResourceRequest request)?
      shouldInterceptRequest;

  ServiceWorkerClient({this.shouldInterceptRequest});
}
