import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'package:flutter_inappwebview_platform_interface/src/types/disposable.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../in_app_webview/platform_inappwebview_controller.dart';
import '../inappwebview_platform.dart';
import '../types/main.dart';
import 'web_storage_item.dart';

part 'platform_web_storage.g.dart';

/// Object specifying creation parameters for creating a [PlatformWebStorage].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///{@template flutter_inappwebview_platform_interface.PlatformWebStorageCreationParams}
/// Object specifying creation parameters for creating a [PlatformWebStorage].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformWebStorageCreationParams.supported_platforms}
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WebPlatform(),
    WindowsPlatform(),
    LinuxPlatform(),
  ],
)
@immutable
class PlatformWebStorageCreationParams {
  /// Used by the platform implementation to create a new [PlatformWebStorage].
  const PlatformWebStorageCreationParams({
    required this.localStorage,
    required this.sessionStorage,
  });

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebStorage.localStorage}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebStorage.localStorage.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  final PlatformLocalStorage localStorage;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebStorage.sessionStorage}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebStorage.sessionStorage.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  final PlatformSessionStorage sessionStorage;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebStorageCreationParams.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformWebStorageCreationParamsClassSupported.isClassSupported(
        platform: platform,
      );

  ///{@template flutter_inappwebview_platform_interface.PlatformWebStorageCreationParams.isPropertySupported}
  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isPropertySupported(
    PlatformWebStorageCreationParamsProperty property, {
    TargetPlatform? platform,
  }) => _PlatformWebStorageCreationParamsPropertySupported.isPropertySupported(
    property,
    platform: platform,
  );
}

///{@template flutter_inappwebview_platform_interface.PlatformWebStorage}
///Class that provides access to the JavaScript [Web Storage API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API): `window.sessionStorage` and `window.localStorage`.
///It used by [PlatformInAppWebViewController.webStorage].
///{@endtemplate}
///{@macro flutter_inappwebview_platform_interface.PlatformWebStorage.supported_platforms}
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WebPlatform(),
    WindowsPlatform(),
    LinuxPlatform(),
  ],
)
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
    final PlatformWebStorage webStorage = InAppWebViewPlatform.instance!
        .createPlatformWebStorage(params);
    PlatformInterface.verify(webStorage, _token);
    return webStorage;
  }

  /// Creates a new empty [PlatformWebStorage] to access static methods.
  factory PlatformWebStorage.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformWebStorage webStorageStatic = InAppWebViewPlatform.instance!
        .createPlatformWebStorageStatic();
    PlatformInterface.verify(webStorageStatic, _token);
    return webStorageStatic;
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
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebStorage.localStorage.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  PlatformLocalStorage get localStorage => params.localStorage;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebStorage.sessionStorage}
  ///Represents `window.sessionStorage`.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebStorage.sessionStorage.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  PlatformSessionStorage get sessionStorage => params.sessionStorage;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebStorage.dispose}
  ///Disposes the web storage.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebStorage.dispose.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  void dispose() {
    throw UnimplementedError(
      'dispose is not implemented on the current platform',
    );
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebStorageCreationParams.isClassSupported}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformWebStorageClassSupported.isClassSupported(platform: platform);

  ///{@template flutter_inappwebview_platform_interface.PlatformWebStorage.isPropertySupported}
  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isPropertySupported(dynamic property, {TargetPlatform? platform}) =>
      property is PlatformWebStorageCreationParamsProperty
      ? params.isPropertySupported(property, platform: platform)
      : _PlatformWebStoragePropertySupported.isPropertySupported(
          property,
          platform: platform,
        );

  ///{@template flutter_inappwebview_platform_interface.PlatformWebStorage.isMethodSupported}
  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isMethodSupported(
    PlatformWebStorageMethod method, {
    TargetPlatform? platform,
  }) => _PlatformWebStorageMethodSupported.isMethodSupported(
    method,
    platform: platform,
  );
}

/// Object specifying creation parameters for creating a [PlatformStorage].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///{@template flutter_inappwebview_platform_interface.PlatformStorageCreationParams}
/// Object specifying creation parameters for creating a [PlatformStorage].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformStorageCreationParams.supported_platforms}
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WebPlatform(),
    WindowsPlatform(),
    LinuxPlatform(),
  ],
)
@immutable
class PlatformStorageCreationParams {
  /// Used by the platform implementation to create a new [PlatformStorage].
  const PlatformStorageCreationParams({
    required this.controller,
    required this.webStorageType,
  });

  ///{@macro flutter_inappwebview_platform_interface.PlatformStorage.controller}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformStorage.controller.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  final PlatformInAppWebViewController? controller;

  ///{@macro flutter_inappwebview_platform_interface.PlatformStorage.webStorageType}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformStorage.webStorageType.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  final WebStorageType webStorageType;

  ///{@template flutter_inappwebview_platform_interface.PlatformStorageCreationParams.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformStorageCreationParamsClassSupported.isClassSupported(
        platform: platform,
      );

  ///{@template flutter_inappwebview_platform_interface.PlatformStorageCreationParams.isPropertySupported}
  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isPropertySupported(
    PlatformStorageCreationParamsProperty property, {
    TargetPlatform? platform,
  }) => _PlatformStorageCreationParamsPropertySupported.isPropertySupported(
    property,
    platform: platform,
  );
}

