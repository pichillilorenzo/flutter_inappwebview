// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_webview_asset_loader.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Helper class to load local files including application's static assets and resources using http(s):// URLs inside a `WebView` class.
///Loading local files using web-like URLs instead of `file://` is desirable as it is compatible with the Same-Origin policy.
///
///For more context about application's assets and resources and how to normally access them please refer to
///[Android Developer Docs: App resources overview](https://developer.android.com/guide/topics/resources/providing-resources).
///
///Using http(s):// URLs to access local resources may conflict with a real website.
///This means that local files should only be hosted on domains your organization owns
///(at paths reserved for this purpose) or the default domain reserved for this: `appassets.androidplatform.net`.
///
///**Officially Supported Platforms/Implementations**:
///- Android native WebView
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
  WebViewAssetLoader({this.domain, this.httpAllowed, this.pathHandlers});

  ///Gets a possible [WebViewAssetLoader] instance from a [Map] value.
  static WebViewAssetLoader? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
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
      "pathHandlers":
          pathHandlers?.map((e) => e.toMap(enumMethod: enumMethod)).toList(),
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
