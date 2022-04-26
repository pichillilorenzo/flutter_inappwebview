import '../in_app_webview/webview.dart';

import 'web_history.dart';

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

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "originalUrl": originalUrl?.toString(),
      "title": title,
      "url": url?.toString(),
      "index": index,
      "offset": offset
    };
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