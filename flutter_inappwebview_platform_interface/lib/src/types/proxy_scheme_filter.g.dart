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

  /// Gets a possible [ProxySchemeFilter] instance value with name [name].
  ///
  /// Goes through [ProxySchemeFilter.values] looking for a value with
  /// name [name], as reported by [ProxySchemeFilter.name].
  /// Returns the first value with the given name, otherwise `null`.
  static ProxySchemeFilter? byName(String? name) {
    if (name != null) {
      try {
        return ProxySchemeFilter.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [ProxySchemeFilter] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, ProxySchemeFilter> asNameMap() =>
      <String, ProxySchemeFilter>{
        for (final value in ProxySchemeFilter.values) value.name(): value
      };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value.
  String toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case '*':
        return 'MATCH_ALL_SCHEMES';
      case 'http':
        return 'MATCH_HTTP';
      case 'https':
        return 'MATCH_HTTPS';
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
