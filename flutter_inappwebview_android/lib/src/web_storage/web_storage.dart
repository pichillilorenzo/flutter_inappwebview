import 'dart:convert';

import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../in_app_webview/in_app_webview_controller.dart';

/// Object specifying creation parameters for creating a [AndroidWebStorage].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformWebStorageCreationParams] for
/// more information.
class AndroidWebStorageCreationParams extends PlatformWebStorageCreationParams {
  /// Creates a new [AndroidWebStorageCreationParams] instance.
  AndroidWebStorageCreationParams(
      {required super.localStorage, required super.sessionStorage});

  /// Creates a [AndroidWebStorageCreationParams] instance based on [PlatformWebStorageCreationParams].
  factory AndroidWebStorageCreationParams.fromPlatformWebStorageCreationParams(
      // Recommended placeholder to prevent being broken by platform interface.
      // ignore: avoid_unused_constructor_parameters
      PlatformWebStorageCreationParams params) {
    return AndroidWebStorageCreationParams(
        localStorage: params.localStorage,
        sessionStorage: params.sessionStorage);
  }
}

///Class that provides access to the JavaScript [Web Storage API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API): `window.sessionStorage` and `window.localStorage`.
///It used by [InAppWebViewController.webStorage].
///
///**Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- MacOS
///- Web
class AndroidWebStorage extends PlatformWebStorage {
  /// Constructs a [AndroidWebStorage].
  AndroidWebStorage(PlatformWebStorageCreationParams params)
      : super.implementation(
          params is AndroidWebStorageCreationParams
              ? params
              : AndroidWebStorageCreationParams
                  .fromPlatformWebStorageCreationParams(params),
        );

  PlatformLocalStorage get localStorage => params.localStorage;

  PlatformSessionStorage get sessionStorage => params.sessionStorage;

  ///Disposes the web storage.
  @override
  void dispose() {
    localStorage.dispose();
    sessionStorage.dispose();
  }
}

/// Object specifying creation parameters for creating a [AndroidStorage].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformStorageCreationParams] for
/// more information.
class AndroidStorageCreationParams extends PlatformStorageCreationParams {
  /// Creates a new [AndroidStorageCreationParams] instance.
  AndroidStorageCreationParams({required super.webStorageType});

  /// Creates a [AndroidStorageCreationParams] instance based on [PlatformStorageCreationParams].
  factory AndroidStorageCreationParams.fromPlatformStorageCreationParams(
      // Recommended placeholder to prevent being broken by platform interface.
      // ignore: avoid_unused_constructor_parameters
      PlatformStorageCreationParams params) {
    return AndroidStorageCreationParams(webStorageType: params.webStorageType);
  }
}

///Class that provides methods to manage the JavaScript [Storage](https://developer.mozilla.org/en-US/docs/Web/API/Storage) object.
///It is used by [AndroidLocalStorage] and [AndroidSessionStorage].
class AndroidStorage extends PlatformStorage {
  /// Constructs a [AndroidStorage].
  AndroidStorage(PlatformStorageCreationParams params)
      : super.implementation(
          params is AndroidStorageCreationParams
              ? params
              : AndroidStorageCreationParams.fromPlatformStorageCreationParams(
                  params),
        );

  AndroidInAppWebViewController? _controller;

  ///Returns an integer representing the number of data items stored in the Storage object.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- Web
  Future<int?> length() async {
    var result = await _controller?.evaluateJavascript(source: """
    window.$webStorageType.length;
    """);
    return result != null ? int.parse(json.decode(result)) : null;
  }

  ///When passed a [key] name and [value], will add that key to the storage, or update that key's value if it already exists.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- Web
  Future<void> setItem({required String key, required dynamic value}) async {
    var encodedValue = json.encode(value);
    await _controller?.evaluateJavascript(source: """
    window.$webStorageType.setItem("$key", ${value is String ? encodedValue : "JSON.stringify($encodedValue)"});
    """);
  }

  ///When passed a [key] name, will return that key's value, or `null` if the key does not exist, in the given Storage object.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- Web
  Future<dynamic> getItem({required String key}) async {
    var itemValue = await _controller?.evaluateJavascript(source: """
    window.$webStorageType.getItem("$key");
    """);

    if (itemValue == null) {
      return null;
    }

    try {
      return json.decode(itemValue);
    } catch (e) {}

    return itemValue;
  }

  ///When passed a [key] name, will remove that key from the given Storage object if it exists.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- Web
  Future<void> removeItem({required String key}) async {
    await _controller?.evaluateJavascript(source: """
    window.$webStorageType.removeItem("$key");
    """);
  }

