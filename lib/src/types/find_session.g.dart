// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_session.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

class FindSession {
  ///Returns the total number of results.
  int resultCount;

  ///Returns the index of the currently highlighted result.
  ///If no result is currently highlighted.
  int highlightedResultIndex;

  /// Defines how results are reported through the find panel's UI.
  SearchResultDisplayStyle searchResultDisplayStyle;
  FindSession(
      {required this.resultCount,
      required this.highlightedResultIndex,
      required this.searchResultDisplayStyle});

  ///Gets a possible [FindSession] instance from a [Map] value.
  static FindSession? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = FindSession(
      resultCount: map['resultCount'],
      highlightedResultIndex: map['highlightedResultIndex'],
      searchResultDisplayStyle: SearchResultDisplayStyle.fromNativeValue(
          map['searchResultDisplayStyle'])!,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "resultCount": resultCount,
      "highlightedResultIndex": highlightedResultIndex,
      "searchResultDisplayStyle": searchResultDisplayStyle.toNativeValue(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'FindSession{resultCount: $resultCount, highlightedResultIndex: $highlightedResultIndex, searchResultDisplayStyle: $searchResultDisplayStyle}';
  }
}
