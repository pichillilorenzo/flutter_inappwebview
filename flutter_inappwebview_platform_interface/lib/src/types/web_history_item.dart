import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../web_uri.dart';
import 'web_history.dart';
import 'enum_method.dart';

part 'web_history_item.g.dart';

///A convenience class for accessing fields in an entry in the back/forward list of a `WebView`.
///Each [WebHistoryItem] is a snapshot of the requested history item.
@ExchangeableObject()
class WebHistoryItem_ {
  ///Original url of this history item.
  WebUri? originalUrl;

  ///Document title of this history item.
  String? title;

  ///Url of this history item.
  WebUri? url;

  ///0-based position index in the back-forward [WebHistory.list].
  int? index;

  ///Position offset respect to the currentIndex of the back-forward [WebHistory.list].
  int? offset;

  ///Unique id of the navigation history entry.
  @SupportedPlatforms(platforms: [WindowsPlatform()])
  int? entryId;

  WebHistoryItem_({
    this.originalUrl,
    this.title,
    this.url,
    this.index,
    this.offset,
    this.entryId,
  });
}
