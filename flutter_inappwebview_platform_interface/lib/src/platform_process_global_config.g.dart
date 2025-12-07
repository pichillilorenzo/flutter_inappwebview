// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_process_global_config.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///{@template flutter_inappwebview_platform_interface.ProcessGlobalConfigSettings}
///Class that represents the settings used to configure the [PlatformProcessGlobalConfig].
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.ProcessGlobalConfigSettings.supported_platforms}
///
///**Officially Supported Platforms/Implementations**:
///- Android WebView ([Official API - ProcessGlobalConfig.apply](https://developer.android.com/reference/androidx/webkit/ProcessGlobalConfig#apply(androidx.webkit.ProcessGlobalConfig)))
class ProcessGlobalConfigSettings {
  ///The directory name suffix to be used for the current process.
  ///Must not contain a path separator and should not be empty.
  ///
  ///Define the directory used to store WebView data for the current process.
  ///The provided suffix will be used when constructing data and cache directory paths.
  ///If this API is not called, no suffix will be used.
  ///Each directory can be used by only one process in the application.
  ///If more than one process in an app wishes to use WebView,
  ///only one process can use the default directory,
  ///and other processes must call this API to define a unique suffix.
  ///
  ///This means that different processes in the same application cannot directly share `WebView`-related data,
  ///since the data directories must be distinct.
  ///Applications that use this API may have to explicitly pass data between processes.
  ///For example, login cookies may have to be copied from one process's cookie jar to the other using [PlatformCookieManager] if both processes' WebViews are intended to be logged in.
  ///
  ///Most applications should simply ensure that all components of the app that rely
  ///on WebView are in the same process, to avoid needing multiple data directories.
  ///The [PlatformInAppWebViewController.disableWebView] method can be used to ensure that the other processes do not use WebView by accident in this case.
  ///
  ///{@macro flutter_inappwebview_platform_interface.ProcessGlobalConfigSettings.dataDirectorySuffix.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView:
  ///    - Available only if [WebViewFeature.STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX] feature is supported.
  String? dataDirectorySuffix;

  ///Set the base directories that `WebView` will use for the current process.
  ///If this method is not used, `WebView` uses the default base paths defined by the Android framework.
  ///
  ///WebView will create and use a subdirectory under each of the base paths supplied to this method.
  ///
  ///This method can be used in conjunction with setDataDirectorySuffix.
  ///A different subdirectory is created for each suffix.
  ///
  ///The base paths must be absolute paths.
  ///
  ///The data directory must not be under the Android cache directory,
  ///as Android may delete cache files when disk space is low and WebView may not function properly if this occurs.
  ///Refer to [this link](https://developer.android.com/training/data-storage/app-specific#internal-remove-cache).
  ///
  ///If the specified directories already exist then they must be readable and writable by the current process.
  ///If they do not already exist, `WebView` will attempt to create them during initialization, along with any missing parent directories.
  ///In such a case, the directory in which `WebView` creates missing directories must be readable and writable by the current process.
  ///
  ///{@macro flutter_inappwebview_platform_interface.ProcessGlobalConfigSettings.directoryBasePaths.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView:
  ///    - Available only if [WebViewFeature.STARTUP_FEATURE_SET_DIRECTORY_BASE_PATHS] feature is supported.
  ProcessGlobalConfigDirectoryBasePaths? directoryBasePaths;

  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - ProcessGlobalConfig.apply](https://developer.android.com/reference/androidx/webkit/ProcessGlobalConfig#apply(androidx.webkit.ProcessGlobalConfig)))
  ProcessGlobalConfigSettings(
      {this.dataDirectorySuffix, this.directoryBasePaths});

  ///Gets a possible [ProcessGlobalConfigSettings] instance from a [Map] value.
  static ProcessGlobalConfigSettings? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = ProcessGlobalConfigSettings(
      dataDirectorySuffix: map['dataDirectorySuffix'],
      directoryBasePaths: ProcessGlobalConfigDirectoryBasePaths.fromMap(
          map['directoryBasePaths']?.cast<String, dynamic>(),
          enumMethod: enumMethod),
    );
    return instance;
  }

  ///{@template flutter_inappwebview_platform_interface.ProcessGlobalConfigSettings.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) =>
      _ProcessGlobalConfigSettingsClassSupported.isClassSupported(
          platform: platform);

  ///{@template flutter_inappwebview_platform_interface.ProcessGlobalConfigSettings.isPropertySupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  static bool isPropertySupported(ProcessGlobalConfigSettingsProperty property,
          {TargetPlatform? platform}) =>
      _ProcessGlobalConfigSettingsPropertySupported.isPropertySupported(
          property,
          platform: platform);

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "dataDirectorySuffix": dataDirectorySuffix,
      "directoryBasePaths": directoryBasePaths?.toMap(enumMethod: enumMethod),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  ///Returns a copy of ProcessGlobalConfigSettings.
  ProcessGlobalConfigSettings copy() {
    return ProcessGlobalConfigSettings.fromMap(toMap()) ??
        ProcessGlobalConfigSettings();
  }

  @override
  String toString() {
    return 'ProcessGlobalConfigSettings{dataDirectorySuffix: $dataDirectorySuffix, directoryBasePaths: $directoryBasePaths}';
  }
}

