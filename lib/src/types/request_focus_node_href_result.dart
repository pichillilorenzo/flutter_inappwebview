import '../in_app_webview/in_app_webview_controller.dart';

///Class that represents the result used by the [InAppWebViewController.requestFocusNodeHref] method.
class RequestFocusNodeHrefResult {
  ///The anchor's href attribute.
  Uri? url;

  ///The anchor's text.
  String? title;

  ///The image's src attribute.
  String? src;

  RequestFocusNodeHrefResult({this.url, this.title, this.src});

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {"url": url?.toString(), "title": title, "src": src};
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