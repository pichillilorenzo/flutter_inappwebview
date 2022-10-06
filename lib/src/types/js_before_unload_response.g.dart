// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'js_before_unload_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the response used by the [WebView.onJsBeforeUnload] event to control a JavaScript alert dialog.
class JsBeforeUnloadResponse {
  ///Message to be displayed in the window.
  String message;

  ///Title of the confirm button.
  String confirmButtonTitle;

  ///Title of the cancel button.
  String cancelButtonTitle;

  ///Whether the client will handle the alert dialog.
  bool handledByClient;

  ///Action used to confirm that the user hit confirm or cancel button.
  JsBeforeUnloadResponseAction? action;
  JsBeforeUnloadResponse(
      {this.message = "",
      this.confirmButtonTitle = "",
      this.cancelButtonTitle = "",
      this.handledByClient = false,
      this.action = JsBeforeUnloadResponseAction.CONFIRM});

  ///Gets a possible [JsBeforeUnloadResponse] instance from a [Map] value.
  static JsBeforeUnloadResponse? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = JsBeforeUnloadResponse();
    instance.message = map['message'];
    instance.confirmButtonTitle = map['confirmButtonTitle'];
    instance.cancelButtonTitle = map['cancelButtonTitle'];
    instance.handledByClient = map['handledByClient'];
    instance.action =
        JsBeforeUnloadResponseAction.fromNativeValue(map['action']);
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "message": message,
      "confirmButtonTitle": confirmButtonTitle,
      "cancelButtonTitle": cancelButtonTitle,
      "handledByClient": handledByClient,
      "action": action?.toNativeValue(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'JsBeforeUnloadResponse{message: $message, confirmButtonTitle: $confirmButtonTitle, cancelButtonTitle: $cancelButtonTitle, handledByClient: $handledByClient, action: $action}';
  }
}
