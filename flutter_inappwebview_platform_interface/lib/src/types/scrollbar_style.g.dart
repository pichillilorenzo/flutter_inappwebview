// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scrollbar_style.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used to configure the style of the scrollbars.
///The scrollbars can be overlaid or inset.
///When inset, they add to the padding of the view. And the scrollbars can be drawn inside the padding area or on the edge of the view.
///For example, if a view has a background drawable and you want to draw the scrollbars inside the padding specified by the drawable,
///you can use [ScrollBarStyle.SCROLLBARS_INSIDE_OVERLAY] or [ScrollBarStyle.SCROLLBARS_INSIDE_INSET].
///If you want them to appear at the edge of the view, ignoring the padding,
///then you can use [ScrollBarStyle.SCROLLBARS_OUTSIDE_OVERLAY] or [ScrollBarStyle.SCROLLBARS_OUTSIDE_INSET].
class ScrollBarStyle {
  final int _value;
  final int? _nativeValue;
  const ScrollBarStyle._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory ScrollBarStyle._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => ScrollBarStyle._internal(value, nativeValue());

  ///The scrollbar style to display the scrollbars inside the padded area, increasing the padding of the view.
  ///The scrollbars will not overlap the content area of the view.
  static const SCROLLBARS_INSIDE_INSET = ScrollBarStyle._internal(
    16777216,
    16777216,
  );

  ///The scrollbar style to display the scrollbars inside the content area, without increasing the padding.
  ///The scrollbars will be overlaid with translucency on the view's content.
  static const SCROLLBARS_INSIDE_OVERLAY = ScrollBarStyle._internal(0, 0);

  ///The scrollbar style to display the scrollbars at the edge of the view, increasing the padding of the view.
  ///The scrollbars will only overlap the background, if any.
  static const SCROLLBARS_OUTSIDE_INSET = ScrollBarStyle._internal(
    50331648,
    50331648,
  );

  ///The scrollbar style to display the scrollbars at the edge of the view, without increasing the padding.
  ///The scrollbars will be overlaid with translucency.
  static const SCROLLBARS_OUTSIDE_OVERLAY = ScrollBarStyle._internal(
    33554432,
    33554432,
  );

  ///Set of all values of [ScrollBarStyle].
  static final Set<ScrollBarStyle> values = [
    ScrollBarStyle.SCROLLBARS_INSIDE_INSET,
    ScrollBarStyle.SCROLLBARS_INSIDE_OVERLAY,
    ScrollBarStyle.SCROLLBARS_OUTSIDE_INSET,
    ScrollBarStyle.SCROLLBARS_OUTSIDE_OVERLAY,
  ].toSet();

