// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cookie.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents a cookie returned by the [CookieManager].
class Cookie {
  ///The cookie name.
  String name;

  ///The cookie value.
  dynamic value;

  ///The cookie expiration date in milliseconds.
  ///
  ///**NOTE**: on Android it will be always `null`.
  int? expiresDate;

  ///Indicates if the cookie is a session only cookie.
  ///
  ///**NOTE**: on Android it will be always `null`.
  bool? isSessionOnly;

  ///The cookie domain.
  ///
  ///**NOTE**: on Android it will be always `null`.
  String? domain;

  ///The cookie same site policy.
  ///
  ///**NOTE**: on Android it will be always `null`.
  HTTPCookieSameSitePolicy? sameSite;

  ///Indicates if the cookie is secure or not.
  ///
  ///**NOTE**: on Android it will be always `null`.
  bool? isSecure;

  ///Indicates if the cookie is a http only cookie.
  ///
  ///**NOTE**: on Android it will be always `null`.
  bool? isHttpOnly;

  ///The cookie path.
  ///
  ///**NOTE**: on Android it will be always `null`.
  String? path;
  Cookie(
      {required this.name,
      this.value,
      this.expiresDate,
      this.isSessionOnly,
      this.domain,
      this.sameSite,
      this.isSecure,
      this.isHttpOnly,
      this.path});

  ///Gets a possible [Cookie] instance from a [Map] value.
  static Cookie? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = Cookie(
      name: map['name'],
      value: map['value'],
      expiresDate: map['expiresDate'],
      isSessionOnly: map['isSessionOnly'],
      domain: map['domain'],
      sameSite: HTTPCookieSameSitePolicy.fromNativeValue(map['sameSite']),
      isSecure: map['isSecure'],
      isHttpOnly: map['isHttpOnly'],
      path: map['path'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "value": value,
      "expiresDate": expiresDate,
      "isSessionOnly": isSessionOnly,
      "domain": domain,
      "sameSite": sameSite?.toNativeValue(),
      "isSecure": isSecure,
      "isHttpOnly": isHttpOnly,
      "path": path,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'Cookie{name: $name, value: $value, expiresDate: $expiresDate, isSessionOnly: $isSessionOnly, domain: $domain, sameSite: $sameSite, isSecure: $isSecure, isHttpOnly: $isHttpOnly, path: $path}';
  }
}
