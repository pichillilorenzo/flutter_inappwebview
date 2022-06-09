// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'js_prompt_request.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the request of the [WebView.onJsPrompt] event.
class JsPromptRequest {
  ///The url of the page requesting the dialog.
  Uri? url;

  ///Message to be displayed in the window.
  String? message;

  ///The default value displayed in the prompt dialog.
  String? defaultValue;

  ///Use [isMainFrame] instead.
  @Deprecated('Use isMainFrame instead')
  bool? iosIsMainFrame;

  ///Indicates whether the request was made for the main frame.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  bool? isMainFrame;
  JsPromptRequest(
      {this.url,
      this.message,
      this.defaultValue,
      @Deprecated('Use isMainFrame instead') this.iosIsMainFrame,
      this.isMainFrame}) {
    isMainFrame = isMainFrame ?? iosIsMainFrame;
  }

  ///Gets a possible [JsPromptRequest] instance from a [Map] value.
  static JsPromptRequest? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = JsPromptRequest(
      url: map['url'] != null ? Uri.parse(map['url']) : null,
      message: map['message'],
      defaultValue: map['defaultValue'],
      iosIsMainFrame: map['isMainFrame'],
      isMainFrame: map['isMainFrame'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "url": url?.toString(),
      "message": message,
      "defaultValue": defaultValue,
      "isMainFrame": isMainFrame,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'JsPromptRequest{url: $url, message: $message, defaultValue: $defaultValue, isMainFrame: $isMainFrame}';
  }
}
