import 'dart:async';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

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
class ProxyController {
  /// Constructs a [ProxyController].
  ///
  /// See [ProxyController.fromPlatformCreationParams] for setting
  /// parameters for a specific platform.
  ProxyController()
      : this.fromPlatformCreationParams(
          const PlatformProxyControllerCreationParams(),
        );

  /// Constructs a [ProxyController] from creation params for a specific
  /// platform.
  ProxyController.fromPlatformCreationParams(
    PlatformProxyControllerCreationParams params,
  ) : this.fromPlatform(PlatformProxyController(params));

  /// Constructs a [ProxyController] from a specific platform
  /// implementation.
  ProxyController.fromPlatform(this.platform);

  /// Implementation of [PlatformWebViewProxyController] for the current platform.
  final PlatformProxyController platform;

  static ProxyController? _instance;

  ///Gets the [ProxyController] shared instance.
  static ProxyController instance() {
    if (_instance == null) {
      _instance = ProxyController();
    }
    return _instance!;
  }

  ///Sets [ProxySettings] which will be used by all [WebView]s in the app.
  ///URLs that match patterns in the bypass list will not be directed to any proxy.
  ///Instead, the request will be made directly to the origin specified by the URL.
  ///Network connections are not guaranteed to immediately use the new proxy setting; wait for the method to return before loading a page.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - ProxyController.setProxyOverride](https://developer.android.com/reference/androidx/webkit/ProxyController#setProxyOverride(androidx.webkit.ProxyConfig,%20java.util.concurrent.Executor,%20java.lang.Runnable)))
  Future<void> setProxyOverride({required ProxySettings settings}) =>
      platform.setProxyOverride(settings: settings);

  ///Clears the proxy settings.
  ///Network connections are not guaranteed to immediately use the new proxy setting; wait for the method to return before loading a page.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - ProxyController.clearProxyOverride](https://developer.android.com/reference/androidx/webkit/ProxyController#clearProxyOverride(java.util.concurrent.Executor,%20java.lang.Runnable)))
  Future<void> clearProxyOverride() => platform.clearProxyOverride();
}
