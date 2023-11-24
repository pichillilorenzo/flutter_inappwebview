import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

///{@macro flutter_inappwebview_platform_interface.PlatformWebStorage}
class WebStorage {
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebStorage}
  WebStorage(
      {required PlatformLocalStorage localStorage,
      required PlatformSessionStorage sessionStorage})
      : this.fromPlatformCreationParams(
            params: PlatformWebStorageCreationParams(
                localStorage: localStorage, sessionStorage: sessionStorage));

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

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebStorage.localStorage}
  LocalStorage get localStorage =>
      LocalStorage.fromPlatform(platform: platform.localStorage);

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebStorage.sessionStorage}
  SessionStorage get sessionStorage =>
      SessionStorage.fromPlatform(platform: platform.sessionStorage);

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebStorage.dispose}
  void dispose() => platform.dispose();
}

///{@macro flutter_inappwebview_platform_interface.PlatformStorage}
class Storage {
  ///{@macro flutter_inappwebview_platform_interface.PlatformStorage}
  Storage({required WebStorageType webStorageType})
      : this.fromPlatformCreationParams(
            params:
                PlatformStorageCreationParams(webStorageType: webStorageType));

  /// Constructs a [Storage].
  ///
  /// See [Storage.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  Storage.fromPlatformCreationParams({
    required PlatformStorageCreationParams params,
  }) : this.fromPlatform(platform: PlatformStorage(params));

  /// Constructs a [Storage] from a specific platform implementation.
  Storage.fromPlatform({required this.platform});

  /// Implementation of [PlatformStorage] for the current platform.
  final PlatformStorage platform;

  ///{@macro flutter_inappwebview_platform_interface.PlatformStorage.webStorageType}
  WebStorageType get webStorageType => platform.webStorageType;

  ///{@macro flutter_inappwebview_platform_interface.PlatformStorage.length}
  Future<int?> length() => platform.length();

  ///{@macro flutter_inappwebview_platform_interface.PlatformStorage.setItem}
  Future<void> setItem({required String key, required dynamic value}) =>
      platform.setItem(key: key, value: value);

  ///{@macro flutter_inappwebview_platform_interface.PlatformStorage.getItem}
  Future<dynamic> getItem({required String key}) => platform.getItem(key: key);

  ///{@macro flutter_inappwebview_platform_interface.PlatformStorage.removeItem}
  Future<void> removeItem({required String key}) =>
      platform.removeItem(key: key);

  ///{@macro flutter_inappwebview_platform_interface.PlatformStorage.getItems}
  Future<List<WebStorageItem>> getItems() => platform.getItems();

  ///{@macro flutter_inappwebview_platform_interface.PlatformStorage.clear}
  Future<void> clear() => platform.clear();

  ///{@macro flutter_inappwebview_platform_interface.PlatformStorage.key}
  Future<String> key({required int index}) => platform.key(index: index);

  ///{@macro flutter_inappwebview_platform_interface.PlatformStorage.dispose}
  void dispose() => platform.dispose();
}

///{@macro flutter_inappwebview_platform_interface.PlatformLocalStorage}
class LocalStorage extends Storage {
  ///{@macro flutter_inappwebview_platform_interface.PlatformLocalStorage}
  LocalStorage()
      : this.fromPlatformCreationParams(
            params: PlatformLocalStorageCreationParams(
                PlatformStorageCreationParams(
                    webStorageType: WebStorageType.LOCAL_STORAGE)));

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
  final PlatformLocalStorage platform;
}

///{@macro flutter_inappwebview_platform_interface.PlatformSessionStorage}
class SessionStorage extends Storage {
  ///{@macro flutter_inappwebview_platform_interface.PlatformSessionStorage}
  SessionStorage()
      : this.fromPlatformCreationParams(
            params: PlatformSessionStorageCreationParams(
                PlatformStorageCreationParams(
                    webStorageType: WebStorageType.SESSION_STORAGE)));

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
  final PlatformSessionStorage platform;
}
