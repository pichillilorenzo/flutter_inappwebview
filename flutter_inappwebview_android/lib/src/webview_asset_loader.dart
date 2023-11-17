import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

/// Object specifying creation parameters for creating a [AndroidWebViewAssetLoader].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformWebViewAssetLoaderCreationParams] for
/// more information.
@immutable
class AndroidWebViewAssetLoaderCreationParams
    extends PlatformWebViewAssetLoaderCreationParams {
  /// Creates a new [AndroidWebViewAssetLoaderCreationParams] instance.
  const AndroidWebViewAssetLoaderCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformWebViewAssetLoaderCreationParams params,
  ) : super();

  /// Creates a [AndroidWebViewAssetLoaderCreationParams] instance based on [PlatformWebViewAssetLoaderCreationParams].
  factory AndroidWebViewAssetLoaderCreationParams.fromPlatformWebViewAssetLoaderCreationParams(
      PlatformWebViewAssetLoaderCreationParams params) {
    return AndroidWebViewAssetLoaderCreationParams(params);
  }
}

///Helper class to load local files including application's static assets and resources using http(s):// URLs inside a [WebView] class.
///Loading local files using web-like URLs instead of `file://` is desirable as it is compatible with the Same-Origin policy.
///
///For more context about application's assets and resources and how to normally access them please refer to
///[Android Developer Docs: App resources overview](https://developer.android.com/guide/topics/resources/providing-resources).
///
///Using http(s):// URLs to access local resources may conflict with a real website.
///This means that local files should only be hosted on domains your organization owns
///(at paths reserved for this purpose) or the default domain reserved for this: `appassets.androidplatform.net`.
///
///**Supported Platforms/Implementations**:
///- Android native WebView
class AndroidWebViewAssetLoader extends PlatformWebViewAssetLoader {
  /// Creates a new [AndroidWebViewAssetLoader].
  AndroidWebViewAssetLoader(PlatformWebViewAssetLoaderCreationParams params)
      : super.implementation(
          params is AndroidWebViewAssetLoaderCreationParams
              ? params
              : AndroidWebViewAssetLoaderCreationParams
                  .fromPlatformWebViewAssetLoaderCreationParams(params),
        );

  factory AndroidWebViewAssetLoader.static() {
    return instance();
  }

  static AndroidWebViewAssetLoader? _instance;

  ///Gets the [AndroidWebViewAssetLoader] shared instance.
  static AndroidWebViewAssetLoader instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static AndroidWebViewAssetLoader _init() {
    _instance = AndroidWebViewAssetLoader(
        AndroidWebViewAssetLoaderCreationParams(
            const PlatformWebViewAssetLoaderCreationParams()));
    return _instance!;
  }

  ///Set the domain under which app assets can be accessed. The default domain is `appassets.androidplatform.net`.
  String? get domain => params.domain;

  ///Allow using the HTTP scheme in addition to HTTPS. The default is to not allow HTTP.
  bool? get httpAllowed => params.httpAllowed;

  ///List of registered path handlers.
  ///
  ///[WebViewAssetLoader] will try Path Handlers in the order they're registered,
  ///and will use whichever is the first to return a non-null.
  List<AndroidPathHandler>? get pathHandlers =>
      params.pathHandlers as List<AndroidPathHandler>?;

  ///Gets a possible [AndroidWebViewAssetLoader] instance from a [Map] value.
  AndroidWebViewAssetLoader? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = AndroidWebViewAssetLoader(
        AndroidWebViewAssetLoaderCreationParams(
            PlatformWebViewAssetLoaderCreationParams(
      domain: map['domain'],
      httpAllowed: map['httpAllowed'],
      pathHandlers: map['pathHandlers'] != null
          ? List<AndroidPathHandler>.from(map['pathHandlers'].map((e) => e))
          : null,
    )));
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "domain": domain,
      "httpAllowed": httpAllowed,
      "pathHandlers": pathHandlers?.map((e) => e.toMap()).toList(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  ///Returns a copy of WebViewAssetLoader.
  AndroidWebViewAssetLoader copy() {
    return fromMap(toMap()) ??
        AndroidWebViewAssetLoader(AndroidWebViewAssetLoaderCreationParams(
            const PlatformWebViewAssetLoaderCreationParams()));
  }

  @override
  String toString() {
    return 'AndroidWebViewAssetLoader{domain: $domain, httpAllowed: $httpAllowed, pathHandlers: $pathHandlers}';
  }
}

/// Object specifying creation parameters for creating a [AndroidPathHandler].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformPathHandlerCreationParams] for
/// more information.
@immutable
class AndroidPathHandlerCreationParams
    extends PlatformPathHandlerCreationParams {
  /// Creates a new [AndroidPathHandlerCreationParams] instance.
  AndroidPathHandlerCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformPathHandlerCreationParams params,
  ) : super(path: params.path);

