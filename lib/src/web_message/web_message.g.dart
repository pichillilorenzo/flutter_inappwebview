// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_message.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///The Dart representation of the HTML5 PostMessage event.
///See https://html.spec.whatwg.org/multipage/comms.html#the-messageevent-interfaces for definition of a MessageEvent in HTML5.
class WebMessage {
  ///The data of the message.
  String? data;

  ///The ports that are sent with the message.
  List<WebMessagePort>? ports;
  WebMessage({this.data, this.ports});

  ///Gets a possible [WebMessage] instance from a [Map] value.
  static WebMessage? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = WebMessage(
      data: map['data'],
      ports: map['ports'] != null
          ? List<WebMessagePort>.from(map['ports'].map((e) => e))
          : null,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "data": data,
      "ports": ports?.map((e) => e.toMap()).toList(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'WebMessage{data: $data, ports: $ports}';
  }
}
