import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'inappwebview_platform.dart';
import 'types/web_resource_response.dart';

part 'platform_webview_asset_loader.g.dart';

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
@ExchangeableObject(copyMethod: true)
class WebViewAssetLoader_ {
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
  List<IPathHandler>? pathHandlers;

  WebViewAssetLoader_({this.domain, this.httpAllowed, this.pathHandlers});
}

///[PlatformPathHandler] interface.
abstract class IPathHandler {
  String get path {
    throw UnimplementedError('path is not implemented on the current platform');
  }

  Map<String, dynamic> toMap() {
    throw UnimplementedError(
        'toMap is not implemented on the current platform');
  }

  Map<String, dynamic> toJson() {
    throw UnimplementedError(
        'toJson is not implemented on the current platform');
  }
}

/// Object specifying creation parameters for creating a [PlatformPathHandler].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
@immutable
class PlatformPathHandlerCreationParams {
  /// Used by the platform implementation to create a new [PlatformPathHandler].
  const PlatformPathHandlerCreationParams({required this.path});

  ///{@macro flutter_inappwebview_platform_interface.PlatformPathHandler.path}
  final String path;
}

///{@template flutter_inappwebview_platform_interface.PlatformPathHandler}
///A handler that produces responses for a registered path.
///
///Implement this interface to handle other use-cases according to your app's needs.
///{@endtemplate}
abstract class PlatformPathHandler extends PlatformInterface
    implements IPathHandler {
  /// Creates a new [PlatformWebViewAssetLoader]
  factory PlatformPathHandler(PlatformPathHandlerCreationParams params) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`WebViewPlatform.instance` before use. For unit testing, '
      '`WebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformPathHandler pathHandler =
        InAppWebViewPlatform.instance!.createPlatformPathHandler(params);
    PlatformInterface.verify(pathHandler, _token);
    return pathHandler;
  }

  /// Used by the platform implementation to create a new
  /// [PlatformPathHandler].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformPathHandler.implementation(this.params) : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformPathHandler].
  final PlatformPathHandlerCreationParams params;

  /// Event handler object that handles the [PlatformPathHandler] events.
  PlatformPathHandlerEvents? eventHandler;

  ///{@template flutter_inappwebview_platform_interface.PlatformPathHandler.path}
  ///The suffix path to be handled.
  ///
  ///The path should start and end with a `"/"` and it shouldn't collide with a real web path.
  ///{@endtemplate}
  String get path => params.path;

  Map<String, dynamic> toMap() {
    throw UnimplementedError(
        'toMap is not implemented on the current platform');
  }

  Map<String, dynamic> toJson() {
    throw UnimplementedError(
        'toJson is not implemented on the current platform');
  }
}

///Interface path handler events.
abstract class PlatformPathHandlerEvents {
  ///{@template flutter_inappwebview_platform_interface.PlatformPathHandler.handle}
  ///Handles the requested URL by returning the appropriate response.
  ///
  ///Returning a `null` value means that the handler decided not to handle this path.
  ///In this case, [WebViewAssetLoader] will try the next handler registered on this path or pass to `WebView` that will fall back to network to try to resolve the URL.
  ///
  ///However, if the handler wants to save unnecessary processing either by another handler or by falling back to network,
  ///in cases like a file cannot be found, it may return a `WebResourceResponse(data: null)`
  ///which is received as an HTTP response with status code `404` and no body.
  ///{@endtemplate}
  Future<WebResourceResponse?> handle(String path) {
    throw UnimplementedError(
        'handle is not implemented on the current platform');
  }
}

/// Object specifying creation parameters for creating a [PlatformAssetsPathHandler].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
@immutable
class PlatformAssetsPathHandlerCreationParams
    extends PlatformPathHandlerCreationParams {
  /// Used by the platform implementation to create a new [PlatformAssetsPathHandler].
  PlatformAssetsPathHandlerCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformPathHandlerCreationParams params,
  ) : super(path: params.path);

  /// Creates a [AndroidCookieManagerCreationParams] instance based on [PlatformCookieManagerCreationParams].
  factory PlatformAssetsPathHandlerCreationParams.fromPlatformPathHandlerCreationParams(
      PlatformPathHandlerCreationParams params) {
    return PlatformAssetsPathHandlerCreationParams(params);
  }
}

