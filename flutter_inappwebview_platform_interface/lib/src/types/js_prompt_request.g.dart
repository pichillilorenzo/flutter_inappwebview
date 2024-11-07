// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'js_prompt_request.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the request of the [PlatformWebViewCreationParams.onJsPrompt] event.
class JsPromptRequest {
  ///The default value displayed in the prompt dialog.
  String? defaultValue;

  ///Use [isMainFrame] instead.
  @Deprecated('Use isMainFrame instead')
  bool? iosIsMainFrame;

  ///Indicates whether the request was made for the main frame.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  bool? isMainFrame;

  ///Message to be displayed in the window.
  String? message;

  ///The url of the page requesting the dialog.
  WebUri? url;
  JsPromptRequest(
      {this.defaultValue,
      @Deprecated('Use isMainFrame instead') this.iosIsMainFrame,
      this.isMainFrame,
      this.message,
      this.url}) {
    isMainFrame = isMainFrame ?? iosIsMainFrame;
  }

  ///Gets a possible [JsPromptRequest] instance from a [Map] value.
  static JsPromptRequest? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = JsPromptRequest(
      defaultValue: map['defaultValue'],
      iosIsMainFrame: map['isMainFrame'],
      isMainFrame: map['isMainFrame'],
      message: map['message'],
      url: map['url'] != null ? WebUri(map['url']) : null,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "defaultValue": defaultValue,
      "isMainFrame": isMainFrame,
      "message": message,
      "url": url?.toString(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'JsPromptRequest{defaultValue: $defaultValue, isMainFrame: $isMainFrame, message: $message, url: $url}';
  }
}
