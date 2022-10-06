// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'js_alert_request.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the request of the [WebView.onJsAlert] event.
class JsAlertRequest {
  ///The url of the page requesting the dialog.
  Uri? url;

  ///Message to be displayed in the window.
  String? message;

  ///Use [isMainFrame] instead.
  @Deprecated('Use isMainFrame instead')
  bool? iosIsMainFrame;

  ///Indicates whether the request was made for the main frame.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  bool? isMainFrame;
  JsAlertRequest(
      {this.url,
      this.message,
      @Deprecated('Use isMainFrame instead') this.iosIsMainFrame,
      this.isMainFrame}) {
    isMainFrame = isMainFrame ?? iosIsMainFrame;
  }

  ///Gets a possible [JsAlertRequest] instance from a [Map] value.
  static JsAlertRequest? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = JsAlertRequest(
      url: map['url'] != null ? Uri.parse(map['url']) : null,
      message: map['message'],
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
      "isMainFrame": isMainFrame,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'JsAlertRequest{url: $url, message: $message, isMainFrame: $isMainFrame}';
  }
}
