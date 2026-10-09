// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_history.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///This class contains a snapshot of the current back/forward list for a `WebView`.
class WebHistory {
  ///Index of the current [WebHistoryItem].
  int? currentIndex;

  ///List of all [WebHistoryItem]s.
  List<WebHistoryItem>? list;
  WebHistory({this.currentIndex, this.list});

  ///Gets a possible [WebHistory] instance from a [Map] value.
  static WebHistory? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = WebHistory(
      currentIndex: map['currentIndex'],
      list: map['list'] != null
          ? List<WebHistoryItem>.from(
              map['list'].map(
                (e) => WebHistoryItem.fromMap(
                  e?.cast<String, dynamic>(),
                  enumMethod: enumMethod,
                )!,
              ),
            )
          : null,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "currentIndex": currentIndex,
      "list": list?.map((e) => e.toMap(enumMethod: enumMethod)).toList(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'WebHistory{currentIndex: $currentIndex, list: $list}';
  }
}
