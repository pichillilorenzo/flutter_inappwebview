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

  /// Gets a possible [URLProtectionSpaceProxyType] instance value with name [name].
  ///
  /// Goes through [URLProtectionSpaceProxyType.values] looking for a value with
  /// name [name], as reported by [URLProtectionSpaceProxyType.name].
  /// Returns the first value with the given name, otherwise `null`.
  static URLProtectionSpaceProxyType? byName(String? name) {
    if (name != null) {
      try {
        return URLProtectionSpaceProxyType.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [URLProtectionSpaceProxyType] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, URLProtectionSpaceProxyType> asNameMap() =>
      <String, URLProtectionSpaceProxyType>{
        for (final value in URLProtectionSpaceProxyType.values)
          value.name(): value
      };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value.
  String toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'NSURLProtectionSpaceFTPProxy':
        return 'URL_PROTECTION_SPACE_FTP_PROXY';
      case 'NSURLProtectionSpaceHTTPSProxy':
        return 'URL_PROTECTION_SPACE_HTTPS_PROXY';
      case 'NSURLProtectionSpaceHTTPProxy':
        return 'URL_PROTECTION_SPACE_HTTP_PROXY';
      case 'NSURLProtectionSpaceSOCKSProxy':
        return 'URL_PROTECTION_SPACE_SOCKS_PROXY';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  ///Checks if the value is supported by the [defaultTargetPlatform].
  bool isSupported() {
    return true;
  }

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

  /// Gets a possible [IOSNSURLProtectionSpaceProxyType] instance value with name [name].
  ///
  /// Goes through [IOSNSURLProtectionSpaceProxyType.values] looking for a value with
  /// name [name], as reported by [IOSNSURLProtectionSpaceProxyType.name].
  /// Returns the first value with the given name, otherwise `null`.
  static IOSNSURLProtectionSpaceProxyType? byName(String? name) {
    if (name != null) {
      try {
        return IOSNSURLProtectionSpaceProxyType.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [IOSNSURLProtectionSpaceProxyType] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, IOSNSURLProtectionSpaceProxyType> asNameMap() =>
      <String, IOSNSURLProtectionSpaceProxyType>{
        for (final value in IOSNSURLProtectionSpaceProxyType.values)
          value.name(): value
      };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value.
  String toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'NSURLProtectionSpaceFTPProxy':
        return 'NSURL_PROTECTION_SPACE_FTP_PROXY';
      case 'NSURLProtectionSpaceHTTPSProxy':
        return 'NSURL_PROTECTION_SPACE_HTTPS_PROXY';
      case 'NSURLProtectionSpaceSOCKSProxy':
        return 'NSURL_PROTECTION_SPACE_SOCKS_PROXY';
      case 'NSURLProtectionSpaceHTTPProxy':
        return 'NSUR_PROTECTION_SPACE_HTTP_PROXY';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  ///Checks if the value is supported by the [defaultTargetPlatform].
  bool isSupported() {
    return true;
  }

  @override
  String toString() {
    return _value;
  }
}
