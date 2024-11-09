// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'js_prompt_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the response used by the [PlatformWebViewCreationParams.onJsPrompt] event to control a JavaScript prompt dialog.
class JsPromptResponse {
  ///Action used to confirm that the user hit confirm or cancel button.
  JsPromptResponseAction? action;

  ///Title of the cancel button.
  String cancelButtonTitle;

  ///Title of the confirm button.
  String confirmButtonTitle;

  ///The default value displayed in the prompt dialog.
  String defaultValue;

  ///Whether the client will handle the prompt dialog.
  bool handledByClient;

  ///Message to be displayed in the window.
  String message;

  ///Value of the prompt dialog.
  String? value;
  JsPromptResponse(
      {this.action = JsPromptResponseAction.CANCEL,
      this.cancelButtonTitle = "",
      this.confirmButtonTitle = "",
      this.defaultValue = "",
      this.handledByClient = false,
      this.message = "",
      this.value});

  ///Gets a possible [JsPromptResponse] instance from a [Map] value.
  static JsPromptResponse? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = JsPromptResponse(
      value: map['value'],
    );
    instance.action = switch (enumMethod ?? EnumMethod.nativeValue) {
      EnumMethod.nativeValue =>
        JsPromptResponseAction.fromNativeValue(map['action']),
      EnumMethod.value => JsPromptResponseAction.fromValue(map['action']),
      EnumMethod.name => JsPromptResponseAction.byName(map['action'])
    };
    if (map['cancelButtonTitle'] != null) {
      instance.cancelButtonTitle = map['cancelButtonTitle'];
    }
    if (map['confirmButtonTitle'] != null) {
      instance.confirmButtonTitle = map['confirmButtonTitle'];
    }
    if (map['defaultValue'] != null) {
      instance.defaultValue = map['defaultValue'];
    }
    if (map['handledByClient'] != null) {
      instance.handledByClient = map['handledByClient'];
    }
    if (map['message'] != null) {
      instance.message = map['message'];
    }
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "action": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => action?.toNativeValue(),
        EnumMethod.value => action?.toValue(),
        EnumMethod.name => action?.name()
      },
      "cancelButtonTitle": cancelButtonTitle,
      "confirmButtonTitle": confirmButtonTitle,
      "defaultValue": defaultValue,
      "handledByClient": handledByClient,
      "message": message,
      "value": value,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'JsPromptResponse{action: $action, cancelButtonTitle: $cancelButtonTitle, confirmButtonTitle: $confirmButtonTitle, defaultValue: $defaultValue, handledByClient: $handledByClient, message: $message, value: $value}';
  }
}
