import 'dart:async';

import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import 'in_app_webview/in_app_webview_controller.dart';
import 'in_app_webview/headless_in_app_webview.dart';

///Class that implements a singleton object (shared instance) which manages the cookies used by WebView instances.
///On Android, it is implemented using [CookieManager](https://developer.android.com/reference/android/webkit/CookieManager).
///On iOS, it is implemented using [WKHTTPCookieStore](https://developer.apple.com/documentation/webkit/wkhttpcookiestore).
///
///**NOTE for iOS below 11.0 and Web platform (LIMITED SUPPORT!)**: in this case, almost all of the methods
///([CookieManager.deleteAllCookies] and [CookieManager.getAllCookies] are not supported!)
///has been implemented using JavaScript because there is no other way to work with them on iOS below 11.0.
///See https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies for JavaScript restrictions.
///
///**Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- MacOS
///- Web
class CookieManager {
  /// Constructs a [CookieManager].
  ///
  /// See [CookieManager.fromPlatformCreationParams] for setting
  /// parameters for a specific platform.
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

  /// Implementation of [PlatformWebViewCookieManager] for the current platform.
  final PlatformCookieManager platform;

  ///Use [CookieManager] instead.
  @Deprecated("Use CookieManager instead")
  IOSCookieManager ios = IOSCookieManager.instance();

  static CookieManager? _instance;

  ///Gets the [CookieManager] shared instance.
  static CookieManager instance() {
    if (_instance == null) {
      _instance = CookieManager();
    }
    return _instance!;
  }

