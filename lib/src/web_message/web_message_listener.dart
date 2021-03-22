import 'package:flutter/services.dart';
import '../in_app_webview/in_app_webview_controller.dart';
import '../types.dart';

///This listener receives messages sent on the JavaScript object which was injected by [InAppWebViewController.addWebMessageListener].
class WebMessageListener {
  ///The name for the injected JavaScript object.
  final String jsObjectName;

  ///A set of matching rules for the allowed origins.
  late Set<String> allowedOriginRules;

  JavaScriptReplyProxy? _replyProxy;

  ///Event that receives a message sent by a `postMessage()` on the injected JavaScript object.
  ///
  ///Note that when the frame is `file:` or `content:` origin, the value of [sourceOrigin] is `null`.
  ///
  ///- [message] represents the message from JavaScript.
  ///- [sourceOrigin] represents the origin of the frame that the message is from.
  ///- [isMainFrame] is `true` if the message is from the main frame.
  ///- [replyProxy] is used to reply back to the JavaScript object.
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/WebViewCompat.WebMessageListener#onPostMessage(android.webkit.WebView,%20androidx.webkit.WebMessageCompat,%20android.net.Uri,%20boolean,%20androidx.webkit.JavaScriptReplyProxy)
  OnPostMessageCallback? onPostMessage;

  late MethodChannel _channel;

  WebMessageListener(
      {required this.jsObjectName,
      Set<String>? allowedOriginRules,
      this.onPostMessage}) {
    this.allowedOriginRules =
        allowedOriginRules != null ? allowedOriginRules : Set.from(["*"]);
    assert(!this.allowedOriginRules.contains(""),
        "allowedOriginRules cannot contain empty strings");
    this._channel = MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_web_message_listener_$jsObjectName');
    this._channel.setMethodCallHandler(handleMethod);
  }

  Future<dynamic> handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onPostMessage":
        if (_replyProxy == null) {
          _replyProxy = new JavaScriptReplyProxy(this);
        }
        if (onPostMessage != null) {
          String? message = call.arguments["message"];
          Uri? sourceOrigin = call.arguments["sourceOrigin"] != null
              ? Uri.parse(call.arguments["sourceOrigin"])
              : null;
          bool isMainFrame = call.arguments["isMainFrame"];
          onPostMessage!(message, sourceOrigin, isMainFrame, _replyProxy!);
        }
        break;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      "jsObjectName": jsObjectName,
      "allowedOriginRules": allowedOriginRules.toList(),
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///This class represents the JavaScript object injected by [InAppWebViewController.addWebMessageListener].
///An instance will be given by [WebMessageListener.onPostMessage].
///The app can use `postMessage(String)` to talk to the JavaScript context.
///
///There is a 1:1 relationship between this object and the JavaScript object in a frame.
class JavaScriptReplyProxy {
  late WebMessageListener _webMessageListener;

  JavaScriptReplyProxy(WebMessageListener webMessageListener) {
    this._webMessageListener = webMessageListener;
  }

  ///Post a [message] to the injected JavaScript object which sent this [JavaScriptReplyProxy].
  ///
  ///**Official Android API**: https://developer.android.com/reference/androidx/webkit/JavaScriptReplyProxy#postMessage(java.lang.String)
  Future<void> postMessage(String message) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('message', () => message);
    await _webMessageListener._channel.invokeMethod('postMessage', args);
  }
}
