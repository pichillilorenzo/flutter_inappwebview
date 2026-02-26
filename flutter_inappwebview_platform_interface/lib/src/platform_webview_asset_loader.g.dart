// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_webview_asset_loader.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///{@template flutter_inappwebview_platform_interface.WebViewAssetLoader}
///Helper class to load local files including application's static assets and resources using http(s):// URLs inside a `WebView` class.
///Loading local files using web-like URLs instead of `file://` is desirable as it is compatible with the Same-Origin policy.
///
///For more context about application's assets and resources and how to normally access them please refer to
///[Android Developer Docs: App resources overview](https://developer.android.com/guide/topics/resources/providing-resources).
///
///Using http(s):// URLs to access local resources may conflict with a real website.
///This means that local files should only be hosted on domains your organization owns
///(at paths reserved for this purpose) or the default domain reserved for this: `appassets.androidplatform.net`.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.WebViewAssetLoader.supported_platforms}
///
///**Officially Supported Platforms/Implementations**:
///- Android WebView
class WebViewAssetLoader {
  ///An unused domain reserved for Android applications to intercept requests for app assets.
  ///
  ///It is used by default unless the user specified a different domain.
  static final String DEFAULT_DOMAIN = "appassets.androidplatform.net";

  ///Set the domain under which app assets can be accessed. The default domain is `appassets.androidplatform.net`.
  String? domain;

  ///Allow using the HTTP scheme in addition to HTTPS. The default is to not allow HTTP.
  bool? httpAllowed;

  ///List of registered path handlers.
  ///
  ///[WebViewAssetLoader] will try Path Handlers in the order they're registered,
  ///and will use whichever is the first to return a non-null.
  List<PlatformPathHandler>? pathHandlers;

  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  WebViewAssetLoader({this.domain, this.httpAllowed, this.pathHandlers});

  ///Gets a possible [WebViewAssetLoader] instance from a [Map] value.
  static WebViewAssetLoader? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = WebViewAssetLoader(
      domain: map['domain'],
      httpAllowed: map['httpAllowed'],
      pathHandlers: map['pathHandlers'] != null
          ? List<PlatformPathHandler>.from(map['pathHandlers'].map((e) => e))
          : null,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "domain": domain,
      "httpAllowed": httpAllowed,
      "pathHandlers": pathHandlers
          ?.map((e) => e.toMap(enumMethod: enumMethod))
          .toList(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  ///Returns a copy of WebViewAssetLoader.
  WebViewAssetLoader copy() {
    return WebViewAssetLoader.fromMap(toMap()) ?? WebViewAssetLoader();
  }

  @override
  String toString() {
    return 'WebViewAssetLoader{domain: $domain, httpAllowed: $httpAllowed, pathHandlers: $pathHandlers}';
  }
}

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

extension _PlatformPathHandlerCreationParamsClassSupported
    on PlatformPathHandlerCreationParams {
  ///{@template flutter_inappwebview_platform_interface.PlatformPathHandlerCreationParams.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [PlatformPathHandlerCreationParams.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android].contains(platform ?? defaultTargetPlatform);
  }
}

extension _PlatformAssetsPathHandlerCreationParamsClassSupported
    on PlatformAssetsPathHandlerCreationParams {
  ///{@template flutter_inappwebview_platform_interface.PlatformAssetsPathHandlerCreationParams.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [PlatformAssetsPathHandlerCreationParams.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android].contains(platform ?? defaultTargetPlatform);
  }
}

extension _PlatformAssetsPathHandlerClassSupported
    on PlatformAssetsPathHandler {
  ///{@template flutter_inappwebview_platform_interface.PlatformAssetsPathHandler.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [PlatformAssetsPathHandler.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android].contains(platform ?? defaultTargetPlatform);
  }
}

extension _PlatformResourcesPathHandlerCreationParamsClassSupported
    on PlatformResourcesPathHandlerCreationParams {
  ///{@template flutter_inappwebview_platform_interface.PlatformResourcesPathHandlerCreationParams.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [PlatformResourcesPathHandlerCreationParams.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android].contains(platform ?? defaultTargetPlatform);
  }
}

extension _PlatformResourcesPathHandlerClassSupported
    on PlatformResourcesPathHandler {
  ///{@template flutter_inappwebview_platform_interface.PlatformResourcesPathHandler.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [PlatformResourcesPathHandler.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android].contains(platform ?? defaultTargetPlatform);
  }
}

extension _PlatformInternalStoragePathHandlerCreationParamsClassSupported
    on PlatformInternalStoragePathHandlerCreationParams {
  ///{@template flutter_inappwebview_platform_interface.PlatformInternalStoragePathHandlerCreationParams.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [PlatformInternalStoragePathHandlerCreationParams.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android].contains(platform ?? defaultTargetPlatform);
  }
}

extension _PlatformInternalStoragePathHandlerClassSupported
    on PlatformInternalStoragePathHandler {
  ///{@template flutter_inappwebview_platform_interface.PlatformInternalStoragePathHandler.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [PlatformInternalStoragePathHandler.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android].contains(platform ?? defaultTargetPlatform);
  }
}

extension _PlatformCustomPathHandlerCreationParamsClassSupported
    on PlatformCustomPathHandlerCreationParams {
  ///{@template flutter_inappwebview_platform_interface.PlatformCustomPathHandlerCreationParams.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [PlatformCustomPathHandlerCreationParams.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android].contains(platform ?? defaultTargetPlatform);
  }
}

extension _PlatformCustomPathHandlerClassSupported
    on PlatformCustomPathHandler {
  ///{@template flutter_inappwebview_platform_interface.PlatformCustomPathHandler.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [PlatformCustomPathHandler.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android].contains(platform ?? defaultTargetPlatform);
  }
}
