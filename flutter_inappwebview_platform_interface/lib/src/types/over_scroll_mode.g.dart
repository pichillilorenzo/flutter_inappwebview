// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'over_scroll_mode.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used to configure the `WebView`'s over-scroll mode.
///Setting the over-scroll mode of a WebView will have an effect only if the `WebView` is capable of scrolling.
class OverScrollMode {
  final int _value;
  final int _nativeValue;
  const OverScrollMode._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory OverScrollMode._internalMultiPlatform(
          int value, Function nativeValue) =>
      OverScrollMode._internal(value, nativeValue());

  ///Always allow a user to over-scroll this view, provided it is a view that can scroll.
  static const ALWAYS = OverScrollMode._internal(0, 0);

  ///Allow a user to over-scroll this view only if the content is large enough to meaningfully scroll, provided it is a view that can scroll.
  static const IF_CONTENT_SCROLLS = OverScrollMode._internal(1, 1);

  ///Never allow a user to over-scroll this view.
  static const NEVER = OverScrollMode._internal(2, 2);

  ///Set of all values of [OverScrollMode].
  static final Set<OverScrollMode> values = [
    OverScrollMode.ALWAYS,
    OverScrollMode.IF_CONTENT_SCROLLS,
    OverScrollMode.NEVER,
  ].toSet();

  ///Gets a possible [OverScrollMode] instance from [int] value.
  static OverScrollMode? fromValue(int? value) {
    if (value != null) {
      try {
        return OverScrollMode.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [OverScrollMode] instance from a native value.
  static OverScrollMode? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return OverScrollMode.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [OverScrollMode] instance value with name [name].
  ///
  /// Goes through [OverScrollMode.values] looking for a value with
  /// name [name], as reported by [OverScrollMode.name].
  /// Returns the first value with the given name, otherwise `null`.
  static OverScrollMode? byName(String? name) {
    if (name != null) {
      try {
        return OverScrollMode.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [OverScrollMode] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, OverScrollMode> asNameMap() => <String, OverScrollMode>{
        for (final value in OverScrollMode.values) value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 0:
        return 'ALWAYS';
      case 1:
        return 'IF_CONTENT_SCROLLS';
      case 2:
        return 'NEVER';
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

///An Android-specific class used to configure the `WebView`'s over-scroll mode.
///Setting the over-scroll mode of a WebView will have an effect only if the `WebView` is capable of scrolling.
///Use [OverScrollMode] instead.
@Deprecated('Use OverScrollMode instead')
class AndroidOverScrollMode {
  final int _value;
  final int _nativeValue;
  const AndroidOverScrollMode._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory AndroidOverScrollMode._internalMultiPlatform(
          int value, Function nativeValue) =>
      AndroidOverScrollMode._internal(value, nativeValue());

  ///Always allow a user to over-scroll this view, provided it is a view that can scroll.
  static const OVER_SCROLL_ALWAYS = AndroidOverScrollMode._internal(0, 0);

  ///Allow a user to over-scroll this view only if the content is large enough to meaningfully scroll, provided it is a view that can scroll.
  static const OVER_SCROLL_IF_CONTENT_SCROLLS =
      AndroidOverScrollMode._internal(1, 1);

  ///Never allow a user to over-scroll this view.
  static const OVER_SCROLL_NEVER = AndroidOverScrollMode._internal(2, 2);

  ///Set of all values of [AndroidOverScrollMode].
  static final Set<AndroidOverScrollMode> values = [
    AndroidOverScrollMode.OVER_SCROLL_ALWAYS,
    AndroidOverScrollMode.OVER_SCROLL_IF_CONTENT_SCROLLS,
    AndroidOverScrollMode.OVER_SCROLL_NEVER,
  ].toSet();

  ///Gets a possible [AndroidOverScrollMode] instance from [int] value.
  static AndroidOverScrollMode? fromValue(int? value) {
    if (value != null) {
      try {
        return AndroidOverScrollMode.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [AndroidOverScrollMode] instance from a native value.
  static AndroidOverScrollMode? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return AndroidOverScrollMode.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [AndroidOverScrollMode] instance value with name [name].
  ///
  /// Goes through [AndroidOverScrollMode.values] looking for a value with
  /// name [name], as reported by [AndroidOverScrollMode.name].
  /// Returns the first value with the given name, otherwise `null`.
  static AndroidOverScrollMode? byName(String? name) {
    if (name != null) {
      try {
        return AndroidOverScrollMode.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [AndroidOverScrollMode] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, AndroidOverScrollMode> asNameMap() =>
      <String, AndroidOverScrollMode>{
        for (final value in AndroidOverScrollMode.values) value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 0:
        return 'OVER_SCROLL_ALWAYS';
      case 1:
        return 'OVER_SCROLL_IF_CONTENT_SCROLLS';
      case 2:
        return 'OVER_SCROLL_NEVER';
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
