// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_usage_target_level.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Constants that describe memory usage target levels.
class MemoryUsageTargetLevel {
  final int _value;
  final int? _nativeValue;
  const MemoryUsageTargetLevel._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory MemoryUsageTargetLevel._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => MemoryUsageTargetLevel._internal(value, nativeValue());

  ///Low memory usage target level.
  static const LOW = MemoryUsageTargetLevel._internal(1, 1);

  ///Normal memory usage target level.
  static const NORMAL = MemoryUsageTargetLevel._internal(0, 0);

  ///Set of all values of [MemoryUsageTargetLevel].
  static final Set<MemoryUsageTargetLevel> values = [
    MemoryUsageTargetLevel.LOW,
    MemoryUsageTargetLevel.NORMAL,
  ].toSet();

  ///Gets a possible [MemoryUsageTargetLevel] instance from [int] value.
  static MemoryUsageTargetLevel? fromValue(int? value) {
    if (value != null) {
      try {
        return MemoryUsageTargetLevel.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [MemoryUsageTargetLevel] instance from a native value.
  static MemoryUsageTargetLevel? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return MemoryUsageTargetLevel.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [MemoryUsageTargetLevel] instance value with name [name].
  ///
  /// Goes through [MemoryUsageTargetLevel.values] looking for a value with
  /// name [name], as reported by [MemoryUsageTargetLevel.name].
  /// Returns the first value with the given name, otherwise `null`.
  static MemoryUsageTargetLevel? byName(String? name) {
    if (name != null) {
      try {
        return MemoryUsageTargetLevel.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [MemoryUsageTargetLevel] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, MemoryUsageTargetLevel> asNameMap() =>
      <String, MemoryUsageTargetLevel>{
        for (final value in MemoryUsageTargetLevel.values) value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 1:
        return 'LOW';
      case 0:
        return 'NORMAL';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  ///Checks if the value is supported by the [defaultTargetPlatform].
  bool isSupported() {
    return _nativeValue != null;
  }

  @override
  String toString() {
    return name();
  }
}
