import '../in_app_webview/webview.dart';

import 'js_alert_response_action.dart';

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
        this.handledByClient = false,
        this.confirmButtonTitle = "",
        this.action = JsAlertResponseAction.CONFIRM});

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "message": message,
      "confirmButtonTitle": confirmButtonTitle,
      "handledByClient": handledByClient,
      "action": action?.toValue()
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