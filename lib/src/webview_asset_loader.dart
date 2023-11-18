import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

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
class WebViewAssetLoader {
  /// Constructs a [WebViewAssetLoader].
  ///
  /// See [WebViewAssetLoader.fromPlatformCreationParams] for setting
  /// parameters for a specific platform.
  WebViewAssetLoader(
      {String? domain, bool? httpAllowed, List<PathHandler>? pathHandlers})
      : this.fromPlatformCreationParams(
            params: PlatformWebViewAssetLoaderCreationParams(
                domain: domain,
                httpAllowed: httpAllowed,
                pathHandlers: pathHandlers?.map((e) => e.platform).toList()));

  /// Constructs a [WebViewAssetLoader].
  ///
  /// See [WebViewAssetLoader.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  WebViewAssetLoader.fromPlatformCreationParams({
    required PlatformWebViewAssetLoaderCreationParams params,
  }) : this.fromPlatform(platform: PlatformWebViewAssetLoader(params));

  /// Constructs a [WebViewAssetLoader] from a specific platform implementation.
  WebViewAssetLoader.fromPlatform({required this.platform});

  /// Implementation of [PlatformWebViewAssetLoader] for the current platform.
  final PlatformWebViewAssetLoader platform;

  ///An unused domain reserved for Android applications to intercept requests for app assets.
  ///
  ///It is used by default unless the user specified a different domain.
  static final String DEFAULT_DOMAIN =
      PlatformWebViewAssetLoader.DEFAULT_DOMAIN;

  ///Set the domain under which app assets can be accessed. The default domain is `appassets.androidplatform.net`.
  String? get domain => platform.domain;

  ///Allow using the HTTP scheme in addition to HTTPS. The default is to not allow HTTP.
  bool? get httpAllowed => platform.httpAllowed;

  ///List of registered path handlers.
  ///
  ///[WebViewAssetLoader] will try Path Handlers in the order they're registered,
  ///and will use whichever is the first to return a non-null.
  List<PathHandler>? get pathHandlers => platform.pathHandlers
      ?.map((platform) {
        switch (platform.runtimeType) {
          case AssetsPathHandler:
            return AssetsPathHandler.fromPlatform(
                platform: platform as PlatformAssetsPathHandler);
          case ResourcesPathHandler:
            return ResourcesPathHandler.fromPlatform(
                platform: platform as PlatformResourcesPathHandler);
          case InternalStoragePathHandler:
            return InternalStoragePathHandler.fromPlatform(
                platform: platform as PlatformInternalStoragePathHandler);
        }
        return null;
      })
      .whereType<PathHandler>()
      .toList();
}

///A handler that produces responses for a registered path.
///
///Implement this interface to handle other use-cases according to your app's needs.
abstract class PathHandler implements PlatformPathHandlerEvents {
  /// Constructs a [PathHandler].
  ///
  /// See [PathHandler.fromPlatformCreationParams] for setting
  /// parameters for a specific platform.
  PathHandler({required String path})
      : this.fromPlatformCreationParams(
            params: PlatformPathHandlerCreationParams(path: path));

  /// Constructs a [PathHandler].
  ///
  /// See [PathHandler.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  PathHandler.fromPlatformCreationParams({
    required PlatformPathHandlerCreationParams params,
  }) : this.fromPlatform(platform: PlatformPathHandler(params));

  /// Constructs a [PathHandler] from a specific platform implementation.
  PathHandler.fromPlatform({required this.platform}) {
    this.platform.eventHandler = this;
  }

  /// Implementation of [PlatformPathHandler] for the current platform.
  final PlatformPathHandler platform;

  ///The suffix path to be handled.
  ///
  ///The path should start and end with a `"/"` and it shouldn't collide with a real web path.
  String get path => platform.path;

  ///Handles the requested URL by returning the appropriate response.
  ///
  ///Returning a `null` value means that the handler decided not to handle this path.
  ///In this case, [WebViewAssetLoader] will try the next handler registered on this path or pass to [WebView] that will fall back to network to try to resolve the URL.
  ///
  ///However, if the handler wants to save unnecessary processing either by another handler or by falling back to network,
  ///in cases like a file cannot be found, it may return a `WebResourceResponse(data: null)`
  ///which is received as an HTTP response with status code `404` and no body.
  Future<WebResourceResponse?> handle(String path) async {
    return null;
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
class AssetsPathHandler extends PathHandler {
  /// Constructs a [AssetsPathHandler].
  ///
  /// See [AssetsPathHandler.fromPlatformCreationParams] for setting
  /// parameters for a specific platform.
  AssetsPathHandler({required String path})
      : this.fromPlatformCreationParams(
            params: PlatformAssetsPathHandlerCreationParams(
                PlatformPathHandlerCreationParams(path: path)));

  /// Constructs a [AssetsPathHandler].
  ///
  /// See [AssetsPathHandler.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  AssetsPathHandler.fromPlatformCreationParams({
    required PlatformAssetsPathHandlerCreationParams params,
  }) : this.fromPlatform(platform: PlatformAssetsPathHandler(params));

  /// Constructs a [AssetsPathHandler] from a specific platform implementation.
  AssetsPathHandler.fromPlatform({required this.platform})
      : super.fromPlatform(platform: platform);

  /// Implementation of [PlatformAssetsPathHandler] for the current platform.
  final PlatformAssetsPathHandler platform;
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
class ResourcesPathHandler extends PathHandler {
  /// Constructs a [ResourcesPathHandler].
  ///
  /// See [ResourcesPathHandler.fromPlatformCreationParams] for setting
  /// parameters for a specific platform.
  ResourcesPathHandler({required String path})
      : this.fromPlatformCreationParams(
            params: PlatformResourcesPathHandlerCreationParams(
                PlatformPathHandlerCreationParams(path: path)));

  /// Constructs a [ResourcesPathHandler].
  ///
  /// See [ResourcesPathHandler.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  ResourcesPathHandler.fromPlatformCreationParams({
    required PlatformResourcesPathHandlerCreationParams params,
  }) : this.fromPlatform(platform: PlatformResourcesPathHandler(params));

  /// Constructs a [ResourcesPathHandler] from a specific platform implementation.
  ResourcesPathHandler.fromPlatform({required this.platform})
      : super.fromPlatform(platform: platform);

  /// Implementation of [PlatformResourcesPathHandler] for the current platform.
  final PlatformResourcesPathHandler platform;
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
class InternalStoragePathHandler extends PathHandler {
  /// Constructs a [InternalStoragePathHandler].
  ///
  /// See [InternalStoragePathHandler.fromPlatformCreationParams] for setting
  /// parameters for a specific platform.
  InternalStoragePathHandler({required String path, required String directory})
      : this.fromPlatformCreationParams(
            params: PlatformInternalStoragePathHandlerCreationParams(
                PlatformPathHandlerCreationParams(path: path),
                directory: directory));

  /// Constructs a [InternalStoragePathHandler].
  ///
  /// See [InternalStoragePathHandler.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  InternalStoragePathHandler.fromPlatformCreationParams({
    required PlatformInternalStoragePathHandlerCreationParams params,
  }) : this.fromPlatform(platform: PlatformInternalStoragePathHandler(params));

  /// Constructs a [InternalStoragePathHandler] from a specific platform implementation.
  InternalStoragePathHandler.fromPlatform({required this.platform})
      : super.fromPlatform(platform: platform);

  /// Implementation of [PlatformInternalStoragePathHandler] for the current platform.
  final PlatformInternalStoragePathHandler platform;

  String get directory => platform.directory;
}
