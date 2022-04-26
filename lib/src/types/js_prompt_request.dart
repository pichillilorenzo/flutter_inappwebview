import '../in_app_webview/webview.dart';

///Class that represents the request of the [WebView.onJsPrompt] event.
class JsPromptRequest {
  ///The url of the page requesting the dialog.
  Uri? url;

  ///Message to be displayed in the window.
  String? message;

  ///The default value displayed in the prompt dialog.
  String? defaultValue;

  ///Use [isMainFrame] instead.
  @Deprecated("Use isMainFrame instead")
  bool? iosIsMainFrame;

  ///Indicates whether the request was made for the main frame.
  ///
  ///**NOTE**: available only on iOS.
  bool? isMainFrame;

  JsPromptRequest(
      {this.url,
        this.message,
        this.defaultValue,
        @Deprecated("Use isMainFrame instead") this.iosIsMainFrame,
        this.isMainFrame}) {
    // ignore: deprecated_member_use_from_same_package
    this.isMainFrame = this.isMainFrame ?? this.iosIsMainFrame;
  }

  ///Gets a possible [JsPromptRequest] instance from a [Map] value.
  static JsPromptRequest? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return JsPromptRequest(
        url: map["url"] != null ? Uri.parse(map["url"]) : null,
        message: map["message"],
        defaultValue: map["defaultValue"],
        // ignore: deprecated_member_use_from_same_package
        iosIsMainFrame: map["isMainFrame"],
        isMainFrame: map["isMainFrame"]);
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "url": url?.toString(),
      "message": message,
      "defaultValue": defaultValue,
      // ignore: deprecated_member_use_from_same_package
      "iosIsMainFrame": isMainFrame ?? iosIsMainFrame,
      // ignore: deprecated_member_use_from_same_package
      "isMainFrame": isMainFrame ?? iosIsMainFrame
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