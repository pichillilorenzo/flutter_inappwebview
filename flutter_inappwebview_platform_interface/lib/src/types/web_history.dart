import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'web_history_item.dart';
import 'enum_method.dart';

part 'web_history.g.dart';

///This class contains a snapshot of the current back/forward list for a `WebView`.
@ExchangeableObject()
class WebHistory_ {
  ///List of all [WebHistoryItem]s.
  List<WebHistoryItem_>? list;

  ///Index of the current [WebHistoryItem].
  int? currentIndex;

  WebHistory_({this.list, this.currentIndex});
}
