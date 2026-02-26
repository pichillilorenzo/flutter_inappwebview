import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../in_app_webview/platform_inappwebview_controller.dart';
import 'meta_tag_attribute.dart';
import 'enum_method.dart';

part 'meta_tag.g.dart';

///Class that represents a `<meta>` HTML tag. It is used by the [PlatformInAppWebViewController.getMetaTags] method.
@ExchangeableObject()
class MetaTag_ {
  ///The meta tag name value.
  String? name;

  ///The meta tag content value.
  String? content;

  ///The meta tag attributes list.
  List<MetaTagAttribute_>? attrs;

  MetaTag_({this.name, this.content, this.attrs});
}
