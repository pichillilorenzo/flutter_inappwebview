// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scrollview_content_inset_adjustment_behavior.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used to configure how safe area insets are added to the adjusted content inset.
class ScrollViewContentInsetAdjustmentBehavior {
  final int _value;
  final int _nativeValue;
  const ScrollViewContentInsetAdjustmentBehavior._internal(
      this._value, this._nativeValue);
// ignore: unused_element
  factory ScrollViewContentInsetAdjustmentBehavior._internalMultiPlatform(
          int value, Function nativeValue) =>
      ScrollViewContentInsetAdjustmentBehavior._internal(value, nativeValue());

  ///Always include the safe area insets in the content adjustment.
  static const ALWAYS =
      ScrollViewContentInsetAdjustmentBehavior._internal(3, 3);

  ///Automatically adjust the scroll view insets.
  static const AUTOMATIC =
      ScrollViewContentInsetAdjustmentBehavior._internal(0, 0);

  ///Do not adjust the scroll view insets.
  static const NEVER = ScrollViewContentInsetAdjustmentBehavior._internal(2, 2);

  ///Adjust the insets only in the scrollable directions.
  static const SCROLLABLE_AXES =
      ScrollViewContentInsetAdjustmentBehavior._internal(1, 1);

  ///Set of all values of [ScrollViewContentInsetAdjustmentBehavior].
  static final Set<ScrollViewContentInsetAdjustmentBehavior> values = [
    ScrollViewContentInsetAdjustmentBehavior.ALWAYS,
    ScrollViewContentInsetAdjustmentBehavior.AUTOMATIC,
    ScrollViewContentInsetAdjustmentBehavior.NEVER,
    ScrollViewContentInsetAdjustmentBehavior.SCROLLABLE_AXES,
  ].toSet();

  ///Gets a possible [ScrollViewContentInsetAdjustmentBehavior] instance from [int] value.
  static ScrollViewContentInsetAdjustmentBehavior? fromValue(int? value) {
    if (value != null) {
      try {
        return ScrollViewContentInsetAdjustmentBehavior.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [ScrollViewContentInsetAdjustmentBehavior] instance from a native value.
  static ScrollViewContentInsetAdjustmentBehavior? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return ScrollViewContentInsetAdjustmentBehavior.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [ScrollViewContentInsetAdjustmentBehavior] instance value with name [name].
  ///
  /// Goes through [ScrollViewContentInsetAdjustmentBehavior.values] looking for a value with
  /// name [name], as reported by [ScrollViewContentInsetAdjustmentBehavior.name].
  /// Returns the first value with the given name, otherwise `null`.
  static ScrollViewContentInsetAdjustmentBehavior? byName(String? name) {
    if (name != null) {
      try {
        return ScrollViewContentInsetAdjustmentBehavior.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [ScrollViewContentInsetAdjustmentBehavior] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, ScrollViewContentInsetAdjustmentBehavior> asNameMap() =>
      <String, ScrollViewContentInsetAdjustmentBehavior>{
        for (final value in ScrollViewContentInsetAdjustmentBehavior.values)
          value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 3:
        return 'ALWAYS';
      case 0:
        return 'AUTOMATIC';
      case 2:
        return 'NEVER';
      case 1:
        return 'SCROLLABLE_AXES';
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

///An iOS-specific class used to configure how safe area insets are added to the adjusted content inset.
///
///**NOTE**: available on iOS 11.0+.
///
///Use [ScrollViewContentInsetAdjustmentBehavior] instead.
@Deprecated('Use ScrollViewContentInsetAdjustmentBehavior instead')
class IOSUIScrollViewContentInsetAdjustmentBehavior {
  final int _value;
  final int _nativeValue;
  const IOSUIScrollViewContentInsetAdjustmentBehavior._internal(
      this._value, this._nativeValue);
// ignore: unused_element
  factory IOSUIScrollViewContentInsetAdjustmentBehavior._internalMultiPlatform(
          int value, Function nativeValue) =>
      IOSUIScrollViewContentInsetAdjustmentBehavior._internal(
          value, nativeValue());

  ///Always include the safe area insets in the content adjustment.
  static const ALWAYS =
      IOSUIScrollViewContentInsetAdjustmentBehavior._internal(3, 3);

  ///Automatically adjust the scroll view insets.
  static const AUTOMATIC =
      IOSUIScrollViewContentInsetAdjustmentBehavior._internal(0, 0);

  ///Do not adjust the scroll view insets.
  static const NEVER =
      IOSUIScrollViewContentInsetAdjustmentBehavior._internal(2, 2);

  ///Adjust the insets only in the scrollable directions.
  static const SCROLLABLE_AXES =
      IOSUIScrollViewContentInsetAdjustmentBehavior._internal(1, 1);

  ///Set of all values of [IOSUIScrollViewContentInsetAdjustmentBehavior].
  static final Set<IOSUIScrollViewContentInsetAdjustmentBehavior> values = [
    IOSUIScrollViewContentInsetAdjustmentBehavior.ALWAYS,
    IOSUIScrollViewContentInsetAdjustmentBehavior.AUTOMATIC,
    IOSUIScrollViewContentInsetAdjustmentBehavior.NEVER,
    IOSUIScrollViewContentInsetAdjustmentBehavior.SCROLLABLE_AXES,
  ].toSet();

  ///Gets a possible [IOSUIScrollViewContentInsetAdjustmentBehavior] instance from [int] value.
  static IOSUIScrollViewContentInsetAdjustmentBehavior? fromValue(int? value) {
    if (value != null) {
      try {
        return IOSUIScrollViewContentInsetAdjustmentBehavior.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [IOSUIScrollViewContentInsetAdjustmentBehavior] instance from a native value.
  static IOSUIScrollViewContentInsetAdjustmentBehavior? fromNativeValue(
      int? value) {
    if (value != null) {
      try {
        return IOSUIScrollViewContentInsetAdjustmentBehavior.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [IOSUIScrollViewContentInsetAdjustmentBehavior] instance value with name [name].
  ///
  /// Goes through [IOSUIScrollViewContentInsetAdjustmentBehavior.values] looking for a value with
  /// name [name], as reported by [IOSUIScrollViewContentInsetAdjustmentBehavior.name].
  /// Returns the first value with the given name, otherwise `null`.
  static IOSUIScrollViewContentInsetAdjustmentBehavior? byName(String? name) {
    if (name != null) {
      try {
        return IOSUIScrollViewContentInsetAdjustmentBehavior.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [IOSUIScrollViewContentInsetAdjustmentBehavior] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, IOSUIScrollViewContentInsetAdjustmentBehavior>
      asNameMap() => <String, IOSUIScrollViewContentInsetAdjustmentBehavior>{
            for (final value
                in IOSUIScrollViewContentInsetAdjustmentBehavior.values)
              value.name(): value
          };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 3:
        return 'ALWAYS';
      case 0:
        return 'AUTOMATIC';
      case 2:
        return 'NEVER';
      case 1:
        return 'SCROLLABLE_AXES';
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
