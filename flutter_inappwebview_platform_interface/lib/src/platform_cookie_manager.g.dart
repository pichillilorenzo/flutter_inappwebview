// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_cookie_manager.dart';

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

extension _PlatformCookieManagerCreationParamsClassSupported
    on PlatformCookieManagerCreationParams {
  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManagerCreationParams.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- Linux WPE WebKit
  ///- macOS WKWebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  ///
  ///Use the [PlatformCookieManagerCreationParams.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return kIsWeb && platform == null
        ? true
        : ((kIsWeb && platform != null) || !kIsWeb) &&
              [
                TargetPlatform.android,
                TargetPlatform.iOS,
                TargetPlatform.linux,
                TargetPlatform.macOS,
                TargetPlatform.windows,
              ].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformCookieManagerCreationParams]'s properties that can be used to check i they are supported or not by the current platform.
enum PlatformCookieManagerCreationParamsProperty {
  ///Can be used to check if the [PlatformCookieManagerCreationParams.webViewEnvironment] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManagerCreationParams.webViewEnvironment.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  ///
  ///Use the [PlatformCookieManagerCreationParams.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  webViewEnvironment,
}

extension _PlatformCookieManagerCreationParamsPropertySupported
    on PlatformCookieManagerCreationParams {
  static bool isPropertySupported(
    PlatformCookieManagerCreationParamsProperty property, {
    TargetPlatform? platform,
  }) {
    switch (property) {
      case PlatformCookieManagerCreationParamsProperty.webViewEnvironment:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
    }
  }
}

extension _PlatformCookieManagerClassSupported on PlatformCookieManager {
  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView:
  ///    - It is implemented using [CookieManager](https://developer.android.com/reference/android/webkit/CookieManager).
  ///- iOS WKWebView:
  ///    - It is implemented using [WKHTTPCookieStore](https://developer.apple.com/documentation/webkit/wkhttpcookiestore). On iOS below 11.0, it is implemented using JavaScript. See https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies for JavaScript restrictions.
  ///- Linux WPE WebKit ([Official API - WebKitCookieManager](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/class.CookieManager.html)):
  ///    - It is implemented using WebKitCookieManager from WPE WebKit.
  ///- macOS WKWebView:
  ///    - It is implemented using [WKHTTPCookieStore](https://developer.apple.com/documentation/webkit/wkhttpcookiestore).
  ///- Web \<iframe\> but requires same origin:
  ///    - It is implemented using JavaScript. See https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies for JavaScript restrictions.
  ///- Windows WebView2
  ///
  ///Use the [PlatformCookieManager.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return kIsWeb && platform == null
        ? true
        : ((kIsWeb && platform != null) || !kIsWeb) &&
              [
                TargetPlatform.android,
                TargetPlatform.iOS,
                TargetPlatform.linux,
                TargetPlatform.macOS,
                TargetPlatform.windows,
              ].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformCookieManager]'s methods that can be used to check if they are supported or not by the current platform.
enum PlatformCookieManagerMethod {
  ///Can be used to check if the [PlatformCookieManager.deleteAllCookies] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.deleteAllCookies.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - CookieManager.removeAllCookies](https://developer.android.com/reference/android/webkit/CookieManager#removeAllCookies(android.webkit.ValueCallback%3Cjava.lang.Boolean%3E)))
  ///- iOS WKWebView 11.0+ ([Official API - WKWebsiteDataStore.removeData](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532938-removedata)):
  ///    - It will return always `true`.
  ///- macOS WKWebView 10.13+ ([Official API - WKWebsiteDataStore.removeData](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532938-removedata)):
  ///    - It will return always `true`.
  ///- Windows WebView2
  ///- Linux WPE WebKit ([Official API - webkit_website_data_manager_clear](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebsiteDataManager.clear.html)):
  ///    - Uses WebsiteDataManager to clear all cookie data.
  ///
  ///Use the [PlatformCookieManager.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  deleteAllCookies,

