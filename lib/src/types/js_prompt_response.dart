import '../in_app_webview/webview.dart';

import 'js_prompt_response_action.dart';

///Class that represents the response used by the [WebView.onJsPrompt] event to control a JavaScript prompt dialog.
class JsPromptResponse {
  ///Message to be displayed in the window.
  String message;

  ///The default value displayed in the prompt dialog.
  String defaultValue;

  ///Title of the confirm button.
  String confirmButtonTitle;

  ///Title of the cancel button.
  String cancelButtonTitle;

  ///Whether the client will handle the prompt dialog.
  bool handledByClient;

  ///Value of the prompt dialog.
  String? value;

  ///Action used to confirm that the user hit confirm or cancel button.
  JsPromptResponseAction? action;

  JsPromptResponse(
      {this.message = "",
        this.defaultValue = "",
        this.handledByClient = false,
        this.confirmButtonTitle = "",
        this.cancelButtonTitle = "",
        this.value,
        this.action = JsPromptResponseAction.CANCEL});

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "message": message,
      "defaultValue": defaultValue,
      "confirmButtonTitle": confirmButtonTitle,
      "cancelButtonTitle": cancelButtonTitle,
      "handledByClient": handledByClient,
      "value": value,
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