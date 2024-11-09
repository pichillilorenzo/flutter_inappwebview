// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_storage_item.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents a single web storage item of the JavaScript `window.sessionStorage` and `window.localStorage` objects.
class WebStorageItem {
  ///Item key.
  String? key;

  ///Item value.
  dynamic value;
  WebStorageItem({this.key, this.value});

  ///Gets a possible [WebStorageItem] instance from a [Map] value.
  static WebStorageItem? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = WebStorageItem(
      key: map['key'],
      value: map['value'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "key": key,
      "value": value,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'WebStorageItem{key: $key, value: $value}';
  }
}
