// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_webview_environment.dart';

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

extension _PlatformWebViewEnvironmentCreationParamsClassSupported
    on PlatformWebViewEnvironmentCreationParams {
  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironmentCreationParams.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  ///
  ///Use the [PlatformWebViewEnvironmentCreationParams.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.windows].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformWebViewEnvironmentCreationParams]'s properties that can be used to check i they are supported or not by the current platform.
enum PlatformWebViewEnvironmentCreationParamsProperty {
  ///Can be used to check if the [PlatformWebViewEnvironmentCreationParams.settings] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironmentCreationParams.settings.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  ///
  ///Use the [PlatformWebViewEnvironmentCreationParams.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  settings,
}

extension _PlatformWebViewEnvironmentCreationParamsPropertySupported
    on PlatformWebViewEnvironmentCreationParams {
  static bool isPropertySupported(
      PlatformWebViewEnvironmentCreationParamsProperty property,
      {TargetPlatform? platform}) {
    switch (property) {
      case PlatformWebViewEnvironmentCreationParamsProperty.settings:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.windows]
                .contains(platform ?? defaultTargetPlatform);
    }
  }
}

extension _PlatformWebViewEnvironmentClassSupported
    on PlatformWebViewEnvironment {
  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  ///
  ///Use the [PlatformWebViewEnvironment.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.windows].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformWebViewEnvironment]'s properties that can be used to check i they are supported or not by the current platform.
enum PlatformWebViewEnvironmentProperty {
  ///Can be used to check if the [PlatformWebViewEnvironment.id] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.id.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  ///
  ///Use the [PlatformWebViewEnvironment.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  id,

  ///Can be used to check if the [PlatformWebViewEnvironment.onBrowserProcessExited] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.onBrowserProcessExited.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.992.28++ ([Official API - ICoreWebView2Environment5.add_BrowserProcessExited](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environment5?view=webview2-1.0.2849.39#add_browserprocessexited))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [detail]: all platforms
  ///
  ///Use the [PlatformWebViewEnvironment.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  onBrowserProcessExited,

  ///Can be used to check if the [PlatformWebViewEnvironment.onNewBrowserVersionAvailable] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.onNewBrowserVersionAvailable.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - ICoreWebView2Environment.add_NewBrowserVersionAvailable](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environment?view=webview2-1.0.2849.39#add_newbrowserversionavailable))
  ///
  ///Use the [PlatformWebViewEnvironment.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  onNewBrowserVersionAvailable,

  ///Can be used to check if the [PlatformWebViewEnvironment.onProcessInfosChanged] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.onProcessInfosChanged.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.1108.44++ ([Official API - ICoreWebView2Environment8.add_ProcessInfosChanged](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environment8?view=webview2-1.0.2849.39#add_processinfoschanged))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [detail]: all platforms
  ///
  ///Use the [PlatformWebViewEnvironment.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  onProcessInfosChanged,
}

extension _PlatformWebViewEnvironmentPropertySupported
    on PlatformWebViewEnvironment {
  static bool isPropertySupported(PlatformWebViewEnvironmentProperty property,
      {TargetPlatform? platform}) {
    switch (property) {
      case PlatformWebViewEnvironmentProperty.id:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.windows]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformWebViewEnvironmentProperty.onBrowserProcessExited:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.windows]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformWebViewEnvironmentProperty.onNewBrowserVersionAvailable:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.windows]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformWebViewEnvironmentProperty.onProcessInfosChanged:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.windows]
                .contains(platform ?? defaultTargetPlatform);
    }
  }
}

///List of [PlatformWebViewEnvironment]'s methods that can be used to check if they are supported or not by the current platform.
enum PlatformWebViewEnvironmentMethod {
  ///Can be used to check if the [PlatformWebViewEnvironment.compareBrowserVersions] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.compareBrowserVersions.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - CompareBrowserVersions](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#comparebrowserversions))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [version1]: all platforms
  ///- [version2]: all platforms
  ///
  ///Use the [PlatformWebViewEnvironment.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  compareBrowserVersions,

  ///Can be used to check if the [PlatformWebViewEnvironment.create] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.create.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - CreateCoreWebView2EnvironmentWithOptions](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2210.55#createcorewebview2environmentwithoptions))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [settings]: all platforms
  ///
  ///Use the [PlatformWebViewEnvironment.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  create,

  ///Can be used to check if the [PlatformWebViewEnvironment.dispose] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.dispose.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  ///
  ///Use the [PlatformWebViewEnvironment.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  dispose,

  ///Can be used to check if the [PlatformWebViewEnvironment.getAvailableVersion] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.getAvailableVersion.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - GetAvailableCoreWebView2BrowserVersionString](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#getavailablecorewebview2browserversionstring))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [browserExecutableFolder]: all platforms
  ///
  ///Use the [PlatformWebViewEnvironment.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getAvailableVersion,

  ///Can be used to check if the [PlatformWebViewEnvironment.getFailureReportFolderPath] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.getFailureReportFolderPath.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.1518.46++ ([Official API - ICoreWebView2Environment11.get_FailureReportFolderPath](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environment11?view=webview2-1.0.2849.39#get_failurereportfolderpath))
  ///
  ///Use the [PlatformWebViewEnvironment.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getFailureReportFolderPath,

  ///Can be used to check if the [PlatformWebViewEnvironment.getProcessInfos] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.getProcessInfos.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.1108.44++ ([Official API - ICoreWebView2Environment8.GetProcessInfos](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environment8?view=webview2-1.0.2849.39#getprocessinfos))
  ///
  ///Use the [PlatformWebViewEnvironment.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getProcessInfos,

  ///Can be used to check if the [PlatformWebViewEnvironment.isInterfaceSupported] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.isInterfaceSupported.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [interface]: all platforms
  ///
  ///Use the [PlatformWebViewEnvironment.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  isInterfaceSupported,
}

extension _PlatformWebViewEnvironmentMethodSupported
    on PlatformWebViewEnvironment {
  static bool isMethodSupported(PlatformWebViewEnvironmentMethod method,
      {TargetPlatform? platform}) {
    switch (method) {
      case PlatformWebViewEnvironmentMethod.compareBrowserVersions:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.windows]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformWebViewEnvironmentMethod.create:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.windows]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformWebViewEnvironmentMethod.dispose:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.windows]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformWebViewEnvironmentMethod.getAvailableVersion:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.windows]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformWebViewEnvironmentMethod.getFailureReportFolderPath:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.windows]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformWebViewEnvironmentMethod.getProcessInfos:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.windows]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformWebViewEnvironmentMethod.isInterfaceSupported:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.windows]
                .contains(platform ?? defaultTargetPlatform);
    }
  }
}
