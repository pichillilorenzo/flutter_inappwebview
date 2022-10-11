import '../web_message/main.dart';

///The listener for handling [WebMessageListener] events sent by a `postMessage()` on the injected JavaScript object.
typedef void OnPostMessageCallback(String? message, Uri? sourceOrigin,
    bool isMainFrame, JavaScriptReplyProxy replyProxy);