///{@template flutter_inappwebview_platform_interface.PlatformStorage}
///Class that provides methods to manage the JavaScript [Storage](https://developer.mozilla.org/en-US/docs/Web/API/Storage) object.
///It is used by [PlatformLocalStorage] and [PlatformSessionStorage].
///{@endtemplate}
///{@macro flutter_inappwebview_platform_interface.PlatformStorage.supported_platforms}
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WebPlatform(),
    WindowsPlatform(),
    LinuxPlatform(),
  ],
)
abstract mixin class PlatformStorage implements Disposable {
  ///{@template flutter_inappwebview_platform_interface.PlatformStorage.controller}
  ///Controller used to interact with storage.
  ///{@endtemplate}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  PlatformInAppWebViewController? get controller;

  ///{@template flutter_inappwebview_platform_interface.PlatformStorage.webStorageType}
  ///The web storage type: `window.sessionStorage` or `window.localStorage`.
  ///{@endtemplate}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  WebStorageType get webStorageType {
    throw UnimplementedError(
      'webStorageType is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformStorage.length}
  ///Returns an integer representing the number of data items stored in the Storage object.
  ///{@endtemplate}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(
        note:
            'This method has an effect only if the iframe has the same origin.',
      ),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<int?> length() {
    throw UnimplementedError(
      'length is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformStorage.setItem}
  ///When passed a [key] name and [value], will add that key to the storage, or update that key's value if it already exists.
  ///{@endtemplate}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(
        note:
            'This method has an effect only if the iframe has the same origin.',
      ),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<void> setItem({required String key, required dynamic value}) {
    throw UnimplementedError(
      'setItem is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformStorage.getItem}
  ///When passed a [key] name, will return that key's value, or `null` if the key does not exist, in the given Storage object.
  ///{@endtemplate}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(
        note:
            'This method has an effect only if the iframe has the same origin.',
      ),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<dynamic> getItem({required String key}) {
    throw UnimplementedError(
      'getItem is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformStorage.removeItem}
  ///When passed a [key] name, will remove that key from the given Storage object if it exists.
  ///{@endtemplate}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(
        note:
            'This method has an effect only if the iframe has the same origin.',
      ),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<void> removeItem({required String key}) {
    throw UnimplementedError(
      'removeItem is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformStorage.getItems}
  ///Returns the list of all items from the given Storage object.
  ///{@endtemplate}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(
        note:
            'This method has an effect only if the iframe has the same origin.',
      ),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<List<WebStorageItem>> getItems() {
    throw UnimplementedError(
      'getItems is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformStorage.clear}
  ///Clears all keys stored in a given Storage object.
  ///{@endtemplate}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(
        note:
            'This method has an effect only if the iframe has the same origin.',
      ),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<void> clear() {
    throw UnimplementedError(
      'clear is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformStorage.key}
  ///When passed a number [index], returns the name of the nth key in a given Storage object.
  ///The order of keys is user-agent defined, so you should not rely on it.
  ///{@endtemplate}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(
        note:
            'This method has an effect only if the iframe has the same origin.',
      ),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<String> key({required int index}) {
    throw UnimplementedError('key is not implemented on the current platform');
  }

  @override
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  void dispose() {
    throw UnimplementedError(
      'dispose is not implemented on the current platform',
    );
  }
}

/// Object specifying creation parameters for creating a [PlatformLocalStorage].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
@immutable
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WebPlatform(),
    WindowsPlatform(),
    LinuxPlatform(),
  ],
)
class PlatformLocalStorageCreationParams extends PlatformStorageCreationParams {
  /// Used by the platform implementation to create a new [PlatformLocalStorage].
  PlatformLocalStorageCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformStorageCreationParams params,
  ) : super(
        controller: params.controller,
        webStorageType: WebStorageType.LOCAL_STORAGE,
      );

  /// Creates a [PlatformLocalStorageCreationParams] instance based on [PlatformLocalStorageCreationParams].
  factory PlatformLocalStorageCreationParams.fromPlatformStorageCreationParams(
    PlatformStorageCreationParams params,
  ) {
    return PlatformLocalStorageCreationParams(params);
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformLocalStorageCreationParams.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformLocalStorageCreationParamsClassSupported.isClassSupported(
        platform: platform,
      );
}

///{@template flutter_inappwebview_platform_interface.PlatformLocalStorage}
///Class that provides methods to manage the JavaScript `window.localStorage` object.
///It used by [PlatformWebStorage].
///{@endtemplate}
///{@macro flutter_inappwebview_platform_interface.PlatformLocalStorage.supported_platforms}
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WebPlatform(),
    WindowsPlatform(),
    LinuxPlatform(),
  ],
)
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
    final PlatformLocalStorage localStorage = InAppWebViewPlatform.instance!
        .createPlatformLocalStorage(params);
    PlatformInterface.verify(localStorage, _token);
    return localStorage;
  }

  /// Creates a new empty [PlatformLocalStorage] to access static methods.
  factory PlatformLocalStorage.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`WebViewPlatform.instance` before use. For unit testing, '
      '`WebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformLocalStorage localStorageStatic = InAppWebViewPlatform
        .instance!
        .createPlatformLocalStorageStatic();
    PlatformInterface.verify(localStorageStatic, _token);
    return localStorageStatic;
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

  ///{@macro flutter_inappwebview_platform_interface.PlatformLocalStorage.isClassSupported}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformLocalStorageClassSupported.isClassSupported(platform: platform);

  ///{@template flutter_inappwebview_platform_interface.PlatformLocalStorage.isPropertySupported}
  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isPropertySupported(
    PlatformStorageCreationParamsProperty property, {
    TargetPlatform? platform,
  }) => params.isPropertySupported(property, platform: platform);

  ///{@template flutter_inappwebview_platform_interface.PlatformLocalStorage.isMethodSupported}
  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isMethodSupported(
    PlatformLocalStorageMethod method, {
    TargetPlatform? platform,
  }) => _PlatformLocalStorageMethodSupported.isMethodSupported(
    method,
    platform: platform,
  );

  @override
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<int?> length() => super.length();

  @override
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<void> setItem({required String key, required dynamic value}) =>
      super.setItem(key: key, value: value);

  @override
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<dynamic> getItem({required String key}) => super.getItem(key: key);

  @override
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<void> removeItem({required String key}) => super.removeItem(key: key);

  @override
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<List<WebStorageItem>> getItems() => super.getItems();

  @override
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<void> clear() => super.clear();

  @override
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<String> key({required int index}) => super.key(index: index);

  @override
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  void dispose() => super.dispose();
}

