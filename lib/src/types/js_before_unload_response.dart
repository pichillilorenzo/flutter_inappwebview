import '../in_app_webview/webview.dart';

import 'js_before_unload_response_action.dart';

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
        this.handledByClient = false,
        this.confirmButtonTitle = "",
        this.cancelButtonTitle = "",
        this.action = JsBeforeUnloadResponseAction.CONFIRM});

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "message": message,
      "confirmButtonTitle": confirmButtonTitle,
      "cancelButtonTitle": cancelButtonTitle,
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