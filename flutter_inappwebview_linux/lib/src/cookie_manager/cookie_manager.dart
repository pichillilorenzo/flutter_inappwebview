import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

/// Object specifying creation parameters for creating a [LinuxCookieManager].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformCookieManagerCreationParams] for
/// more information.
class LinuxCookieManagerCreationParams
    extends PlatformCookieManagerCreationParams {
  /// Creates a new [LinuxCookieManagerCreationParams] instance.
  const LinuxCookieManagerCreationParams();

  /// Creates a [LinuxCookieManagerCreationParams] instance based on [PlatformCookieManagerCreationParams].
  factory LinuxCookieManagerCreationParams.fromPlatformCookieManagerCreationParams(
    PlatformCookieManagerCreationParams params,
  ) {
    return const LinuxCookieManagerCreationParams();
  }
}

/// Implementation of [PlatformCookieManager] for Linux using WebKitGTK.
class LinuxCookieManager extends PlatformCookieManager {
  static const MethodChannel _channel = MethodChannel(
    'com.pichillilorenzo/flutter_inappwebview_cookiemanager',
  );

  /// Constructs a [LinuxCookieManager].
  LinuxCookieManager(PlatformCookieManagerCreationParams params)
    : super.implementation(
        params is LinuxCookieManagerCreationParams
            ? params
            : LinuxCookieManagerCreationParams.fromPlatformCookieManagerCreationParams(
                params,
              ),
      );

  static final LinuxCookieManager _instance = LinuxCookieManager(
    const LinuxCookieManagerCreationParams(),
  );

  /// The [LinuxCookieManager] singleton instance.
  static LinuxCookieManager instance() => _instance;

  /// Creates and returns a new [LinuxCookieManager] for static methods.
  factory LinuxCookieManager.static() => _instance;

  @override
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
    PlatformInAppWebViewController? iosBelow11WebViewController,
    PlatformInAppWebViewController? webViewController,
  }) async {
    final Map<String, dynamic> cookie = {
      'name': name,
      'value': value,
      'path': path,
      if (domain != null) 'domain': domain,
      if (expiresDate != null) 'expiresDate': expiresDate,
      if (maxAge != null) 'maxAge': maxAge,
      if (isSecure != null) 'isSecure': isSecure,
      if (isHttpOnly != null) 'isHttpOnly': isHttpOnly,
      if (sameSite != null) 'sameSite': sameSite.toString().split('.').last,
    };

    final result = await _channel.invokeMethod<bool>('setCookie', {
      'url': url.toString(),
      'cookie': cookie,
    });

    return result ?? false;
  }

  @override
  Future<List<Cookie>> getCookies({
    required WebUri url,
    @Deprecated("Use webViewController instead")
    PlatformInAppWebViewController? iosBelow11WebViewController,
    PlatformInAppWebViewController? webViewController,
  }) async {
    final result = await _channel.invokeMethod<List<dynamic>>('getCookies', {
      'url': url.toString(),
    });

    if (result == null) {
      return [];
    }

    return result
        .cast<Map<dynamic, dynamic>>()
        .map((cookieMap) => Cookie.fromMap(cookieMap.cast<String, dynamic>())!)
        .toList();
  }

  @override
  Future<Cookie?> getCookie({
    required WebUri url,
    required String name,
    @Deprecated("Use webViewController instead")
    PlatformInAppWebViewController? iosBelow11WebViewController,
    PlatformInAppWebViewController? webViewController,
  }) async {
    final result = await _channel.invokeMethod<Map<dynamic, dynamic>?>(
      'getCookie',
      {'url': url.toString(), 'name': name},
    );

    if (result == null) {
      return null;
    }

    return Cookie.fromMap(result.cast<String, dynamic>());
  }

  @override
  Future<bool> deleteCookie({
    required WebUri url,
    required String name,
    String path = "/",
    String? domain,
    @Deprecated("Use webViewController instead")
    PlatformInAppWebViewController? iosBelow11WebViewController,
    PlatformInAppWebViewController? webViewController,
  }) async {
    final result = await _channel.invokeMethod<bool>('deleteCookie', {
      'url': url.toString(),
      'name': name,
      'path': path,
      'domain': domain ?? '',
    });

    return result ?? false;
  }

  @override
  Future<bool> deleteCookies({
    required WebUri url,
    String path = "/",
    String? domain,
    @Deprecated("Use webViewController instead")
    PlatformInAppWebViewController? iosBelow11WebViewController,
    PlatformInAppWebViewController? webViewController,
  }) async {
    final result = await _channel.invokeMethod<bool>('deleteCookies', {
      'url': url.toString(),
      'path': path,
      'domain': domain ?? '',
    });

    return result ?? false;
  }

  @override
  Future<bool> deleteAllCookies() async {
    final result = await _channel.invokeMethod<bool>('deleteAllCookies');
    return result ?? false;
  }

  @override
  Future<List<Cookie>> getAllCookies() async {
    final result = await _channel.invokeMethod<List<dynamic>>('getAllCookies');

    if (result == null) {
      return [];
    }

    return result
        .cast<Map<dynamic, dynamic>>()
        .map((cookieMap) => Cookie.fromMap(cookieMap.cast<String, dynamic>())!)
        .toList();
  }
}
