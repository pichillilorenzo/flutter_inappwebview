import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

///{@macro flutter_inappwebview_platform_interface.PlatformPathHandler}
abstract class PathHandler
    implements PlatformPathHandler, PlatformPathHandlerEvents {
  /// Constructs a [PathHandler] from a specific platform implementation.
  PathHandler.fromPlatform({required this.platform}) {
    this.platform.eventHandler = this;
  }

  @override
  late final PlatformPathHandlerEvents? eventHandler;

  /// Implementation of [PlatformPathHandler] for the current platform.
  final PlatformPathHandler platform;

  @override
  String get type => platform.type;

  @override
  String get path => platform.path;

  @override
  Future<WebResourceResponse?> handle(String path) async {
    return null;
  }

  @override
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) =>
      platform.toMap(enumMethod: enumMethod);

  @override
  Map<String, dynamic> toJson() => platform.toJson();
}

///{@macro flutter_inappwebview_platform_interface.PlatformAssetsPathHandler}
class AssetsPathHandler extends PathHandler {
  ///{@macro flutter_inappwebview_platform_interface.PlatformAssetsPathHandler}
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

///{@macro flutter_inappwebview_platform_interface.PlatformResourcesPathHandler}
class ResourcesPathHandler extends PathHandler {
  ///{@macro flutter_inappwebview_platform_interface.PlatformResourcesPathHandler}
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

///{@macro flutter_inappwebview_platform_interface.PlatformInternalStoragePathHandler}
class InternalStoragePathHandler extends PathHandler {
  ///{@macro flutter_inappwebview_platform_interface.PlatformInternalStoragePathHandler}
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

///{@macro flutter_inappwebview_platform_interface.PlatformCustomPathHandler}
abstract class CustomPathHandler extends PathHandler {
  ///{@macro flutter_inappwebview_platform_interface.PlatformCustomPathHandler}
  CustomPathHandler({required String path})
      : this.fromPlatformCreationParams(
            params: PlatformCustomPathHandlerCreationParams(
                PlatformPathHandlerCreationParams(path: path)));

  /// Constructs a [CustomPathHandler].
  ///
  /// See [CustomPathHandler.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  CustomPathHandler.fromPlatformCreationParams({
    required PlatformCustomPathHandlerCreationParams params,
  }) : this.fromPlatform(platform: PlatformCustomPathHandler(params));

  /// Constructs a [CustomPathHandler] from a specific platform implementation.
  CustomPathHandler.fromPlatform({required this.platform})
      : super.fromPlatform(platform: platform);

  /// Implementation of [PlatformCustomPathHandler] for the current platform.
  final PlatformCustomPathHandler platform;
}
