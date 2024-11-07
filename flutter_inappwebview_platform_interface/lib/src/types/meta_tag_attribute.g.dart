// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meta_tag_attribute.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents an attribute of a `<meta>` HTML tag. It is used by the [MetaTag] class.
class MetaTagAttribute {
  ///The attribute name.
  String? name;

  ///The attribute value.
  String? value;
  MetaTagAttribute({this.name, this.value});

  ///Gets a possible [MetaTagAttribute] instance from a [Map] value.
  static MetaTagAttribute? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = MetaTagAttribute(
      name: map['name'],
      value: map['value'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "name": name,
      "value": value,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'MetaTagAttribute{name: $name, value: $value}';
  }
}
