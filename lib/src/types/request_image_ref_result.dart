import '../in_app_webview/in_app_webview_controller.dart';

///Class that represents the result used by the [InAppWebViewController.requestImageRef] method.
class RequestImageRefResult {
  ///The image's url.
  Uri? url;

  RequestImageRefResult({this.url});

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "url": url?.toString(),
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