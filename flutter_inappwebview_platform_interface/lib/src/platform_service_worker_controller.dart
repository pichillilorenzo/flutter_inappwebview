import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'inappwebview_platform.dart';
import 'platform_webview_feature.dart';
import 'types/main.dart';

part 'platform_service_worker_controller.g.dart';

///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerControllerCreationParams}
/// Object specifying creation parameters for creating a [PlatformServiceWorkerController].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerControllerCreationParams.supported_platforms}
@SupportedPlatforms(platforms: [AndroidPlatform()])
@immutable
class PlatformServiceWorkerControllerCreationParams {
  /// Used by the platform implementation to create a new [PlatformServiceWorkerController].
  const PlatformServiceWorkerControllerCreationParams();

  ///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerControllerCreationParams.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformServiceWorkerControllerCreationParamsClassSupported.isClassSupported(
        platform: platform,
      );
}

///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerController}
///Class that manages Service Workers used by `WebView`.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerControllerCreationParams.supported_platforms}
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(
      apiName: 'ServiceWorkerControllerCompat',
      apiUrl:
          'https://developer.android.com/reference/androidx/webkit/ServiceWorkerControllerCompat',
    ),
  ],
)
abstract class PlatformServiceWorkerController extends PlatformInterface {
  /// Creates a new [PlatformServiceWorkerController]
  factory PlatformServiceWorkerController(
    PlatformServiceWorkerControllerCreationParams params,
  ) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`WebViewPlatform.instance` before use. For unit testing, '
      '`WebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformServiceWorkerController serviceWorkerController =
        InAppWebViewPlatform.instance!.createPlatformServiceWorkerController(
          params,
        );
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
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setServiceWorkerClient.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'ServiceWorkerControllerCompat.setServiceWorkerClient',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/ServiceWorkerControllerCompat#setServiceWorkerClient(androidx.webkit.ServiceWorkerClientCompat)',
      ),
    ],
  )
  Future<void> setServiceWorkerClient(ServiceWorkerClient? value) {
    throw UnimplementedError(
      'setServiceWorkerClient is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getAllowContentAccess}
  ///Gets whether Service Workers support content URL access.
  ///This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.SERVICE_WORKER_CONTENT_ACCESS].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getAllowContentAccess.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'ServiceWorkerWebSettingsCompat.getAllowContentAccess',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#getAllowContentAccess()',
      ),
    ],
  )
  Future<bool> getAllowContentAccess() {
    throw UnimplementedError(
      'getAllowContentAccess is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getAllowFileAccess}
  ///Gets whether Service Workers support file access.
  ///This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.SERVICE_WORKER_FILE_ACCESS].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getAllowFileAccess.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'ServiceWorkerWebSettingsCompat.getAllowFileAccess',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#getAllowFileAccess()',
      ),
    ],
  )
  Future<bool> getAllowFileAccess() {
    throw UnimplementedError(
      'getAllowFileAccess is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getBlockNetworkLoads}
  ///Gets whether Service Workers are prohibited from loading any resources from the network.
  ///This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.SERVICE_WORKER_BLOCK_NETWORK_LOADS].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getBlockNetworkLoads.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'ServiceWorkerWebSettingsCompat.getBlockNetworkLoads',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#getBlockNetworkLoads()',
      ),
    ],
  )
  Future<bool> getBlockNetworkLoads() {
    throw UnimplementedError(
      'getBlockNetworkLoads is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getCacheMode}
  ///Gets the current setting for overriding the cache mode.
  ///This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.SERVICE_WORKER_CACHE_MODE].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getCacheMode.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'ServiceWorkerWebSettingsCompat.getCacheMode',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#getCacheMode()',
      ),
    ],
  )
  Future<CacheMode?> getCacheMode() {
    throw UnimplementedError(
      'getCacheMode is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setAllowContentAccess}
  ///Enables or disables content URL access from Service Workers.
  ///This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.SERVICE_WORKER_CONTENT_ACCESS].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setAllowContentAccess.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'ServiceWorkerWebSettingsCompat.setAllowContentAccess',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#setAllowContentAccess(boolean)',
      ),
    ],
  )
  Future<void> setAllowContentAccess(bool allow) {
    throw UnimplementedError(
      'setAllowContentAccess is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setAllowFileAccess}
  ///Enables or disables file access within Service Workers.
  ///This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.SERVICE_WORKER_FILE_ACCESS].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setAllowFileAccess.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'ServiceWorkerWebSettingsCompat.setAllowFileAccess',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#setAllowFileAccess(boolean)',
      ),
    ],
  )
  Future<void> setAllowFileAccess(bool allow) {
    throw UnimplementedError(
      'setAllowFileAccess is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setBlockNetworkLoads}
  ///Sets whether Service Workers should not load resources from the network.
  ///This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.SERVICE_WORKER_BLOCK_NETWORK_LOADS].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setBlockNetworkLoads.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'ServiceWorkerWebSettingsCompat.setBlockNetworkLoads',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#setBlockNetworkLoads(boolean)',
      ),
    ],
  )
  Future<void> setBlockNetworkLoads(bool flag) {
    throw UnimplementedError(
      'setBlockNetworkLoads is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setCacheMode}
  ///Overrides the way the cache is used.
  ///This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.SERVICE_WORKER_CACHE_MODE].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setCacheMode.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'ServiceWorkerWebSettingsCompat.setCacheMode',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#setCacheMode(int)',
      ),
    ],
  )
  Future<void> setCacheMode(CacheMode mode) {
    throw UnimplementedError(
      'setCacheMode is not implemented on the current platform',
    );
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformServiceWorkerControllerCreationParams.isClassSupported}
  bool isClassSupported({TargetPlatform? platform}) =>
      params.isClassSupported(platform: platform);

  ///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerController.isMethodSupported}
  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isMethodSupported(
    PlatformServiceWorkerControllerMethod method, {
    TargetPlatform? platform,
  }) => _PlatformServiceWorkerControllerMethodSupported.isMethodSupported(
    method,
    platform: platform,
  );
}

///{@template flutter_inappwebview_platform_interface.ServiceWorkerClient}
///Class used by clients to capture Service Worker related callbacks.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.ServiceWorkerClient.supported_platforms}
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(
      apiName: 'ServiceWorkerClientCompat',
      apiUrl:
          'https://developer.android.com/reference/androidx/webkit/ServiceWorkerClientCompat',
    ),
  ],
)
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
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.ServiceWorkerClient.shouldInterceptRequest.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'ServiceWorkerClientCompat.shouldInterceptRequest',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/ServiceWorkerClientCompat#shouldInterceptRequest(android.webkit.WebResourceRequest)',
      ),
    ],
  )
  final Future<WebResourceResponse?> Function(WebResourceRequest request)?
  shouldInterceptRequest;

  ServiceWorkerClient({this.shouldInterceptRequest});

  ///{@template flutter_inappwebview_platform_interface.ServiceWorkerClient.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformServiceWorkerControllerCreationParamsClassSupported.isClassSupported(
        platform: platform,
      );

  ///{@template flutter_inappwebview_platform_interface.ServiceWorkerClient.isPropertySupported}
  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  static bool isPropertySupported(
    ServiceWorkerClientProperty property, {
    TargetPlatform? platform,
  }) => _ServiceWorkerClientPropertySupported.isPropertySupported(
    property,
    platform: platform,
  );
}
