// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cookie.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents a cookie returned by the [PlatformCookieManager].
class Cookie {
  ///The cookie domain.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Android WebView:
  ///    - available on Android only if [WebViewFeature.GET_COOKIE_INFO] feature is supported.
  ///- Windows WebView2
  String? domain;

  ///The cookie expiration date in milliseconds.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Android WebView:
  ///    - available on Android only if [WebViewFeature.GET_COOKIE_INFO] feature is supported.
  ///- Windows WebView2
  int? expiresDate;

  ///Indicates if the cookie is a http only cookie.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Android WebView:
  ///    - available on Android only if [WebViewFeature.GET_COOKIE_INFO] feature is supported.
  ///- Windows WebView2
  bool? isHttpOnly;

  ///Indicates if the cookie is secure or not.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Android WebView:
  ///    - available on Android only if [WebViewFeature.GET_COOKIE_INFO] feature is supported.
  ///- Windows WebView2
  bool? isSecure;

  ///Indicates if the cookie is a session only cookie.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  bool? isSessionOnly;

  ///The cookie name.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Android WebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  String name;

  ///The cookie path.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Android WebView:
  ///    - available on Android only if [WebViewFeature.GET_COOKIE_INFO] feature is supported.
  ///- Windows WebView2
  String? path;

  ///The cookie same site policy.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Android WebView:
  ///    - available on Android only if [WebViewFeature.GET_COOKIE_INFO] feature is supported.
  ///- Windows WebView2
  HTTPCookieSameSitePolicy? sameSite;

  ///The cookie value.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Android WebView
  ///- Web \<iframe\> but requires same origin
  ///- Windows WebView2
  dynamic value;
  Cookie(
      {this.domain,
      this.expiresDate,
      this.isHttpOnly,
      this.isSecure,
      this.isSessionOnly,
      required this.name,
      this.path,
      this.sameSite,
      this.value});

  ///Gets a possible [Cookie] instance from a [Map] value.
  static Cookie? fromMap(Map<String, dynamic>? map, {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = Cookie(
      domain: map['domain'],
      expiresDate: map['expiresDate'],
      isHttpOnly: map['isHttpOnly'],
      isSecure: map['isSecure'],
      isSessionOnly: map['isSessionOnly'],
      name: map['name'],
      path: map['path'],
      sameSite: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          HTTPCookieSameSitePolicy.fromNativeValue(map['sameSite']),
        EnumMethod.value => HTTPCookieSameSitePolicy.fromValue(map['sameSite']),
        EnumMethod.name => HTTPCookieSameSitePolicy.byName(map['sameSite'])
      },
      value: map['value'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "domain": domain,
      "expiresDate": expiresDate,
      "isHttpOnly": isHttpOnly,
      "isSecure": isSecure,
      "isSessionOnly": isSessionOnly,
      "name": name,
      "path": path,
      "sameSite": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => sameSite?.toNativeValue(),
        EnumMethod.value => sameSite?.toValue(),
        EnumMethod.name => sameSite?.name()
      },
      "value": value,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'Cookie{domain: $domain, expiresDate: $expiresDate, isHttpOnly: $isHttpOnly, isSecure: $isSecure, isSessionOnly: $isSessionOnly, name: $name, path: $path, sameSite: $sameSite, value: $value}';
  }
}
