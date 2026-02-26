import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'inappwebview_platform.dart';
import 'types/web_resource_response.dart';

part 'platform_webview_asset_loader.g.dart';

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
@SupportedPlatforms(platforms: [AndroidPlatform()])
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
  List<PlatformPathHandler>? pathHandlers;

  WebViewAssetLoader_({this.domain, this.httpAllowed, this.pathHandlers});
}

///{@template flutter_inappwebview_platform_interface.PlatformPathHandlerCreationParams}
/// Object specifying creation parameters for creating a [PlatformPathHandler].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformPathHandlerCreationParams.supported_platforms}
@SupportedPlatforms(platforms: [AndroidPlatform()])
@immutable
class PlatformPathHandlerCreationParams {
  /// Used by the platform implementation to create a new [PlatformPathHandler].
  const PlatformPathHandlerCreationParams({required this.path});

  ///{@template flutter_inappwebview_platform_interface.PlatformPathHandlerCreationParams.path}
  ///{@macro flutter_inappwebview_platform_interface.PlatformPathHandler.path}
  ///{@endtemplate}
  final String path;

  ///{@template flutter_inappwebview_platform_interface.PlatformPathHandlerCreationParams.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformPathHandlerCreationParamsClassSupported.isClassSupported(
        platform: platform,
      );
}

///{@template flutter_inappwebview_platform_interface.PlatformPathHandler}
///A handler that produces responses for a registered path.
///
///Implement this interface to handle other use-cases according to your app's needs.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformPathHandler.supported_platforms}
@SupportedPlatforms(platforms: [AndroidPlatform()])
abstract class PlatformPathHandler {
  /// Event handler object that handles the [PlatformPathHandler] events.
  late final PlatformPathHandlerEvents? eventHandler;

  ///{@template flutter_inappwebview_platform_interface.PlatformPathHandler.type}
  ///The path handler type.
  ///{@endtemplate}
  String get type {
    throw UnimplementedError('type is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformPathHandler.path}
  ///The suffix path to be handled.
  ///
  ///The path should start and end with a `"/"` and it shouldn't collide with a real web path.
  ///{@endtemplate}
  String get path {
    throw UnimplementedError('path is not implemented on the current platform');
  }

  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    throw UnimplementedError(
      'toMap is not implemented on the current platform',
    );
  }

  Map<String, dynamic> toJson() {
    throw UnimplementedError(
      'toJson is not implemented on the current platform',
    );
  }
}

///{@template flutter_inappwebview_platform_interface.PlatformPathHandlerEvents}
///Interface path handler events.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformPathHandlerEvents.supported_platforms}
@SupportedPlatforms(platforms: [AndroidPlatform()])
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
      'handle is not implemented on the current platform',
    );
  }
}

///{@template flutter_inappwebview_platform_interface.PlatformAssetsPathHandlerCreationParams}
/// Object specifying creation parameters for creating a [PlatformAssetsPathHandler].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformAssetsPathHandlerCreationParams.supported_platforms}
@SupportedPlatforms(platforms: [AndroidPlatform()])
@immutable
class PlatformAssetsPathHandlerCreationParams
    extends PlatformPathHandlerCreationParams {
  /// Used by the platform implementation to create a new [PlatformAssetsPathHandler].
  PlatformAssetsPathHandlerCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformPathHandlerCreationParams params,
  ) : super(path: params.path);

  /// Creates a [PlatformAssetsPathHandlerCreationParams] instance based on [PlatformPathHandlerCreationParams].
  factory PlatformAssetsPathHandlerCreationParams.fromPlatformPathHandlerCreationParams(
    PlatformPathHandlerCreationParams params,
  ) {
    return PlatformAssetsPathHandlerCreationParams(params);
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformAssetsPathHandlerCreationParams.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  @override
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformAssetsPathHandlerCreationParamsClassSupported.isClassSupported(
        platform: platform,
      );
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
///
///{@macro flutter_inappwebview_platform_interface.PlatformAssetsPathHandler.supported_platforms}
@SupportedPlatforms(platforms: [AndroidPlatform()])
abstract class PlatformAssetsPathHandler extends PlatformInterface
    implements PlatformPathHandler {
  /// Creates a new [PlatformAssetsPathHandler]
  factory PlatformAssetsPathHandler(
    PlatformAssetsPathHandlerCreationParams params,
  ) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformAssetsPathHandler assetsPathHandler = InAppWebViewPlatform
        .instance!
        .createPlatformAssetsPathHandler(params);
    PlatformInterface.verify(assetsPathHandler, _token);
    return assetsPathHandler;
  }

  /// Creates a new empty [PlatformAssetsPathHandler] to access static methods.
  factory PlatformAssetsPathHandler.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformAssetsPathHandler assetsPathHandlerStatic =
        InAppWebViewPlatform.instance!.createPlatformAssetsPathHandlerStatic();
    PlatformInterface.verify(assetsPathHandlerStatic, _token);
    return assetsPathHandlerStatic;
  }

  /// Used by the platform implementation to create a new [PlatformAssetsPathHandler].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformAssetsPathHandler.implementation(this.params) : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformAssetsPathHandler].
  final PlatformAssetsPathHandlerCreationParams params;

  @override
  String get type => 'AssetsPathHandler';

  @override
  String get path => params.path;

  ///{@macro flutter_inappwebview_platform_interface.PlatformAssetsPathHandlerCreationParams.isClassSupported}
  bool isClassSupported({TargetPlatform? platform}) =>
      params.isClassSupported(platform: platform);
}