  /// Creates a [AndroidPathHandlerCreationParams] instance based on [PlatformPathHandlerCreationParams].
  factory AndroidPathHandlerCreationParams.fromPlatformPathHandlerCreationParams(
      PlatformPathHandlerCreationParams params) {
    return AndroidPathHandlerCreationParams(params);
  }
}

///A handler that produces responses for a registered path.
///
///Implement this interface to handle other use-cases according to your app's needs.
class AndroidPathHandler extends PlatformPathHandler
    with ChannelController {
  /// Creates a new [AndroidPathHandler].
  AndroidPathHandler(PlatformPathHandlerCreationParams params)
      : super.implementation(
          params is AndroidPathHandlerCreationParams
              ? params
              : AndroidPathHandlerCreationParams
                  .fromPlatformPathHandlerCreationParams(params),
        ) {
    _type = this.runtimeType.toString();
    _id = IdGenerator.generate();
    channel = MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_custompathhandler_${_id}');
    handler = _handleMethod;
    initMethodCallHandler();
  }

  late final String _type;
  late final String _id;

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "handle":
        String path = call.arguments["path"];
        return (await eventHandler?.handle(path))?.toMap();
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {"path": path, "type": _type, "id": _id};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'AndroidPathHandler{path: $path}';
  }

  @override
  void dispose() {
    disposeChannel();
    eventHandler = null;
  }
}

/// Object specifying creation parameters for creating a [AndroidAssetsPathHandler].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformAssetsPathHandlerCreationParams] for
/// more information.
@immutable
class AndroidAssetsPathHandlerCreationParams
    extends PlatformAssetsPathHandlerCreationParams {
  /// Creates a new [AndroidAssetsPathHandlerCreationParams] instance.
  AndroidAssetsPathHandlerCreationParams(
      // This parameter prevents breaking changes later.
      // ignore: avoid_unused_constructor_parameters
      PlatformAssetsPathHandlerCreationParams params,
      ) : super(params);

  /// Creates a [AndroidAssetsPathHandlerCreationParams] instance based on [PlatformAssetsPathHandlerCreationParams].
  factory AndroidAssetsPathHandlerCreationParams.fromPlatformAssetsPathHandlerCreationParams(
      PlatformAssetsPathHandlerCreationParams params) {
    return AndroidAssetsPathHandlerCreationParams(params);
  }
}

///Handler class to open a file from assets directory in the application APK.
///
///Opens the requested file from the application's assets directory.
///
///The matched prefix path used shouldn't be a prefix of a real web path.
///Thus, if the requested file cannot be found a [WebResourceResponse] object with a `null` data will be returned instead of `null`.
///This saves the time of falling back to network and trying to resolve a path that doesn't exist.
///A [WebResourceResponse] with `null` data will be received as an HTTP response with status code `404` and no body.
///
///The MIME type for the file will be determined from the file's extension using
///[guessContentTypeFromName](https://developer.android.com/reference/java/net/URLConnection.html#guessContentTypeFromName-java.lang.String-).
///Developers should ensure that asset files are named using standard file extensions.
///If the file does not have a recognised extension, `text/plain` will be used by default.
class AndroidAssetsPathHandler extends AndroidPathHandler implements PlatformAssetsPathHandler {
  /// Constructs a [AndroidAssetsPathHandler].
  AndroidAssetsPathHandler(PlatformAssetsPathHandlerCreationParams params)
      : super(
    params is AndroidAssetsPathHandlerCreationParams
        ? params
        : AndroidAssetsPathHandlerCreationParams
        .fromPlatformAssetsPathHandlerCreationParams(params),
  );
}

/// Object specifying creation parameters for creating a [AndroidResourcesPathHandler].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformResourcesPathHandlerCreationParams] for
/// more information.
@immutable
class AndroidResourcesPathHandlerCreationParams
    extends PlatformResourcesPathHandlerCreationParams {
  /// Creates a new [AndroidResourcesPathHandlerCreationParams] instance.
  AndroidResourcesPathHandlerCreationParams(
      // This parameter prevents breaking changes later.
      // ignore: avoid_unused_constructor_parameters
      PlatformResourcesPathHandlerCreationParams params,
      ) : super(params);

  /// Creates a [AndroidResourcesPathHandlerCreationParams] instance based on [PlatformResourcesPathHandlerCreationParams].
  factory AndroidResourcesPathHandlerCreationParams.fromPlatformResourcesPathHandlerCreationParams(
      PlatformResourcesPathHandlerCreationParams params) {
    return AndroidResourcesPathHandlerCreationParams(params);
  }
}

