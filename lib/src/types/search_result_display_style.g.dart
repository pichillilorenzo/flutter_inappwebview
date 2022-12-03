// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_result_display_style.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Constants that describe the results summary the find panel UI includes.
class SearchResultDisplayStyle {
  final int _value;
  final int _nativeValue;
  const SearchResultDisplayStyle._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory SearchResultDisplayStyle._internalMultiPlatform(
          int value, Function nativeValue) =>
      SearchResultDisplayStyle._internal(value, nativeValue());

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
        return SearchResultDisplayStyle.values
            .firstWhere((element) => element.toValue() == value);
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
        return SearchResultDisplayStyle.values
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
        return 'CURRENT_AND_TOTAL';
      case 2:
        return 'NONE';
      case 1:
        return 'TOTAL';
    }
    return _value.toString();
  }
}
