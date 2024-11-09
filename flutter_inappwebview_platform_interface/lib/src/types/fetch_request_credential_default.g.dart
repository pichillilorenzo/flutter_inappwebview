// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fetch_request_credential_default.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the default credentials used by an [FetchRequest].
class FetchRequestCredentialDefault extends FetchRequestCredential {
  ///The value of the credentials.
  String? value;
  FetchRequestCredentialDefault({this.value, String? type}) : super(type: type);

  ///Gets a possible [FetchRequestCredentialDefault] instance from a [Map] value.
  static FetchRequestCredentialDefault? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = FetchRequestCredentialDefault(
      value: map['value'],
    );
    instance.type = map['type'];
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "type": type,
      "value": value,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'FetchRequestCredentialDefault{type: $type, value: $value}';
  }
}
