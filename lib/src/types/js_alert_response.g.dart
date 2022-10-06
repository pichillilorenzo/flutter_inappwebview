// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'js_alert_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the response used by the [WebView.onJsAlert] event to control a JavaScript alert dialog.
class JsAlertResponse {
  ///Message to be displayed in the window.
  String message;

  ///Title of the confirm button.
  String confirmButtonTitle;

  ///Whether the client will handle the alert dialog.
  bool handledByClient;

  ///Action used to confirm that the user hit confirm button.
  JsAlertResponseAction? action;
  JsAlertResponse(
      {this.message = "",
      this.confirmButtonTitle = "",
      this.handledByClient = false,
      this.action = JsAlertResponseAction.CONFIRM});

  ///Gets a possible [JsAlertResponse] instance from a [Map] value.
  static JsAlertResponse? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = JsAlertResponse();
    instance.message = map['message'];
    instance.confirmButtonTitle = map['confirmButtonTitle'];
    instance.handledByClient = map['handledByClient'];
    instance.action = JsAlertResponseAction.fromNativeValue(map['action']);
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "message": message,
      "confirmButtonTitle": confirmButtonTitle,
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
    return 'JsAlertResponse{message: $message, confirmButtonTitle: $confirmButtonTitle, handledByClient: $handledByClient, action: $action}';
  }
}
