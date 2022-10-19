import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'in_app_webview/in_app_webview_controller.dart';
import 'in_app_webview/in_app_webview_options.dart';
import 'in_app_webview/headless_in_app_webview.dart';
import 'platform_util.dart';

import 'types.dart';

///Class that implements a singleton object (shared instance) which manages the cookies used by WebView instances.
///On Android, it is implemented using [CookieManager](https://developer.android.com/reference/android/webkit/CookieManager).
///On iOS, it is implemented using [WKHTTPCookieStore](https://developer.apple.com/documentation/webkit/wkhttpcookiestore).
///
///**NOTE for iOS below 11.0 (LIMITED SUPPORT!)**: in this case, almost all of the methods ([CookieManager.deleteAllCookies] and [IOSCookieManager.getAllCookies] are not supported!)
///has been implemented using JavaScript because there is no other way to work with them on iOS below 11.0.
///See https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies for JavaScript restrictions.
class CookieManager {
  static CookieManager? _instance;
  static const MethodChannel _channel = const MethodChannel(
      'com.pichillilorenzo/flutter_inappwebview_cookiemanager');

  CookieManager._();

  ///Contains only iOS-specific methods of [CookieManager].
  late IOSCookieManager ios;

  ///Gets the [CookieManager] shared instance.
  static CookieManager instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static CookieManager _init() {
    _channel.setMethodCallHandler(_handleMethod);
    _instance = CookieManager._();
    _instance!.ios = IOSCookieManager.instance();
    return _instance!;
  }

  static Future<dynamic> _handleMethod(MethodCall call) async {}

  ///Sets a cookie for the given [url]. Any existing cookie with the same [host], [path] and [name] will be replaced with the new cookie.
  ///The cookie being set will be ignored if it is expired.
  ///
  ///The default value of [path] is `"/"`.
  ///
  ///[iosBelow11WebViewController] could be used if you need to set a session-only cookie using JavaScript (so [isHttpOnly] cannot be set, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies)
  ///on the current URL of the [WebView] managed by that controller when you need to target iOS below 11. In this case the [url] parameter is ignored.
  ///
  ///**NOTE for iOS below 11.0**: If [iosBelow11WebViewController] is `null` or JavaScript is disabled for it, it will try to use a [HeadlessInAppWebView]
  ///to set the cookie (session-only cookie won't work! In that case, you should set also [expiresDate] or [maxAge]).
  Future<void> setCookie(
      {required Uri url,
      required String name,
      required String value,
      String path = "/",
      String? domain,
      int? expiresDate,
      int? maxAge,
      bool? isSecure,
      bool? isHttpOnly,
      HTTPCookieSameSitePolicy? sameSite,
      InAppWebViewController? iosBelow11WebViewController}) async {
    assert(url.toString().isNotEmpty);
    assert(name.isNotEmpty);
    assert(value.isNotEmpty);
    assert(path.isNotEmpty);

    if (await _shouldUseJavascript()) {
      await _setCookieWithJavaScript(
          url: url,
          name: name,
          value: value,
          domain: domain,
          path: path,
          expiresDate: expiresDate,
          maxAge: maxAge,
          isSecure: isSecure,
          sameSite: sameSite,
          webViewController: iosBelow11WebViewController);
      return;
    }

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url.toString());
    args.putIfAbsent('name', () => name);
    args.putIfAbsent('value', () => value);
    args.putIfAbsent('domain', () => domain);
    args.putIfAbsent('path', () => path);
    args.putIfAbsent('expiresDate', () => expiresDate?.toString());
    args.putIfAbsent('maxAge', () => maxAge);
    args.putIfAbsent('isSecure', () => isSecure);
    args.putIfAbsent('isHttpOnly', () => isHttpOnly);
    args.putIfAbsent('sameSite', () => sameSite?.toValue());