///Handler class to open a file from resources directory in the application APK.
///
///Opens the requested file from application's resources directory.
///
///The matched prefix path used shouldn't be a prefix of a real web path.
///Thus, if the requested file cannot be found a [WebResourceResponse] object with a `null` data will be returned instead of `null`.
///This saves the time of falling back to network and trying to resolve a path that doesn't exist.
///A [WebResourceResponse] with `null` data will be received as an HTTP response with status code `404` and no body.
///
///The MIME type for the file will be determined from the file's extension using
///[guessContentTypeFromName](https://developer.android.com/reference/java/net/URLConnection.html#guessContentTypeFromName-java.lang.String-).
///Developers should ensure that asset files are named using standard file extensions.
///If the file does not have a recognised extension, `text/plain` will be used by default.
class AndroidResourcesPathHandler extends AndroidPathHandler implements PlatformResourcesPathHandler {
  /// Constructs a [AndroidResourcesPathHandler].
  AndroidResourcesPathHandler(PlatformResourcesPathHandlerCreationParams params)
      : super(
    params is AndroidResourcesPathHandlerCreationParams
        ? params
        : AndroidResourcesPathHandlerCreationParams
        .fromPlatformResourcesPathHandlerCreationParams(params),
  );
}

/// Object specifying creation parameters for creating a [AndroidInternalStoragePathHandler].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformInternalStoragePathHandlerCreationParams] for
/// more information.
@immutable
class AndroidInternalStoragePathHandlerCreationParams
    extends PlatformInternalStoragePathHandlerCreationParams {
  /// Creates a new [AndroidInternalStoragePathHandlerCreationParams] instance.
  AndroidInternalStoragePathHandlerCreationParams(
      // This parameter prevents breaking changes later.
      // ignore: avoid_unused_constructor_parameters
      PlatformInternalStoragePathHandlerCreationParams params,
      ) : super(params, directory: params.directory);

  /// Creates a [AndroidInternalStoragePathHandlerCreationParams] instance based on [PlatformInternalStoragePathHandlerCreationParams].
  factory AndroidInternalStoragePathHandlerCreationParams.fromPlatformInternalStoragePathHandlerCreationParams(
      PlatformInternalStoragePathHandlerCreationParams params) {
    return AndroidInternalStoragePathHandlerCreationParams(params);
  }
}

///Handler class to open files from application internal storage.
///For more information about android storage please refer to
///[Android Developers Docs: Data and file storage overview](https://developer.android.com/guide/topics/data/data-storage).
///
///To avoid leaking user or app data to the web, make sure to choose [directory] carefully,
///and assume any file under this directory could be accessed by any web page subject to same-origin rules.
///
///Opens the requested file from the exposed data directory.
///
///The matched prefix path used shouldn't be a prefix of a real web path.
///Thus, if the requested file cannot be found a [WebResourceResponse] object with a `null` data will be returned instead of `null`.
///This saves the time of falling back to network and trying to resolve a path that doesn't exist.
///A [WebResourceResponse] with `null` data will be received as an HTTP response with status code `404` and no body.
///
///The MIME type for the file will be determined from the file's extension using
///[guessContentTypeFromName](https://developer.android.com/reference/java/net/URLConnection.html#guessContentTypeFromName-java.lang.String-).
///Developers should ensure that asset files are named using standard file extensions.
///If the file does not have a recognised extension, `text/plain` will be used by default.
class AndroidInternalStoragePathHandler extends AndroidPathHandler implements PlatformInternalStoragePathHandler {
  /// Constructs a [AndroidInternalStoragePathHandler].
  AndroidInternalStoragePathHandler(PlatformInternalStoragePathHandlerCreationParams params)
      : super(
    params is AndroidInternalStoragePathHandlerCreationParams
        ? params
        : AndroidInternalStoragePathHandlerCreationParams
        .fromPlatformInternalStoragePathHandlerCreationParams(params),
  );

  AndroidInternalStoragePathHandlerCreationParams get _internalParams =>
      params as AndroidInternalStoragePathHandlerCreationParams;

  @override
  String get directory => _internalParams.directory;
}
