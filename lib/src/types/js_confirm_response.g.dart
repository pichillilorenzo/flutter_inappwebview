// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'js_confirm_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the response used by the [WebView.onJsConfirm] event to control a JavaScript confirm dialog.
class JsConfirmResponse {
  ///Message to be displayed in the window.
  String message;

  ///Title of the confirm button.
  String confirmButtonTitle;

  ///Title of the cancel button.
  String cancelButtonTitle;

  ///Whether the client will handle the confirm dialog.
  bool handledByClient;

  ///Action used to confirm that the user hit confirm or cancel button.
  JsConfirmResponseAction? action;
  JsConfirmResponse(
      {this.message = "",
      this.confirmButtonTitle = "",
      this.cancelButtonTitle = "",
      this.handledByClient = false,
      this.action = JsConfirmResponseAction.CANCEL});

  ///Gets a possible [JsConfirmResponse] instance from a [Map] value.
  static JsConfirmResponse? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = JsConfirmResponse();
    instance.message = map['message'];
    instance.confirmButtonTitle = map['confirmButtonTitle'];
    instance.cancelButtonTitle = map['cancelButtonTitle'];
    instance.handledByClient = map['handledByClient'];
    instance.action = JsConfirmResponseAction.fromNativeValue(map['action']);
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
    return 'JsConfirmResponse{message: $message, confirmButtonTitle: $confirmButtonTitle, cancelButtonTitle: $cancelButtonTitle, handledByClient: $handledByClient, action: $action}';
  }
}