  ///Gets a possible [ScrollBarStyle] instance from [int] value.
  static ScrollBarStyle? fromValue(int? value) {
    if (value != null) {
      try {
        return ScrollBarStyle.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [ScrollBarStyle] instance from a native value.
  static ScrollBarStyle? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return ScrollBarStyle.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [ScrollBarStyle] instance value with name [name].
  ///
  /// Goes through [ScrollBarStyle.values] looking for a value with
  /// name [name], as reported by [ScrollBarStyle.name].
  /// Returns the first value with the given name, otherwise `null`.
  static ScrollBarStyle? byName(String? name) {
    if (name != null) {
      try {
        return ScrollBarStyle.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [ScrollBarStyle] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, ScrollBarStyle> asNameMap() => <String, ScrollBarStyle>{
    for (final value in ScrollBarStyle.values) value.name(): value,
  };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 16777216:
        return 'SCROLLBARS_INSIDE_INSET';
      case 0:
        return 'SCROLLBARS_INSIDE_OVERLAY';
      case 50331648:
        return 'SCROLLBARS_OUTSIDE_INSET';
      case 33554432:
        return 'SCROLLBARS_OUTSIDE_OVERLAY';
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

///An Android-specific class used to configure the style of the scrollbars.
///The scrollbars can be overlaid or inset.
///When inset, they add to the padding of the view. And the scrollbars can be drawn inside the padding area or on the edge of the view.
///For example, if a view has a background drawable and you want to draw the scrollbars inside the padding specified by the drawable,
///you can use [AndroidScrollBarStyle.SCROLLBARS_INSIDE_OVERLAY] or [AndroidScrollBarStyle.SCROLLBARS_INSIDE_INSET].
///If you want them to appear at the edge of the view, ignoring the padding,
///then you can use [AndroidScrollBarStyle.SCROLLBARS_OUTSIDE_OVERLAY] or [AndroidScrollBarStyle.SCROLLBARS_OUTSIDE_INSET].
///
///Use [ScrollBarStyle] instead.
@Deprecated('Use ScrollBarStyle instead')
class AndroidScrollBarStyle {
  final int _value;
  final int? _nativeValue;
  const AndroidScrollBarStyle._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory AndroidScrollBarStyle._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => AndroidScrollBarStyle._internal(value, nativeValue());

  ///The scrollbar style to display the scrollbars inside the padded area, increasing the padding of the view.
  ///The scrollbars will not overlap the content area of the view.
  static const SCROLLBARS_INSIDE_INSET = AndroidScrollBarStyle._internal(
    16777216,
    16777216,
  );

  ///The scrollbar style to display the scrollbars inside the content area, without increasing the padding.
  ///The scrollbars will be overlaid with translucency on the view's content.
  static const SCROLLBARS_INSIDE_OVERLAY = AndroidScrollBarStyle._internal(
    0,
    0,
  );

  ///The scrollbar style to display the scrollbars at the edge of the view, increasing the padding of the view.
  ///The scrollbars will only overlap the background, if any.
  static const SCROLLBARS_OUTSIDE_INSET = AndroidScrollBarStyle._internal(
    50331648,
    50331648,
  );

  ///The scrollbar style to display the scrollbars at the edge of the view, without increasing the padding.
  ///The scrollbars will be overlaid with translucency.
  static const SCROLLBARS_OUTSIDE_OVERLAY = AndroidScrollBarStyle._internal(
    33554432,
    33554432,
  );

  ///Set of all values of [AndroidScrollBarStyle].
  static final Set<AndroidScrollBarStyle> values = [
    AndroidScrollBarStyle.SCROLLBARS_INSIDE_INSET,
    AndroidScrollBarStyle.SCROLLBARS_INSIDE_OVERLAY,
    AndroidScrollBarStyle.SCROLLBARS_OUTSIDE_INSET,
    AndroidScrollBarStyle.SCROLLBARS_OUTSIDE_OVERLAY,
  ].toSet();

  ///Gets a possible [AndroidScrollBarStyle] instance from [int] value.
  static AndroidScrollBarStyle? fromValue(int? value) {
    if (value != null) {
      try {
        return AndroidScrollBarStyle.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [AndroidScrollBarStyle] instance from a native value.
  static AndroidScrollBarStyle? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return AndroidScrollBarStyle.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [AndroidScrollBarStyle] instance value with name [name].
  ///
  /// Goes through [AndroidScrollBarStyle.values] looking for a value with
  /// name [name], as reported by [AndroidScrollBarStyle.name].
  /// Returns the first value with the given name, otherwise `null`.
  static AndroidScrollBarStyle? byName(String? name) {
    if (name != null) {
      try {
        return AndroidScrollBarStyle.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [AndroidScrollBarStyle] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, AndroidScrollBarStyle> asNameMap() =>
      <String, AndroidScrollBarStyle>{
        for (final value in AndroidScrollBarStyle.values) value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 16777216:
        return 'SCROLLBARS_INSIDE_INSET';
      case 0:
        return 'SCROLLBARS_INSIDE_OVERLAY';
      case 50331648:
        return 'SCROLLBARS_OUTSIDE_INSET';
      case 33554432:
        return 'SCROLLBARS_OUTSIDE_OVERLAY';
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
