// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'http_cookie_same_site_policy.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the same site policy of a cookie. Used by the [Cookie] class.
class HTTPCookieSameSitePolicy {
  final String _value;
  final String _nativeValue;
  const HTTPCookieSameSitePolicy._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory HTTPCookieSameSitePolicy._internalMultiPlatform(
          String value, Function nativeValue) =>
      HTTPCookieSameSitePolicy._internal(value, nativeValue());

  ///SameSite=Lax;
  ///
  ///Cookies are allowed to be sent with top-level navigations and will be sent along with GET
  ///request initiated by third party website. This is the default value in modern browsers.
  static const LAX = HTTPCookieSameSitePolicy._internal('Lax', 'Lax');

  ///SameSite=None;
  ///
  ///Cookies will be sent in all contexts, i.e sending cross-origin is allowed.
  ///`None` requires the `Secure` attribute in latest browser versions.
  static const NONE = HTTPCookieSameSitePolicy._internal('None', 'None');

  ///SameSite=Strict;
  ///
  ///Cookies will only be sent in a first-party context and not be sent along with requests initiated by third party websites.
  static const STRICT = HTTPCookieSameSitePolicy._internal('Strict', 'Strict');

  ///Set of all values of [HTTPCookieSameSitePolicy].
  static final Set<HTTPCookieSameSitePolicy> values = [
    HTTPCookieSameSitePolicy.LAX,
    HTTPCookieSameSitePolicy.NONE,
    HTTPCookieSameSitePolicy.STRICT,
  ].toSet();

  ///Gets a possible [HTTPCookieSameSitePolicy] instance from [String] value.
  static HTTPCookieSameSitePolicy? fromValue(String? value) {
    if (value != null) {
      try {
        return HTTPCookieSameSitePolicy.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [HTTPCookieSameSitePolicy] instance from a native value.
  static HTTPCookieSameSitePolicy? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return HTTPCookieSameSitePolicy.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value.
  String toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    return _value;
  }
}