  ///Sets a cookie for the given [url]. Any existing cookie with the same [host], [path] and [name] will be replaced with the new cookie.
  ///The cookie being set will be ignored if it is expired.
  ///
  ///The default value of [path] is `"/"`.
  ///
  ///[webViewController] could be used if you need to set a session-only cookie using JavaScript (so [isHttpOnly] cannot be set, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies)
  ///on the current URL of the [WebView] managed by that controller when you need to target iOS below 11, MacOS below 10.13 and Web platform. In this case the [url] parameter is ignored.
  ///
  ///The return value indicates whether the cookie was set successfully.
  ///Note that it will return always `true` for Web platform, iOS below 11.0 and MacOS below 10.13.
  ///
  ///**NOTE for iOS below 11.0 and MacOS below 10.13**: If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [HeadlessInAppWebView]
  ///to set the cookie (session-only cookie won't work! In that case, you should set also [expiresDate] or [maxAge]).
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [HeadlessInAppWebView]
  ///to set the cookie (session-only cookie won't work! In that case, you should set also [expiresDate] or [maxAge]).
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - CookieManager.setCookie](https://developer.android.com/reference/android/webkit/CookieManager#setCookie(java.lang.String,%20java.lang.String,%20android.webkit.ValueCallback%3Cjava.lang.Boolean%3E)))
  ///- iOS ([Official API - WKHTTPCookieStore.setCookie](https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882007-setcookie))
  ///- MacOS ([Official API - WKHTTPCookieStore.setCookie](https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882007-setcookie))
  ///- Web
  Future<bool> setCookie(
          {required WebUri url,
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
          InAppWebViewController? webViewController}) =>
      platform.setCookie(
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
          webViewController: webViewController?.platform);

  ///Gets all the cookies for the given [url].
  ///
  ///[webViewController] is used for getting the cookies (also session-only cookies) using JavaScript (cookies with `isHttpOnly` enabled cannot be found, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies)
  ///from the current context of the [WebView] managed by that controller when you need to target iOS below 11, MacOS below 10.13 and Web platform. JavaScript must be enabled in order to work.
  ///In this case the [url] parameter is ignored.
  ///
  ///**NOTE for iOS below 11.0 and MacOS below 10.13**: All the cookies returned this way will have all the properties to `null` except for [Cookie.name] and [Cookie.value].
  ///If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [HeadlessInAppWebView]
  ///to get the cookies (session-only cookies and cookies with `isHttpOnly` enabled won't be found!).
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [HeadlessInAppWebView]
  ///to get the cookies (session-only cookies and cookies with `isHttpOnly` enabled won't be found!).
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - CookieManager.getCookie](https://developer.android.com/reference/android/webkit/CookieManager#getCookie(java.lang.String)))
  ///- iOS ([Official API - WKHTTPCookieStore.getAllCookies](https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882005-getallcookies))
  ///- MacOS ([Official API - WKHTTPCookieStore.getAllCookies](https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882005-getallcookies))
  ///- Web
  Future<List<Cookie>> getCookies(
          {required WebUri url,
          @Deprecated("Use webViewController instead")
          InAppWebViewController? iosBelow11WebViewController,
          InAppWebViewController? webViewController}) =>
      platform.getCookies(
          url: url,
          iosBelow11WebViewController: iosBelow11WebViewController?.platform,
          webViewController: webViewController?.platform);

  ///Gets a cookie by its [name] for the given [url].
  ///
  ///[webViewController] is used for getting the cookie (also session-only cookie) using JavaScript (cookie with `isHttpOnly` enabled cannot be found, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies)
  ///from the current context of the [WebView] managed by that controller when you need to target iOS below 11, MacOS below 10.13 and Web platform. JavaScript must be enabled in order to work.
  ///In this case the [url] parameter is ignored.
  ///
  ///**NOTE for iOS below 11.0 and MacOS below 10.13**: All the cookies returned this way will have all the properties to `null` except for [Cookie.name] and [Cookie.value].
  ///If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [HeadlessInAppWebView]
  ///to get the cookie (session-only cookie and cookie with `isHttpOnly` enabled won't be found!).
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [HeadlessInAppWebView]
  ///to get the cookie (session-only cookie and cookie with `isHttpOnly` enabled won't be found!).
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  Future<Cookie?> getCookie(
          {required WebUri url,
          required String name,
          @Deprecated("Use webViewController instead")
          InAppWebViewController? iosBelow11WebViewController,
          InAppWebViewController? webViewController}) =>
      platform.getCookie(
          url: url,
          name: name,
          iosBelow11WebViewController: iosBelow11WebViewController?.platform,
          webViewController: webViewController?.platform);

  ///Removes a cookie by its [name] for the given [url], [domain] and [path].
  ///
  ///The default value of [path] is `"/"`.
  ///
  ///[webViewController] is used for deleting the cookie (also session-only cookie) using JavaScript (cookie with `isHttpOnly` enabled cannot be deleted, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies)
  ///from the current context of the [WebView] managed by that controller when you need to target iOS below 11, MacOS below 10.13 and Web platform. JavaScript must be enabled in order to work.
  ///In this case the [url] parameter is ignored.
  ///
  ///**NOTE for iOS below 11.0 and MacOS below 10.13**: If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [HeadlessInAppWebView]
  ///to delete the cookie (session-only cookie and cookie with `isHttpOnly` enabled won't be deleted!).
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [HeadlessInAppWebView]
  ///to delete the cookie (session-only cookie and cookie with `isHttpOnly` enabled won't be deleted!).
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - WKHTTPCookieStore.delete](https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882009-delete)
  ///- MacOS ([Official API - WKHTTPCookieStore.delete](https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882009-delete)
  ///- Web
  Future<void> deleteCookie(
          {required WebUri url,
          required String name,
          String path = "/",
          String? domain,
          @Deprecated("Use webViewController instead")
          InAppWebViewController? iosBelow11WebViewController,
          InAppWebViewController? webViewController}) =>
      platform.deleteCookie(
          url: url,
          name: name,
          path: path,
          domain: domain,
          iosBelow11WebViewController: iosBelow11WebViewController?.platform,
          webViewController: webViewController?.platform);

  ///Removes all cookies for the given [url], [domain] and [path].
  ///
  ///The default value of [path] is `"/"`.
  ///
  ///[webViewController] is used for deleting the cookies (also session-only cookies) using JavaScript (cookies with `isHttpOnly` enabled cannot be deleted, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies)
  ///from the current context of the [WebView] managed by that controller when you need to target iOS below 11, MacOS below 10.13 and Web platform. JavaScript must be enabled in order to work.
  ///In this case the [url] parameter is ignored.
  ///
  ///**NOTE for iOS below 11.0 and MacOS below 10.13**: If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [HeadlessInAppWebView]
  ///to delete the cookies (session-only cookies and cookies with `isHttpOnly` enabled won't be deleted!).
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [HeadlessInAppWebView]
  ///to delete the cookies (session-only cookies and cookies with `isHttpOnly` enabled won't be deleted!).
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  Future<void> deleteCookies(
          {required WebUri url,
          String path = "/",
          String? domain,
          @Deprecated("Use webViewController instead")
          InAppWebViewController? iosBelow11WebViewController,
          InAppWebViewController? webViewController}) =>
      platform.deleteCookies(
          url: url,
          path: path,
          domain: domain,
          iosBelow11WebViewController: iosBelow11WebViewController?.platform,
          webViewController: webViewController?.platform);

  ///Removes all cookies.
  ///
  ///**NOTE for iOS**: available from iOS 11.0+.
  ///
  ///**NOTE for MacOS**: available from iOS 10.13+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - CookieManager.removeAllCookies](https://developer.android.com/reference/android/webkit/CookieManager#removeAllCookies(android.webkit.ValueCallback%3Cjava.lang.Boolean%3E)))
  ///- iOS ([Official API - WKWebsiteDataStore.removeData](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532938-removedata))
  ///- MacOS ([Official API - WKWebsiteDataStore.removeData](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532938-removedata))
  Future<void> deleteAllCookies() => platform.deleteAllCookies();

  ///Fetches all stored cookies.
  ///
  ///**NOTE for iOS**: available on iOS 11.0+.
  ///
  ///**NOTE for MacOS**: available from iOS 10.13+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKHTTPCookieStore.getAllCookies](https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882005-getallcookies))
  ///- MacOS ([Official API - WKHTTPCookieStore.getAllCookies](https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882005-getallcookies))
  Future<List<Cookie>> getAllCookies() => platform.getAllCookies();
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
