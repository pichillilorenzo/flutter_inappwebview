// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environment_scrollbar_style.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///The ScrollBar style used during [PlatformWebViewEnvironment] creation.
class EnvironmentScrollbarStyle {
  final int _value;
  final int _nativeValue;
  const EnvironmentScrollbarStyle._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory EnvironmentScrollbarStyle._internalMultiPlatform(
          int value, Function nativeValue) =>
      EnvironmentScrollbarStyle._internal(value, nativeValue());

  ///Browser default ScrollBar style.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  static final DEFAULT =
      EnvironmentScrollbarStyle._internalMultiPlatform(0, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 0;
      default:
        break;
    }
    return null;
  });

  ///Window style fluent overlay scroll bar.
  ///Please see [Fluent UI](https://developer.microsoft.com/fluentui#/) for more details on fluent UI.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  static final FLUENT_OVERLAY =
      EnvironmentScrollbarStyle._internalMultiPlatform(1, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return 1;
      default:
        break;
    }
    return null;
  });

  ///Set of all values of [EnvironmentScrollbarStyle].
  static final Set<EnvironmentScrollbarStyle> values = [
    EnvironmentScrollbarStyle.DEFAULT,
    EnvironmentScrollbarStyle.FLUENT_OVERLAY,
  ].toSet();

  ///Gets a possible [EnvironmentScrollbarStyle] instance from [int] value.
  static EnvironmentScrollbarStyle? fromValue(int? value) {
    if (value != null) {
      try {
        return EnvironmentScrollbarStyle.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [EnvironmentScrollbarStyle] instance from a native value.
  static EnvironmentScrollbarStyle? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return EnvironmentScrollbarStyle.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [EnvironmentScrollbarStyle] instance value with name [name].
  ///
  /// Goes through [EnvironmentScrollbarStyle.values] looking for a value with
  /// name [name], as reported by [EnvironmentScrollbarStyle.name].
  /// Returns the first value with the given name, otherwise `null`.
  static EnvironmentScrollbarStyle? byName(String? name) {
    if (name != null) {
      try {
        return EnvironmentScrollbarStyle.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [EnvironmentScrollbarStyle] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, EnvironmentScrollbarStyle> asNameMap() =>
      <String, EnvironmentScrollbarStyle>{
        for (final value in EnvironmentScrollbarStyle.values)
          value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 0:
        return 'DEFAULT';
      case 1:
        return 'FLUENT_OVERLAY';
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