  ///Can be used to check if the [PlatformCookieManager.deleteCookie] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.deleteCookie.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - CookieManager.getCookie](https://developer.android.com/reference/android/webkit/CookieManager#getCookie(java.lang.String)))
  ///- iOS WKWebView ([Official API - WKHTTPCookieStore.delete](https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882009-delete)):
  ///    - On iOS below 11.0, the [webViewController] is used for deleting the cookie (also session-only cookie) using JavaScript (cookie with `isHttpOnly` enabled cannot be deleted, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies) from the current context of the `WebView` managed by that controller. JavaScript must be enabled in order to work. In this case the [url] parameter is ignored. If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [PlatformHeadlessInAppWebView] to delete the cookie (session-only cookie and cookie with `isHttpOnly` enabled won't be deleted!). In this case, this method will return always `true`.
  ///- macOS WKWebView ([Official API - WKHTTPCookieStore.delete](https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882009-delete)):
  ///    - On macOS below 10.13, the [webViewController] is used for deleting the cookie (also session-only cookie) using JavaScript (cookie with `isHttpOnly` enabled cannot be deleted, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies) from the current context of the `WebView` managed by that controller. JavaScript must be enabled in order to work. In this case the [url] parameter is ignored. If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [PlatformHeadlessInAppWebView] to delete the cookie (session-only cookie and cookie with `isHttpOnly` enabled won't be deleted!). In this case, this method will return always `true`.
  ///- Web \<iframe\> but requires same origin:
  ///    - The [webViewController] is used for deleting the cookie (also session-only cookie) using JavaScript (cookie with `isHttpOnly` enabled cannot be deleted, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies) from the current context of the `WebView` managed by that controller. JavaScript must be enabled in order to work. In this case the [url] parameter is ignored. If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [PlatformHeadlessInAppWebView] to delete the cookie (session-only cookie and cookie with `isHttpOnly` enabled won't be deleted!). In this case, this method will return always `true`.
  ///- Windows WebView2:
  ///    - The [webViewController] could be used to access cookies accessible only on the WebView managed by that controller, such as cookie with partition key.
  ///- Linux WPE WebKit ([Official API - webkit_cookie_manager_delete_cookie](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.CookieManager.delete_cookie.html))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [url]: all platforms
  ///- [name]: all platforms
  ///- [path]: all platforms
  ///- [domain]: all platforms
  ///- [webViewController]:
  ///    - macOS WKWebView
  ///    - iOS WKWebView
  ///    - Web \<iframe\> but requires same origin
  ///    - Windows WebView2
  ///
  ///Use the [PlatformCookieManager.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  deleteCookie,

