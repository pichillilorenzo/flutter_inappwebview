// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_direction.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Constants that describe the notification text direction.
class NotificationDirection {
  final int _value;
  final int _nativeValue;
  const NotificationDirection._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory NotificationDirection._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => NotificationDirection._internal(value, nativeValue());

  ///Default text direction.
  static const DEFAULT = NotificationDirection._internal(0, 0);

  ///Left-to-right text direction.
  static const LEFT_TO_RIGHT = NotificationDirection._internal(1, 1);

  ///Right-to-left text direction.
  static const RIGHT_TO_LEFT = NotificationDirection._internal(2, 2);

  ///Set of all values of [NotificationDirection].
  static final Set<NotificationDirection> values = [
    NotificationDirection.DEFAULT,
    NotificationDirection.LEFT_TO_RIGHT,
    NotificationDirection.RIGHT_TO_LEFT,
  ].toSet();

  ///Gets a possible [NotificationDirection] instance from [int] value.
  static NotificationDirection? fromValue(int? value) {
    if (value != null) {
      try {
        return NotificationDirection.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [NotificationDirection] instance from a native value.
  static NotificationDirection? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return NotificationDirection.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [NotificationDirection] instance value with name [name].
  ///
  /// Goes through [NotificationDirection.values] looking for a value with
  /// name [name], as reported by [NotificationDirection.name].
  /// Returns the first value with the given name, otherwise `null`.
  static NotificationDirection? byName(String? name) {
    if (name != null) {
      try {
        return NotificationDirection.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [NotificationDirection] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, NotificationDirection> asNameMap() =>
      <String, NotificationDirection>{
        for (final value in NotificationDirection.values) value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 0:
        return 'DEFAULT';
      case 1:
        return 'LEFT_TO_RIGHT';
      case 2:
        return 'RIGHT_TO_LEFT';
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
