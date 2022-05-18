import '../in_app_webview/in_app_webview_controller.dart';

///Class that represents a favicon of a website. It is used by [InAppWebViewController.getFavicons] method.
class Favicon {
  ///The url of the favicon image.
  Uri url;

  ///The relationship between the current web page and the favicon image.
  String? rel;

  ///The width of the favicon image.
  int? width;

  ///The height of the favicon image.
  int? height;

  Favicon({required this.url, this.rel, this.width, this.height});

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "url": url.toString(),
      "rel": rel,
      "width": width,
      "height": height
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