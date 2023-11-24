// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'js_confirm_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the response used by the [PlatformWebViewCreationParams.onJsConfirm] event to control a JavaScript confirm dialog.
class JsConfirmResponse {
  ///Action used to confirm that the user hit confirm or cancel button.
  JsConfirmResponseAction? action;

  ///Title of the cancel button.
  String cancelButtonTitle;

  ///Title of the confirm button.
  String confirmButtonTitle;

  ///Whether the client will handle the confirm dialog.
  bool handledByClient;

  ///Message to be displayed in the window.
  String message;
  JsConfirmResponse(
      {this.action = JsConfirmResponseAction.CANCEL,
      this.cancelButtonTitle = "",
      this.confirmButtonTitle = "",
      this.handledByClient = false,
      this.message = ""});

  ///Gets a possible [JsConfirmResponse] instance from a [Map] value.
  static JsConfirmResponse? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = JsConfirmResponse();
    instance.action = JsConfirmResponseAction.fromNativeValue(map['action']);
    instance.cancelButtonTitle = map['cancelButtonTitle'];
    instance.confirmButtonTitle = map['confirmButtonTitle'];
    instance.handledByClient = map['handledByClient'];
    instance.message = map['message'];
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "action": action?.toNativeValue(),
      "cancelButtonTitle": cancelButtonTitle,
      "confirmButtonTitle": confirmButtonTitle,
      "handledByClient": handledByClient,
      "message": message,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'JsConfirmResponse{action: $action, cancelButtonTitle: $cancelButtonTitle, confirmButtonTitle: $confirmButtonTitle, handledByClient: $handledByClient, message: $message}';
  }
}
