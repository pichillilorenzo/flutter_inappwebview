// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permission_response_action.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used by [PermissionResponse] class.
class PermissionResponseAction {
  final int _value;
  final int _nativeValue;
  const PermissionResponseAction._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory PermissionResponseAction._internalMultiPlatform(
          int value, Function nativeValue) =>
      PermissionResponseAction._internal(value, nativeValue());

  ///Denies the request.
  static const DENY = PermissionResponseAction._internal(0, 0);

  ///Grants origin the permission to access the given resources.
  static const GRANT = PermissionResponseAction._internal(1, 1);

  ///Prompt the user for permission for the requested resource.
  static const PROMPT = PermissionResponseAction._internal(2, 2);

  ///Set of all values of [PermissionResponseAction].
  static final Set<PermissionResponseAction> values = [
    PermissionResponseAction.DENY,
    PermissionResponseAction.GRANT,
    PermissionResponseAction.PROMPT,
  ].toSet();

  ///Gets a possible [PermissionResponseAction] instance from [int] value.
  static PermissionResponseAction? fromValue(int? value) {
    if (value != null) {
      try {
        return PermissionResponseAction.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [PermissionResponseAction] instance from a native value.
  static PermissionResponseAction? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return PermissionResponseAction.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [PermissionResponseAction] instance value with name [name].
  ///
  /// Goes through [PermissionResponseAction.values] looking for a value with
  /// name [name], as reported by [PermissionResponseAction.name].
  /// Returns the first value with the given name, otherwise `null`.
  static PermissionResponseAction? byName(String? name) {
    if (name != null) {
      try {
        return PermissionResponseAction.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [PermissionResponseAction] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, PermissionResponseAction> asNameMap() =>
      <String, PermissionResponseAction>{
        for (final value in PermissionResponseAction.values) value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 0:
        return 'DENY';
      case 1:
        return 'GRANT';
      case 2:
        return 'PROMPT';
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

///Class used by [PermissionRequestResponse] class.
///Use [PermissionResponseAction] instead.
@Deprecated('Use PermissionResponseAction instead')
class PermissionRequestResponseAction {
  final int _value;
  final int _nativeValue;
  const PermissionRequestResponseAction._internal(
      this._value, this._nativeValue);
// ignore: unused_element
  factory PermissionRequestResponseAction._internalMultiPlatform(
          int value, Function nativeValue) =>
      PermissionRequestResponseAction._internal(value, nativeValue());

  ///Denies the request.
  static const DENY = PermissionRequestResponseAction._internal(0, 0);

  ///Grants origin the permission to access the given resources.
  static const GRANT = PermissionRequestResponseAction._internal(1, 1);

  ///Set of all values of [PermissionRequestResponseAction].
  static final Set<PermissionRequestResponseAction> values = [
    PermissionRequestResponseAction.DENY,
    PermissionRequestResponseAction.GRANT,
  ].toSet();

  ///Gets a possible [PermissionRequestResponseAction] instance from [int] value.
  static PermissionRequestResponseAction? fromValue(int? value) {
    if (value != null) {
      try {
        return PermissionRequestResponseAction.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [PermissionRequestResponseAction] instance from a native value.
  static PermissionRequestResponseAction? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return PermissionRequestResponseAction.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [PermissionRequestResponseAction] instance value with name [name].
  ///
  /// Goes through [PermissionRequestResponseAction.values] looking for a value with
  /// name [name], as reported by [PermissionRequestResponseAction.name].
  /// Returns the first value with the given name, otherwise `null`.
  static PermissionRequestResponseAction? byName(String? name) {
    if (name != null) {
      try {
        return PermissionRequestResponseAction.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [PermissionRequestResponseAction] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, PermissionRequestResponseAction> asNameMap() =>
      <String, PermissionRequestResponseAction>{
        for (final value in PermissionRequestResponseAction.values)
          value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 0:
        return 'DENY';
      case 1:
        return 'GRANT';
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
