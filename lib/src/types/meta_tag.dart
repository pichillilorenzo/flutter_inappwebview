import '../in_app_webview/in_app_webview_controller.dart';
import 'meta_tag_attribute.dart';

///Class that represents a `<meta>` HTML tag. It is used by the [InAppWebViewController.getMetaTags] method.
class MetaTag {
  ///The meta tag name value.
  String? name;

  ///The meta tag content value.
  String? content;

  ///The meta tag attributes list.
  List<MetaTagAttribute>? attrs;

  MetaTag({this.name, this.content, this.attrs});

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {"name": name, "content": content, "attrs": attrs};
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