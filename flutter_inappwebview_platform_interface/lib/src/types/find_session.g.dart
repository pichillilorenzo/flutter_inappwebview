// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_session.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

class FindSession {
  ///Returns the index of the currently highlighted result.
  ///If no result is currently highlighted.
  int highlightedResultIndex;

  ///Returns the total number of results.
  int resultCount;

  /// Defines how results are reported through the find panel's UI.
  SearchResultDisplayStyle searchResultDisplayStyle;
  FindSession(
      {required this.highlightedResultIndex,
      required this.resultCount,
      required this.searchResultDisplayStyle});

  ///Gets a possible [FindSession] instance from a [Map] value.
  static FindSession? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = FindSession(
      highlightedResultIndex: map['highlightedResultIndex'],
      resultCount: map['resultCount'],
      searchResultDisplayStyle: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => SearchResultDisplayStyle.fromNativeValue(
            map['searchResultDisplayStyle']),
        EnumMethod.value =>
          SearchResultDisplayStyle.fromValue(map['searchResultDisplayStyle']),
        EnumMethod.name =>
          SearchResultDisplayStyle.byName(map['searchResultDisplayStyle'])
      }!,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "highlightedResultIndex": highlightedResultIndex,
      "resultCount": resultCount,
      "searchResultDisplayStyle": switch (
          enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => searchResultDisplayStyle.toNativeValue(),
        EnumMethod.value => searchResultDisplayStyle.toValue(),
        EnumMethod.name => searchResultDisplayStyle.name()
      },
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'FindSession{highlightedResultIndex: $highlightedResultIndex, resultCount: $resultCount, searchResultDisplayStyle: $searchResultDisplayStyle}';
  }
}
