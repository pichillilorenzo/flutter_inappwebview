// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'should_allow_deprecated_tls_action.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that is used by [PlatformWebViewCreationParams.shouldAllowDeprecatedTLS] event.
///It represents the policy to pass back to the decision handler.
class ShouldAllowDeprecatedTLSAction {
  final int _value;
  final int _nativeValue;
  const ShouldAllowDeprecatedTLSAction._internal(
      this._value, this._nativeValue);
// ignore: unused_element
  factory ShouldAllowDeprecatedTLSAction._internalMultiPlatform(
          int value, Function nativeValue) =>
      ShouldAllowDeprecatedTLSAction._internal(value, nativeValue());

  ///Allow the navigation to continue.
  static const ALLOW = ShouldAllowDeprecatedTLSAction._internal(1, 1);

  ///Cancel the navigation.
  static const CANCEL = ShouldAllowDeprecatedTLSAction._internal(0, 0);

  ///Set of all values of [ShouldAllowDeprecatedTLSAction].
  static final Set<ShouldAllowDeprecatedTLSAction> values = [
    ShouldAllowDeprecatedTLSAction.ALLOW,
    ShouldAllowDeprecatedTLSAction.CANCEL,
  ].toSet();

  ///Gets a possible [ShouldAllowDeprecatedTLSAction] instance from [int] value.
  static ShouldAllowDeprecatedTLSAction? fromValue(int? value) {
    if (value != null) {
      try {
        return ShouldAllowDeprecatedTLSAction.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [ShouldAllowDeprecatedTLSAction] instance from a native value.
  static ShouldAllowDeprecatedTLSAction? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return ShouldAllowDeprecatedTLSAction.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [ShouldAllowDeprecatedTLSAction] instance value with name [name].
  ///
  /// Goes through [ShouldAllowDeprecatedTLSAction.values] looking for a value with
  /// name [name], as reported by [ShouldAllowDeprecatedTLSAction.name].
  /// Returns the first value with the given name, otherwise `null`.
  static ShouldAllowDeprecatedTLSAction? byName(String? name) {
    if (name != null) {
      try {
        return ShouldAllowDeprecatedTLSAction.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [ShouldAllowDeprecatedTLSAction] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, ShouldAllowDeprecatedTLSAction> asNameMap() =>
      <String, ShouldAllowDeprecatedTLSAction>{
        for (final value in ShouldAllowDeprecatedTLSAction.values)
          value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 1:
        return 'ALLOW';
      case 0:
        return 'CANCEL';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    return name();
  }
}

///Class that is used by [PlatformWebViewCreationParams.shouldAllowDeprecatedTLS] event.
///It represents the policy to pass back to the decision handler.
///Use [ShouldAllowDeprecatedTLSAction] instead.
@Deprecated('Use ShouldAllowDeprecatedTLSAction instead')
class IOSShouldAllowDeprecatedTLSAction {
  final int _value;
  final int _nativeValue;
  const IOSShouldAllowDeprecatedTLSAction._internal(
      this._value, this._nativeValue);
// ignore: unused_element
  factory IOSShouldAllowDeprecatedTLSAction._internalMultiPlatform(
          int value, Function nativeValue) =>
      IOSShouldAllowDeprecatedTLSAction._internal(value, nativeValue());

  ///Allow the navigation to continue.
  static const ALLOW = IOSShouldAllowDeprecatedTLSAction._internal(1, 1);

  ///Cancel the navigation.
  static const CANCEL = IOSShouldAllowDeprecatedTLSAction._internal(0, 0);

  ///Set of all values of [IOSShouldAllowDeprecatedTLSAction].
  static final Set<IOSShouldAllowDeprecatedTLSAction> values = [
    IOSShouldAllowDeprecatedTLSAction.ALLOW,
    IOSShouldAllowDeprecatedTLSAction.CANCEL,
  ].toSet();

  ///Gets a possible [IOSShouldAllowDeprecatedTLSAction] instance from [int] value.
  static IOSShouldAllowDeprecatedTLSAction? fromValue(int? value) {
    if (value != null) {
      try {
        return IOSShouldAllowDeprecatedTLSAction.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [IOSShouldAllowDeprecatedTLSAction] instance from a native value.
  static IOSShouldAllowDeprecatedTLSAction? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return IOSShouldAllowDeprecatedTLSAction.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [IOSShouldAllowDeprecatedTLSAction] instance value with name [name].
  ///
  /// Goes through [IOSShouldAllowDeprecatedTLSAction.values] looking for a value with
  /// name [name], as reported by [IOSShouldAllowDeprecatedTLSAction.name].
  /// Returns the first value with the given name, otherwise `null`.
  static IOSShouldAllowDeprecatedTLSAction? byName(String? name) {
    if (name != null) {
      try {
        return IOSShouldAllowDeprecatedTLSAction.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [IOSShouldAllowDeprecatedTLSAction] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, IOSShouldAllowDeprecatedTLSAction> asNameMap() =>
      <String, IOSShouldAllowDeprecatedTLSAction>{
        for (final value in IOSShouldAllowDeprecatedTLSAction.values)
          value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 1:
        return 'ALLOW';
      case 0:
        return 'CANCEL';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    return name();
  }
}
