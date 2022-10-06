// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'js_prompt_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

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
      this.confirmButtonTitle = "",
      this.cancelButtonTitle = "",
      this.handledByClient = false,
      this.value,
      this.action = JsPromptResponseAction.CANCEL});

  ///Gets a possible [JsPromptResponse] instance from a [Map] value.
  static JsPromptResponse? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = JsPromptResponse(
      value: map['value'],
    );
    instance.message = map['message'];
    instance.defaultValue = map['defaultValue'];
    instance.confirmButtonTitle = map['confirmButtonTitle'];
    instance.cancelButtonTitle = map['cancelButtonTitle'];
    instance.handledByClient = map['handledByClient'];
    instance.action = JsPromptResponseAction.fromNativeValue(map['action']);
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "message": message,
      "defaultValue": defaultValue,
      "confirmButtonTitle": confirmButtonTitle,
      "cancelButtonTitle": cancelButtonTitle,
      "handledByClient": handledByClient,
      "value": value,
      "action": action?.toNativeValue(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'JsPromptResponse{message: $message, defaultValue: $defaultValue, confirmButtonTitle: $confirmButtonTitle, cancelButtonTitle: $cancelButtonTitle, handledByClient: $handledByClient, value: $value, action: $action}';
  }
}
