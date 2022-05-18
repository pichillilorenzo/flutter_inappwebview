import '../in_app_webview/webview.dart';

///Class that represents the request of the [WebView.onJsBeforeUnload] event.
class JsBeforeUnloadRequest {
  ///The url of the page requesting the dialog.
  Uri? url;

  ///Message to be displayed in the window.
  String? message;

  JsBeforeUnloadRequest({this.url, this.message});

  ///Gets a possible [JsBeforeUnloadRequest] instance from a [Map] value.
  static JsBeforeUnloadRequest? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return JsBeforeUnloadRequest(
      url: map["url"] != null ? Uri.parse(map["url"]) : null,
      message: map["message"],
    );
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {"url": url?.toString(), "message": message};
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