///{@template flutter_inappwebview_platform_interface.PlatformResourcesPathHandlerCreationParams}
/// Object specifying creation parameters for creating a [PlatformResourcesPathHandler].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformResourcesPathHandlerCreationParams.supported_platforms}
@SupportedPlatforms(platforms: [AndroidPlatform()])
@immutable
class PlatformResourcesPathHandlerCreationParams
    extends PlatformPathHandlerCreationParams {
  /// Used by the platform implementation to create a new [PlatformResourcesPathHandler].
  PlatformResourcesPathHandlerCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformPathHandlerCreationParams params,
  ) : super(path: params.path);

  /// Creates a [PlatformResourcesPathHandlerCreationParams] instance based on [PlatformPathHandlerCreationParams].
  factory PlatformResourcesPathHandlerCreationParams.fromPlatformPathHandlerCreationParams(
    PlatformPathHandlerCreationParams params,
  ) {
    return PlatformResourcesPathHandlerCreationParams(params);
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformResourcesPathHandlerCreationParams.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  @override
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformResourcesPathHandlerCreationParamsClassSupported.isClassSupported(
        platform: platform,
      );
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
///
///{@macro flutter_inappwebview_platform_interface.PlatformResourcesPathHandler.supported_platforms}
@SupportedPlatforms(platforms: [AndroidPlatform()])
abstract class PlatformResourcesPathHandler extends PlatformInterface
    implements PlatformPathHandler {
  /// Creates a new [PlatformResourcesPathHandler]
  factory PlatformResourcesPathHandler(
    PlatformResourcesPathHandlerCreationParams params,
  ) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformResourcesPathHandler resourcesPathHandler =
        InAppWebViewPlatform.instance!.createPlatformResourcesPathHandler(
          params,
        );
    PlatformInterface.verify(resourcesPathHandler, _token);
    return resourcesPathHandler;
  }

  /// Creates a new empty [PlatformResourcesPathHandler] to access static methods.
  factory PlatformResourcesPathHandler.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformResourcesPathHandler resourcesPathHandlerStatic =
        InAppWebViewPlatform.instance!
            .createPlatformResourcesPathHandlerStatic();
    PlatformInterface.verify(resourcesPathHandlerStatic, _token);
    return resourcesPathHandlerStatic;
  }

  /// Used by the platform implementation to create a new [PlatformResourcesPathHandler].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformResourcesPathHandler.implementation(this.params)
    : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformResourcesPathHandler].
  final PlatformResourcesPathHandlerCreationParams params;

  @override
  String get type => 'ResourcesPathHandler';

  @override
  String get path => params.path;

  ///{@macro flutter_inappwebview_platform_interface.PlatformResourcesPathHandlerCreationParams.isClassSupported}
  bool isClassSupported({TargetPlatform? platform}) =>
      params.isClassSupported(platform: platform);
}

