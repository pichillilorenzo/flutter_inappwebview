// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vertical_scrollbar_position.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used to configure the position of the vertical scroll bar.
class VerticalScrollbarPosition {
  final int _value;
  final int? _nativeValue;
  const VerticalScrollbarPosition._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory VerticalScrollbarPosition._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => VerticalScrollbarPosition._internal(value, nativeValue());

  ///Position the scroll bar at the default position as determined by the system.
  static const SCROLLBAR_POSITION_DEFAULT = VerticalScrollbarPosition._internal(
    0,
    0,
  );

  ///Position the scroll bar along the left edge.
  static const SCROLLBAR_POSITION_LEFT = VerticalScrollbarPosition._internal(
    1,
    1,
  );

  ///Position the scroll bar along the right edge.
  static const SCROLLBAR_POSITION_RIGHT = VerticalScrollbarPosition._internal(
    2,
    2,
  );

  ///Set of all values of [VerticalScrollbarPosition].
  static final Set<VerticalScrollbarPosition> values = [
    VerticalScrollbarPosition.SCROLLBAR_POSITION_DEFAULT,
    VerticalScrollbarPosition.SCROLLBAR_POSITION_LEFT,
    VerticalScrollbarPosition.SCROLLBAR_POSITION_RIGHT,
  ].toSet();

  ///Gets a possible [VerticalScrollbarPosition] instance from [int] value.
  static VerticalScrollbarPosition? fromValue(int? value) {
    if (value != null) {
      try {
        return VerticalScrollbarPosition.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [VerticalScrollbarPosition] instance from a native value.
  static VerticalScrollbarPosition? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return VerticalScrollbarPosition.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [VerticalScrollbarPosition] instance value with name [name].
  ///
  /// Goes through [VerticalScrollbarPosition.values] looking for a value with
  /// name [name], as reported by [VerticalScrollbarPosition.name].
  /// Returns the first value with the given name, otherwise `null`.
  static VerticalScrollbarPosition? byName(String? name) {
    if (name != null) {
      try {
        return VerticalScrollbarPosition.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [VerticalScrollbarPosition] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, VerticalScrollbarPosition> asNameMap() =>
      <String, VerticalScrollbarPosition>{
        for (final value in VerticalScrollbarPosition.values)
          value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 0:
        return 'SCROLLBAR_POSITION_DEFAULT';
      case 1:
        return 'SCROLLBAR_POSITION_LEFT';
      case 2:
        return 'SCROLLBAR_POSITION_RIGHT';
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

///An Android-specific class used to configure the position of the vertical scroll bar.
///Use [VerticalScrollbarPosition] instead.
@Deprecated('Use VerticalScrollbarPosition instead')
class AndroidVerticalScrollbarPosition {
  final int _value;
  final int? _nativeValue;
  const AndroidVerticalScrollbarPosition._internal(
    this._value,
    this._nativeValue,
  );
  // ignore: unused_element
  factory AndroidVerticalScrollbarPosition._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => AndroidVerticalScrollbarPosition._internal(value, nativeValue());

  ///Position the scroll bar at the default position as determined by the system.
  static const SCROLLBAR_POSITION_DEFAULT =
      AndroidVerticalScrollbarPosition._internal(0, 0);

  ///Position the scroll bar along the left edge.
  static const SCROLLBAR_POSITION_LEFT =
      AndroidVerticalScrollbarPosition._internal(1, 1);

  ///Position the scroll bar along the right edge.
  static const SCROLLBAR_POSITION_RIGHT =
      AndroidVerticalScrollbarPosition._internal(2, 2);

  ///Set of all values of [AndroidVerticalScrollbarPosition].
  static final Set<AndroidVerticalScrollbarPosition> values = [
    AndroidVerticalScrollbarPosition.SCROLLBAR_POSITION_DEFAULT,
    AndroidVerticalScrollbarPosition.SCROLLBAR_POSITION_LEFT,
    AndroidVerticalScrollbarPosition.SCROLLBAR_POSITION_RIGHT,
  ].toSet();

  ///Gets a possible [AndroidVerticalScrollbarPosition] instance from [int] value.
  static AndroidVerticalScrollbarPosition? fromValue(int? value) {
    if (value != null) {
      try {
        return AndroidVerticalScrollbarPosition.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [AndroidVerticalScrollbarPosition] instance from a native value.
  static AndroidVerticalScrollbarPosition? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return AndroidVerticalScrollbarPosition.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [AndroidVerticalScrollbarPosition] instance value with name [name].
  ///
  /// Goes through [AndroidVerticalScrollbarPosition.values] looking for a value with
  /// name [name], as reported by [AndroidVerticalScrollbarPosition.name].
  /// Returns the first value with the given name, otherwise `null`.
  static AndroidVerticalScrollbarPosition? byName(String? name) {
    if (name != null) {
      try {
        return AndroidVerticalScrollbarPosition.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [AndroidVerticalScrollbarPosition] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, AndroidVerticalScrollbarPosition> asNameMap() =>
      <String, AndroidVerticalScrollbarPosition>{
        for (final value in AndroidVerticalScrollbarPosition.values)
          value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 0:
        return 'SCROLLBAR_POSITION_DEFAULT';
      case 1:
        return 'SCROLLBAR_POSITION_LEFT';
      case 2:
        return 'SCROLLBAR_POSITION_RIGHT';
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
