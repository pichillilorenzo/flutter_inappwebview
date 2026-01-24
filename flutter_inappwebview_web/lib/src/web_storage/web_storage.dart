import 'dart:convert';

import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../in_app_webview/in_app_webview_controller.dart';

/// Object specifying creation parameters for creating a [WebPlatformWebStorage].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformWebStorageCreationParams] for
/// more information.
class WebPlatformWebStorageCreationParams
    extends PlatformWebStorageCreationParams {
  /// Creates a new [WebPlatformWebStorageCreationParams] instance.
  WebPlatformWebStorageCreationParams({
    required super.localStorage,
    required super.sessionStorage,
  });

  /// Creates a [WebPlatformWebStorageCreationParams] instance based on [PlatformWebStorageCreationParams].
  factory WebPlatformWebStorageCreationParams.fromPlatformWebStorageCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformWebStorageCreationParams params,
  ) {
    return WebPlatformWebStorageCreationParams(
      localStorage: params.localStorage,
      sessionStorage: params.sessionStorage,
    );
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformWebStorage}
class WebPlatformWebStorage extends PlatformWebStorage {
  /// Constructs a [WebPlatformWebStorage].
  WebPlatformWebStorage(PlatformWebStorageCreationParams params)
    : super.implementation(
        params is WebPlatformWebStorageCreationParams
            ? params
            : WebPlatformWebStorageCreationParams.fromPlatformWebStorageCreationParams(
                params,
              ),
      );

  @override
  PlatformLocalStorage get localStorage => params.localStorage;

  @override
  PlatformSessionStorage get sessionStorage => params.sessionStorage;

  @override
  void dispose() {
    localStorage.dispose();
    sessionStorage.dispose();
  }
}

/// Object specifying creation parameters for creating a [WebPlatformStorage].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformStorageCreationParams] for
/// more information.
class WebPlatformStorageCreationParams extends PlatformStorageCreationParams {
  /// Creates a new [WebPlatformStorageCreationParams] instance.
  WebPlatformStorageCreationParams({
    required super.controller,
    required super.webStorageType,
  });

  /// Creates a [WebPlatformStorageCreationParams] instance based on [PlatformStorageCreationParams].
  factory WebPlatformStorageCreationParams.fromPlatformStorageCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformStorageCreationParams params,
  ) {
    return WebPlatformStorageCreationParams(
      controller: params.controller,
      webStorageType: params.webStorageType,
    );
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformStorage}
abstract mixin class WebPlatformStorage implements PlatformStorage {
  @override
  WebPlatformInAppWebViewController? controller;

  @override
  Future<int?> length() async {
    var result = await controller?.evaluateJavascript(
      source:
          """
    window.$webStorageType.length;
    """,
    );
    // evaluateJavascript already decodes the JSON, so result is already a num
    return result != null ? (result as num).toInt() : null;
  }

  @override
  Future<void> setItem({required String key, required dynamic value}) async {
    var encodedValue = json.encode(value);
    await controller?.evaluateJavascript(
      source:
          """
    window.$webStorageType.setItem("$key", ${value is String ? encodedValue : "JSON.stringify($encodedValue)"});
    """,
    );
  }

  @override
  Future<dynamic> getItem({required String key}) async {
    var itemValue = await controller?.evaluateJavascript(
      source:
          """
    window.$webStorageType.getItem("$key");
    """,
    );

    if (itemValue == null) {
      return null;
    }

    try {
      return json.decode(itemValue);
    } catch (e) {}

    return itemValue;
  }

  @override
  Future<void> removeItem({required String key}) async {
    await controller?.evaluateJavascript(
      source:
          """
    window.$webStorageType.removeItem("$key");
    """,
    );
  }

  @override
  Future<List<WebStorageItem>> getItems() async {
    var webStorageItems = <WebStorageItem>[];

    List<Map<dynamic, dynamic>>? items = (await controller?.evaluateJavascript(
      source:
          """
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
    """,
    ))?.cast<Map<dynamic, dynamic>>();

    if (items == null) {
      return webStorageItems;
    }

    for (var item in items) {
      webStorageItems.add(
        WebStorageItem(key: item["key"], value: item["value"]),
      );
    }

    return webStorageItems;
  }

  @override
  Future<void> clear() async {
    await controller?.evaluateJavascript(
      source:
          """
    window.$webStorageType.clear();
    """,
    );
  }

  @override
  Future<String> key({required int index}) async {
    var result = await controller?.evaluateJavascript(
      source:
          """
    window.$webStorageType.key($index);
    """,
    );
    // evaluateJavascript already decodes the JSON, so result is already a String
    return result as String? ?? '';
  }

  @override
  void dispose() {
    controller = null;
  }
}