  ///Returns the list of all items from the given Storage object.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- Web
  Future<List<WebStorageItem>> getItems() async {
    var webStorageItems = <WebStorageItem>[];

    List<Map<dynamic, dynamic>>? items =
        (await _controller?.evaluateJavascript(source: """
(function() {
  var webStorageItems = [];
  for(var i = 0; i < window.$webStorageType.length; i++){
    var key = window.$webStorageType.key(i);
    webStorageItems.push(
      {
        key: key,
        value: window.$webStorageType.getItem(key)
      }
    );
  }
  return webStorageItems;
})();
    """)).cast<Map<dynamic, dynamic>>();

    if (items == null) {
      return webStorageItems;
    }

    for (var item in items) {
      webStorageItems
          .add(WebStorageItem(key: item["key"], value: item["value"]));
    }

    return webStorageItems;
  }

  ///Clears all keys stored in a given Storage object.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- Web
  Future<void> clear() async {
    await _controller?.evaluateJavascript(source: """
    window.$webStorageType.clear();
    """);
  }

  ///When passed a number [index], returns the name of the nth key in a given Storage object.
  ///The order of keys is user-agent defined, so you should not rely on it.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- Web
  Future<String> key({required int index}) async {
    var result = await _controller?.evaluateJavascript(source: """
    window.$webStorageType.key($index);
    """);
    return result != null ? json.decode(result) : null;
  }

  ///Disposes the storage.
  @override
  void dispose() {
    _controller = null;
  }
}

/// Object specifying creation parameters for creating a [AndroidLocalStorage].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformLocalStorageCreationParams] for
/// more information.
class AndroidLocalStorageCreationParams
    extends PlatformLocalStorageCreationParams {
  /// Creates a new [AndroidLocalStorageCreationParams] instance.
  AndroidLocalStorageCreationParams(super.params);

  /// Creates a [AndroidLocalStorageCreationParams] instance based on [PlatformLocalStorageCreationParams].
  factory AndroidLocalStorageCreationParams.fromPlatformLocalStorageCreationParams(
      // Recommended placeholder to prevent being broken by platform interface.
      // ignore: avoid_unused_constructor_parameters
      PlatformLocalStorageCreationParams params) {
    return AndroidLocalStorageCreationParams(params);
  }
}

///Class that provides methods to manage the JavaScript `window.localStorage` object.
///It used by [AndroidWebStorage].
class AndroidLocalStorage extends AndroidStorage implements PlatformLocalStorage {
  /// Constructs a [AndroidLocalStorage].
  AndroidLocalStorage(PlatformLocalStorageCreationParams params)
      : super(
          params is AndroidLocalStorageCreationParams
              ? params
              : AndroidLocalStorageCreationParams
                  .fromPlatformLocalStorageCreationParams(params),
        );

  /// Default storage
  factory AndroidLocalStorage.defaultStorage() {
    return AndroidLocalStorage(AndroidLocalStorageCreationParams(
        PlatformLocalStorageCreationParams(PlatformStorageCreationParams(
            webStorageType: WebStorageType.LOCAL_STORAGE))));
  }
}

/// Object specifying creation parameters for creating a [AndroidSessionStorage].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformSessionStorageCreationParams] for
/// more information.
class AndroidSessionStorageCreationParams
    extends PlatformSessionStorageCreationParams {
  /// Creates a new [AndroidSessionStorageCreationParams] instance.
  AndroidSessionStorageCreationParams(super.params);

  /// Creates a [AndroidSessionStorageCreationParams] instance based on [PlatformSessionStorageCreationParams].
  factory AndroidSessionStorageCreationParams.fromPlatformSessionStorageCreationParams(
      // Recommended placeholder to prevent being broken by platform interface.
      // ignore: avoid_unused_constructor_parameters
      PlatformSessionStorageCreationParams params) {
    return AndroidSessionStorageCreationParams(params);
  }
}

///Class that provides methods to manage the JavaScript `window.sessionStorage` object.
///It used by [AndroidWebStorage].
class AndroidSessionStorage extends AndroidStorage implements PlatformSessionStorage {
  /// Constructs a [AndroidSessionStorage].
  AndroidSessionStorage(PlatformSessionStorageCreationParams params)
      : super(
          params is AndroidSessionStorageCreationParams
              ? params
              : AndroidSessionStorageCreationParams
                  .fromPlatformSessionStorageCreationParams(params),
        );

  /// Default storage
  factory AndroidSessionStorage.defaultStorage() {
    return AndroidSessionStorage(AndroidSessionStorageCreationParams(
        PlatformSessionStorageCreationParams(PlatformStorageCreationParams(
            webStorageType: WebStorageType.SESSION_STORAGE))));
  }
}