  ///Can be used to check if the [PlatformCookieManager.deleteCookies] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.deleteCookies.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - CookieManager.getCookie](https://developer.android.com/reference/android/webkit/CookieManager#getCookie(java.lang.String)))
  ///- iOS WKWebView ([Official API - WKHTTPCookieStore.delete](https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882009-delete)):
  ///    - On iOS below 11.0, the [webViewController] is used for deleting the cookies (also session-only cookies) using JavaScript (cookies with `isHttpOnly` enabled cannot be deleted, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies) from the current context of the `WebView` managed by that controller. JavaScript must be enabled in order to work. In this case the [url] parameter is ignored. If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [PlatformHeadlessInAppWebView] to delete the cookies (session-only cookies and cookies with `isHttpOnly` enabled won't be deleted!). In this case, this method will return always `true`.
  ///- macOS WKWebView ([Official API - WKHTTPCookieStore.delete](https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882009-delete)):
  ///    - On macOS below 10.13, the [webViewController] is used for deleting the cookies (also session-only cookies) using JavaScript (cookies with `isHttpOnly` enabled cannot be deleted, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies) from the current context of the `WebView` managed by that controller. JavaScript must be enabled in order to work. In this case the [url] parameter is ignored. If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [PlatformHeadlessInAppWebView] to delete the cookies (session-only cookies and cookies with `isHttpOnly` enabled won't be deleted!). In this case, this method will return always `true`.
  ///- Web \<iframe\> but requires same origin:
  ///    - The [webViewController] is used for deleting the cookies (also session-only cookies) using JavaScript (cookies with `isHttpOnly` enabled cannot be deleted, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies) from the current context of the `WebView` managed by that controller. JavaScript must be enabled in order to work. In this case the [url] parameter is ignored. If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [PlatformHeadlessInAppWebView] to delete the cookies (session-only cookies and cookies with `isHttpOnly` enabled won't be deleted!). In this case, this method will return always `true`.
  ///- Windows WebView2:
  ///    - The [webViewController] could be used to access cookies accessible only on the WebView managed by that controller, such as cookie with partition key.
  ///- Linux WPE WebKit ([Official API - webkit_cookie_manager_delete_cookie](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.CookieManager.delete_cookie.html))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [url]: all platforms
  ///- [path]: all platforms
  ///- [domain]: all platforms
  ///- [webViewController]:
  ///    - macOS WKWebView
  ///    - iOS WKWebView
  ///    - Web \<iframe\> but requires same origin
  ///    - Windows WebView2
  ///
  ///Use the [PlatformCookieManager.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  deleteCookies,

  ///Can be used to check if the [PlatformCookieManager.flush] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.flush.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - CookieManager.flush](https://developer.android.com/reference/android/webkit/CookieManager#flush()))
  ///
  ///Use the [PlatformCookieManager.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  flush,

  ///Can be used to check if the [PlatformCookieManager.getAllCookies] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.getAllCookies.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 11.0+ ([Official API - WKHTTPCookieStore.getAllCookies](https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882005-getallcookies))
  ///- macOS WKWebView 10.13+ ([Official API - WKHTTPCookieStore.getAllCookies](https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882005-getallcookies))
  ///- Linux WPE WebKit ([Official API - webkit_cookie_manager_get_all_cookies](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.CookieManager.get_all_cookies.html))
  ///
  ///Use the [PlatformCookieManager.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getAllCookies,

  ///Can be used to check if the [PlatformCookieManager.getCookie] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.getCookie.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - CookieManager.getCookie](https://developer.android.com/reference/android/webkit/CookieManager#getCookie(java.lang.String)))
  ///- iOS WKWebView ([Official API - WKHTTPCookieStore.getAllCookies](https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882005-getallcookies)):
  ///    - On iOS below 11.0, the [webViewController] is used for getting the cookie (also session-only cookie) using JavaScript (cookie with `isHttpOnly` enabled cannot be found, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies) from the current context of the `WebView` managed by that controller. JavaScript must be enabled in order to work. In this case the [url] parameter is ignored. All the cookies returned this way will have all the properties to `null` except for [Cookie.name] and [Cookie.value]. If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [PlatformHeadlessInAppWebView] to get the cookie (session-only cookie and cookie with `isHttpOnly` enabled won't be found!).
  ///- macOS WKWebView ([Official API - WKHTTPCookieStore.getAllCookies](https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882005-getallcookies)):
  ///    - On macOS below 10.13, the [webViewController] is used for getting the cookie (also session-only cookie) using JavaScript (cookie with `isHttpOnly` enabled cannot be found, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies) from the current context of the `WebView` managed by that controller. JavaScript must be enabled in order to work. In this case the [url] parameter is ignored. All the cookies returned this way will have all the properties to `null` except for [Cookie.name] and [Cookie.value]. If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [PlatformHeadlessInAppWebView] to get the cookie (session-only cookie and cookie with `isHttpOnly` enabled won't be found!).
  ///- Web \<iframe\> but requires same origin:
  ///    - The [webViewController] is used for getting the cookie (also session-only cookie) using JavaScript (cookie with `isHttpOnly` enabled cannot be found, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies) from the current context of the `WebView` managed by that controller. JavaScript must be enabled in order to work. In this case the [url] parameter is ignored. If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [PlatformHeadlessInAppWebView] to get the cookie (session-only cookie and cookie with `isHttpOnly` enabled won't be found!).
  ///- Windows WebView2:
  ///    - The [webViewController] could be used to access cookies accessible only on the WebView managed by that controller, such as cookie with partition key.
  ///- Linux WPE WebKit ([Official API - webkit_cookie_manager_get_cookies](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.CookieManager.get_cookies.html))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [url]: all platforms
  ///- [name]: all platforms
  ///- [webViewController]:
  ///    - macOS WKWebView
  ///    - iOS WKWebView
  ///    - Web \<iframe\> but requires same origin
  ///    - Windows WebView2
  ///
  ///Use the [PlatformCookieManager.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getCookie,

