// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_web_notification_controller.dart';

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

extension _PlatformWebNotificationControllerCreationParamsClassSupported
    on PlatformWebNotificationControllerCreationParams {
  ///{@template flutter_inappwebview_platform_interface.PlatformWebNotificationControllerCreationParams.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  ///
  ///Use the [PlatformWebNotificationControllerCreationParams.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.windows].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformWebNotificationControllerCreationParams]'s properties that can be used to check i they are supported or not by the current platform.
enum PlatformWebNotificationControllerCreationParamsProperty {
  ///Can be used to check if the [PlatformWebNotificationControllerCreationParams.id] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebNotificationControllerCreationParams.id.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  ///
  ///Use the [PlatformWebNotificationControllerCreationParams.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  id,

  ///Can be used to check if the [PlatformWebNotificationControllerCreationParams.notification] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebNotificationControllerCreationParams.notification.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  ///
  ///Use the [PlatformWebNotificationControllerCreationParams.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  notification,
}

extension _PlatformWebNotificationControllerCreationParamsPropertySupported
    on PlatformWebNotificationControllerCreationParams {
  static bool isPropertySupported(
    PlatformWebNotificationControllerCreationParamsProperty property, {
    TargetPlatform? platform,
  }) {
    switch (property) {
      case PlatformWebNotificationControllerCreationParamsProperty.id:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformWebNotificationControllerCreationParamsProperty.notification:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
    }
  }
}

extension _PlatformWebNotificationControllerClassSupported
    on PlatformWebNotificationController {
  ///{@template flutter_inappwebview_platform_interface.PlatformWebNotificationController.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  ///
  ///Use the [PlatformWebNotificationController.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.windows].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformWebNotificationController]'s properties that can be used to check i they are supported or not by the current platform.
enum PlatformWebNotificationControllerProperty {
  ///Can be used to check if the [PlatformWebNotificationController.onClose] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebNotificationController.onClose.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - ICoreWebView2Notification.add_CloseRequested](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2notification?view=webview2-1.0.3595.46#add_closerequested))
  ///
  ///Use the [PlatformWebNotificationController.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  onClose,
}

extension _PlatformWebNotificationControllerPropertySupported
    on PlatformWebNotificationController {
  static bool isPropertySupported(
    PlatformWebNotificationControllerProperty property, {
    TargetPlatform? platform,
  }) {
    switch (property) {
      case PlatformWebNotificationControllerProperty.onClose:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
    }
  }
}

///List of [PlatformWebNotificationController]'s methods that can be used to check if they are supported or not by the current platform.
enum PlatformWebNotificationControllerMethod {
  ///Can be used to check if the [PlatformWebNotificationController.dispose] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebNotificationController.dispose.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  ///
  ///Use the [PlatformWebNotificationController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  dispose,

  ///Can be used to check if the [PlatformWebNotificationController.reportClicked] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebNotificationController.reportClicked.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - ICoreWebView2Notification.ReportClicked](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2notification?view=webview2-1.0.3595.46#reportclicked))
  ///
  ///Use the [PlatformWebNotificationController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  reportClicked,

  ///Can be used to check if the [PlatformWebNotificationController.reportClosed] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebNotificationController.reportClosed.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - ICoreWebView2Notification.ReportClosed](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2notification?view=webview2-1.0.3595.46#reportclosed))
  ///
  ///Use the [PlatformWebNotificationController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  reportClosed,

  ///Can be used to check if the [PlatformWebNotificationController.reportShown] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebNotificationController.reportShown.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - ICoreWebView2Notification.ReportShown](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2notification?view=webview2-1.0.3595.46#reportshown))
  ///
  ///Use the [PlatformWebNotificationController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  reportShown,
}

extension _PlatformWebNotificationControllerMethodSupported
    on PlatformWebNotificationController {
  static bool isMethodSupported(
    PlatformWebNotificationControllerMethod method, {
    TargetPlatform? platform,
  }) {
    switch (method) {
      case PlatformWebNotificationControllerMethod.dispose:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformWebNotificationControllerMethod.reportClicked:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformWebNotificationControllerMethod.reportClosed:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformWebNotificationControllerMethod.reportShown:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
    }
  }
}
