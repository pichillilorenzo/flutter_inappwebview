import 'package:flutter/foundation.dart';
import 'package:drago_inappwebview/platform_interface/platform_interface.dart';

import '../in_app_webview/in_app_webview_controller.dart';

///{@macro drago_inappwebview.PlatformWebStorage}
///
///{@macro drago_inappwebview.PlatformWebStorage.supported_platforms}
class WebStorage {
  ///{@macro drago_inappwebview.PlatformWebStorage}
  WebStorage({
    required PlatformLocalStorage localStorage,
    required PlatformSessionStorage sessionStorage,
  }) : this.fromPlatformCreationParams(
         params: PlatformWebStorageCreationParams(
           localStorage: localStorage,
           sessionStorage: sessionStorage,
         ),
       );

  /// Constructs a [WebStorage].
  ///
  /// See [WebStorage.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  WebStorage.fromPlatformCreationParams({
    required PlatformWebStorageCreationParams params,
  }) : this.fromPlatform(platform: PlatformWebStorage(params));

  /// Constructs a [WebStorage] from a specific platform implementation.
  WebStorage.fromPlatform({required this.platform});

  /// Implementation of [PlatformWebStorage] for the current platform.
  final PlatformWebStorage platform;

  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformWebStorage.static().isClassSupported(platform: platform);

  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isPropertySupported(
    dynamic property, {
    TargetPlatform? platform,
  }) => PlatformWebStorage.static().isPropertySupported(
    property,
    platform: platform,
  );

  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isMethodSupported(
    PlatformWebStorageMethod method, {
    TargetPlatform? platform,
  }) =>
      PlatformWebStorage.static().isMethodSupported(method, platform: platform);

  ///{@macro drago_inappwebview.PlatformWebStorage.localStorage}
  ///
  ///{@macro drago_inappwebview.PlatformWebStorage.localStorage.supported_platforms}
  LocalStorage get localStorage =>
      LocalStorage.fromPlatform(platform: platform.localStorage);

  ///{@macro drago_inappwebview.PlatformWebStorage.sessionStorage}
  ///
  ///{@macro drago_inappwebview.PlatformWebStorage.sessionStorage.supported_platforms}
  SessionStorage get sessionStorage =>
      SessionStorage.fromPlatform(platform: platform.sessionStorage);

  ///{@macro drago_inappwebview.PlatformWebStorage.dispose}
  ///
  ///{@macro drago_inappwebview.PlatformWebStorage.dispose.supported_platforms}
  void dispose() => platform.dispose();
}

///{@macro drago_inappwebview.PlatformStorage}
///
///{@macro drago_inappwebview.PlatformStorage.supported_platforms}
abstract class Storage implements PlatformStorage {
  /// Constructs a [Storage] from a specific platform implementation.
  Storage.fromPlatform({required this.platform});

  /// Implementation of [PlatformStorage] for the current platform.
  final PlatformStorage platform;

  ///{@macro drago_inappwebview.PlatformStorage.controller}
  ///
  ///{@macro drago_inappwebview.PlatformStorage.controller.supported_platforms}
  @override
  PlatformInAppWebViewController? get controller => platform.controller;

  ///{@macro drago_inappwebview.PlatformStorage.webStorageType}
  ///
  ///{@macro drago_inappwebview.PlatformStorage.webStorageType.supported_platforms}
  @override
  WebStorageType get webStorageType => platform.webStorageType;

  ///{@macro drago_inappwebview.PlatformStorage.length}
  ///
  ///{@macro drago_inappwebview.PlatformStorage.length.supported_platforms}
  @override
  Future<int?> length() => platform.length();

  ///{@macro drago_inappwebview.PlatformStorage.setItem}
  ///
  ///{@macro drago_inappwebview.PlatformStorage.setItem.supported_platforms}
  @override
  Future<void> setItem({required String key, required dynamic value}) =>
      platform.setItem(key: key, value: value);

  ///{@macro drago_inappwebview.PlatformStorage.getItem}
  ///
  ///{@macro drago_inappwebview.PlatformStorage.getItem.supported_platforms}
  @override
  Future<dynamic> getItem({required String key}) => platform.getItem(key: key);

  ///{@macro drago_inappwebview.PlatformStorage.removeItem}
  ///
  ///{@macro drago_inappwebview.PlatformStorage.removeItem.supported_platforms}
  @override
  Future<void> removeItem({required String key}) =>
      platform.removeItem(key: key);