  ///Can be used to check if the [PlatformCookieManager.getCookies] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.getCookies.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - CookieManager.getCookie](https://developer.android.com/reference/android/webkit/CookieManager#getCookie(java.lang.String)))
  ///- iOS WKWebView ([Official API - WKHTTPCookieStore.getAllCookies](https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882005-getallcookies)):
  ///    - On iOS below 11.0, the [webViewController] is used for getting the cookies (also session-only cookies) using JavaScript (cookies with `isHttpOnly` enabled cannot be found, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies) from the current context of the `WebView` managed by that controller. JavaScript must be enabled in order to work. In this case the [url] parameter is ignored. All the cookies returned this way will have all the properties to `null` except for [Cookie.name] and [Cookie.value]. If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [PlatformHeadlessInAppWebView] to get the cookies (session-only cookies and cookies with `isHttpOnly` enabled won't be found!).
  ///- macOS WKWebView ([Official API - WKHTTPCookieStore.getAllCookies](https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882005-getallcookies)):
  ///    - On macOS below 10.13, the [webViewController] is used for getting the cookies (also session-only cookies) using JavaScript (cookies with `isHttpOnly` enabled cannot be found, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies) from the current context of the `WebView` managed by that controller. JavaScript must be enabled in order to work. In this case the [url] parameter is ignored. All the cookies returned this way will have all the properties to `null` except for [Cookie.name] and [Cookie.value]. If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [PlatformHeadlessInAppWebView] to get the cookies (session-only cookies and cookies with `isHttpOnly` enabled won't be found!).
  ///- Web \<iframe\> but requires same origin:
  ///    - The [webViewController] is used for getting the cookies (also session-only cookies) using JavaScript (cookies with `isHttpOnly` enabled cannot be found, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies) from the current context of the `WebView` managed by that controller. JavaScript must be enabled in order to work. In this case the [url] parameter is ignored. If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [PlatformHeadlessInAppWebView] to get the cookies (session-only cookies and cookies with `isHttpOnly` enabled won't be found!).
  ///- Windows WebView2:
  ///    - The [webViewController] could be used to access cookies accessible only on the WebView managed by that controller, such as cookie with partition key.
  ///- Linux WPE WebKit ([Official API - webkit_cookie_manager_get_cookies](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.CookieManager.get_cookies.html))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [url]: all platforms
  ///- [webViewController]:
  ///    - macOS WKWebView
  ///    - iOS WKWebView
  ///    - Web \<iframe\> but requires same origin
  ///    - Windows WebView2
  ///
  ///Use the [PlatformCookieManager.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getCookies,

  ///Can be used to check if the [PlatformCookieManager.removeSessionCookies] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.removeSessionCookies.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - CookieManager.removeSessionCookies](https://developer.android.com/reference/android/webkit/CookieManager#removeSessionCookies(android.webkit.ValueCallback%3Cjava.lang.Boolean%3E)))
  ///
  ///Use the [PlatformCookieManager.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  removeSessionCookies,

