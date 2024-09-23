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
  static FindSession? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = FindSession(
      highlightedResultIndex: map['highlightedResultIndex'],
      resultCount: map['resultCount'],
      searchResultDisplayStyle: SearchResultDisplayStyle.fromNativeValue(
          map['searchResultDisplayStyle'])!,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "highlightedResultIndex": highlightedResultIndex,
      "resultCount": resultCount,
      "searchResultDisplayStyle": searchResultDisplayStyle.toNativeValue(),
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
