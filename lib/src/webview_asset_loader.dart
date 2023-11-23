import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

///A handler that produces responses for a registered path.
///
///Implement this interface to handle other use-cases according to your app's needs.
abstract class PathHandler implements IPathHandler, PlatformPathHandlerEvents {
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

  @override
  Map<String, dynamic> toMap() => platform.toMap();

  @override
  Map<String, dynamic> toJson() => platform.toJson();
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