/// Object specifying creation parameters for creating a [PlatformSessionStorage].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
@immutable
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WebPlatform(),
    WindowsPlatform(),
    LinuxPlatform(),
  ],
)
class PlatformSessionStorageCreationParams
    extends PlatformStorageCreationParams {
  /// Used by the platform implementation to create a new [PlatformSessionStorage].
  PlatformSessionStorageCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformStorageCreationParams params,
  ) : super(
        controller: params.controller,
        webStorageType: WebStorageType.SESSION_STORAGE,
      );

  /// Creates a [PlatformSessionStorageCreationParams] instance based on [PlatformStorageCreationParams].
  factory PlatformSessionStorageCreationParams.fromPlatformStorageCreationParams(
    PlatformStorageCreationParams params,
  ) {
    return PlatformSessionStorageCreationParams(params);
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformSessionStorageCreationParams.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformSessionStorageCreationParamsClassSupported.isClassSupported(
        platform: platform,
      );
}

///{@template flutter_inappwebview_platform_interface.PlatformSessionStorage}
///Class that provides methods to manage the JavaScript `window.sessionStorage` object.
///It used by [PlatformWebStorage].
///{@endtemplate}
///{@macro flutter_inappwebview_platform_interface.PlatformSessionStorage.supported_platforms}
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WebPlatform(),
    WindowsPlatform(),
    LinuxPlatform(),
  ],
)
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
    final PlatformSessionStorage sessionStorage = InAppWebViewPlatform.instance!
        .createPlatformSessionStorage(params);
    PlatformInterface.verify(sessionStorage, _token);
    return sessionStorage;
  }

  /// Creates a new empty [PlatformSessionStorage] to access static methods.
  factory PlatformSessionStorage.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`WebViewPlatform.instance` before use. For unit testing, '
      '`WebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformSessionStorage sessionStorageStatic = InAppWebViewPlatform
        .instance!
        .createPlatformSessionStorageStatic();
    PlatformInterface.verify(sessionStorageStatic, _token);
    return sessionStorageStatic;
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

  ///{@macro flutter_inappwebview_platform_interface.PlatformSessionStorage.isClassSupported}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformSessionStorageClassSupported.isClassSupported(
        platform: platform,
      );

  ///{@template flutter_inappwebview_platform_interface.PlatformSessionStorage.isPropertySupported}
  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isPropertySupported(
    PlatformStorageCreationParamsProperty property, {
    TargetPlatform? platform,
  }) => params.isPropertySupported(property, platform: platform);

  ///{@template flutter_inappwebview_platform_interface.PlatformSessionStorage.isMethodSupported}
  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isMethodSupported(
    PlatformSessionStorageMethod method, {
    TargetPlatform? platform,
  }) => _PlatformSessionStorageMethodSupported.isMethodSupported(
    method,
    platform: platform,
  );

  @override
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<int?> length() => super.length();

  @override
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<void> setItem({required String key, required dynamic value}) =>
      super.setItem(key: key, value: value);

  @override
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<dynamic> getItem({required String key}) => super.getItem(key: key);

  @override
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<void> removeItem({required String key}) => super.removeItem(key: key);

  @override
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<List<WebStorageItem>> getItems() => super.getItems();

  @override
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<void> clear() => super.clear();

  @override
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  Future<String> key({required int index}) => super.key(index: index);

  @override
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WebPlatform(),
      WindowsPlatform(),
      LinuxPlatform(),
    ],
  )
  void dispose() => super.dispose();
}
