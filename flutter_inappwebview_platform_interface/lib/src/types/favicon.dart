import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../in_app_webview/platform_inappwebview_controller.dart';
import '../web_uri.dart';
import 'enum_method.dart';

part 'favicon.g.dart';

///Class that represents a favicon of a website. It is used by [PlatformInAppWebViewController.getFavicons] method.
@ExchangeableObject()
class Favicon_ {
  ///The url of the favicon image.
  WebUri url;

  ///The relationship between the current web page and the favicon image.
  String? rel;

  ///The width of the favicon image.
  int? width;

  ///The height of the favicon image.
  int? height;

  Favicon_({required this.url, this.rel, this.width, this.height});
}
