// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'js_before_unload_request.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

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
    final instance = JsBeforeUnloadRequest(
      url: map['url'] != null ? Uri.parse(map['url']) : null,
      message: map['message'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "url": url?.toString(),
      "message": message,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'JsBeforeUnloadRequest{url: $url, message: $message}';
  }
}
