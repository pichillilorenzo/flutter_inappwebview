import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../in_app_webview/platform_webview.dart';
import 'console_message_level.dart';
import 'enum_method.dart';

part 'console_message.g.dart';

///Class representing a JavaScript console message from WebCore.
///This could be a issued by a call to one of the console logging functions (e.g. console.log('...')) or a JavaScript error on the page.
///
///To receive notifications of these messages, use the [PlatformWebViewCreationParams.onConsoleMessage] event.
@ExchangeableObject()
class ConsoleMessage_ {
  ///Console message
  String message;

  ///Console message level
  ConsoleMessageLevel_ messageLevel;

  ConsoleMessage_({
    this.message = "",
    this.messageLevel = ConsoleMessageLevel_.LOG,
  });
}
