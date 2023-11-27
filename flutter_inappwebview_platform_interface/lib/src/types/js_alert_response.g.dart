// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'js_alert_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the response used by the [PlatformWebViewCreationParams.onJsAlert] event to control a JavaScript alert dialog.
class JsAlertResponse {
  ///Action used to confirm that the user hit confirm button.
  JsAlertResponseAction? action;

  ///Title of the confirm button.
  String confirmButtonTitle;

  ///Whether the client will handle the alert dialog.
  bool handledByClient;

  ///Message to be displayed in the window.
  String message;
  JsAlertResponse(
      {this.action = JsAlertResponseAction.CONFIRM,
      this.confirmButtonTitle = "",
      this.handledByClient = false,
      this.message = ""});

  ///Gets a possible [JsAlertResponse] instance from a [Map] value.
  static JsAlertResponse? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = JsAlertResponse();
    instance.action = JsAlertResponseAction.fromNativeValue(map['action']);
    instance.confirmButtonTitle = map['confirmButtonTitle'];
    instance.handledByClient = map['handledByClient'];
    instance.message = map['message'];
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "action": action?.toNativeValue(),
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
    return 'JsAlertResponse{action: $action, confirmButtonTitle: $confirmButtonTitle, handledByClient: $handledByClient, message: $message}';
  }
}
