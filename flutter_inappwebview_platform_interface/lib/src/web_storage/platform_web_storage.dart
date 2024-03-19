import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/src/types/disposable.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../in_app_webview/platform_inappwebview_controller.dart';
import '../inappwebview_platform.dart';
import '../types/main.dart';
import 'web_storage_item.dart';

/// Object specifying creation parameters for creating a [PlatformWebStorage].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
@immutable
class PlatformWebStorageCreationParams {
  /// Used by the platform implementation to create a new [PlatformWebStorage].
  const PlatformWebStorageCreationParams(
      {required this.localStorage, required this.sessionStorage});

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebStorage.localStorage}
  final PlatformLocalStorage localStorage;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebStorage.sessionStorage}
  final PlatformSessionStorage sessionStorage;
}

///{@template flutter_inappwebview_platform_interface.PlatformWebStorage}
///Class that provides access to the JavaScript [Web Storage API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API): `window.sessionStorage` and `window.localStorage`.
///It used by [PlatformInAppWebViewController.webStorage].
///
///**Officially Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- MacOS
///- Web
///- Windows
///{@endtemplate}
abstract class PlatformWebStorage extends PlatformInterface
    implements Disposable {
  /// Creates a new [PlatformWebStorage]
  factory PlatformWebStorage(PlatformWebStorageCreationParams params) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformWebStorage webStorage =
        InAppWebViewPlatform.instance!.createPlatformWebStorage(params);
    PlatformInterface.verify(webStorage, _token);
    return webStorage;
  }

  /// Used by the platform implementation to create a new [PlatformWebStorage].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformWebStorage.implementation(this.params) : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformWebStorage].
  final PlatformWebStorageCreationParams params;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebStorage.localStorage}
  ///Represents `window.localStorage`.
  ///{@endtemplate}
  PlatformLocalStorage get localStorage => params.localStorage;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebStorage.sessionStorage}
  ///Represents `window.sessionStorage`.
  ///{@endtemplate}
  PlatformSessionStorage get sessionStorage => params.sessionStorage;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebStorage.dispose}
  ///Disposes the web storage.
  ///{@endtemplate}
  void dispose() {
    throw UnimplementedError(
        'dispose is not implemented on the current platform');
  }
}

/// Object specifying creation parameters for creating a [PlatformStorage].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
@immutable
class PlatformStorageCreationParams {
  /// Used by the platform implementation to create a new [PlatformStorage].
  const PlatformStorageCreationParams(
      {required this.controller, required this.webStorageType});

  ///{@macro flutter_inappwebview_platform_interface.PlatformStorage.controller}
  final PlatformInAppWebViewController? controller;

  ///{@macro flutter_inappwebview_platform_interface.PlatformStorage.webStorageType}
  final WebStorageType webStorageType;
}

///{@template flutter_inappwebview_platform_interface.PlatformStorage}
///Class that provides methods to manage the JavaScript [Storage](https://developer.mozilla.org/en-US/docs/Web/API/Storage) object.
///It is used by [PlatformLocalStorage] and [PlatformSessionStorage].
///{@endtemplate}
abstract class PlatformStorage implements Disposable {
  ///{@template flutter_inappwebview_platform_interface.PlatformStorage.controller}
  ///Controller used to interact with storage.
  ///{@endtemplate}
  PlatformInAppWebViewController? get controller;