///{@template flutter_inappwebview_platform_interface.PlatformAssetsPathHandler}
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
///{@endtemplate}
abstract class PlatformAssetsPathHandler extends PlatformPathHandler {
  /// Creates a new [PlatformAssetsPathHandler]
  factory PlatformAssetsPathHandler(
      PlatformAssetsPathHandlerCreationParams params) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformAssetsPathHandler assetsPathHandler =
        InAppWebViewPlatform.instance!.createPlatformAssetsPathHandler(params);
    PlatformInterface.verify(assetsPathHandler, _token);
    return assetsPathHandler;
  }

  /// Used by the platform implementation to create a new [PlatformAssetsPathHandler].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformAssetsPathHandler.implementation(
      PlatformPathHandlerCreationParams params)
      : super.implementation(
          params is PlatformAssetsPathHandlerCreationParams
              ? params
              : PlatformAssetsPathHandlerCreationParams
                  .fromPlatformPathHandlerCreationParams(params),
        );

  static final Object _token = Object();
}

/// Object specifying creation parameters for creating a [PlatformResourcesPathHandler].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
@immutable
class PlatformResourcesPathHandlerCreationParams
    extends PlatformPathHandlerCreationParams {
  /// Used by the platform implementation to create a new [PlatformResourcesPathHandler].
  PlatformResourcesPathHandlerCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformPathHandlerCreationParams params,
  ) : super(path: params.path);

  /// Creates a [AndroidCookieManagerCreationParams] instance based on [PlatformCookieManagerCreationParams].
  factory PlatformResourcesPathHandlerCreationParams.fromPlatformPathHandlerCreationParams(
      PlatformPathHandlerCreationParams params) {
    return PlatformResourcesPathHandlerCreationParams(params);
  }
}

///{@template flutter_inappwebview_platform_interface.PlatformResourcesPathHandler}
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
///{@endtemplate}
abstract class PlatformResourcesPathHandler extends PlatformPathHandler {
  /// Creates a new [PlatformResourcesPathHandler]
  factory PlatformResourcesPathHandler(
      PlatformResourcesPathHandlerCreationParams params) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformResourcesPathHandler resourcesPathHandler =
        InAppWebViewPlatform.instance!
            .createPlatformResourcesPathHandler(params);
    PlatformInterface.verify(resourcesPathHandler, _token);
    return resourcesPathHandler;
  }

  /// Used by the platform implementation to create a new [PlatformResourcesPathHandler].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformResourcesPathHandler.implementation(
      PlatformPathHandlerCreationParams params)
      : super.implementation(
          params is PlatformResourcesPathHandlerCreationParams
              ? params
              : PlatformResourcesPathHandlerCreationParams
                  .fromPlatformPathHandlerCreationParams(params),
        );

  static final Object _token = Object();
}

/// Object specifying creation parameters for creating a [PlatformInternalStoragePathHandler].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
@immutable
class PlatformInternalStoragePathHandlerCreationParams
    extends PlatformPathHandlerCreationParams {
  /// Used by the platform implementation to create a new [PlatformInternalStoragePathHandler].
  PlatformInternalStoragePathHandlerCreationParams(
      // This parameter prevents breaking changes later.
      // ignore: avoid_unused_constructor_parameters
      PlatformPathHandlerCreationParams params,
      {required this.directory})
      : super(path: params.path);

  /// Creates a [AndroidCookieManagerCreationParams] instance based on [PlatformCookieManagerCreationParams].
  factory PlatformInternalStoragePathHandlerCreationParams.fromPlatformPathHandlerCreationParams(
      PlatformPathHandlerCreationParams params,
      {required String directory}) {
    return PlatformInternalStoragePathHandlerCreationParams(params,
        directory: directory);
  }

  final String directory;
}

///{@template flutter_inappwebview_platform_interface.PlatformInternalStoragePathHandler}
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
///{@endtemplate}
abstract class PlatformInternalStoragePathHandler extends PlatformPathHandler {
  /// Creates a new [PlatformResourcesPathHandler]
  factory PlatformInternalStoragePathHandler(
      PlatformInternalStoragePathHandlerCreationParams params) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformInternalStoragePathHandler internalStoragePathHandler =
        InAppWebViewPlatform.instance!
            .createPlatformInternalStoragePathHandler(params);
    PlatformInterface.verify(internalStoragePathHandler, _token);
    return internalStoragePathHandler;
  }

  /// Used by the platform implementation to create a new [PlatformInternalStoragePathHandler].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformInternalStoragePathHandler.implementation(
      PlatformPathHandlerCreationParams params,
      {required String directory})
      : super.implementation(
          params is PlatformInternalStoragePathHandlerCreationParams
              ? params
              : PlatformInternalStoragePathHandlerCreationParams
                  .fromPlatformPathHandlerCreationParams(params,
                      directory: directory),
        );

  static final Object _token = Object();

  PlatformInternalStoragePathHandlerCreationParams get _internalParams =>
      params as PlatformInternalStoragePathHandlerCreationParams;

  String get directory => _internalParams.directory;
}
