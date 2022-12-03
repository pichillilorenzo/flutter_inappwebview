// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'url_protection_space_proxy_type.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the supported proxy types.
class URLProtectionSpaceProxyType {
  final String _value;
  final String _nativeValue;
  const URLProtectionSpaceProxyType._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory URLProtectionSpaceProxyType._internalMultiPlatform(
          String value, Function nativeValue) =>
      URLProtectionSpaceProxyType._internal(value, nativeValue());

  ///The proxy type for FTP proxies.
  static const URL_PROTECTION_SPACE_FTP_PROXY =
      URLProtectionSpaceProxyType._internal(
          'NSURLProtectionSpaceFTPProxy', 'NSURLProtectionSpaceFTPProxy');

  ///The proxy type for HTTPS proxies.
  static const URL_PROTECTION_SPACE_HTTPS_PROXY =
      URLProtectionSpaceProxyType._internal(
          'NSURLProtectionSpaceHTTPSProxy', 'NSURLProtectionSpaceHTTPSProxy');

  ///The proxy type for HTTP proxies.
  static const URL_PROTECTION_SPACE_HTTP_PROXY =
      URLProtectionSpaceProxyType._internal(
          'NSURLProtectionSpaceHTTPProxy', 'NSURLProtectionSpaceHTTPProxy');

  ///The proxy type for SOCKS proxies.
  static const URL_PROTECTION_SPACE_SOCKS_PROXY =
      URLProtectionSpaceProxyType._internal(
          'NSURLProtectionSpaceSOCKSProxy', 'NSURLProtectionSpaceSOCKSProxy');

  ///Set of all values of [URLProtectionSpaceProxyType].
  static final Set<URLProtectionSpaceProxyType> values = [
    URLProtectionSpaceProxyType.URL_PROTECTION_SPACE_FTP_PROXY,
    URLProtectionSpaceProxyType.URL_PROTECTION_SPACE_HTTPS_PROXY,
    URLProtectionSpaceProxyType.URL_PROTECTION_SPACE_HTTP_PROXY,
    URLProtectionSpaceProxyType.URL_PROTECTION_SPACE_SOCKS_PROXY,
  ].toSet();

  ///Gets a possible [URLProtectionSpaceProxyType] instance from [String] value.
  static URLProtectionSpaceProxyType? fromValue(String? value) {
    if (value != null) {
      try {
        return URLProtectionSpaceProxyType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [URLProtectionSpaceProxyType] instance from a native value.
  static URLProtectionSpaceProxyType? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return URLProtectionSpaceProxyType.values
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

///An iOS-specific Class that represents the supported proxy types.
///Use [URLProtectionSpaceProxyType] instead.
@Deprecated('Use URLProtectionSpaceProxyType instead')
class IOSNSURLProtectionSpaceProxyType {
  final String _value;
  final String _nativeValue;
  const IOSNSURLProtectionSpaceProxyType._internal(
      this._value, this._nativeValue);
// ignore: unused_element
  factory IOSNSURLProtectionSpaceProxyType._internalMultiPlatform(
          String value, Function nativeValue) =>
      IOSNSURLProtectionSpaceProxyType._internal(value, nativeValue());

  ///The proxy type for FTP proxies.
  static const NSURL_PROTECTION_SPACE_FTP_PROXY =
      IOSNSURLProtectionSpaceProxyType._internal(
          'NSURLProtectionSpaceFTPProxy', 'NSURLProtectionSpaceFTPProxy');

  ///The proxy type for HTTPS proxies.
  static const NSURL_PROTECTION_SPACE_HTTPS_PROXY =
      IOSNSURLProtectionSpaceProxyType._internal(
          'NSURLProtectionSpaceHTTPSProxy', 'NSURLProtectionSpaceHTTPSProxy');

  ///The proxy type for SOCKS proxies.
  static const NSURL_PROTECTION_SPACE_SOCKS_PROXY =
      IOSNSURLProtectionSpaceProxyType._internal(
          'NSURLProtectionSpaceSOCKSProxy', 'NSURLProtectionSpaceSOCKSProxy');

  ///The proxy type for HTTP proxies.
  static const NSUR_PROTECTION_SPACE_HTTP_PROXY =
      IOSNSURLProtectionSpaceProxyType._internal(
          'NSURLProtectionSpaceHTTPProxy', 'NSURLProtectionSpaceHTTPProxy');

  ///Set of all values of [IOSNSURLProtectionSpaceProxyType].
  static final Set<IOSNSURLProtectionSpaceProxyType> values = [
    IOSNSURLProtectionSpaceProxyType.NSURL_PROTECTION_SPACE_FTP_PROXY,
    IOSNSURLProtectionSpaceProxyType.NSURL_PROTECTION_SPACE_HTTPS_PROXY,
    IOSNSURLProtectionSpaceProxyType.NSURL_PROTECTION_SPACE_SOCKS_PROXY,
    IOSNSURLProtectionSpaceProxyType.NSUR_PROTECTION_SPACE_HTTP_PROXY,
  ].toSet();

  ///Gets a possible [IOSNSURLProtectionSpaceProxyType] instance from [String] value.
  static IOSNSURLProtectionSpaceProxyType? fromValue(String? value) {
    if (value != null) {
      try {
        return IOSNSURLProtectionSpaceProxyType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [IOSNSURLProtectionSpaceProxyType] instance from a native value.
  static IOSNSURLProtectionSpaceProxyType? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return IOSNSURLProtectionSpaceProxyType.values
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
