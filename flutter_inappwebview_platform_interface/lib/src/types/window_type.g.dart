// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'window_type.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents how a browser window should be added to the main window.
class WindowType {
  final String _value;
  final String _nativeValue;
  const WindowType._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory WindowType._internalMultiPlatform(
          String value, Function nativeValue) =>
      WindowType._internal(value, nativeValue());

  ///Adds the new browser window as a child window of the main window.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  ///- Windows
  static final CHILD = WindowType._internalMultiPlatform('CHILD', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
        return 'CHILD';
      case TargetPlatform.windows:
        return 'CHILD';
      default:
        break;
    }
    return null;
  });

  ///Adds the new browser window as a new tab in a tabbed window of the main window.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS 10.12++
  static final TABBED = WindowType._internalMultiPlatform('TABBED', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
        return 'TABBED';
      default:
        break;
    }
    return null;
  });

  ///Adds the new browser window as a separate new window from the main window.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  ///- Windows
  static final WINDOW = WindowType._internalMultiPlatform('WINDOW', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
        return 'WINDOW';
      case TargetPlatform.windows:
        return 'WINDOW';
      default:
        break;
    }
    return null;
  });

  ///Set of all values of [WindowType].
  static final Set<WindowType> values = [
    WindowType.CHILD,
    WindowType.TABBED,
    WindowType.WINDOW,
  ].toSet();

  ///Gets a possible [WindowType] instance from [String] value.
  static WindowType? fromValue(String? value) {
    if (value != null) {
      try {
        return WindowType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [WindowType] instance from a native value.
  static WindowType? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return WindowType.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value.
  String toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    return _value;
  }
}