///Class that represents the settings used to configure the [ProcessGlobalConfigSettings.directoryBasePaths].
///
///**Officially Supported Platforms/Implementations**:
///- Android native WebView ([Official API - ProxyConfig](https://developer.android.com/reference/androidx/webkit/ProxyConfig))
class ProcessGlobalConfigDirectoryBasePaths {
  ///The absolute base path for the WebView cache directory.
  String cacheDirectoryBasePath;

  ///The absolute base path for the WebView data directory.
  String dataDirectoryBasePath;
  ProcessGlobalConfigDirectoryBasePaths(
      {required this.cacheDirectoryBasePath,
      required this.dataDirectoryBasePath});

  ///Gets a possible [ProcessGlobalConfigDirectoryBasePaths] instance from a [Map] value.
  static ProcessGlobalConfigDirectoryBasePaths? fromMap(
      Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = ProcessGlobalConfigDirectoryBasePaths(
      cacheDirectoryBasePath: map['cacheDirectoryBasePath'],
      dataDirectoryBasePath: map['dataDirectoryBasePath'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "cacheDirectoryBasePath": cacheDirectoryBasePath,
      "dataDirectoryBasePath": dataDirectoryBasePath,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'ProcessGlobalConfigDirectoryBasePaths{cacheDirectoryBasePath: $cacheDirectoryBasePath, dataDirectoryBasePath: $dataDirectoryBasePath}';
  }
}

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

extension _PlatformProcessGlobalConfigCreationParamsClassSupported
    on PlatformProcessGlobalConfigCreationParams {
  ///{@template flutter_inappwebview_platform_interface.PlatformProcessGlobalConfigCreationParams.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [PlatformProcessGlobalConfigCreationParams.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android].contains(platform ?? defaultTargetPlatform);
  }
}

extension _PlatformProcessGlobalConfigClassSupported
    on PlatformProcessGlobalConfig {
  ///{@template flutter_inappwebview_platform_interface.PlatformProcessGlobalConfig.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - ProcessGlobalConfig](https://developer.android.com/reference/androidx/webkit/ProcessGlobalConfig))
  ///
  ///Use the [PlatformProcessGlobalConfig.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformProcessGlobalConfig]'s methods that can be used to check if they are supported or not by the current platform.
enum PlatformProcessGlobalConfigMethod {
  ///Can be used to check if the [PlatformProcessGlobalConfig.apply] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformProcessGlobalConfig.apply.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - ProcessGlobalConfig.apply](https://developer.android.com/reference/androidx/webkit/ProcessGlobalConfig#apply(androidx.webkit.ProcessGlobalConfig)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [settings]: all platforms
  ///
  ///Use the [PlatformProcessGlobalConfig.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  apply,
}

extension _PlatformProcessGlobalConfigMethodSupported
    on PlatformProcessGlobalConfig {
  static bool isMethodSupported(PlatformProcessGlobalConfigMethod method,
      {TargetPlatform? platform}) {
    switch (method) {
      case PlatformProcessGlobalConfigMethod.apply:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
    }
  }
}

extension _ProcessGlobalConfigSettingsClassSupported
    on ProcessGlobalConfigSettings {
  ///{@template flutter_inappwebview_platform_interface.ProcessGlobalConfigSettings.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - ProcessGlobalConfig.apply](https://developer.android.com/reference/androidx/webkit/ProcessGlobalConfig#apply(androidx.webkit.ProcessGlobalConfig)))
  ///
  ///Use the [ProcessGlobalConfigSettings.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [ProcessGlobalConfigSettings]'s properties that can be used to check i they are supported or not by the current platform.
enum ProcessGlobalConfigSettingsProperty {
  ///Can be used to check if the [ProcessGlobalConfigSettings.dataDirectorySuffix] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ProcessGlobalConfigSettings.dataDirectorySuffix.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView:
  ///    - Available only if [WebViewFeature.STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX] feature is supported.
  ///
  ///Use the [ProcessGlobalConfigSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  dataDirectorySuffix,

  ///Can be used to check if the [ProcessGlobalConfigSettings.directoryBasePaths] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ProcessGlobalConfigSettings.directoryBasePaths.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView:
  ///    - Available only if [WebViewFeature.STARTUP_FEATURE_SET_DIRECTORY_BASE_PATHS] feature is supported.
  ///
  ///Use the [ProcessGlobalConfigSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  directoryBasePaths,
}

extension _ProcessGlobalConfigSettingsPropertySupported
    on ProcessGlobalConfigSettings {
  static bool isPropertySupported(ProcessGlobalConfigSettingsProperty property,
      {TargetPlatform? platform}) {
    switch (property) {
      case ProcessGlobalConfigSettingsProperty.dataDirectorySuffix:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case ProcessGlobalConfigSettingsProperty.directoryBasePaths:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
    }
  }
}
