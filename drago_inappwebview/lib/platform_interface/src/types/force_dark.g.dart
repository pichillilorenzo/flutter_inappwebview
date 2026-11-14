// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'force_dark.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used to indicate the force dark mode.
class ForceDark {
  final int _value;
  final int? _nativeValue;
  const ForceDark._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory ForceDark._internalMultiPlatform(int value, Function nativeValue) =>
      ForceDark._internal(value, nativeValue());

  ///Enable force dark dependent on the state of the WebView parent view.
  static const AUTO = ForceDark._internal(1, 1);

  ///Disable force dark, irrespective of the force dark mode of the WebView parent.
  ///In this mode, WebView content will always be rendered as-is, regardless of whether native views are being automatically darkened.
  static const OFF = ForceDark._internal(0, 0);

  ///Unconditionally enable force dark. In this mode WebView content will always be rendered so as to emulate a dark theme.
  static const ON = ForceDark._internal(2, 2);

  ///Set of all values of [ForceDark].
  static final Set<ForceDark> values = [
    ForceDark.AUTO,
    ForceDark.OFF,
    ForceDark.ON,
  ].toSet();

  ///Gets a possible [ForceDark] instance from [int] value.
  static ForceDark? fromValue(int? value) {
    if (value != null) {
      try {
        return ForceDark.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [ForceDark] instance from a native value.
  static ForceDark? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return ForceDark.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [ForceDark] instance value with name [name].
  ///
  /// Goes through [ForceDark.values] looking for a value with
  /// name [name], as reported by [ForceDark.name].
  /// Returns the first value with the given name, otherwise `null`.
  static ForceDark? byName(String? name) {
    if (name != null) {
      try {
        return ForceDark.values.firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [ForceDark] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, ForceDark> asNameMap() => <String, ForceDark>{
    for (final value in ForceDark.values) value.name(): value,
  };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 1:
        return 'AUTO';
      case 0:
        return 'OFF';
      case 2:
        return 'ON';
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

///An Android-specific class used to indicate the force dark mode.
///
///**NOTE**: available on Android 29+.
///
///Use [ForceDark] instead.
@Deprecated('Use ForceDark instead')
class AndroidForceDark {
  final int _value;
  final int? _nativeValue;
  const AndroidForceDark._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory AndroidForceDark._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => AndroidForceDark._internal(value, nativeValue());

  ///Enable force dark dependent on the state of the WebView parent view.
  static const FORCE_DARK_AUTO = AndroidForceDark._internal(1, 1);

  ///Disable force dark, irrespective of the force dark mode of the WebView parent.
  ///In this mode, WebView content will always be rendered as-is, regardless of whether native views are being automatically darkened.
  static const FORCE_DARK_OFF = AndroidForceDark._internal(0, 0);

  ///Unconditionally enable force dark. In this mode WebView content will always be rendered so as to emulate a dark theme.
  static const FORCE_DARK_ON = AndroidForceDark._internal(2, 2);

  ///Set of all values of [AndroidForceDark].
  static final Set<AndroidForceDark> values = [
    AndroidForceDark.FORCE_DARK_AUTO,
    AndroidForceDark.FORCE_DARK_OFF,
    AndroidForceDark.FORCE_DARK_ON,
  ].toSet();

  ///Gets a possible [AndroidForceDark] instance from [int] value.
  static AndroidForceDark? fromValue(int? value) {
    if (value != null) {
      try {
        return AndroidForceDark.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [AndroidForceDark] instance from a native value.
  static AndroidForceDark? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return AndroidForceDark.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [AndroidForceDark] instance value with name [name].
  ///
  /// Goes through [AndroidForceDark.values] looking for a value with
  /// name [name], as reported by [AndroidForceDark.name].
  /// Returns the first value with the given name, otherwise `null`.
  static AndroidForceDark? byName(String? name) {
    if (name != null) {
      try {
        return AndroidForceDark.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [AndroidForceDark] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, AndroidForceDark> asNameMap() =>
      <String, AndroidForceDark>{
        for (final value in AndroidForceDark.values) value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 1:
        return 'FORCE_DARK_AUTO';
      case 0:
        return 'FORCE_DARK_OFF';
      case 2:
        return 'FORCE_DARK_ON';
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
