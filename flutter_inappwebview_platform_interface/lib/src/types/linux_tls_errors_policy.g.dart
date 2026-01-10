// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'linux_tls_errors_policy.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///TLS errors policy for WebKitWebContext on Linux.
///
///Determines how TLS certificate errors are handled.
class LinuxTLSErrorsPolicy {
  final int _value;
  final int _nativeValue;
  const LinuxTLSErrorsPolicy._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory LinuxTLSErrorsPolicy._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => LinuxTLSErrorsPolicy._internal(value, nativeValue());

  ///Fail on TLS errors, preventing resources with certificate errors from loading.
  ///This is the default and recommended policy for secure applications.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Linux WPE WebKit ([Official API - WEBKIT_TLS_ERRORS_POLICY_FAIL](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/enum.TLSErrorsPolicy.html))
  static final FAIL = LinuxTLSErrorsPolicy._internalMultiPlatform(1, () {
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
  static final IGNORE = LinuxTLSErrorsPolicy._internalMultiPlatform(0, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.linux:
        return 0;
      default:
        break;
    }
    return null;
  });

  ///Set of all values of [LinuxTLSErrorsPolicy].
  static final Set<LinuxTLSErrorsPolicy> values = [
    LinuxTLSErrorsPolicy.FAIL,
    LinuxTLSErrorsPolicy.IGNORE,
  ].toSet();

  ///Gets a possible [LinuxTLSErrorsPolicy] instance from [int] value.
  static LinuxTLSErrorsPolicy? fromValue(int? value) {
    if (value != null) {
      try {
        return LinuxTLSErrorsPolicy.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [LinuxTLSErrorsPolicy] instance from a native value.
  static LinuxTLSErrorsPolicy? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return LinuxTLSErrorsPolicy.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [LinuxTLSErrorsPolicy] instance value with name [name].
  ///
  /// Goes through [LinuxTLSErrorsPolicy.values] looking for a value with
  /// name [name], as reported by [LinuxTLSErrorsPolicy.name].
  /// Returns the first value with the given name, otherwise `null`.
  static LinuxTLSErrorsPolicy? byName(String? name) {
    if (name != null) {
      try {
        return LinuxTLSErrorsPolicy.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [LinuxTLSErrorsPolicy] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, LinuxTLSErrorsPolicy> asNameMap() =>
      <String, LinuxTLSErrorsPolicy>{
        for (final value in LinuxTLSErrorsPolicy.values) value.name(): value,
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
