import '../web_message/main.dart';
import '../web_uri.dart';

///The listener for handling [PlatformWebMessageListener] events sent by a `postMessage()` on the injected JavaScript object.
typedef void OnPostMessageCallback(
  WebMessage? message,
  WebUri? sourceOrigin,
  bool isMainFrame,
  PlatformJavaScriptReplyProxy replyProxy,
);
