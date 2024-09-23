// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'url_protection_space_authentication_method.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the constants describing known values of the [URLProtectionSpace.authenticationMethod] property.
class URLProtectionSpaceAuthenticationMethod {
  final String _value;
  final String _nativeValue;
  const URLProtectionSpaceAuthenticationMethod._internal(
      this._value, this._nativeValue);
// ignore: unused_element
  factory URLProtectionSpaceAuthenticationMethod._internalMultiPlatform(
          String value, Function nativeValue) =>
      URLProtectionSpaceAuthenticationMethod._internal(value, nativeValue());

  ///Use client certificate authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_CLIENT_CERTIFICATE =
      URLProtectionSpaceAuthenticationMethod._internal(
          'NSURLAuthenticationMethodClientCertificate',
          'NSURLAuthenticationMethodClientCertificate');

  ///Negotiate whether to use Kerberos or NTLM authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_NEGOTIATE =
      URLProtectionSpaceAuthenticationMethod._internal(
          'NSURLAuthenticationMethodNegotiate',
          'NSURLAuthenticationMethodNegotiate');

  ///Use NTLM authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_NTLM =
      URLProtectionSpaceAuthenticationMethod._internal(
          'NSURLAuthenticationMethodNTLM', 'NSURLAuthenticationMethodNTLM');

  ///Perform server trust authentication (certificate validation) for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_SERVER_TRUST =
      URLProtectionSpaceAuthenticationMethod._internal(
          'NSURLAuthenticationMethodServerTrust',
          'NSURLAuthenticationMethodServerTrust');

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

  ///Gets a possible [URLProtectionSpaceAuthenticationMethod] instance from [String] value.
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

  ///Gets a possible [URLProtectionSpaceAuthenticationMethod] instance from a native value.
  static URLProtectionSpaceAuthenticationMethod? fromNativeValue(
      String? value) {
    if (value != null) {
      try {
        return URLProtectionSpaceAuthenticationMethod.values
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

///An iOS-specific Class that represents the constants describing known values of the [URLProtectionSpace.authenticationMethod] property.
///Use [URLProtectionSpaceAuthenticationMethod] instead.
@Deprecated('Use URLProtectionSpaceAuthenticationMethod instead')
class IOSNSURLProtectionSpaceAuthenticationMethod {
  final String _value;
  final String _nativeValue;
  const IOSNSURLProtectionSpaceAuthenticationMethod._internal(
      this._value, this._nativeValue);
// ignore: unused_element
  factory IOSNSURLProtectionSpaceAuthenticationMethod._internalMultiPlatform(
          String value, Function nativeValue) =>
      IOSNSURLProtectionSpaceAuthenticationMethod._internal(
          value, nativeValue());

  ///Use client certificate authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_CLIENT_CERTIFICATE =
      IOSNSURLProtectionSpaceAuthenticationMethod._internal(
          'NSURLAuthenticationMethodClientCertificate',
          'NSURLAuthenticationMethodClientCertificate');

  ///Negotiate whether to use Kerberos or NTLM authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_NEGOTIATE =
      IOSNSURLProtectionSpaceAuthenticationMethod._internal(
          'NSURLAuthenticationMethodNegotiate',
          'NSURLAuthenticationMethodNegotiate');

  ///Use NTLM authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_NTLM =
      IOSNSURLProtectionSpaceAuthenticationMethod._internal(
          'NSURLAuthenticationMethodNTLM', 'NSURLAuthenticationMethodNTLM');

  ///Perform server trust authentication (certificate validation) for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_SERVER_TRUST =
      IOSNSURLProtectionSpaceAuthenticationMethod._internal(
          'NSURLAuthenticationMethodServerTrust',
          'NSURLAuthenticationMethodServerTrust');

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

  ///Gets a possible [IOSNSURLProtectionSpaceAuthenticationMethod] instance from [String] value.
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

  ///Gets a possible [IOSNSURLProtectionSpaceAuthenticationMethod] instance from a native value.
  static IOSNSURLProtectionSpaceAuthenticationMethod? fromNativeValue(
      String? value) {
    if (value != null) {
      try {
        return IOSNSURLProtectionSpaceAuthenticationMethod.values
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
