import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'types.dart';

///CookieManager class implements a singleton object (shared instance) which manages the cookies used by WebView instances.
///
///**NOTE for iOS**: available from iOS 11.0+.
class CookieManager {
  static CookieManager _instance;
  static const MethodChannel _channel = const MethodChannel('com.pichillilorenzo/flutter_inappbrowser_cookiemanager');

  ///Gets the cookie manager shared instance.
  static CookieManager instance() {
    return (_instance != null) ? _instance : _init();
  }

  static CookieManager _init() {
    _channel.setMethodCallHandler(_handleMethod);
    _instance = new CookieManager();
    return _instance;
  }

  static Future<dynamic> _handleMethod(MethodCall call) async {
  }

  ///Sets a cookie for the given [url]. Any existing cookie with the same [host], [path] and [name] will be replaced with the new cookie. The cookie being set will be ignored if it is expired.
  ///
  ///The default value of [path] is `"/"`.
  ///If [domain] is `null`, its default value will be the domain name of [url].
  Future<void> setCookie({@required String url, @required String name, @required String value,
        String domain,
        String path = "/",
        int expiresDate,
        int maxAge,
        bool isSecure }) async {
    if (domain == null)
      domain = _getDomainName(url);

    assert(url != null && url.isNotEmpty);
    assert(name != null && name.isNotEmpty);
    assert(value != null && value.isNotEmpty);
    assert(domain != null && domain.isNotEmpty);
    assert(path != null && path.isNotEmpty);

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url);
    args.putIfAbsent('name', () => name);
    args.putIfAbsent('value', () => value);
    args.putIfAbsent('domain', () => domain);
    args.putIfAbsent('path', () => path);
    args.putIfAbsent('expiresDate', () => expiresDate?.toString());
    args.putIfAbsent('maxAge', () => maxAge);
    args.putIfAbsent('isSecure', () => isSecure);

    await _channel.invokeMethod('setCookie', args);
  }

  ///Gets all the cookies for the given [url].
  Future<List<Cookie>> getCookies({@required String url}) async {
    assert(url != null && url.isNotEmpty);

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url);
    List<dynamic> cookieListMap = await _channel.invokeMethod('getCookies', args);
    cookieListMap = cookieListMap.cast<Map<dynamic, dynamic>>();
    List<Cookie> cookies = [];
    for(var i = 0; i < cookieListMap.length; i++) {
      cookies.add(Cookie(name: cookieListMap[i]["name"], value: cookieListMap[i]["value"]));
    }
    return cookies;
  }

  ///Gets a cookie by its [name] for the given [url].
  Future<Cookie> getCookie({@required String url, @required String name}) async {
    assert(url != null && url.isNotEmpty);
    assert(name != null && name.isNotEmpty);

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url);
    List<dynamic> cookies = await _channel.invokeMethod('getCookies', args);
    cookies = cookies.cast<Map<dynamic, dynamic>>();
    for(var i = 0; i < cookies.length; i++) {
      cookies[i] = cookies[i].cast<String, dynamic>();
      if (cookies[i]["name"] == name)
        return Cookie(name: cookies[i]["name"], value: cookies[i]["value"]);
    }
    return null;
  }

  ///Removes a cookie by its [name] for the given [url], [domain] and [path].
  ///
  ///The default value of [path] is `"/"`.
  ///If [domain] is `null` or empty, its default value will be the domain name of [url].
  Future<void> deleteCookie({@required String url, @required String name, String domain = "", String path = "/"}) async {
    if (domain == null || domain.isEmpty)
      domain = _getDomainName(url);

    assert(url != null && url.isNotEmpty);
    assert(name != null && name.isNotEmpty);
    assert(domain != null && url.isNotEmpty);
    assert(path != null && url.isNotEmpty);

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url);
    args.putIfAbsent('name', () => name);
    args.putIfAbsent('domain', () => domain);
    args.putIfAbsent('path', () => path);
    await _channel.invokeMethod('deleteCookie', args);
  }

  ///Removes all cookies for the given [url], [domain] and [path].
  ///
  ///The default value of [path] is `"/"`.
  ///If [domain] is `null` or empty, its default value will be the domain name of [url].
  Future<void> deleteCookies({@required String url, String domain = "", String path = "/"}) async {
    if (domain == null || domain.isEmpty)
      domain = _getDomainName(url);

    assert(url != null && url.isNotEmpty);
    assert(domain != null && url.isNotEmpty);
    assert(path != null && url.isNotEmpty);

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url);
    args.putIfAbsent('domain', () => domain);
    args.putIfAbsent('path', () => path);
    await _channel.invokeMethod('deleteCookies', args);
  }

  ///Removes all cookies.
  Future<void> deleteAllCookies() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod('deleteAllCookies', args);
  }

  String _getDomainName(String url) {
    Uri uri = Uri.parse(url);
    String domain = uri.host;
    if (domain == null)
      return "";
    return domain.startsWith("www.") ? domain.substring(4) : domain;
  }
}