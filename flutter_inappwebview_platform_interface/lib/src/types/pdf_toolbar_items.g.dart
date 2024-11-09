// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_toolbar_items.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class used to customize the PDF toolbar items.
class PdfToolbarItems {
  final int _value;
  final int _nativeValue;
  const PdfToolbarItems._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory PdfToolbarItems._internalMultiPlatform(
          int value, Function nativeValue) =>
      PdfToolbarItems._internal(value, nativeValue());

  ///The bookmarks button.
  static const BOOKMARKS = PdfToolbarItems._internal(256, 256);

  ///The fit page button.
  static const FIT_PAGE = PdfToolbarItems._internal(64, 64);

  ///The full screen button.
  static const FULL_SCREEN = PdfToolbarItems._internal(2048, 2048);

  ///The more settings button.
  static const MORE_SETTINGS = PdfToolbarItems._internal(4096, 4096);

  ///No item.
  static const NONE = PdfToolbarItems._internal(0, 0);

  ///The page layout button.
  static const PAGE_LAYOUT = PdfToolbarItems._internal(128, 128);

  ///The page select button.
  static const PAGE_SELECTOR = PdfToolbarItems._internal(512, 512);

  ///The print button.
  static const PRINT = PdfToolbarItems._internal(2, 2);

  ///The rotate button.
  static const ROTATE = PdfToolbarItems._internal(32, 32);

  ///The save button.
  static const SAVE = PdfToolbarItems._internal(1, 1);

  ///The save as button.
  static const SAVE_AS = PdfToolbarItems._internal(4, 4);

  ///The search button.
  static const SEARCH = PdfToolbarItems._internal(1024, 1024);

  ///The zoom in button.
  static const ZOOM_IN = PdfToolbarItems._internal(8, 8);

  ///The zoom out button.
  static const ZOOM_OUT = PdfToolbarItems._internal(16, 16);

  ///Set of all values of [PdfToolbarItems].
  static final Set<PdfToolbarItems> values = [
    PdfToolbarItems.BOOKMARKS,
    PdfToolbarItems.FIT_PAGE,
    PdfToolbarItems.FULL_SCREEN,
    PdfToolbarItems.MORE_SETTINGS,
    PdfToolbarItems.NONE,
    PdfToolbarItems.PAGE_LAYOUT,
    PdfToolbarItems.PAGE_SELECTOR,
    PdfToolbarItems.PRINT,
    PdfToolbarItems.ROTATE,
    PdfToolbarItems.SAVE,
    PdfToolbarItems.SAVE_AS,
    PdfToolbarItems.SEARCH,
    PdfToolbarItems.ZOOM_IN,
    PdfToolbarItems.ZOOM_OUT,
  ].toSet();

  ///Gets a possible [PdfToolbarItems] instance from [int] value.
  static PdfToolbarItems? fromValue(int? value) {
    if (value != null) {
      try {
        return PdfToolbarItems.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return PdfToolbarItems._internal(value, value);
      }
    }
    return null;
  }

  ///Gets a possible [PdfToolbarItems] instance from a native value.
  static PdfToolbarItems? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return PdfToolbarItems.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return PdfToolbarItems._internal(value, value);
      }
    }
    return null;
  }

  /// Gets a possible [PdfToolbarItems] instance value with name [name].
  ///
  /// Goes through [PdfToolbarItems.values] looking for a value with
  /// name [name], as reported by [PdfToolbarItems.name].
  /// Returns the first value with the given name, otherwise `null`.
  static PdfToolbarItems? byName(String? name) {
    if (name != null) {
      try {
        return PdfToolbarItems.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [PdfToolbarItems] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, PdfToolbarItems> asNameMap() => <String, PdfToolbarItems>{
        for (final value in PdfToolbarItems.values) value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 256:
        return 'BOOKMARKS';
      case 64:
        return 'FIT_PAGE';
      case 2048:
        return 'FULL_SCREEN';
      case 4096:
        return 'MORE_SETTINGS';
      case 0:
        return 'NONE';
      case 128:
        return 'PAGE_LAYOUT';
      case 512:
        return 'PAGE_SELECTOR';
      case 2:
        return 'PRINT';
      case 32:
        return 'ROTATE';
      case 1:
        return 'SAVE';
      case 4:
        return 'SAVE_AS';
      case 1024:
        return 'SEARCH';
      case 8:
        return 'ZOOM_IN';
      case 16:
        return 'ZOOM_OUT';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  PdfToolbarItems operator |(PdfToolbarItems value) =>
      PdfToolbarItems._internal(
          value.toValue() | _value, value.toNativeValue() | _nativeValue);
  @override
  String toString() {
    return name();
  }
}
