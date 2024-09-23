// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy_scheme_filter.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represent scheme filters used by [PlatformProxyController].
class ProxySchemeFilter {
  final String _value;
  final String _nativeValue;
  const ProxySchemeFilter._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory ProxySchemeFilter._internalMultiPlatform(
          String value, Function nativeValue) =>
      ProxySchemeFilter._internal(value, nativeValue());

  ///Matches all schemes.
  static const MATCH_ALL_SCHEMES = ProxySchemeFilter._internal('*', '*');

  ///HTTP scheme.
  static const MATCH_HTTP = ProxySchemeFilter._internal('http', 'http');

  ///HTTPS scheme.
  static const MATCH_HTTPS = ProxySchemeFilter._internal('https', 'https');

  ///Set of all values of [ProxySchemeFilter].
  static final Set<ProxySchemeFilter> values = [
    ProxySchemeFilter.MATCH_ALL_SCHEMES,
    ProxySchemeFilter.MATCH_HTTP,
    ProxySchemeFilter.MATCH_HTTPS,
  ].toSet();

  ///Gets a possible [ProxySchemeFilter] instance from [String] value.
  static ProxySchemeFilter? fromValue(String? value) {
    if (value != null) {
      try {
        return ProxySchemeFilter.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [ProxySchemeFilter] instance from a native value.
  static ProxySchemeFilter? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return ProxySchemeFilter.values
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
