// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'layout_algorithm.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used to set the underlying layout algorithm.
class LayoutAlgorithm {
  final String _value;
  final String _nativeValue;
  const LayoutAlgorithm._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory LayoutAlgorithm._internalMultiPlatform(
          String value, Function nativeValue) =>
      LayoutAlgorithm._internal(value, nativeValue());

  ///NARROW_COLUMNS makes all columns no wider than the screen if possible. Only use this for API levels prior to `Build.VERSION_CODES.KITKAT`.
  static const NARROW_COLUMNS =
      LayoutAlgorithm._internal('NARROW_COLUMNS', 'NARROW_COLUMNS');

  ///NORMAL means no rendering changes. This is the recommended choice for maximum compatibility across different platforms and Android versions.
  static const NORMAL = LayoutAlgorithm._internal('NORMAL', 'NORMAL');

  ///TEXT_AUTOSIZING boosts font size of paragraphs based on heuristics to make the text readable when viewing a wide-viewport layout in the overview mode.
  ///It is recommended to enable zoom support [InAppWebViewSettings.supportZoom] when using this mode.
  ///
  ///**NOTE**: available on Android 19+.
  static const TEXT_AUTOSIZING =
      LayoutAlgorithm._internal('TEXT_AUTOSIZING', 'TEXT_AUTOSIZING');

  ///Set of all values of [LayoutAlgorithm].
  static final Set<LayoutAlgorithm> values = [
    LayoutAlgorithm.NARROW_COLUMNS,
    LayoutAlgorithm.NORMAL,
    LayoutAlgorithm.TEXT_AUTOSIZING,
  ].toSet();

  ///Gets a possible [LayoutAlgorithm] instance from [String] value.
  static LayoutAlgorithm? fromValue(String? value) {
    if (value != null) {
      try {
        return LayoutAlgorithm.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [LayoutAlgorithm] instance from a native value.
  static LayoutAlgorithm? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return LayoutAlgorithm.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [LayoutAlgorithm] instance value with name [name].
  ///
  /// Goes through [LayoutAlgorithm.values] looking for a value with
  /// name [name], as reported by [LayoutAlgorithm.name].
  /// Returns the first value with the given name, otherwise `null`.
  static LayoutAlgorithm? byName(String? name) {
    if (name != null) {
      try {
        return LayoutAlgorithm.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [LayoutAlgorithm] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, LayoutAlgorithm> asNameMap() => <String, LayoutAlgorithm>{
        for (final value in LayoutAlgorithm.values) value.name(): value
      };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value.
  String toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'NARROW_COLUMNS':
        return 'NARROW_COLUMNS';
      case 'NORMAL':
        return 'NORMAL';
      case 'TEXT_AUTOSIZING':
        return 'TEXT_AUTOSIZING';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    return _value;
  }
}

///An Android-specific class used to set the underlying layout algorithm.
///Use [LayoutAlgorithm] instead.
@Deprecated('Use LayoutAlgorithm instead')
class AndroidLayoutAlgorithm {
  final String _value;
  final String _nativeValue;
  const AndroidLayoutAlgorithm._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory AndroidLayoutAlgorithm._internalMultiPlatform(
          String value, Function nativeValue) =>
      AndroidLayoutAlgorithm._internal(value, nativeValue());

  ///NARROW_COLUMNS makes all columns no wider than the screen if possible. Only use this for API levels prior to `Build.VERSION_CODES.KITKAT`.
  static const NARROW_COLUMNS =
      AndroidLayoutAlgorithm._internal('NARROW_COLUMNS', 'NARROW_COLUMNS');

  ///NORMAL means no rendering changes. This is the recommended choice for maximum compatibility across different platforms and Android versions.
  static const NORMAL = AndroidLayoutAlgorithm._internal('NORMAL', 'NORMAL');

  ///TEXT_AUTOSIZING boosts font size of paragraphs based on heuristics to make the text readable when viewing a wide-viewport layout in the overview mode.
  ///It is recommended to enable zoom support [InAppWebViewOptions.supportZoom] when using this mode.
  ///
  ///**NOTE**: available on Android 19+.
  static const TEXT_AUTOSIZING =
      AndroidLayoutAlgorithm._internal('TEXT_AUTOSIZING', 'TEXT_AUTOSIZING');

  ///Set of all values of [AndroidLayoutAlgorithm].
  static final Set<AndroidLayoutAlgorithm> values = [
    AndroidLayoutAlgorithm.NARROW_COLUMNS,
    AndroidLayoutAlgorithm.NORMAL,
    AndroidLayoutAlgorithm.TEXT_AUTOSIZING,
  ].toSet();

  ///Gets a possible [AndroidLayoutAlgorithm] instance from [String] value.
  static AndroidLayoutAlgorithm? fromValue(String? value) {
    if (value != null) {
      try {
        return AndroidLayoutAlgorithm.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [AndroidLayoutAlgorithm] instance from a native value.
  static AndroidLayoutAlgorithm? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return AndroidLayoutAlgorithm.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [AndroidLayoutAlgorithm] instance value with name [name].
  ///
  /// Goes through [AndroidLayoutAlgorithm.values] looking for a value with
  /// name [name], as reported by [AndroidLayoutAlgorithm.name].
  /// Returns the first value with the given name, otherwise `null`.
  static AndroidLayoutAlgorithm? byName(String? name) {
    if (name != null) {
      try {
        return AndroidLayoutAlgorithm.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [AndroidLayoutAlgorithm] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, AndroidLayoutAlgorithm> asNameMap() =>
      <String, AndroidLayoutAlgorithm>{
        for (final value in AndroidLayoutAlgorithm.values) value.name(): value
      };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value.
  String toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'NARROW_COLUMNS':
        return 'NARROW_COLUMNS';
      case 'NORMAL':
        return 'NORMAL';
      case 'TEXT_AUTOSIZING':
        return 'TEXT_AUTOSIZING';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    return _value;
  }
}
