// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'layout_in_display_cutout_mode.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class representing the share state that should be applied to the custom tab.
class LayoutInDisplayCutoutMode {
  final int _value;
  final int _nativeValue;
  const LayoutInDisplayCutoutMode._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory LayoutInDisplayCutoutMode._internalMultiPlatform(
          int value, Function nativeValue) =>
      LayoutInDisplayCutoutMode._internal(value, nativeValue());

  ///With this default setting, content renders into the cutout area when displayed in portrait mode, but content is letterboxed when displayed in landscape mode.
  ///
  ///**NOTE**: available on Android 28+.
  static const DEFAULT = LayoutInDisplayCutoutMode._internal(0, 0);

  ///Content renders into the cutout area in both portrait and landscape modes.
  ///
  ///**NOTE**: available on Android 28+.
  static const SHORT_EDGES = LayoutInDisplayCutoutMode._internal(1, 1);

  ///Content never renders into the cutout area.
  ///
  ///**NOTE**: available on Android 28+.
  static const NEVER = LayoutInDisplayCutoutMode._internal(2, 2);

  ///The window is always allowed to extend into the DisplayCutout areas on the all edges of the screen.
  ///
  ///**NOTE**: available on Android 30+.
  static const ALWAYS = LayoutInDisplayCutoutMode._internal(3, 3);

  ///Set of all values of [LayoutInDisplayCutoutMode].
  static final Set<LayoutInDisplayCutoutMode> values = [
    LayoutInDisplayCutoutMode.DEFAULT,
    LayoutInDisplayCutoutMode.SHORT_EDGES,
    LayoutInDisplayCutoutMode.NEVER,
    LayoutInDisplayCutoutMode.ALWAYS,
  ].toSet();

  ///Gets a possible [LayoutInDisplayCutoutMode] instance from [int] value.
  static LayoutInDisplayCutoutMode? fromValue(int? value) {
    if (value != null) {
      try {
        return LayoutInDisplayCutoutMode.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [LayoutInDisplayCutoutMode] instance from a native value.
  static LayoutInDisplayCutoutMode? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return LayoutInDisplayCutoutMode.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    switch (_value) {
      case 0:
        return 'DEFAULT';
      case 1:
        return 'SHORT_EDGES';
      case 2:
        return 'NEVER';
      case 3:
        return 'ALWAYS';
    }
    return _value.toString();
  }
}

///Android-specific class representing the share state that should be applied to the custom tab.
///
///**NOTE**: available on Android 28+.
///
///Use [LayoutInDisplayCutoutMode] instead.
@Deprecated('Use LayoutInDisplayCutoutMode instead')
class AndroidLayoutInDisplayCutoutMode {
  final int _value;
  final int _nativeValue;
  const AndroidLayoutInDisplayCutoutMode._internal(
      this._value, this._nativeValue);
// ignore: unused_element
  factory AndroidLayoutInDisplayCutoutMode._internalMultiPlatform(
          int value, Function nativeValue) =>
      AndroidLayoutInDisplayCutoutMode._internal(value, nativeValue());

  ///With this default setting, content renders into the cutout area when displayed in portrait mode, but content is letterboxed when displayed in landscape mode.
  ///
  ///**NOTE**: available on Android 28+.
  static const DEFAULT = AndroidLayoutInDisplayCutoutMode._internal(0, 0);

  ///Content renders into the cutout area in both portrait and landscape modes.
  ///
  ///**NOTE**: available on Android 28+.
  static const SHORT_EDGES = AndroidLayoutInDisplayCutoutMode._internal(1, 1);

  ///Content never renders into the cutout area.
  ///
  ///**NOTE**: available on Android 28+.
  static const NEVER = AndroidLayoutInDisplayCutoutMode._internal(2, 2);

  ///The window is always allowed to extend into the DisplayCutout areas on the all edges of the screen.
  ///
  ///**NOTE**: available on Android 30+.
  static const ALWAYS = AndroidLayoutInDisplayCutoutMode._internal(3, 3);

  ///Set of all values of [AndroidLayoutInDisplayCutoutMode].
  static final Set<AndroidLayoutInDisplayCutoutMode> values = [
    AndroidLayoutInDisplayCutoutMode.DEFAULT,
    AndroidLayoutInDisplayCutoutMode.SHORT_EDGES,
    AndroidLayoutInDisplayCutoutMode.NEVER,
    AndroidLayoutInDisplayCutoutMode.ALWAYS,
  ].toSet();

  ///Gets a possible [AndroidLayoutInDisplayCutoutMode] instance from [int] value.
  static AndroidLayoutInDisplayCutoutMode? fromValue(int? value) {
    if (value != null) {
      try {
        return AndroidLayoutInDisplayCutoutMode.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [AndroidLayoutInDisplayCutoutMode] instance from a native value.
  static AndroidLayoutInDisplayCutoutMode? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return AndroidLayoutInDisplayCutoutMode.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    switch (_value) {
      case 0:
        return 'DEFAULT';
      case 1:
        return 'SHORT_EDGES';
      case 2:
        return 'NEVER';
      case 3:
        return 'ALWAYS';
    }
    return _value.toString();
  }
}
