import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'in_app_webview/platform_inappwebview_controller.dart';
import 'types/main.dart';
import 'web_uri.dart';
import 'inappwebview_platform.dart';
import 'in_app_webview/platform_headless_in_app_webview.dart';
import 'webview_environment/platform_webview_environment.dart';

/// Object specifying creation parameters for creating a [PlatformCookieManager].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
@immutable
class PlatformCookieManagerCreationParams {
  /// Used by the platform implementation to create a new [PlatformCookieManager].
  const PlatformCookieManagerCreationParams({this.webViewEnvironment});

  ///Used to create the [PlatformCookieManager] using the specified environment.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows
  final PlatformWebViewEnvironment? webViewEnvironment;
}

///{@template flutter_inappwebview_platform_interface.PlatformCookieManager}
///Class that implements a singleton object (shared instance) which manages the cookies used by WebView instances.
///On Android, it is implemented using [CookieManager](https://developer.android.com/reference/android/webkit/CookieManager).
///On iOS, it is implemented using [WKHTTPCookieStore](https://developer.apple.com/documentation/webkit/wkhttpcookiestore).
///
///**NOTE for iOS below 11.0 and Web platform (LIMITED SUPPORT!)**: in this case, almost all of the methods ([PlatformCookieManager.deleteAllCookies] and [PlatformCookieManager.getAllCookies] are not supported!)
///has been implemented using JavaScript because there is no other way to work with them on iOS below 11.0.
///See https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies for JavaScript restrictions.
///
///**Officially Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- MacOS
///- Web
///- Windows
///{@endtemplate}
abstract class PlatformCookieManager extends PlatformInterface {
  /// Creates a new [PlatformCookieManager]
  factory PlatformCookieManager(PlatformCookieManagerCreationParams params) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`WebViewPlatform.instance` before use. For unit testing, '
      '`WebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformCookieManager cookieManager =
        InAppWebViewPlatform.instance!.createPlatformCookieManager(params);
    PlatformInterface.verify(cookieManager, _token);
    return cookieManager;
  }

  /// Used by the platform implementation to create a new
  /// [PlatformCookieManager].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformCookieManager.implementation(this.params) : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformCookieManager].
  final PlatformCookieManagerCreationParams params;

  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.setCookie}
  ///Sets a cookie for the given [url]. Any existing cookie with the same [host], [path] and [name] will be replaced with the new cookie.
  ///The cookie being set will be ignored if it is expired.
  ///
  ///The default value of [path] is `"/"`.
  ///
  ///On Windows, the [webViewController] could be used to access cookies accessible only on the WebView managed by that controller,
  ///such as cookie with partition key.
  ///
  ///When you need to target iOS below 11, MacOS below 10.13 and Web platform,
  ///[webViewController] could be used if you need to set a session-only cookie using JavaScript (so [isHttpOnly] cannot be set, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies)
  ///on the current URL of the `WebView` managed by that controller. JavaScript must be enabled in order to work.
  ///
  ///The return value indicates whether the cookie was set successfully.
  ///Note that it will return always `true` for Web platform, iOS below 11.0 and MacOS below 10.13.
  ///
  ///**NOTE for iOS below 11.0 and MacOS below 10.13**: If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [PlatformHeadlessInAppWebView]
  ///to set the cookie (session-only cookie won't work! In that case, you should set also [expiresDate] or [maxAge]).
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [PlatformHeadlessInAppWebView]
  ///to set the cookie (session-only cookie won't work! In that case, you should set also [expiresDate] or [maxAge]).
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - CookieManager.setCookie](https://developer.android.com/reference/android/webkit/CookieManager#setCookie(java.lang.String,%20java.lang.String,%20android.webkit.ValueCallback%3Cjava.lang.Boolean%3E)))
  ///- iOS ([Official API - WKHTTPCookieStore.setCookie](https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882007-setcookie))
  ///- MacOS ([Official API - WKHTTPCookieStore.setCookie](https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882007-setcookie))
  ///- Web
  ///- Windows
  ///{@endtemplate}
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
      PlatformInAppWebViewController? iosBelow11WebViewController,
      PlatformInAppWebViewController? webViewController}) {
    throw UnimplementedError(
        'setCookie is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.getCookies}
  ///Gets all the cookies for the given [url].
  ///
  ///On Windows, the [webViewController] could be used to access cookies accessible only on the WebView managed by that controller,
  ///such as cookie with partition key.
  ///
  ///When you need to target iOS below 11, MacOS below 10.13 and Web platform,
  ///[webViewController] is used for getting the cookies (also session-only cookies) using JavaScript (cookies with `isHttpOnly` enabled cannot be found, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies)
  ///from the current context of the `WebView` managed by that controller. JavaScript must be enabled in order to work.
  ///In this case the [url] parameter is ignored.
  ///
  ///**NOTE for iOS below 11.0 and MacOS below 10.13**: All the cookies returned this way will have all the properties to `null` except for [Cookie.name] and [Cookie.value].
  ///If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [PlatformHeadlessInAppWebView]
  ///to get the cookies (session-only cookies and cookies with `isHttpOnly` enabled won't be found!).
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [PlatformHeadlessInAppWebView]
  ///to get the cookies (session-only cookies and cookies with `isHttpOnly` enabled won't be found!).
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - CookieManager.getCookie](https://developer.android.com/reference/android/webkit/CookieManager#getCookie(java.lang.String)))
  ///- iOS ([Official API - WKHTTPCookieStore.getAllCookies](https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882005-getallcookies))
  ///- MacOS ([Official API - WKHTTPCookieStore.getAllCookies](https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882005-getallcookies))
  ///- Web
  ///- Windows
  ///{@endtemplate}
  Future<List<Cookie>> getCookies(
      {required WebUri url,
      @Deprecated("Use webViewController instead")
      PlatformInAppWebViewController? iosBelow11WebViewController,
      PlatformInAppWebViewController? webViewController}) {
    throw UnimplementedError(
        'getCookies is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.getCookie}
  ///Gets a cookie by its [name] for the given [url].
  ///
  ///On Windows, the [webViewController] could be used to access cookies accessible only on the WebView managed by that controller,
  ///such as cookie with partition key.
  ///
  ///When you need to target iOS below 11, MacOS below 10.13 and Web platform,
  ///[webViewController] is used for getting the cookie (also session-only cookie) using JavaScript (cookie with `isHttpOnly` enabled cannot be found, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies)
  ///from the current context of the `WebView` managed by that controller. JavaScript must be enabled in order to work.
  ///In this case the [url] parameter is ignored.
  ///
  ///**NOTE for iOS below 11.0 and MacOS below 10.13**: All the cookies returned this way will have all the properties to `null` except for [Cookie.name] and [Cookie.value].
  ///If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [PlatformHeadlessInAppWebView]
  ///to get the cookie (session-only cookie and cookie with `isHttpOnly` enabled won't be found!).
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [PlatformHeadlessInAppWebView]
  ///to get the cookie (session-only cookie and cookie with `isHttpOnly` enabled won't be found!).
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  ///- Windows
  ///{@endtemplate}
  Future<Cookie?> getCookie(
      {required WebUri url,
      required String name,
      @Deprecated("Use webViewController instead")
      PlatformInAppWebViewController? iosBelow11WebViewController,
      PlatformInAppWebViewController? webViewController}) {
    throw UnimplementedError(
        'getCookie is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.deleteCookie}
  ///Removes a cookie by its [name] for the given [url], [domain] and [path].
  ///
  ///The default value of [path] is `"/"`.
  ///
  ///On Windows, the [webViewController] could be used to access cookies accessible only on the WebView managed by that controller,
  ///such as cookie with partition key.
  ///
  ///When you need to target iOS below 11, MacOS below 10.13 and Web platform,
  ///[webViewController] is used for deleting the cookie (also session-only cookie) using JavaScript (cookie with `isHttpOnly` enabled cannot be deleted, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies)
  ///from the current context of the `WebView` managed by that controller. JavaScript must be enabled in order to work.
  ///In this case the [url] parameter is ignored.
  ///
  ///The return value indicates whether the cookie was deleted successfully.
  ///Note that it will return always `true` for Web platform, iOS below 11.0 and MacOS below 10.13.
  ///
  ///**NOTE for iOS below 11.0 and MacOS below 10.13**: If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [PlatformHeadlessInAppWebView]
  ///to delete the cookie (session-only cookie and cookie with `isHttpOnly` enabled won't be deleted!).
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [PlatformHeadlessInAppWebView]
  ///to delete the cookie (session-only cookie and cookie with `isHttpOnly` enabled won't be deleted!).
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - WKHTTPCookieStore.delete](https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882009-delete)
  ///- MacOS ([Official API - WKHTTPCookieStore.delete](https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882009-delete)
  ///- Web
  ///- Windows
  ///{@endtemplate}
  Future<bool> deleteCookie(
      {required WebUri url,
      required String name,
      String path = "/",
      String? domain,
      @Deprecated("Use webViewController instead")
      PlatformInAppWebViewController? iosBelow11WebViewController,
      PlatformInAppWebViewController? webViewController}) {
    throw UnimplementedError(
        'deleteCookie is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.deleteCookies}
  ///Removes all cookies for the given [url], [domain] and [path].
  ///
  ///The default value of [path] is `"/"`.
  ///
  ///On Windows, the [webViewController] could be used to access cookies accessible only on the WebView managed by that controller,
  ///such as cookie with partition key.
  ///
  ///When you need to target iOS below 11, MacOS below 10.13 and Web platform,
  ///[webViewController] is used for deleting the cookies (also session-only cookies) using JavaScript (cookies with `isHttpOnly` enabled cannot be deleted, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies)
  ///from the current context of the `WebView` managed by that controller. JavaScript must be enabled in order to work.
  ///In this case the [url] parameter is ignored.
  ///
  ///The return value indicates whether cookies were deleted successfully.
  ///Note that it will return always `true` for Web platform, iOS below 11.0 and MacOS below 10.13.
  ///
  ///**NOTE for iOS below 11.0 and MacOS below 10.13**: If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [PlatformHeadlessInAppWebView]
  ///to delete the cookies (session-only cookies and cookies with `isHttpOnly` enabled won't be deleted!).
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [PlatformHeadlessInAppWebView]
  ///to delete the cookies (session-only cookies and cookies with `isHttpOnly` enabled won't be deleted!).
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  ///- Windows
  ///{@endtemplate}
  Future<bool> deleteCookies(
      {required WebUri url,
      String path = "/",
      String? domain,
      @Deprecated("Use webViewController instead")
      PlatformInAppWebViewController? iosBelow11WebViewController,
      PlatformInAppWebViewController? webViewController}) {
    throw UnimplementedError(
        'deleteCookies is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.deleteAllCookies}
  ///Removes all cookies.
  ///
  ///The return value indicates whether any cookies were removed.
  ///Note that it will return always `true` for Web, iOS and MacOS platforms.
  ///
  ///**NOTE for iOS**: available from iOS 11.0+.
  ///
  ///**NOTE for MacOS**: available from iOS 10.13+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - CookieManager.removeAllCookies](https://developer.android.com/reference/android/webkit/CookieManager#removeAllCookies(android.webkit.ValueCallback%3Cjava.lang.Boolean%3E)))
  ///- iOS ([Official API - WKWebsiteDataStore.removeData](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532938-removedata))
  ///- MacOS ([Official API - WKWebsiteDataStore.removeData](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532938-removedata))
  ///- Windows
  ///{@endtemplate}
  Future<bool> deleteAllCookies() {
    throw UnimplementedError(
        'deleteAllCookies is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.getAllCookies}
  ///Fetches all stored cookies.
  ///
  ///**NOTE for iOS**: available on iOS 11.0+.
  ///
  ///**NOTE for MacOS**: available from iOS 10.13+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKHTTPCookieStore.getAllCookies](https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882005-getallcookies))
  ///- MacOS ([Official API - WKHTTPCookieStore.getAllCookies](https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882005-getallcookies))
  ///{@endtemplate}
  Future<List<Cookie>> getAllCookies() {
    throw UnimplementedError(
        'getAllCookies is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.removeSessionCookies}
  ///Removes all session cookies, which are cookies without an expiration date.
  ///
  ///The return value indicates whether any cookies were removed.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - CookieManager.removeSessionCookies](https://developer.android.com/reference/android/webkit/CookieManager#removeSessionCookies(android.webkit.ValueCallback%3Cjava.lang.Boolean%3E)))
  ///{@endtemplate}
  Future<bool> removeSessionCookies() {
    throw UnimplementedError(
        'removeSessionCookies is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.flush}
  ///Ensures all cookies currently accessible through the getCookie API are written to persistent storage.
  ///This call will block the caller until it is done and may perform I/O.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - CookieManager.flush](https://developer.android.com/reference/android/webkit/CookieManager#flush()))
  ///{@endtemplate}
  Future<void> flush() {
    throw UnimplementedError(
        'flush is not implemented on the current platform');
  }
}