/// Object specifying creation parameters for creating a [WebPlatformLocalStorage].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformLocalStorageCreationParams] for
/// more information.
class WebPlatformLocalStorageCreationParams
    extends PlatformLocalStorageCreationParams {
  /// Creates a new [WebPlatformLocalStorageCreationParams] instance.
  WebPlatformLocalStorageCreationParams(super.params);

  /// Creates a [WebPlatformLocalStorageCreationParams] instance based on [PlatformLocalStorageCreationParams].
  factory WebPlatformLocalStorageCreationParams.fromPlatformLocalStorageCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformLocalStorageCreationParams params,
  ) {
    return WebPlatformLocalStorageCreationParams(params);
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformLocalStorage}
class WebPlatformLocalStorage extends PlatformLocalStorage
    with WebPlatformStorage {
  /// Constructs a [WebPlatformLocalStorage].
  WebPlatformLocalStorage(PlatformLocalStorageCreationParams params)
    : super.implementation(
        params is WebPlatformLocalStorageCreationParams
            ? params
            : WebPlatformLocalStorageCreationParams.fromPlatformLocalStorageCreationParams(
                params,
              ),
      );

  /// Default storage
  factory WebPlatformLocalStorage.defaultStorage({
    required PlatformInAppWebViewController? controller,
  }) {
    return WebPlatformLocalStorage(
      WebPlatformLocalStorageCreationParams(
        PlatformLocalStorageCreationParams(
          PlatformStorageCreationParams(
            controller: controller,
            webStorageType: WebStorageType.LOCAL_STORAGE,
          ),
        ),
      ),
    );
  }

  @override
  WebPlatformInAppWebViewController? get controller =>
      params.controller as WebPlatformInAppWebViewController?;
}

/// Object specifying creation parameters for creating a [WebPlatformSessionStorage].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformSessionStorageCreationParams] for
/// more information.
class WebPlatformSessionStorageCreationParams
    extends PlatformSessionStorageCreationParams {
  /// Creates a new [WebPlatformSessionStorageCreationParams] instance.
  WebPlatformSessionStorageCreationParams(super.params);

  /// Creates a [WebPlatformSessionStorageCreationParams] instance based on [PlatformSessionStorageCreationParams].
  factory WebPlatformSessionStorageCreationParams.fromPlatformSessionStorageCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformSessionStorageCreationParams params,
  ) {
    return WebPlatformSessionStorageCreationParams(params);
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformSessionStorage}
class WebPlatformSessionStorage extends PlatformSessionStorage
    with WebPlatformStorage {
  /// Constructs a [WebPlatformSessionStorage].
  WebPlatformSessionStorage(PlatformSessionStorageCreationParams params)
    : super.implementation(
        params is WebPlatformSessionStorageCreationParams
            ? params
            : WebPlatformSessionStorageCreationParams.fromPlatformSessionStorageCreationParams(
                params,
              ),
      );

  /// Default storage
  factory WebPlatformSessionStorage.defaultStorage({
    required PlatformInAppWebViewController? controller,
  }) {
    return WebPlatformSessionStorage(
      WebPlatformSessionStorageCreationParams(
        PlatformSessionStorageCreationParams(
          PlatformStorageCreationParams(
            controller: controller,
            webStorageType: WebStorageType.SESSION_STORAGE,
          ),
        ),
      ),
    );
  }

  @override
  WebPlatformInAppWebViewController? get controller =>
      params.controller as WebPlatformInAppWebViewController?;
}
