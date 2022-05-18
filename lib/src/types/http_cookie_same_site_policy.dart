import 'cookie.dart';

///Class that represents the same site policy of a cookie. Used by the [Cookie] class.
class HTTPCookieSameSitePolicy {
  final String _value;

  const HTTPCookieSameSitePolicy._internal(this._value);

  ///Set of all values of [HTTPCookieSameSitePolicy].
  static final Set<HTTPCookieSameSitePolicy> values = [
    HTTPCookieSameSitePolicy.LAX,
    HTTPCookieSameSitePolicy.STRICT,
    HTTPCookieSameSitePolicy.NONE,
  ].toSet();

  ///Gets a possible [HTTPCookieSameSitePolicy] instance from a [String] value.
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

  ///Gets [String] value.
  String toValue() => _value;

  @override
  String toString() => _value;

  ///SameSite=Lax;
  ///
  ///Cookies are allowed to be sent with top-level navigations and will be sent along with GET
  ///request initiated by third party website. This is the default value in modern browsers.
  static const LAX = const HTTPCookieSameSitePolicy._internal("Lax");

  ///SameSite=Strict;
  ///
  ///Cookies will only be sent in a first-party context and not be sent along with requests initiated by third party websites.
  static const STRICT = const HTTPCookieSameSitePolicy._internal("Strict");

  ///SameSite=None;
  ///
  ///Cookies will be sent in all contexts, i.e sending cross-origin is allowed.
  ///`None` requires the `Secure` attribute in latest browser versions.
  static const NONE = const HTTPCookieSameSitePolicy._internal("None");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}