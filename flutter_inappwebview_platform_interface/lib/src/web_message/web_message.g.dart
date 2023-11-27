// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_message.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///The type corresponding to the [WebMessage].
class WebMessageType {
  final int _value;
  final int _nativeValue;
  const WebMessageType._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory WebMessageType._internalMultiPlatform(
          int value, Function nativeValue) =>
      WebMessageType._internal(value, nativeValue());

  ///Indicates the payload of WebMessageCompat is JavaScript ArrayBuffer.
  ///
  ///**NOTE**: available only if [WebViewFeature.WEB_MESSAGE_ARRAY_BUFFER] feature is supported.
  static const ARRAY_BUFFER = WebMessageType._internal(1, 1);

  ///Indicates the payload of WebMessageCompat is String.
  static const STRING = WebMessageType._internal(0, 0);

  ///Set of all values of [WebMessageType].
  static final Set<WebMessageType> values = [
    WebMessageType.ARRAY_BUFFER,
    WebMessageType.STRING,
  ].toSet();

  ///Gets a possible [WebMessageType] instance from [int] value.
  static WebMessageType? fromValue(int? value) {
    if (value != null) {
      try {
        return WebMessageType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [WebMessageType] instance from a native value.
  static WebMessageType? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return WebMessageType.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return 'ARRAY_BUFFER';
      case 0:
        return 'STRING';
    }
    return _value.toString();
  }
}

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///The Dart representation of the HTML5 PostMessage event.
///See https://html.spec.whatwg.org/multipage/comms.html#the-messageevent-interfaces for definition of a MessageEvent in HTML5.
class WebMessage {
  ///The data of the message.
  dynamic data;

  ///The ports that are sent with the message.
  List<IWebMessagePort>? ports;

  ///The payload type of the message.
  WebMessageType type;
  WebMessage({this.data, this.type = WebMessageType.STRING, this.ports}) {
    assert(((this.data == null || this.data is String) &&
            this.type == WebMessageType.STRING) ||
        (this.data != null &&
            this.data is Uint8List &&
            this.type == WebMessageType.ARRAY_BUFFER));
  }

  ///Gets a possible [WebMessage] instance from a [Map] value.
  static WebMessage? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = WebMessage(
      data: map['data'],
      ports: map['ports'] != null
          ? List<IWebMessagePort>.from(map['ports'].map((e) => e))
          : null,
      type: WebMessageType.fromNativeValue(map['type'])!,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "data": data,
      "ports": ports?.map((e) => e.toMap()).toList(),
      "type": type.toNativeValue(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'WebMessage{data: $data, ports: $ports, type: $type}';
  }
}