    await _channel.invokeMethod('setCookie', args);
  }

  Future<void> _setCookieWithJavaScript(
      {required Uri url,
      required String name,
      required String value,
      String path = "/",
      String? domain,
      int? expiresDate,
      int? maxAge,
      bool? isSecure,
      HTTPCookieSameSitePolicy? sameSite,
      InAppWebViewController? webViewController}) async {
    var cookieValue = name + "=" + value + "; Path=" + path;

    if (domain != null) cookieValue += "; Domain=" + domain;

    if (expiresDate != null)
      cookieValue += "; Expires=" + await _getCookieExpirationDate(expiresDate);

    if (maxAge != null) cookieValue += "; Max-Age=" + maxAge.toString();

    if (isSecure != null && isSecure) cookieValue += "; Secure";

    if (sameSite != null) cookieValue += "; SameSite=" + sameSite.toValue();

    cookieValue += ";";

    if (webViewController != null) {
      InAppWebViewGroupOptions? options = await webViewController.getOptions();
      if (options != null && options.crossPlatform.javaScriptEnabled) {
        await webViewController.evaluateJavascript(
            source: 'document.cookie="$cookieValue"');
        return;
      }
    }

    var setCookieCompleter = Completer<void>();
    var headlessWebView = new HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: url),
      onLoadStop: (controller, url) async {
        await controller.evaluateJavascript(
            source: 'document.cookie="$cookieValue"');
        setCookieCompleter.complete();
      },
    );
    await headlessWebView.run();
    await setCookieCompleter.future;
    await headlessWebView.dispose();
  }

  ///Gets all the cookies for the given [url].
  ///
  ///[iosBelow11WebViewController] is used for getting the cookies (also session-only cookies) using JavaScript (cookies with `isHttpOnly` enabled cannot be found, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies)
  ///from the current context of the [WebView] managed by that controller when you need to target iOS below 11. JavaScript must be enabled in order to work.
  ///In this case the [url] parameter is ignored.
  ///
  ///**NOTE for iOS below 11.0**: All the cookies returned this way will have all the properties to `null` except for [Cookie.name] and [Cookie.value].
  ///If [iosBelow11WebViewController] is `null` or JavaScript is disabled for it, it will try to use a [HeadlessInAppWebView]
  ///to get the cookies (session-only cookies and cookies with `isHttpOnly` enabled won't be found!).
  Future<List<Cookie>> getCookies(
      {required Uri url,
      InAppWebViewController? iosBelow11WebViewController}) async {
    assert(url.toString().isNotEmpty);

    if (await _shouldUseJavascript()) {
      return await _getCookiesWithJavaScript(
          url: url, webViewController: iosBelow11WebViewController);
    }

    List<Cookie> cookies = [];

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url.toString());
    List<dynamic> cookieListMap =
        await _channel.invokeMethod('getCookies', args);
    cookieListMap = cookieListMap.cast<Map<dynamic, dynamic>>();

    cookieListMap.forEach((cookieMap) {
      cookies.add(Cookie(
          name: cookieMap["name"],
          value: cookieMap["value"],
          expiresDate: cookieMap["expiresDate"],
          isSessionOnly: cookieMap["isSessionOnly"],
          domain: cookieMap["domain"],
          sameSite: HTTPCookieSameSitePolicy.fromValue(cookieMap["sameSite"]),
          isSecure: cookieMap["isSecure"],
          isHttpOnly: cookieMap["isHttpOnly"],
          path: cookieMap["path"]));
    });
    return cookies;
  }

  Future<List<Cookie>> _getCookiesWithJavaScript(
      {required Uri url, InAppWebViewController? webViewController}) async {
    assert(url.toString().isNotEmpty);

    List<Cookie> cookies = [];

    if (webViewController != null) {
      InAppWebViewGroupOptions? options = await webViewController.getOptions();
      if (options != null && options.crossPlatform.javaScriptEnabled) {
        List<String> documentCookies = (await webViewController
                .evaluateJavascript(source: 'document.cookie') as String)
            .split(';')
            .map((documentCookie) => documentCookie.trim())
            .toList();
        documentCookies.forEach((documentCookie) {
          List<String> cookie = documentCookie.split('=');
          cookies.add(Cookie(
            name: cookie[0],
            value: cookie[1],
          ));
        });
        return cookies;
      }
    }

    var pageLoaded = Completer<void>();
    var headlessWebView = new HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: url),
      onLoadStop: (controller, url) async {
        pageLoaded.complete();
      },
    );
    await headlessWebView.run();
    await pageLoaded.future;

    List<String> documentCookies = (await headlessWebView.webViewController
            .evaluateJavascript(source: 'document.cookie') as String)
        .split(';')
        .map((documentCookie) => documentCookie.trim())
        .toList();
    documentCookies.forEach((documentCookie) {
      List<String> cookie = documentCookie.split('=');
      cookies.add(Cookie(
        name: cookie[0],
        value: cookie[1],
      ));
    });
    await headlessWebView.dispose();
    return cookies;
  }

  ///Gets a cookie by its [name] for the given [url].
  ///
  ///[iosBelow11WebViewController] is used for getting the cookie (also session-only cookie) using JavaScript (cookie with `isHttpOnly` enabled cannot be found, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies)
  ///from the current context of the [WebView] managed by that controller when you need to target iOS below 11. JavaScript must be enabled in order to work.
  ///In this case the [url] parameter is ignored.
  ///
  ///**NOTE for iOS below 11.0**: All the cookies returned this way will have all the properties to `null` except for [Cookie.name] and [Cookie.value].
  ///If [iosBelow11WebViewController] is `null` or JavaScript is disabled for it, it will try to use a [HeadlessInAppWebView]
  ///to get the cookie (session-only cookie and cookie with `isHttpOnly` enabled won't be found!).
  Future<Cookie?> getCookie(
      {required Uri url,
      required String name,
      InAppWebViewController? iosBelow11WebViewController}) async {
    assert(url.toString().isNotEmpty);
    assert(name.isNotEmpty);

    if (await _shouldUseJavascript()) {
      List<Cookie> cookies = await _getCookiesWithJavaScript(
          url: url, webViewController: iosBelow11WebViewController);
      return cookies
          .cast<Cookie?>()
          .firstWhere((cookie) => cookie!.name == name, orElse: () => null);
    }

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url.toString());
    List<dynamic> cookies = await _channel.invokeMethod('getCookies', args);
    cookies = cookies.cast<Map<dynamic, dynamic>>();
    for (var i = 0; i < cookies.length; i++) {
      cookies[i] = cookies[i].cast<String, dynamic>();
      if (cookies[i]["name"] == name)
        return Cookie(
            name: cookies[i]["name"],
            value: cookies[i]["value"],
            expiresDate: cookies[i]["expiresDate"],
            isSessionOnly: cookies[i]["isSessionOnly"],
            domain: cookies[i]["domain"],
            sameSite:
                HTTPCookieSameSitePolicy.fromValue(cookies[i]["sameSite"]),
            isSecure: cookies[i]["isSecure"],
            isHttpOnly: cookies[i]["isHttpOnly"],
            path: cookies[i]["path"]);
    }
    return null;
  }

  ///Removes a cookie by its [name] for the given [url], [domain] and [path].
  ///
  ///The default value of [path] is `"/"`.
  ///
  ///[iosBelow11WebViewController] is used for deleting the cookie (also session-only cookie) using JavaScript (cookie with `isHttpOnly` enabled cannot be deleted, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies)
  ///from the current context of the [WebView] managed by that controller when you need to target iOS below 11. JavaScript must be enabled in order to work.
  ///In this case the [url] parameter is ignored.
  ///
  ///**NOTE for iOS below 11.0**: If [iosBelow11WebViewController] is `null` or JavaScript is disabled for it, it will try to use a [HeadlessInAppWebView]
  ///to delete the cookie (session-only cookie and cookie with `isHttpOnly` enabled won't be deleted!).
  Future<void> deleteCookie(
      {required Uri url,
      required String name,
      String path = "/",
      String? domain,
      InAppWebViewController? iosBelow11WebViewController}) async {
    assert(url.toString().isNotEmpty);
    assert(name.isNotEmpty);

    if (await _shouldUseJavascript()) {
      await _setCookieWithJavaScript(
          url: url,
          name: name,
          value: "",
          path: path,
          domain: domain,
          maxAge: -1,
          webViewController: iosBelow11WebViewController);
      return;
    }

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url.toString());
    args.putIfAbsent('name', () => name);
    args.putIfAbsent('domain', () => domain);
    args.putIfAbsent('path', () => path);
    await _channel.invokeMethod('deleteCookie', args);
  }

  ///Removes all cookies for the given [url], [domain] and [path].
  ///
  ///The default value of [path] is `"/"`.
  ///
  ///[iosBelow11WebViewController] is used for deleting the cookies (also session-only cookies) using JavaScript (cookies with `isHttpOnly` enabled cannot be deleted, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies)
  ///from the current context of the [WebView] managed by that controller when you need to target iOS below 11. JavaScript must be enabled in order to work.
  ///In this case the [url] parameter is ignored.
  ///
  ///**NOTE for iOS below 11.0**: If [iosBelow11WebViewController] is `null` or JavaScript is disabled for it, it will try to use a [HeadlessInAppWebView]
  ///to delete the cookies (session-only cookies and cookies with `isHttpOnly` enabled won't be deleted!).
  Future<void> deleteCookies(
      {required Uri url,
      String path = "/",
      String? domain,
      InAppWebViewController? iosBelow11WebViewController}) async {
    assert(url.toString().isNotEmpty);

    if (await _shouldUseJavascript()) {
      List<Cookie> cookies = await _getCookiesWithJavaScript(
          url: url, webViewController: iosBelow11WebViewController);
      for (var i = 0; i < cookies.length; i++) {
        await _setCookieWithJavaScript(
            url: url,
            name: cookies[i].name,
            value: "",
            path: path,
            domain: domain,
            maxAge: -1,
            webViewController: iosBelow11WebViewController);
      }
      return;
    }

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('url', () => url.toString());
    args.putIfAbsent('domain', () => domain);
    args.putIfAbsent('path', () => path);
    await _channel.invokeMethod('deleteCookies', args);
  }

  ///Removes all cookies.
  ///
  ///**NOTE for iOS**: available from iOS 11.0+.
  Future<void> deleteAllCookies() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod('deleteAllCookies', args);
  }

  Future<String> _getCookieExpirationDate(int expiresDate) async {
    var platformUtil = PlatformUtil.instance();
    var dateTime = DateTime.fromMillisecondsSinceEpoch(expiresDate).toUtc();
    return await platformUtil.formatDate(
        date: dateTime,
        format: 'EEE, dd MMM yyyy hh:mm:ss z',
        locale: 'en_US',
        timezone: 'GMT');
  }

  Future<bool> _shouldUseJavascript() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final platformUtil = PlatformUtil.instance();
      final systemVersion = await platformUtil.getSystemVersion();
      return systemVersion.compareTo("11") == -1;
    }
    return false;
  }
}

///Class that contains only iOS-specific methods of [CookieManager].
class IOSCookieManager {
  static IOSCookieManager? _instance;

  IOSCookieManager._();

  ///Gets the [IOSCookieManager] shared instance.
  static IOSCookieManager instance() {
    return (_instance != null) ? _instance! : _init();
  }

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
    List<Cookie> cookies = [];

    Map<String, dynamic> args = <String, dynamic>{};
    List<dynamic> cookieListMap =
        await CookieManager._channel.invokeMethod('getAllCookies', args);
    cookieListMap = cookieListMap.cast<Map<dynamic, dynamic>>();

    cookieListMap.forEach((cookieMap) {
      cookies.add(Cookie(
          name: cookieMap["name"],
          value: cookieMap["value"],
          expiresDate: cookieMap["expiresDate"],
          isSessionOnly: cookieMap["isSessionOnly"],
          domain: cookieMap["domain"],
          sameSite: HTTPCookieSameSitePolicy.fromValue(cookieMap["sameSite"]),
          isSecure: cookieMap["isSecure"],
          isHttpOnly: cookieMap["isHttpOnly"],
          path: cookieMap["path"]));
    });
    return cookies;
  }
}
