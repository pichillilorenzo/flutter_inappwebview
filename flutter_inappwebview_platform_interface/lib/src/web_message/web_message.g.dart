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

  /// Gets a possible [WebMessageType] instance value with name [name].
  ///
  /// Goes through [WebMessageType.values] looking for a value with
  /// name [name], as reported by [WebMessageType.name].
  /// Returns the first value with the given name, otherwise `null`.
  static WebMessageType? byName(String? name) {
    if (name != null) {
      try {
        return WebMessageType.values
            .firstWhere((element) => element.name() == name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [WebMessageType] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, WebMessageType> asNameMap() => <String, WebMessageType>{
        for (final value in WebMessageType.values) value.name(): value
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 1:
        return 'ARRAY_BUFFER';
      case 0:
        return 'STRING';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  ///Checks if the value is supported by the [defaultTargetPlatform].
  bool isSupported() {
    return true;
  }

  @override
  String toString() {
    return name();
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
  static WebMessage? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = WebMessage(
      data: map['data'],
      ports: map['ports'] != null
          ? List<IWebMessagePort>.from(map['ports'].map((e) => e))
          : null,
      type: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => WebMessageType.fromNativeValue(map['type']),
        EnumMethod.value => WebMessageType.fromValue(map['type']),
        EnumMethod.name => WebMessageType.byName(map['type'])
      }!,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "data": data,
      "ports": ports?.map((e) => e.toMap(enumMethod: enumMethod)).toList(),
      "type": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => type.toNativeValue(),
        EnumMethod.value => type.toValue(),
        EnumMethod.name => type.name()
      },
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
