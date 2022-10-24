import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../chrome_safari_browser/chrome_safari_browser.dart';

part 'prewarming_token.g.dart';

///Class that represents the Prewarming Token returned by [ChromeSafariBrowser.prewarmConnections].
@ExchangeableObject()
class PrewarmingToken_ {
  ///Prewarming Token id.
  final String id;

  PrewarmingToken_({required this.id});
}
