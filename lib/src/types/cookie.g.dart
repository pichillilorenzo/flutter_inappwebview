// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cookie.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents a cookie returned by the [CookieManager].
class Cookie {
  ///The cookie domain.
  ///
  ///**NOTE**: on Android it will be always `null`.
  String? domain;

  ///The cookie expiration date in milliseconds.
  ///
  ///**NOTE**: on Android it will be always `null`.
  int? expiresDate;

  ///Indicates if the cookie is a http only cookie.
  ///
  ///**NOTE**: on Android it will be always `null`.
  bool? isHttpOnly;

  ///Indicates if the cookie is secure or not.
  ///
  ///**NOTE**: on Android it will be always `null`.
  bool? isSecure;

  ///Indicates if the cookie is a session only cookie.
  ///
  ///**NOTE**: on Android it will be always `null`.
  bool? isSessionOnly;

  ///The cookie name.
  String name;

  ///The cookie path.
  ///
  ///**NOTE**: on Android it will be always `null`.
  String? path;

  ///The cookie same site policy.
  ///
  ///**NOTE**: on Android it will be always `null`.
  HTTPCookieSameSitePolicy? sameSite;

  ///The cookie value.
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
  static Cookie? fromMap(Map<String, dynamic>? map) {
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
      sameSite: HTTPCookieSameSitePolicy.fromNativeValue(map['sameSite']),
      value: map['value'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "domain": domain,
      "expiresDate": expiresDate,
      "isHttpOnly": isHttpOnly,
      "isSecure": isSecure,
      "isSessionOnly": isSessionOnly,
      "name": name,
      "path": path,
      "sameSite": sameSite?.toNativeValue(),
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
