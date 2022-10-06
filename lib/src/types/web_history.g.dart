// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_history.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///This class contains a snapshot of the current back/forward list for a [WebView].
class WebHistory {
  ///List of all [WebHistoryItem]s.
  List<WebHistoryItem>? list;

  ///Index of the current [WebHistoryItem].
  int? currentIndex;
  WebHistory({this.list, this.currentIndex});

  ///Gets a possible [WebHistory] instance from a [Map] value.
  static WebHistory? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = WebHistory(
      list: map['list'] != null
          ? List<WebHistoryItem>.from(map['list']
              .map((e) => WebHistoryItem.fromMap(e?.cast<String, dynamic>())!))
          : null,
      currentIndex: map['currentIndex'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "list": list?.map((e) => e.toMap()).toList(),
      "currentIndex": currentIndex,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'WebHistory{list: $list, currentIndex: $currentIndex}';
  }
}