  ///Can be used to check if the [PlatformCookieManager.setCookie] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformCookieManager.setCookie.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - CookieManager.setCookie](https://developer.android.com/reference/android/webkit/CookieManager#setCookie(java.lang.String,%20java.lang.String,%20android.webkit.ValueCallback%3Cjava.lang.Boolean%3E)))
  ///- iOS WKWebView ([Official API - WKHTTPCookieStore.setCookie](https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882007-setcookie)):
  ///    - On iOS below 11.0, the [webViewController] could be used if you need to set a session-only cookie using JavaScript (so [isHttpOnly] cannot be set, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies) on the current URL of the `WebView` managed by that controller. JavaScript must be enabled in order to work. If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [PlatformHeadlessInAppWebView] to set the cookie (session-only cookie won't work! In that case, you should set also [expiresDate] or [maxAge]). In this case, this method will return always `true`.
  ///- macOS WKWebView ([Official API - WKHTTPCookieStore.setCookie](https://developer.apple.com/documentation/webkit/wkhttpcookiestore/2882007-setcookie)):
  ///    - On macOS below 10.13, the [webViewController] could be used if you need to set a session-only cookie using JavaScript (so [isHttpOnly] cannot be set, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies) on the current URL of the `WebView` managed by that controller. JavaScript must be enabled in order to work. If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [PlatformHeadlessInAppWebView] to set the cookie (session-only cookie won't work! In that case, you should set also [expiresDate] or [maxAge]). In this case, this method will return always `true`.
  ///- Web \<iframe\> but requires same origin:
  ///    - The [webViewController] could be used if you need to set a session-only cookie using JavaScript (so [isHttpOnly] cannot be set, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies) on the current URL of the `WebView` managed by that controller. JavaScript must be enabled in order to work. If [webViewController] is `null` or JavaScript is disabled for it, it will try to use a [PlatformHeadlessInAppWebView] to set the cookie (session-only cookie won't work! In that case, you should set also [expiresDate] or [maxAge]). In this case, this method will return always `true`.
  ///- Windows WebView2:
  ///    - The [webViewController] could be used to access cookies accessible only on the WebView managed by that controller, such as cookie with partition key.
  ///- Linux WPE WebKit ([Official API - webkit_cookie_manager_add_cookie](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.CookieManager.add_cookie.html))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [url]: all platforms
  ///- [name]: all platforms
  ///- [value]: all platforms
  ///- [path]: all platforms
  ///- [domain]: all platforms
  ///- [expiresDate]: all platforms
  ///- [maxAge]: all platforms
  ///- [isSecure]: all platforms
  ///- [isHttpOnly]: all platforms
  ///- [sameSite]: all platforms
  ///- [webViewController]:
  ///    - macOS WKWebView
  ///    - iOS WKWebView
  ///    - Web \<iframe\> but requires same origin
  ///    - Windows WebView2
  ///
  ///Use the [PlatformCookieManager.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setCookie,
}

extension _PlatformCookieManagerMethodSupported on PlatformCookieManager {
  static bool isMethodSupported(
    PlatformCookieManagerMethod method, {
    TargetPlatform? platform,
  }) {
    switch (method) {
      case PlatformCookieManagerMethod.deleteAllCookies:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformCookieManagerMethod.deleteCookie:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformCookieManagerMethod.deleteCookies:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformCookieManagerMethod.flush:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformCookieManagerMethod.getAllCookies:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformCookieManagerMethod.getCookie:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformCookieManagerMethod.getCookies:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
      case PlatformCookieManagerMethod.removeSessionCookies:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformCookieManagerMethod.setCookie:
        return kIsWeb && platform == null
            ? true
            : ((kIsWeb && platform != null) || !kIsWeb) &&
                  [
                    TargetPlatform.android,
                    TargetPlatform.iOS,
                    TargetPlatform.macOS,
                    TargetPlatform.windows,
                    TargetPlatform.linux,
                  ].contains(platform ?? defaultTargetPlatform);
    }
  }
}
