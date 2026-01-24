// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_service_worker_controller.dart';

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

extension _PlatformServiceWorkerControllerCreationParamsClassSupported
    on PlatformServiceWorkerControllerCreationParams {
  ///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerControllerCreationParams.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [PlatformServiceWorkerControllerCreationParams.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android].contains(platform ?? defaultTargetPlatform);
  }
}

extension _PlatformServiceWorkerControllerClassSupported
    on PlatformServiceWorkerController {
  ///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerController.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - ServiceWorkerControllerCompat](https://developer.android.com/reference/androidx/webkit/ServiceWorkerControllerCompat))
  ///
  ///Use the [PlatformServiceWorkerController.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformServiceWorkerController]'s methods that can be used to check if they are supported or not by the current platform.
enum PlatformServiceWorkerControllerMethod {
  ///Can be used to check if the [PlatformServiceWorkerController.getAllowContentAccess] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getAllowContentAccess.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - ServiceWorkerWebSettingsCompat.getAllowContentAccess](https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#getAllowContentAccess()))
  ///
  ///Use the [PlatformServiceWorkerController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getAllowContentAccess,

  ///Can be used to check if the [PlatformServiceWorkerController.getAllowFileAccess] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getAllowFileAccess.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - ServiceWorkerWebSettingsCompat.getAllowFileAccess](https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#getAllowFileAccess()))
  ///
  ///Use the [PlatformServiceWorkerController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getAllowFileAccess,

  ///Can be used to check if the [PlatformServiceWorkerController.getBlockNetworkLoads] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getBlockNetworkLoads.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - ServiceWorkerWebSettingsCompat.getBlockNetworkLoads](https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#getBlockNetworkLoads()))
  ///
  ///Use the [PlatformServiceWorkerController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getBlockNetworkLoads,

  ///Can be used to check if the [PlatformServiceWorkerController.getCacheMode] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerController.getCacheMode.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - ServiceWorkerWebSettingsCompat.getCacheMode](https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#getCacheMode()))
  ///
  ///Use the [PlatformServiceWorkerController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getCacheMode,

  ///Can be used to check if the [PlatformServiceWorkerController.setAllowContentAccess] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setAllowContentAccess.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - ServiceWorkerWebSettingsCompat.setAllowContentAccess](https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#setAllowContentAccess(boolean)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [allow]: all platforms
  ///
  ///Use the [PlatformServiceWorkerController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setAllowContentAccess,

  ///Can be used to check if the [PlatformServiceWorkerController.setAllowFileAccess] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setAllowFileAccess.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - ServiceWorkerWebSettingsCompat.setAllowFileAccess](https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#setAllowFileAccess(boolean)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [allow]: all platforms
  ///
  ///Use the [PlatformServiceWorkerController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setAllowFileAccess,

  ///Can be used to check if the [PlatformServiceWorkerController.setBlockNetworkLoads] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setBlockNetworkLoads.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - ServiceWorkerWebSettingsCompat.setBlockNetworkLoads](https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#setBlockNetworkLoads(boolean)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [flag]: all platforms
  ///
  ///Use the [PlatformServiceWorkerController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setBlockNetworkLoads,

  ///Can be used to check if the [PlatformServiceWorkerController.setCacheMode] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setCacheMode.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - ServiceWorkerWebSettingsCompat.setCacheMode](https://developer.android.com/reference/androidx/webkit/ServiceWorkerWebSettingsCompat#setCacheMode(int)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [mode]: all platforms
  ///
  ///Use the [PlatformServiceWorkerController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setCacheMode,

  ///Can be used to check if the [PlatformServiceWorkerController.setServiceWorkerClient] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformServiceWorkerController.setServiceWorkerClient.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - ServiceWorkerControllerCompat.setServiceWorkerClient](https://developer.android.com/reference/androidx/webkit/ServiceWorkerControllerCompat#setServiceWorkerClient(androidx.webkit.ServiceWorkerClientCompat)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [value]: all platforms
  ///
  ///Use the [PlatformServiceWorkerController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setServiceWorkerClient,
}

extension _PlatformServiceWorkerControllerMethodSupported
    on PlatformServiceWorkerController {
  static bool isMethodSupported(
    PlatformServiceWorkerControllerMethod method, {
    TargetPlatform? platform,
  }) {
    switch (method) {
      case PlatformServiceWorkerControllerMethod.getAllowContentAccess:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformServiceWorkerControllerMethod.getAllowFileAccess:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformServiceWorkerControllerMethod.getBlockNetworkLoads:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformServiceWorkerControllerMethod.getCacheMode:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformServiceWorkerControllerMethod.setAllowContentAccess:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformServiceWorkerControllerMethod.setAllowFileAccess:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformServiceWorkerControllerMethod.setBlockNetworkLoads:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformServiceWorkerControllerMethod.setCacheMode:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformServiceWorkerControllerMethod.setServiceWorkerClient:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
    }
  }
}

extension _ServiceWorkerClientClassSupported on ServiceWorkerClient {
  ///{@template flutter_inappwebview_platform_interface.ServiceWorkerClient.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - ServiceWorkerClientCompat](https://developer.android.com/reference/androidx/webkit/ServiceWorkerClientCompat))
  ///
  ///Use the [ServiceWorkerClient.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [ServiceWorkerClient]'s properties that can be used to check i they are supported or not by the current platform.
enum ServiceWorkerClientProperty {
  ///Can be used to check if the [ServiceWorkerClient.shouldInterceptRequest] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ServiceWorkerClient.shouldInterceptRequest.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - ServiceWorkerClientCompat.shouldInterceptRequest](https://developer.android.com/reference/androidx/webkit/ServiceWorkerClientCompat#shouldInterceptRequest(android.webkit.WebResourceRequest)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [request]: all platforms
  ///
  ///Use the [ServiceWorkerClient.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  shouldInterceptRequest,
}

extension _ServiceWorkerClientPropertySupported on ServiceWorkerClient {
  static bool isPropertySupported(
    ServiceWorkerClientProperty property, {
    TargetPlatform? platform,
  }) {
    switch (property) {
      case ServiceWorkerClientProperty.shouldInterceptRequest:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
    }
  }
}
