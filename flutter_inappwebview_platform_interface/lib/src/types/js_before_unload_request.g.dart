// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'js_before_unload_request.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the request of the [PlatformWebViewCreationParams.onJsBeforeUnload] event.
class JsBeforeUnloadRequest {
  ///Message to be displayed in the window.
  String? message;

  ///The url of the page requesting the dialog.
  WebUri? url;
  JsBeforeUnloadRequest({this.message, this.url});

  ///Gets a possible [JsBeforeUnloadRequest] instance from a [Map] value.
  static JsBeforeUnloadRequest? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = JsBeforeUnloadRequest(
      message: map['message'],
      url: map['url'] != null ? WebUri(map['url']) : null,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "message": message,
      "url": url?.toString(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'JsBeforeUnloadRequest{message: $message, url: $url}';
  }
}
