// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_print_job_controller.dart';

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

extension _PlatformPrintJobControllerCreationParamsClassSupported
    on PlatformPrintJobControllerCreationParams {
  ///{@template flutter_inappwebview_platform_interface.PlatformPrintJobControllerCreationParams.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [PlatformPrintJobControllerCreationParams.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
            .contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformPrintJobControllerCreationParams]'s properties that can be used to check i they are supported or not by the current platform.
enum PlatformPrintJobControllerCreationParamsProperty {
  ///Can be used to check if the [PlatformPrintJobControllerCreationParams.id] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformPrintJobControllerCreationParams.id.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [PlatformPrintJobControllerCreationParams.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  id,
}

extension _PlatformPrintJobControllerCreationParamsPropertySupported
    on PlatformPrintJobControllerCreationParams {
  static bool isPropertySupported(
      PlatformPrintJobControllerCreationParamsProperty property,
      {TargetPlatform? platform}) {
    switch (property) {
      case PlatformPrintJobControllerCreationParamsProperty.id:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
    }
  }
}

extension _PlatformPrintJobControllerClassSupported
    on PlatformPrintJobController {
  ///{@template flutter_inappwebview_platform_interface.PlatformPrintJobController.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [PlatformPrintJobController.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
            .contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformPrintJobController]'s properties that can be used to check i they are supported or not by the current platform.
enum PlatformPrintJobControllerProperty {
  ///Can be used to check if the [PlatformPrintJobController.onComplete] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformPrintJobController.onComplete.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - PrintDocumentAdapter.onFinish](https://developer.android.com/reference/android/print/PrintDocumentAdapter#onFinish())):
  ///    - `completed` is always `true` and `error` is always `null`.
  ///- iOS WKWebView ([Official API - UIPrintInteractionController.CompletionHandler](https://developer.apple.com/documentation/uikit/uiprintinteractioncontroller/completionhandler))
  ///- macOS WKWebView ([Official API - NSPrintOperation.runModal](https://developer.apple.com/documentation/appkit/nsprintoperation/1532065-runmodal))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [completed]: all platforms
  ///- [error]: all platforms
  ///
  ///Use the [PlatformPrintJobController.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  onComplete,
}

extension _PlatformPrintJobControllerPropertySupported
    on PlatformPrintJobController {
  static bool isPropertySupported(PlatformPrintJobControllerProperty property,
      {TargetPlatform? platform}) {
    switch (property) {
      case PlatformPrintJobControllerProperty.onComplete:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
    }
  }
}

///List of [PlatformPrintJobController]'s methods that can be used to check if they are supported or not by the current platform.
enum PlatformPrintJobControllerMethod {
  ///Can be used to check if the [PlatformPrintJobController.cancel] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformPrintJobController.cancel.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - PrintJob.cancel](https://developer.android.com/reference/android/print/PrintJob#cancel()))
  ///
  ///Use the [PlatformPrintJobController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  cancel,

  ///Can be used to check if the [PlatformPrintJobController.dismiss] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformPrintJobController.dismiss.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [animated]: all platforms
  ///
  ///Use the [PlatformPrintJobController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  dismiss,

  ///Can be used to check if the [PlatformPrintJobController.dispose] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformPrintJobController.dispose.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [PlatformPrintJobController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  dispose,

  ///Can be used to check if the [PlatformPrintJobController.getInfo] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformPrintJobController.getInfo.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - PrintJob.getInfo](https://developer.android.com/reference/android/print/PrintJob#getInfo()))
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///
  ///Use the [PlatformPrintJobController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getInfo,

  ///Can be used to check if the [PlatformPrintJobController.restart] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformPrintJobController.restart.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - PrintJob.restart](https://developer.android.com/reference/android/print/PrintJob#restart()))
  ///
  ///Use the [PlatformPrintJobController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  restart,
}

extension _PlatformPrintJobControllerMethodSupported
    on PlatformPrintJobController {
  static bool isMethodSupported(PlatformPrintJobControllerMethod method,
      {TargetPlatform? platform}) {
    switch (method) {
      case PlatformPrintJobControllerMethod.cancel:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformPrintJobControllerMethod.dismiss:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case PlatformPrintJobControllerMethod.dispose:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformPrintJobControllerMethod.getInfo:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformPrintJobControllerMethod.restart:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
    }
  }
}
