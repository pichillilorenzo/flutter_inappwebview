// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_history_item.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///A convenience class for accessing fields in an entry in the back/forward list of a `WebView`.
///Each [WebHistoryItem] is a snapshot of the requested history item.
class WebHistoryItem {
  ///Unique id of the navigation history entry.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows
  int? entryId;

  ///0-based position index in the back-forward [WebHistory.list].
  int? index;

  ///Position offset respect to the currentIndex of the back-forward [WebHistory.list].
  int? offset;

  ///Original url of this history item.
  WebUri? originalUrl;

  ///Document title of this history item.
  String? title;

  ///Url of this history item.
  WebUri? url;
  WebHistoryItem(
      {this.entryId,
      this.index,
      this.offset,
      this.originalUrl,
      this.title,
      this.url});

  ///Gets a possible [WebHistoryItem] instance from a [Map] value.
  static WebHistoryItem? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = WebHistoryItem(
      entryId: map['entryId'],
      index: map['index'],
      offset: map['offset'],
      originalUrl:
          map['originalUrl'] != null ? WebUri(map['originalUrl']) : null,
      title: map['title'],
      url: map['url'] != null ? WebUri(map['url']) : null,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "entryId": entryId,
      "index": index,
      "offset": offset,
      "originalUrl": originalUrl?.toString(),
      "title": title,
      "url": url?.toString(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'WebHistoryItem{entryId: $entryId, index: $index, offset: $offset, originalUrl: $originalUrl, title: $title, url: $url}';
  }
}