  ///{@template flutter_inappwebview_platform_interface.PlatformStorage.webStorageType}
  ///The web storage type: `window.sessionStorage` or `window.localStorage`.
  ///{@endtemplate}
  WebStorageType get webStorageType {
    throw UnimplementedError(
        'webStorageType is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformStorage.length}
  ///Returns an integer representing the number of data items stored in the Storage object.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  ///{@endtemplate}
  Future<int?> length() {
    throw UnimplementedError(
        'length is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformStorage.setItem}
  ///When passed a [key] name and [value], will add that key to the storage, or update that key's value if it already exists.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  ///{@endtemplate}
  Future<void> setItem({required String key, required dynamic value}) {
    throw UnimplementedError(
        'setItem is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformStorage.getItem}
  ///When passed a [key] name, will return that key's value, or `null` if the key does not exist, in the given Storage object.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  ///{@endtemplate}
  Future<dynamic> getItem({required String key}) {
    throw UnimplementedError(
        'getItem is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformStorage.removeItem}
  ///When passed a [key] name, will remove that key from the given Storage object if it exists.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  ///{@endtemplate}
  Future<void> removeItem({required String key}) {
    throw UnimplementedError(
        'removeItem is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformStorage.getItems}
  ///Returns the list of all items from the given Storage object.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  ///{@endtemplate}
  Future<List<WebStorageItem>> getItems() {
    throw UnimplementedError(
        'getItems is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformStorage.clear}
  ///Clears all keys stored in a given Storage object.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  ///{@endtemplate}
  Future<void> clear() {
    throw UnimplementedError(
        'clear is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformStorage.key}
  ///When passed a number [index], returns the name of the nth key in a given Storage object.
  ///The order of keys is user-agent defined, so you should not rely on it.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  ///{@endtemplate}
  Future<String> key({required int index}) {
    throw UnimplementedError('key is not implemented on the current platform');
  }

  @override
  void dispose() {
    throw UnimplementedError(
        'dispose is not implemented on the current platform');
  }
}

/// Object specifying creation parameters for creating a [PlatformLocalStorage].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
@immutable
class PlatformLocalStorageCreationParams extends PlatformStorageCreationParams {
  /// Used by the platform implementation to create a new [PlatformLocalStorage].
  PlatformLocalStorageCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformStorageCreationParams params,
  ) : super(
            controller: params.controller,
            webStorageType: WebStorageType.LOCAL_STORAGE);

  /// Creates a [AndroidCookieManagerCreationParams] instance based on [PlatformCookieManagerCreationParams].
  factory PlatformLocalStorageCreationParams.fromPlatformStorageCreationParams(
      PlatformStorageCreationParams params) {
    return PlatformLocalStorageCreationParams(params);
  }
}

///{@template flutter_inappwebview_platform_interface.PlatformLocalStorage}
///Class that provides methods to manage the JavaScript `window.localStorage` object.
///It used by [PlatformWebStorage].
///{@endtemplate}
abstract class PlatformLocalStorage extends PlatformInterface
    with PlatformStorage {
  /// Creates a new [PlatformLocalStorage]
  factory PlatformLocalStorage(PlatformLocalStorageCreationParams params) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformLocalStorage localStorage =
        InAppWebViewPlatform.instance!.createPlatformLocalStorage(params);
    PlatformInterface.verify(localStorage, _token);
    return localStorage;
  }

  /// Used by the platform implementation to create a new [PlatformLocalStorage].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformLocalStorage.implementation(this.params) : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformLocalStorage].
  final PlatformLocalStorageCreationParams params;

  @override
  WebStorageType get webStorageType => params.webStorageType;
}

/// Object specifying creation parameters for creating a [PlatformSessionStorage].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
@immutable
class PlatformSessionStorageCreationParams
    extends PlatformStorageCreationParams {
  /// Used by the platform implementation to create a new [PlatformSessionStorage].
  PlatformSessionStorageCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformStorageCreationParams params,
  ) : super(
            controller: params.controller,
            webStorageType: WebStorageType.SESSION_STORAGE);

  /// Creates a [AndroidCookieManagerCreationParams] instance based on [PlatformCookieManagerCreationParams].
  factory PlatformSessionStorageCreationParams.fromPlatformStorageCreationParams(
      PlatformStorageCreationParams params) {
    return PlatformSessionStorageCreationParams(params);
  }
}

///{@template flutter_inappwebview_platform_interface.PlatformSessionStorage}
///Class that provides methods to manage the JavaScript `window.sessionStorage` object.
///It used by [PlatformWebStorage].
///{@endtemplate}
abstract class PlatformSessionStorage extends PlatformInterface
    with PlatformStorage {
  /// Creates a new [PlatformSessionStorage]
  factory PlatformSessionStorage(PlatformSessionStorageCreationParams params) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformSessionStorage sessionStorage =
        InAppWebViewPlatform.instance!.createPlatformSessionStorage(params);
    PlatformInterface.verify(sessionStorage, _token);
    return sessionStorage;
  }

  /// Used by the platform implementation to create a new [PlatformSessionStorage].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformSessionStorage.implementation(this.params) : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformSessionStorage].
  final PlatformSessionStorageCreationParams params;

  @override
  WebStorageType get webStorageType => params.webStorageType;
}
