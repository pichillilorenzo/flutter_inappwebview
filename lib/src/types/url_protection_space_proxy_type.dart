///Class that represents the supported proxy types.
class URLProtectionSpaceProxyType {
  final String _value;

  const URLProtectionSpaceProxyType._internal(this._value);

  ///Set of all values of [URLProtectionSpaceProxyType].
  static final Set<URLProtectionSpaceProxyType> values = [
    URLProtectionSpaceProxyType.NSUR_PROTECTION_SPACE_HTTP_PROXY,
    URLProtectionSpaceProxyType.NSURL_PROTECTION_SPACE_HTTPS_PROXY,
    URLProtectionSpaceProxyType.NSURL_PROTECTION_SPACE_FTP_PROXY,
    URLProtectionSpaceProxyType.NSURL_PROTECTION_SPACE_SOCKS_PROXY,
  ].toSet();

  ///Gets a possible [URLProtectionSpaceProxyType] instance from a [String] value.
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

  ///Gets [String] value.
  String toValue() => _value;

  @override
  String toString() => _value;

  ///The proxy type for HTTP proxies.
  static const NSUR_PROTECTION_SPACE_HTTP_PROXY =
  const URLProtectionSpaceProxyType._internal(
      "NSURLProtectionSpaceHTTPProxy");

  ///The proxy type for HTTPS proxies.
  static const NSURL_PROTECTION_SPACE_HTTPS_PROXY =
  const URLProtectionSpaceProxyType._internal(
      "NSURLProtectionSpaceHTTPSProxy");

  ///The proxy type for FTP proxies.
  static const NSURL_PROTECTION_SPACE_FTP_PROXY =
  const URLProtectionSpaceProxyType._internal(
      "NSURLProtectionSpaceFTPProxy");

  ///The proxy type for SOCKS proxies.
  static const NSURL_PROTECTION_SPACE_SOCKS_PROXY =
  const URLProtectionSpaceProxyType._internal(
      "NSURLProtectionSpaceSOCKSProxy");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///An iOS-specific Class that represents the supported proxy types.
///Use [URLProtectionSpaceProxyType] instead.
@Deprecated("Use URLProtectionSpaceProxyType instead")
class IOSNSURLProtectionSpaceProxyType {
  final String _value;

  const IOSNSURLProtectionSpaceProxyType._internal(this._value);

  ///Set of all values of [IOSNSURLProtectionSpaceProxyType].
  static final Set<IOSNSURLProtectionSpaceProxyType> values = [
    IOSNSURLProtectionSpaceProxyType.NSUR_PROTECTION_SPACE_HTTP_PROXY,
    IOSNSURLProtectionSpaceProxyType.NSURL_PROTECTION_SPACE_HTTPS_PROXY,
    IOSNSURLProtectionSpaceProxyType.NSURL_PROTECTION_SPACE_FTP_PROXY,
    IOSNSURLProtectionSpaceProxyType.NSURL_PROTECTION_SPACE_SOCKS_PROXY,
  ].toSet();

  ///Gets a possible [IOSNSURLProtectionSpaceProxyType] instance from a [String] value.
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

  ///Gets [String] value.
  String toValue() => _value;

  @override
  String toString() => _value;

  ///The proxy type for HTTP proxies.
  static const NSUR_PROTECTION_SPACE_HTTP_PROXY =
  const IOSNSURLProtectionSpaceProxyType._internal(
      "NSURLProtectionSpaceHTTPProxy");

  ///The proxy type for HTTPS proxies.
  static const NSURL_PROTECTION_SPACE_HTTPS_PROXY =
  const IOSNSURLProtectionSpaceProxyType._internal(
      "NSURLProtectionSpaceHTTPSProxy");

  ///The proxy type for FTP proxies.
  static const NSURL_PROTECTION_SPACE_FTP_PROXY =
  const IOSNSURLProtectionSpaceProxyType._internal(
      "NSURLProtectionSpaceFTPProxy");

  ///The proxy type for SOCKS proxies.
  static const NSURL_PROTECTION_SPACE_SOCKS_PROXY =
  const IOSNSURLProtectionSpaceProxyType._internal(
      "NSURLProtectionSpaceSOCKSProxy");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}