// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'window_titlebar_separator_style.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the type of separator that the app displays between the title bar and content of a browser window.
class WindowTitlebarSeparatorStyle {
  final int _value;
  final int? _nativeValue;
  const WindowTitlebarSeparatorStyle._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory WindowTitlebarSeparatorStyle._internalMultiPlatform(
          int value, Function nativeValue) =>
      WindowTitlebarSeparatorStyle._internal(value, nativeValue());

  ///A style indicating that the system determines the type of separator.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  static final AUTOMATIC =
      WindowTitlebarSeparatorStyle._internalMultiPlatform(0, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
        return 0;
      default:
        break;
    }
    return null;
  });

  ///A style indicating that there’s no title bar separator.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  static final LINE =
      WindowTitlebarSeparatorStyle._internalMultiPlatform(2, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
        return 2;
      default:
        break;
    }
    return null;
  });

  ///A style indicating that the title bar separator is a line.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  static final NONE =
      WindowTitlebarSeparatorStyle._internalMultiPlatform(1, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
        return 1;
      default:
        break;
    }
    return null;
  });

  ///A style indicating that the title bar separator is a shadow.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  static final SHADOW =
      WindowTitlebarSeparatorStyle._internalMultiPlatform(3, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
        return 3;
      default:
        break;
    }
    return null;
  });

  ///Set of all values of [WindowTitlebarSeparatorStyle].
  static final Set<WindowTitlebarSeparatorStyle> values = [
    WindowTitlebarSeparatorStyle.AUTOMATIC,
    WindowTitlebarSeparatorStyle.LINE,
    WindowTitlebarSeparatorStyle.NONE,
    WindowTitlebarSeparatorStyle.SHADOW,
  ].toSet();

  ///Gets a possible [WindowTitlebarSeparatorStyle] instance from [int] value.
  static WindowTitlebarSeparatorStyle? fromValue(int? value) {
    if (value != null) {
      try {
        return WindowTitlebarSeparatorStyle.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [WindowTitlebarSeparatorStyle] instance from a native value.
  static WindowTitlebarSeparatorStyle? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return WindowTitlebarSeparatorStyle.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [WindowTitlebarSeparatorStyle] instance value with name [name].
  ///
  /// Goes through [WindowTitlebarSeparatorStyle.values] looking for a value with
  /// name [name], as reported by [WindowTitlebarSeparatorStyle.name].
  /// Returns the first value with the given name, otherwise `null`.
  static WindowTitlebarSeparatorStyle? byName(String? name) {
    if (name != null) {
      try {
        return WindowTitlebarSeparatorStyle.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [WindowTitlebarSeparatorStyle] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, WindowTitlebarSeparatorStyle> asNameMap() =>
      <String, WindowTitlebarSeparatorStyle>{
        for (final value in WindowTitlebarSeparatorStyle.values)
          value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 0:
        return 'AUTOMATIC';
      case 2:
        return 'LINE';
      case 1:
        return 'NONE';
      case 3:
        return 'SHADOW';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  ///Checks if the value is supported by the [defaultTargetPlatform].
  bool isSupported() {
    return toNativeValue() != null;
  }

  @override
  String toString() {
    return name();
  }
}
