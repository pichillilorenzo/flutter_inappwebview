// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferred_content_mode.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the content mode to prefer when loading and rendering a webpage.
class UserPreferredContentMode {
  final int _value;
  final int _nativeValue;
  const UserPreferredContentMode._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory UserPreferredContentMode._internalMultiPlatform(
          int value, Function nativeValue) =>
      UserPreferredContentMode._internal(value, nativeValue());

  ///Represents content targeting desktop browsers.
  static const DESKTOP = UserPreferredContentMode._internal(2, 2);

  ///Represents content targeting mobile browsers.
  static const MOBILE = UserPreferredContentMode._internal(1, 1);

  ///The recommended content mode for the current platform.
  static const RECOMMENDED = UserPreferredContentMode._internal(0, 0);

  ///Set of all values of [UserPreferredContentMode].
  static final Set<UserPreferredContentMode> values = [
    UserPreferredContentMode.DESKTOP,
    UserPreferredContentMode.MOBILE,
    UserPreferredContentMode.RECOMMENDED,
  ].toSet();

  ///Gets a possible [UserPreferredContentMode] instance from [int] value.
  static UserPreferredContentMode? fromValue(int? value) {
    if (value != null) {
      try {
        return UserPreferredContentMode.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [UserPreferredContentMode] instance from a native value.
  static UserPreferredContentMode? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return UserPreferredContentMode.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [UserPreferredContentMode] instance value with name [name].
  ///
  /// Goes through [UserPreferredContentMode.values] looking for a value with
  /// name [name], as reported by [UserPreferredContentMode.name].
  /// Returns the first value with the given name, otherwise `null`.
  static UserPreferredContentMode? byName(String? name) {
    if (name != null) {
      try {
        return UserPreferredContentMode.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [UserPreferredContentMode] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, UserPreferredContentMode> asNameMap() =>
      <String, UserPreferredContentMode>{
        for (final value in UserPreferredContentMode.values) value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 2:
        return 'DESKTOP';
      case 1:
        return 'MOBILE';
      case 0:
        return 'RECOMMENDED';
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
    return name();
  }
}