///{@template flutter_inappwebview_platform_interface.PlatformInternalStoragePathHandlerCreationParams}
/// Object specifying creation parameters for creating a [PlatformInternalStoragePathHandler].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformInternalStoragePathHandlerCreationParams.supported_platforms}
@SupportedPlatforms(platforms: [AndroidPlatform()])
@immutable
class PlatformInternalStoragePathHandlerCreationParams
    extends PlatformPathHandlerCreationParams {
  /// Used by the platform implementation to create a new [PlatformInternalStoragePathHandler].
  PlatformInternalStoragePathHandlerCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformPathHandlerCreationParams params, {
    required this.directory,
  }) : super(path: params.path);

  /// Creates a [PlatformInternalStoragePathHandlerCreationParams] instance based on [PlatformPathHandlerCreationParams].
  factory PlatformInternalStoragePathHandlerCreationParams.fromPlatformPathHandlerCreationParams(
    PlatformPathHandlerCreationParams params, {
    required String directory,
  }) {
    return PlatformInternalStoragePathHandlerCreationParams(
      params,
      directory: directory,
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformInternalStoragePathHandlerCreationParams.directory}
  ///The directory for which files should be served.
  ///{@endtemplate}
  final String directory;

  ///{@template flutter_inappwebview_platform_interface.PlatformInternalStoragePathHandlerCreationParams.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  @override
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformInternalStoragePathHandlerCreationParamsClassSupported.isClassSupported(
        platform: platform,
      );
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
///
///{@macro flutter_inappwebview_platform_interface.PlatformInternalStoragePathHandler.supported_platforms}
@SupportedPlatforms(platforms: [AndroidPlatform()])
abstract class PlatformInternalStoragePathHandler extends PlatformInterface
    implements PlatformPathHandler {
  /// Creates a new [PlatformInternalStoragePathHandler]
  factory PlatformInternalStoragePathHandler(
    PlatformInternalStoragePathHandlerCreationParams params,
  ) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformInternalStoragePathHandler internalStoragePathHandler =
        InAppWebViewPlatform.instance!.createPlatformInternalStoragePathHandler(
          params,
        );
    PlatformInterface.verify(internalStoragePathHandler, _token);
    return internalStoragePathHandler;
  }

  /// Creates a new empty [PlatformInternalStoragePathHandler] to access static methods.
  factory PlatformInternalStoragePathHandler.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformInternalStoragePathHandler internalStoragePathHandlerStatic =
        InAppWebViewPlatform.instance!
            .createPlatformInternalStoragePathHandlerStatic();
    PlatformInterface.verify(internalStoragePathHandlerStatic, _token);
    return internalStoragePathHandlerStatic;
  }

  /// Used by the platform implementation to create a new [PlatformInternalStoragePathHandler].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformInternalStoragePathHandler.implementation(this.params)
    : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformInternalStoragePathHandler].
  final PlatformInternalStoragePathHandlerCreationParams params;

  @override
  String get type => 'InternalStoragePathHandler';

  @override
  String get path => params.path;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInternalStoragePathHandlerCreationParams.directory}
  String get directory => params.directory;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInternalStoragePathHandlerCreationParams.isClassSupported}
  bool isClassSupported({TargetPlatform? platform}) =>
      params.isClassSupported(platform: platform);
}

///{@template flutter_inappwebview_platform_interface.PlatformCustomPathHandlerCreationParams}
/// Object specifying creation parameters for creating a [PlatformCustomPathHandler].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformCustomPathHandlerCreationParams.supported_platforms}
@SupportedPlatforms(platforms: [AndroidPlatform()])
@immutable
class PlatformCustomPathHandlerCreationParams
    extends PlatformPathHandlerCreationParams {
  /// Used by the platform implementation to create a new [PlatformCustomPathHandler].
  PlatformCustomPathHandlerCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformPathHandlerCreationParams params,
  ) : super(path: params.path);

  /// Creates a [PlatformCustomPathHandlerCreationParams] instance based on [PlatformPathHandlerCreationParams].
  factory PlatformCustomPathHandlerCreationParams.fromPlatformPathHandlerCreationParams(
    PlatformPathHandlerCreationParams params,
  ) {
    return PlatformCustomPathHandlerCreationParams(params);
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformCustomPathHandlerCreationParams.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  @override
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformCustomPathHandlerCreationParamsClassSupported.isClassSupported(
        platform: platform,
      );
}

///{@template flutter_inappwebview_platform_interface.PlatformCustomPathHandler}
///Custom handler class used to implement a custom logic to open a file.
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
///
///{@macro flutter_inappwebview_platform_interface.PlatformCustomPathHandler.supported_platforms}
@SupportedPlatforms(platforms: [AndroidPlatform()])
abstract class PlatformCustomPathHandler extends PlatformInterface
    implements PlatformPathHandler {
  /// Creates a new [PlatformCustomPathHandler]
  factory PlatformCustomPathHandler(
    PlatformCustomPathHandlerCreationParams params,
  ) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformCustomPathHandler customPathHandler = InAppWebViewPlatform
        .instance!
        .createPlatformCustomPathHandler(params);
    PlatformInterface.verify(customPathHandler, _token);
    return customPathHandler;
  }

  /// Creates a new empty [PlatformCustomPathHandler] to access static methods.
  factory PlatformCustomPathHandler.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformCustomPathHandler customPathHandlerStatic =
        InAppWebViewPlatform.instance!.createPlatformCustomPathHandlerStatic();
    PlatformInterface.verify(customPathHandlerStatic, _token);
    return customPathHandlerStatic;
  }

  /// Used by the platform implementation to create a new [PlatformCustomPathHandler].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformCustomPathHandler.implementation(this.params) : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformCustomPathHandler].
  final PlatformCustomPathHandlerCreationParams params;

  @override
  String get type => 'CustomPathHandler';

  @override
  String get path => params.path;

  ///{@macro flutter_inappwebview_platform_interface.PlatformCustomPathHandlerCreationParams.isClassSupported}
  bool isClassSupported({TargetPlatform? platform}) =>
      params.isClassSupported(platform: platform);
}
