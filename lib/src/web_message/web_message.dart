import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'web_message_port.dart';

part 'web_message.g.dart';

///The Dart representation of the HTML5 PostMessage event.
///See https://html.spec.whatwg.org/multipage/comms.html#the-messageevent-interfaces for definition of a MessageEvent in HTML5.
@ExchangeableObject()
class WebMessage_ {
  ///The data of the message.
  String? data;

  ///The ports that are sent with the message.
  List<WebMessagePort>? ports;

  WebMessage_({this.data, this.ports});
}
