// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'console_message_level.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class representing the level of a console message.
class ConsoleMessageLevel {
  final int _value;
  final int _nativeValue;
  const ConsoleMessageLevel._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory ConsoleMessageLevel._internalMultiPlatform(
          int value, Function nativeValue) =>
      ConsoleMessageLevel._internal(value, nativeValue());

  ///Console DEBUG level
  static const DEBUG = ConsoleMessageLevel._internal(4, 4);

  ///Console ERROR level
  static const ERROR = ConsoleMessageLevel._internal(3, 3);

  ///Console LOG level
  static const LOG = ConsoleMessageLevel._internal(1, 1);

  ///Console TIP level
  static const TIP = ConsoleMessageLevel._internal(0, 0);

  ///Console WARNING level
  static const WARNING = ConsoleMessageLevel._internal(2, 2);

  ///Set of all values of [ConsoleMessageLevel].
  static final Set<ConsoleMessageLevel> values = [
    ConsoleMessageLevel.DEBUG,
    ConsoleMessageLevel.ERROR,
    ConsoleMessageLevel.LOG,
    ConsoleMessageLevel.TIP,
    ConsoleMessageLevel.WARNING,
  ].toSet();

  ///Gets a possible [ConsoleMessageLevel] instance from [int] value.
  static ConsoleMessageLevel? fromValue(int? value) {
    if (value != null) {
      try {
        return ConsoleMessageLevel.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [ConsoleMessageLevel] instance from a native value.
  static ConsoleMessageLevel? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return ConsoleMessageLevel.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [ConsoleMessageLevel] instance value with name [name].
  ///
  /// Goes through [ConsoleMessageLevel.values] looking for a value with
  /// name [name], as reported by [ConsoleMessageLevel.name].
  /// Returns the first value with the given name, otherwise `null`.
  static ConsoleMessageLevel? byName(String? name) {
    if (name != null) {
      try {
        return ConsoleMessageLevel.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [ConsoleMessageLevel] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, ConsoleMessageLevel> asNameMap() =>
      <String, ConsoleMessageLevel>{
        for (final value in ConsoleMessageLevel.values) value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 4:
        return 'DEBUG';
      case 3:
        return 'ERROR';
      case 1:
        return 'LOG';
      case 0:
        return 'TIP';
      case 2:
        return 'WARNING';
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
