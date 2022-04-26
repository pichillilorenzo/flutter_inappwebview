import '../cookie_manager.dart';
import 'http_cookie_same_site_policy.dart';

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
        required this.value,
        this.expiresDate,
        this.isSessionOnly,
        this.domain,
        this.sameSite,
        this.isSecure,
        this.isHttpOnly,
        this.path});

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "value": value,
      "expiresDate": expiresDate,
      "isSessionOnly": isSessionOnly,
      "domain": domain,
      "sameSite": sameSite?.toValue(),
      "isSecure": isSecure,
      "isHttpOnly": isHttpOnly,
      "path": path
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}