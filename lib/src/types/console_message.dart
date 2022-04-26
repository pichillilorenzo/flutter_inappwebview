import '../in_app_webview/webview.dart';

import 'console_message_level.dart';

///Class representing a JavaScript console message from WebCore.
///This could be a issued by a call to one of the console logging functions (e.g. console.log('...')) or a JavaScript error on the page.
///
///To receive notifications of these messages, use the [WebView.onConsoleMessage] event.
class ConsoleMessage {
  ///Console message
  String message;

  ///Console messsage level
  ConsoleMessageLevel messageLevel;

  ConsoleMessage(
      {this.message = "", this.messageLevel = ConsoleMessageLevel.LOG});

  ///Gets a possible [ConsoleMessage] instance from a [Map] value.
  static ConsoleMessage? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return ConsoleMessage(
      message: map["message"],
      messageLevel: ConsoleMessageLevel.fromValue(map["messageLevel"]) ??
          ConsoleMessageLevel.LOG,
    );
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {"message": message, "messageLevel": messageLevel.toValue()};
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