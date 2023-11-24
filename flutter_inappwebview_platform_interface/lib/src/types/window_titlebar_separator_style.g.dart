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
  ///- MacOS
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
  ///- MacOS
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
  ///- MacOS
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
  ///- MacOS
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

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int?] native value.
  int? toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
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
}
