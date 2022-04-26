import 'dart:collection';

import '../in_app_webview/webview.dart';

import 'web_history_item.dart';

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

    List<LinkedHashMap<dynamic, dynamic>>? historyListMap =
    map["history"]?.cast<LinkedHashMap<dynamic, dynamic>>();
    int currentIndex = map["currentIndex"];

    List<WebHistoryItem> historyList = <WebHistoryItem>[];
    if (historyListMap != null) {
      for (var i = 0; i < historyListMap.length; i++) {
        var historyItem = historyListMap[i];
        historyList.add(WebHistoryItem(
            originalUrl: historyItem["originalUrl"] != null
                ? Uri.parse(historyItem["originalUrl"])
                : null,
            title: historyItem["title"],
            url: historyItem["url"] != null
                ? Uri.parse(historyItem["url"])
                : null,
            index: i,
            offset: i - currentIndex));
      }
    }

    return WebHistory(list: historyList, currentIndex: currentIndex);
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {"list": list, "currentIndex": currentIndex};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}