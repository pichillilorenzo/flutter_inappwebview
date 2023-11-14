import '../web_message/main.dart';

///The listener for handling [WebMessagePort] events.
///The message callback methods are called on the main thread.
typedef void WebMessageCallback(WebMessage? message);
