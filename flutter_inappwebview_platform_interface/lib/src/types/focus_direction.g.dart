// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_direction.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used to indicate the force dark mode.
class FocusDirection {
  final String _value;
  final dynamic _nativeValue;
  const FocusDirection._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory FocusDirection._internalMultiPlatform(
          String value, Function nativeValue) =>
      FocusDirection._internal(value, nativeValue());

  ///Move focus down.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - FOCUS_DOWN](https://developer.android.com/reference/android/view/View#FOCUS_DOWN))
  static final DOWN = FocusDirection._internalMultiPlatform('DOWN', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 130;
      default:
        break;
    }
    return null;
  });

  ///Move focus to the left.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - FOCUS_LEFT](https://developer.android.com/reference/android/view/View#FOCUS_LEFT))
  static final LEFT = FocusDirection._internalMultiPlatform('LEFT', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 130;
      default:
        break;
    }
    return null;
  });

  ///Move focus to the right.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - FOCUS_RIGHT](https://developer.android.com/reference/android/view/View#FOCUS_RIGHT))
  static final RIGHT = FocusDirection._internalMultiPlatform('RIGHT', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 130;
      default:
        break;
    }
    return null;
  });

  ///Move focus up.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - FOCUS_UP](https://developer.android.com/reference/android/view/View#FOCUS_UP))
  static final UP = FocusDirection._internalMultiPlatform('UP', () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 33;
      default:
        break;
    }
    return null;
  });

  ///Set of all values of [FocusDirection].
  static final Set<FocusDirection> values = [
    FocusDirection.DOWN,
    FocusDirection.LEFT,
    FocusDirection.RIGHT,
    FocusDirection.UP,
  ].toSet();

  ///Gets a possible [FocusDirection] instance from [String] value.
  static FocusDirection? fromValue(String? value) {
    if (value != null) {
      try {
        return FocusDirection.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [FocusDirection] instance from a native value.
  static FocusDirection? fromNativeValue(dynamic value) {
    if (value != null) {
      try {
        return FocusDirection.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [dynamic] native value.
  dynamic toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    return _value;
  }
}
