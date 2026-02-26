import 'dart:typed_data';

import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../web_uri.dart';
import 'enum_method.dart';

part 'favicon_changed_request.g.dart';

///Class that represents the request used by the [PlatformWebViewCreationParams.onFaviconChanged] event.
@ExchangeableObject()
class FaviconChangedRequest_ {
  ///The favicon URL for the current page, if available.
  WebUri? url;

  ///The favicon bytes for the current page, if available.
  Uint8List? icon;

  FaviconChangedRequest_({this.url, this.icon});
}
