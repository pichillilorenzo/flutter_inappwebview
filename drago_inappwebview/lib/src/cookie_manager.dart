import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:drago_inappwebview/platform_interface/platform_interface.dart';

import 'in_app_webview/in_app_webview_controller.dart';
import 'webview_environment/webview_environment.dart';

///{@macro drago_inappwebview.PlatformCookieManager}
///
///{@macro drago_inappwebview.PlatformCookieManager.supported_platforms}
class CookieManager {
  ///{@macro drago_inappwebview.PlatformCookieManager}
  ///
  ///{@macro drago_inappwebview.PlatformCookieManager.supported_platforms}
  CookieManager()
    : this.fromPlatformCreationParams(
        const PlatformCookieManagerCreationParams(),
      );

  /// Constructs a [CookieManager] from creation params for a specific
  /// platform.
  CookieManager.fromPlatformCreationParams(
    PlatformCookieManagerCreationParams params,
  ) : this.fromPlatform(PlatformCookieManager(params));

  /// Constructs a [CookieManager] from a specific platform
  /// implementation.
  CookieManager.fromPlatform(this.platform);

  /// Implementation of [PlatformCookieManager] for the current platform.
  final PlatformCookieManager platform;

  ///Use [CookieManager] instead.
  @Deprecated("Use CookieManager instead")
  IOSCookieManager ios = IOSCookieManager.instance();

  static CookieManager? _instance;

  ///Gets the [CookieManager] shared instance.
  ///
  ///[webViewEnvironment] (Supported only on Windows) - Used to create the [CookieManager] using the specified environment.
  static CookieManager instance({WebViewEnvironment? webViewEnvironment}) {
    if (webViewEnvironment == null) {
      _instance ??= CookieManager();
      return _instance!;
    } else {
      return CookieManager.fromPlatformCreationParams(
        PlatformCookieManagerCreationParams(
          webViewEnvironment: webViewEnvironment.platform,
        ),
      );
    }
  }

  ///{@macro drago_inappwebview.PlatformCookieManager.setCookie}
  ///
  ///{@macro drago_inappwebview.PlatformCookieManager.setCookie.supported_platforms}
  Future<bool> setCookie({
    required WebUri url,
    required String name,
    required String value,
    String path = "/",
    String? domain,
    int? expiresDate,
    int? maxAge,
    bool? isSecure,
    bool? isHttpOnly,
    HTTPCookieSameSitePolicy? sameSite,
    @Deprecated("Use webViewController instead")
    InAppWebViewController? iosBelow11WebViewController,
    InAppWebViewController? webViewController,
  }) => platform.setCookie(
    url: url,
    name: name,
    value: value,
    path: path,
    domain: domain,
    expiresDate: expiresDate,
    maxAge: maxAge,
    isSecure: isSecure,
    isHttpOnly: isHttpOnly,
    sameSite: sameSite,
    iosBelow11WebViewController: iosBelow11WebViewController?.platform,
    webViewController: webViewController?.platform,
  );

  ///{@macro drago_inappwebview.PlatformCookieManager.getCookies}
  ///
  ///{@macro drago_inappwebview.PlatformCookieManager.getCookies.supported_platforms}
  Future<List<Cookie>> getCookies({
    required WebUri url,
    @Deprecated("Use webViewController instead")
    InAppWebViewController? iosBelow11WebViewController,
    InAppWebViewController? webViewController,
  }) => platform.getCookies(
    url: url,
    iosBelow11WebViewController: iosBelow11WebViewController?.platform,
    webViewController: webViewController?.platform,
  );

  ///{@macro drago_inappwebview.PlatformCookieManager.getCookie}
  ///
  ///{@macro drago_inappwebview.PlatformCookieManager.getCookie.supported_platforms}
  Future<Cookie?> getCookie({
    required WebUri url,
    required String name,
    @Deprecated("Use webViewController instead")
    InAppWebViewController? iosBelow11WebViewController,
    InAppWebViewController? webViewController,
  }) => platform.getCookie(
    url: url,
    name: name,
    iosBelow11WebViewController: iosBelow11WebViewController?.platform,
    webViewController: webViewController?.platform,
  );

