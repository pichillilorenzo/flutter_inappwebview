// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tls_errors_policy.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///TLS errors policy for WebKitWebContext.
///
///Determines how TLS certificate errors are handled.
class TLSErrorsPolicy {
  final int _value;
  final int _nativeValue;
  const TLSErrorsPolicy._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory TLSErrorsPolicy._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => TLSErrorsPolicy._internal(value, nativeValue());

  ///Fail on TLS errors, preventing resources with certificate errors from loading.
  ///This is the default and recommended policy for secure applications.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - WEBKIT_TLS_ERRORS_POLICY_FAIL](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/enum.TLSErrorsPolicy.html))
  static final FAIL = TLSErrorsPolicy._internalMultiPlatform(1, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.linux:
        return 1;
      default:
        break;
    }
    return null;
  });

  ///Ignore TLS errors and continue to load resources.
  ///This policy is less secure but may be useful for development purposes.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - WEBKIT_TLS_ERRORS_POLICY_IGNORE](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/enum.TLSErrorsPolicy.html))
  static final IGNORE = TLSErrorsPolicy._internalMultiPlatform(0, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.linux:
        return 0;
      default:
        break;
    }
    return null;
  });

  ///Set of all values of [TLSErrorsPolicy].
  static final Set<TLSErrorsPolicy> values = [
    TLSErrorsPolicy.FAIL,
    TLSErrorsPolicy.IGNORE,
  ].toSet();

  ///Gets a possible [TLSErrorsPolicy] instance from [int] value.
  static TLSErrorsPolicy? fromValue(int? value) {
    if (value != null) {
      try {
        return TLSErrorsPolicy.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [TLSErrorsPolicy] instance from a native value.
  static TLSErrorsPolicy? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return TLSErrorsPolicy.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [TLSErrorsPolicy] instance value with name [name].
  ///
  /// Goes through [TLSErrorsPolicy.values] looking for a value with
  /// name [name], as reported by [TLSErrorsPolicy.name].
  /// Returns the first value with the given name, otherwise `null`.
  static TLSErrorsPolicy? byName(String? name) {
    if (name != null) {
      try {
        return TLSErrorsPolicy.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [TLSErrorsPolicy] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, TLSErrorsPolicy> asNameMap() => <String, TLSErrorsPolicy>{
    for (final value in TLSErrorsPolicy.values) value.name(): value,
  };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 1:
        return 'FAIL';
      case 0:
        return 'IGNORE';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  ///Checks if the value is supported by the [defaultTargetPlatform].
  bool isSupported() {
    return toNativeValue() != null;
  }

  @override
  String toString() {
    return name();
  }
}
