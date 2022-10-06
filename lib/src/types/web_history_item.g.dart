// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_history_item.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///A convenience class for accessing fields in an entry in the back/forward list of a [WebView].
///Each [WebHistoryItem] is a snapshot of the requested history item.
class WebHistoryItem {
  ///Original url of this history item.
  Uri? originalUrl;

  ///Document title of this history item.
  String? title;

  ///Url of this history item.
  Uri? url;

  ///0-based position index in the back-forward [WebHistory.list].
  int? index;

  ///Position offset respect to the currentIndex of the back-forward [WebHistory.list].
  int? offset;
  WebHistoryItem(
      {this.originalUrl, this.title, this.url, this.index, this.offset});

  ///Gets a possible [WebHistoryItem] instance from a [Map] value.
  static WebHistoryItem? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = WebHistoryItem(
      originalUrl:
          map['originalUrl'] != null ? Uri.parse(map['originalUrl']) : null,
      title: map['title'],
      url: map['url'] != null ? Uri.parse(map['url']) : null,
      index: map['index'],
      offset: map['offset'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "originalUrl": originalUrl?.toString(),
      "title": title,
      "url": url?.toString(),
      "index": index,
      "offset": offset,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'WebHistoryItem{originalUrl: $originalUrl, title: $title, url: $url, index: $index, offset: $offset}';
  }
}
