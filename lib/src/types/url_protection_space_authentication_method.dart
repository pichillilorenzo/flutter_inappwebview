import 'url_protection_space.dart';

///Class that represents the constants describing known values of the [URLProtectionSpace.authenticationMethod] property.
class URLProtectionSpaceAuthenticationMethod {
  final String _value;

  const URLProtectionSpaceAuthenticationMethod._internal(this._value);

  ///Set of all values of [URLProtectionSpaceAuthenticationMethod].
  static final Set<URLProtectionSpaceAuthenticationMethod> values = [
    URLProtectionSpaceAuthenticationMethod
        .NSURL_AUTHENTICATION_METHOD_CLIENT_CERTIFICATE,
    URLProtectionSpaceAuthenticationMethod
        .NSURL_AUTHENTICATION_METHOD_NEGOTIATE,
    URLProtectionSpaceAuthenticationMethod.NSURL_AUTHENTICATION_METHOD_NTLM,
    URLProtectionSpaceAuthenticationMethod
        .NSURL_AUTHENTICATION_METHOD_SERVER_TRUST,
  ].toSet();

  ///Gets a possible [URLProtectionSpaceAuthenticationMethod] instance from a [String] value.
  static URLProtectionSpaceAuthenticationMethod? fromValue(String? value) {
    if (value != null) {
      try {
        return URLProtectionSpaceAuthenticationMethod.values
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

  ///Use client certificate authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_CLIENT_CERTIFICATE =
  const URLProtectionSpaceAuthenticationMethod._internal(
      "NSURLAuthenticationMethodClientCertificate");

  ///Negotiate whether to use Kerberos or NTLM authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_NEGOTIATE =
  const URLProtectionSpaceAuthenticationMethod._internal(
      "NSURLAuthenticationMethodNegotiate");

  ///Use NTLM authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_NTLM =
  const URLProtectionSpaceAuthenticationMethod._internal(
      "NSURLAuthenticationMethodNTLM");

  ///Perform server trust authentication (certificate validation) for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_SERVER_TRUST =
  const URLProtectionSpaceAuthenticationMethod._internal(
      "NSURLAuthenticationMethodServerTrust");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///An iOS-specific Class that represents the constants describing known values of the [URLProtectionSpace.authenticationMethod] property.
///Use [URLProtectionSpaceAuthenticationMethod] instead.
@Deprecated("Use URLProtectionSpaceAuthenticationMethod instead")
class IOSNSURLProtectionSpaceAuthenticationMethod {
  final String _value;

  const IOSNSURLProtectionSpaceAuthenticationMethod._internal(this._value);

  ///Set of all values of [IOSNSURLProtectionSpaceAuthenticationMethod].
  static final Set<IOSNSURLProtectionSpaceAuthenticationMethod> values = [
    IOSNSURLProtectionSpaceAuthenticationMethod
        .NSURL_AUTHENTICATION_METHOD_CLIENT_CERTIFICATE,
    IOSNSURLProtectionSpaceAuthenticationMethod
        .NSURL_AUTHENTICATION_METHOD_NEGOTIATE,
    IOSNSURLProtectionSpaceAuthenticationMethod
        .NSURL_AUTHENTICATION_METHOD_NTLM,
    IOSNSURLProtectionSpaceAuthenticationMethod
        .NSURL_AUTHENTICATION_METHOD_SERVER_TRUST,
  ].toSet();

  ///Gets a possible [IOSNSURLProtectionSpaceAuthenticationMethod] instance from a [String] value.
  static IOSNSURLProtectionSpaceAuthenticationMethod? fromValue(String? value) {
    if (value != null) {
      try {
        return IOSNSURLProtectionSpaceAuthenticationMethod.values
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

  ///Use client certificate authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_CLIENT_CERTIFICATE =
  const IOSNSURLProtectionSpaceAuthenticationMethod._internal(
      "NSURLAuthenticationMethodClientCertificate");

  ///Negotiate whether to use Kerberos or NTLM authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_NEGOTIATE =
  const IOSNSURLProtectionSpaceAuthenticationMethod._internal(
      "NSURLAuthenticationMethodNegotiate");

  ///Use NTLM authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_NTLM =
  const IOSNSURLProtectionSpaceAuthenticationMethod._internal(
      "NSURLAuthenticationMethodNTLM");

  ///Perform server trust authentication (certificate validation) for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_SERVER_TRUST =
  const IOSNSURLProtectionSpaceAuthenticationMethod._internal(
      "NSURLAuthenticationMethodServerTrust");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}