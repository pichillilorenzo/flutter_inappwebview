// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_result_display_style.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Constants that describe the results summary the find panel UI includes.
class SearchResultDisplayStyle {
  final int _value;
  final int? _nativeValue;
  const SearchResultDisplayStyle._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory SearchResultDisplayStyle._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => SearchResultDisplayStyle._internal(value, nativeValue());

  ///The find panel includes the total number of results the session reports and the index of the target result.
  static const CURRENT_AND_TOTAL = SearchResultDisplayStyle._internal(0, 0);

  ///The find panel doesn’t include the number of results the session reports.
  static const NONE = SearchResultDisplayStyle._internal(2, 2);

  ///The find panel includes the total number of results the session reports.
  static const TOTAL = SearchResultDisplayStyle._internal(1, 1);

  ///Set of all values of [SearchResultDisplayStyle].
  static final Set<SearchResultDisplayStyle> values = [
    SearchResultDisplayStyle.CURRENT_AND_TOTAL,
    SearchResultDisplayStyle.NONE,
    SearchResultDisplayStyle.TOTAL,
  ].toSet();

  ///Gets a possible [SearchResultDisplayStyle] instance from [int] value.
  static SearchResultDisplayStyle? fromValue(int? value) {
    if (value != null) {
      try {
        return SearchResultDisplayStyle.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [SearchResultDisplayStyle] instance from a native value.
  static SearchResultDisplayStyle? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return SearchResultDisplayStyle.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [SearchResultDisplayStyle] instance value with name [name].
  ///
  /// Goes through [SearchResultDisplayStyle.values] looking for a value with
  /// name [name], as reported by [SearchResultDisplayStyle.name].
  /// Returns the first value with the given name, otherwise `null`.
  static SearchResultDisplayStyle? byName(String? name) {
    if (name != null) {
      try {
        return SearchResultDisplayStyle.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [SearchResultDisplayStyle] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, SearchResultDisplayStyle> asNameMap() =>
      <String, SearchResultDisplayStyle>{
        for (final value in SearchResultDisplayStyle.values)
          value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 0:
        return 'CURRENT_AND_TOTAL';
      case 2:
        return 'NONE';
      case 1:
        return 'TOTAL';
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
