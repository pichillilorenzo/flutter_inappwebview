import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../in_app_webview/in_app_webview_controller.dart';

///Class that provides access to the JavaScript [Web Storage API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API): `window.sessionStorage` and `window.localStorage`.
///It used by [InAppWebViewController.webStorage].
///
///**Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- MacOS
///- Web
class WebStorage {
  /// Constructs a [WebStorage].
  ///
  /// See [WebStorage.fromPlatformCreationParams] for setting
  /// parameters for a specific platform.
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

  ///Disposes the web storage.
  void dispose() => platform.dispose();
}

///Class that provides methods to manage the JavaScript [Storage](https://developer.mozilla.org/en-US/docs/Web/API/Storage) object.
///It is used by [LocalStorage] and [SessionStorage].
class Storage {
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

  ///Returns an integer representing the number of data items stored in the Storage object.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- Web
  Future<int?> length() => platform.length();

  ///When passed a [key] name and [value], will add that key to the storage, or update that key's value if it already exists.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- Web
  Future<void> setItem({required String key, required dynamic value}) =>
      platform.setItem(key: key, value: value);

  ///When passed a [key] name, will return that key's value, or `null` if the key does not exist, in the given Storage object.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- Web
  Future<dynamic> getItem({required String key}) => platform.getItem(key: key);

  ///When passed a [key] name, will remove that key from the given Storage object if it exists.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- Web
  Future<void> removeItem({required String key}) =>
      platform.removeItem(key: key);

  ///Returns the list of all items from the given Storage object.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- Web
  Future<List<WebStorageItem>> getItems() => platform.getItems();

  ///Clears all keys stored in a given Storage object.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- Web
  Future<void> clear() => platform.clear();

  ///When passed a number [index], returns the name of the nth key in a given Storage object.
  ///The order of keys is user-agent defined, so you should not rely on it.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- Web
  Future<String> key({required int index}) => platform.key(index: index);

  ///Disposes the storage.
  void dispose() => platform.dispose();
}

///Class that provides methods to manage the JavaScript `window.localStorage` object.
///It used by [WebStorage].
class LocalStorage extends Storage {
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

///Class that provides methods to manage the JavaScript `window.sessionStorage` object.
///It used by [WebStorage].
class SessionStorage extends Storage {
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
