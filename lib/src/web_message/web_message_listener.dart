import 'package:flutter/services.dart';

class WebMessageListener {
  String jsObjectName;
  late Set<String> allowedOriginRules;
  JavaScriptReplyProxy? _replyProxy;
  Function(String? message, Uri? sourceOrigin, bool isMainFrame, JavaScriptReplyProxy replyProxy)? onPostMessage;

  late MethodChannel _channel;

  WebMessageListener({required this.jsObjectName, Set<String>? allowedOriginRules, this.onPostMessage}) {
    this.allowedOriginRules = allowedOriginRules != null ? allowedOriginRules : Set.from(["*"]);
    assert(!this.allowedOriginRules.contains(""), "allowedOriginRules cannot contain empty strings");
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
          Uri? sourceOrigin = call.arguments["sourceOrigin"] != null ? Uri.parse(call.arguments["sourceOrigin"]) : null;
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

class JavaScriptReplyProxy {
  late WebMessageListener _webMessageListener;

  JavaScriptReplyProxy(WebMessageListener webMessageListener) {
    this._webMessageListener = webMessageListener;
  }

  Future<void> postMessage(String message) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('message', () => message);
    await _webMessageListener._channel.invokeMethod('postMessage', args);
  }
}
