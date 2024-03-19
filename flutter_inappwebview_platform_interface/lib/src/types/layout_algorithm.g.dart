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