  ///{@macro drago_inappwebview.PlatformStorage.getItems}
  ///
  ///{@macro drago_inappwebview.PlatformStorage.getItems.supported_platforms}
  @override
  Future<List<WebStorageItem>> getItems() => platform.getItems();

  ///{@macro drago_inappwebview.PlatformStorage.clear}
  ///
  ///{@macro drago_inappwebview.PlatformStorage.clear.supported_platforms}
  @override
  Future<void> clear() => platform.clear();

  ///{@macro drago_inappwebview.PlatformStorage.key}
  ///
  ///{@macro drago_inappwebview.PlatformStorage.key.supported_platforms}
  @override
  Future<String> key({required int index}) => platform.key(index: index);

  ///{@macro drago_inappwebview.PlatformStorage.dispose}
  ///
  ///{@macro drago_inappwebview.PlatformStorage.dispose.supported_platforms}
  @override
  void dispose() => platform.dispose();
}

///{@macro drago_inappwebview.PlatformLocalStorage}
///
///{@macro drago_inappwebview.PlatformLocalStorage.supported_platforms}
class LocalStorage extends Storage {
  ///{@macro drago_inappwebview.PlatformLocalStorage}
  LocalStorage({required InAppWebViewController? controller})
    : this.fromPlatformCreationParams(
        params: PlatformLocalStorageCreationParams(
          PlatformStorageCreationParams(
            controller: controller?.platform,
            webStorageType: WebStorageType.LOCAL_STORAGE,
          ),
        ),
      );

  /// Constructs a [LocalStorage].
  ///
  /// See [LocalStorage.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  LocalStorage.fromPlatformCreationParams({
    required PlatformLocalStorageCreationParams params,
  }) : this.fromPlatform(platform: PlatformLocalStorage(params));

  /// Constructs a [LocalStorage] from a specific platform implementation.
  LocalStorage.fromPlatform({required this.platform})
    : super.fromPlatform(platform: platform);

  /// Implementation of [PlatformLocalStorage] for the current platform.
  @override
  final PlatformLocalStorage platform;

  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformLocalStorage.static().isClassSupported(platform: platform);

  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isPropertySupported(
    PlatformStorageCreationParamsProperty property, {
    TargetPlatform? platform,
  }) => PlatformLocalStorage.static().isPropertySupported(
    property,
    platform: platform,
  );

  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isMethodSupported(
    PlatformLocalStorageMethod method, {
    TargetPlatform? platform,
  }) => PlatformLocalStorage.static().isMethodSupported(
    method,
    platform: platform,
  );
}

///{@macro drago_inappwebview.PlatformSessionStorage}
///
///{@macro drago_inappwebview.PlatformSessionStorage.supported_platforms}
class SessionStorage extends Storage {
  ///{@macro drago_inappwebview.PlatformSessionStorage}
  SessionStorage({required InAppWebViewController? controller})
    : this.fromPlatformCreationParams(
        params: PlatformSessionStorageCreationParams(
          PlatformStorageCreationParams(
            controller: controller?.platform,
            webStorageType: WebStorageType.SESSION_STORAGE,
          ),
        ),
      );

  /// Constructs a [SessionStorage].
  ///
  /// See [SessionStorage.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  SessionStorage.fromPlatformCreationParams({
    required PlatformSessionStorageCreationParams params,
  }) : this.fromPlatform(platform: PlatformSessionStorage(params));

  /// Constructs a [SessionStorage] from a specific platform implementation.
  SessionStorage.fromPlatform({required this.platform})
    : super.fromPlatform(platform: platform);

  /// Implementation of [PlatformSessionStorage] for the current platform.
  @override
  final PlatformSessionStorage platform;

  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformSessionStorage.static().isClassSupported(platform: platform);

  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isPropertySupported(
    PlatformStorageCreationParamsProperty property, {
    TargetPlatform? platform,
  }) => PlatformSessionStorage.static().isPropertySupported(
    property,
    platform: platform,
  );

  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isMethodSupported(
    PlatformSessionStorageMethod method, {
    TargetPlatform? platform,
  }) => PlatformSessionStorage.static().isMethodSupported(
    method,
    platform: platform,
  );
}