  ///{@macro drago_inappwebview.PlatformCookieManager.deleteCookie}
  ///
  ///{@macro drago_inappwebview.PlatformCookieManager.deleteCookie.supported_platforms}
  Future<bool> deleteCookie({
    required WebUri url,
    required String name,
    String path = "/",
    String? domain,
    @Deprecated("Use webViewController instead")
    InAppWebViewController? iosBelow11WebViewController,
    InAppWebViewController? webViewController,
  }) => platform.deleteCookie(
    url: url,
    name: name,
    path: path,
    domain: domain,
    iosBelow11WebViewController: iosBelow11WebViewController?.platform,
    webViewController: webViewController?.platform,
  );

  ///{@macro drago_inappwebview.PlatformCookieManager.deleteCookies}
  ///
  ///{@macro drago_inappwebview.PlatformCookieManager.deleteCookies.supported_platforms}
  Future<bool> deleteCookies({
    required WebUri url,
    String path = "/",
    String? domain,
    @Deprecated("Use webViewController instead")
    InAppWebViewController? iosBelow11WebViewController,
    InAppWebViewController? webViewController,
  }) => platform.deleteCookies(
    url: url,
    path: path,
    domain: domain,
    iosBelow11WebViewController: iosBelow11WebViewController?.platform,
    webViewController: webViewController?.platform,
  );

  ///{@macro drago_inappwebview.PlatformCookieManager.deleteAllCookies}
  ///
  ///{@macro drago_inappwebview.PlatformCookieManager.deleteAllCookies.supported_platforms}
  Future<bool> deleteAllCookies() => platform.deleteAllCookies();

  ///{@macro drago_inappwebview.PlatformCookieManager.getAllCookies}
  ///
  ///{@macro drago_inappwebview.PlatformCookieManager.getAllCookies.supported_platforms}
  Future<List<Cookie>> getAllCookies() => platform.getAllCookies();

  ///{@macro drago_inappwebview.PlatformCookieManager.removeSessionCookies}
  ///
  ///{@macro drago_inappwebview.PlatformCookieManager.removeSessionCookies.supported_platforms}
  Future<bool> removeSessionCookies() => platform.removeSessionCookies();

  ///{@macro drago_inappwebview.PlatformCookieManager.flush}
  ///
  ///{@macro drago_inappwebview.PlatformCookieManager.flush.supported_platforms}
  Future<void> flush() => platform.flush();

  ///{@macro drago_inappwebview.PlatformCookieManagerCreationParams.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformCookieManager.static().isClassSupported(platform: platform);

  ///{@macro drago_inappwebview.PlatformCookieManagerCreationParams.isPropertySupported}
  static bool isPropertySupported(
    PlatformCookieManagerCreationParamsProperty property, {
    TargetPlatform? platform,
  }) => PlatformCookieManager.static().isPropertySupported(
    property,
    platform: platform,
  );

  ///{@macro drago_inappwebview.PlatformCookieManager.isMethodSupported}
  static bool isMethodSupported(
    PlatformCookieManagerMethod method, {
    TargetPlatform? platform,
  }) => PlatformCookieManager.static().isMethodSupported(
    method,
    platform: platform,
  );
}

///Class that contains only iOS-specific methods of [CookieManager].
///Use [CookieManager] instead.
@Deprecated("Use CookieManager instead")
class IOSCookieManager {
  static IOSCookieManager? _instance;

  ///Gets the [IOSCookieManager] shared instance.
  static IOSCookieManager instance() {
    return (_instance != null) ? _instance! : _init();
  }

  IOSCookieManager._();

  static IOSCookieManager _init() {
    _instance = IOSCookieManager._();
    return _instance!;
  }

  ///Fetches all stored cookies.
  ///
  ///**NOTE**: available on iOS 11.0+.
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882005-getallcookies
  Future<List<Cookie>> getAllCookies() async {
    return CookieManager.instance().getAllCookies();
  }
}
