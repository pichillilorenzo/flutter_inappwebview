import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

/// Object specifying creation parameters for creating a [AndroidProxyController].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformProxyControllerCreationParams] for
/// more information.
@immutable
class AndroidProxyControllerCreationParams
    extends PlatformProxyControllerCreationParams {
  /// Creates a new [AndroidProxyControllerCreationParams] instance.
  const AndroidProxyControllerCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformProxyControllerCreationParams params,
  ) : super();

  /// Creates a [AndroidProxyControllerCreationParams] instance based on [PlatformProxyControllerCreationParams].
  factory AndroidProxyControllerCreationParams.fromPlatformProxyControllerCreationParams(
      PlatformProxyControllerCreationParams params) {
    return AndroidProxyControllerCreationParams(params);
  }
}

///Manages setting and clearing a process-specific override for the Android system-wide proxy settings that govern network requests made by [WebView].
///
///[WebView] may make network requests in order to fetch content that is not otherwise read from the file system or provided directly by application code.
///In this case by default the system-wide Android network proxy settings are used to redirect requests to appropriate proxy servers.
///
///In the rare case that it is necessary for an application to explicitly specify its proxy configuration,
///this API may be used to explicitly specify the proxy rules that govern WebView initiated network requests.
///
///**Supported Platforms/Implementations**:
///- Android native WebView ([Official API - ProxyController](https://developer.android.com/reference/androidx/webkit/ProxyController))
class AndroidProxyController extends PlatformProxyController
    with ChannelController {
  /// Creates a new [AndroidProxyController].
  AndroidProxyController(PlatformProxyControllerCreationParams params)
      : super.implementation(
          params is AndroidProxyControllerCreationParams
              ? params
              : AndroidProxyControllerCreationParams
                  .fromPlatformProxyControllerCreationParams(params),
        ) {
    channel = const MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_proxycontroller');
    handler = handleMethod;
    initMethodCallHandler();
  }

  static AndroidProxyController? _instance;

  ///Gets the [AndroidProxyController] shared instance.
  static AndroidProxyController instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static AndroidProxyController _init() {
    _instance = AndroidProxyController(AndroidProxyControllerCreationParams(
        const PlatformProxyControllerCreationParams()));
    return _instance!;
  }

  Future<dynamic> _handleMethod(MethodCall call) async {}

  ///Sets [ProxySettings] which will be used by all [WebView]s in the app.
  ///URLs that match patterns in the bypass list will not be directed to any proxy.
  ///Instead, the request will be made directly to the origin specified by the URL.
  ///Network connections are not guaranteed to immediately use the new proxy setting; wait for the method to return before loading a page.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - ProxyController.setProxyOverride](https://developer.android.com/reference/androidx/webkit/ProxyController#setProxyOverride(androidx.webkit.ProxyConfig,%20java.util.concurrent.Executor,%20java.lang.Runnable)))
  Future<void> setProxyOverride({required ProxySettings settings}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("settings", () => settings.toMap());
    await channel?.invokeMethod('setProxyOverride', args);
  }

  ///Clears the proxy settings.
  ///Network connections are not guaranteed to immediately use the new proxy setting; wait for the method to return before loading a page.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - ProxyController.clearProxyOverride](https://developer.android.com/reference/androidx/webkit/ProxyController#clearProxyOverride(java.util.concurrent.Executor,%20java.lang.Runnable)))
  Future<void> clearProxyOverride() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('clearProxyOverride', args);
  }

  @override
  void dispose() {
    // empty
  }
}

extension InternalProxyController on AndroidProxyController {
  get handleMethod => _handleMethod;
}
