// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fetch_request_credential.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that is an interface for [FetchRequestCredentialDefault], [FetchRequestFederatedCredential] and [FetchRequestPasswordCredential] classes.
class FetchRequestCredential {
  ///Type of credentials.
  String? type;
  FetchRequestCredential({this.type});

  ///Gets a possible [FetchRequestCredential] instance from a [Map] value.
  static FetchRequestCredential? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = FetchRequestCredential(
      type: map['type'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "type": type,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'FetchRequestCredential{type: $type}';
  }
}
