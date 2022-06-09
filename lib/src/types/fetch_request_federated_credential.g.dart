// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fetch_request_federated_credential.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents a [FederatedCredential](https://developer.mozilla.org/en-US/docs/Web/API/FederatedCredential) type of credentials.
class FetchRequestFederatedCredential extends FetchRequestCredential {
  ///Credential's identifier.
  dynamic id;

  ///The name associated with a credential. It should be a human-readable, public name.
  String? name;

  ///Credential's federated identity protocol.
  String? protocol;

  ///Credential's federated identity provider.
  String? provider;

  ///URL pointing to an image for an icon. This image is intended for display in a credential chooser. The URL must be accessible without authentication.
  Uri? iconURL;
  FetchRequestFederatedCredential(
      {this.id,
      this.name,
      this.protocol,
      this.provider,
      this.iconURL,
      String? type})
      : super(type: type);

  ///Gets a possible [FetchRequestFederatedCredential] instance from a [Map] value.
  static FetchRequestFederatedCredential? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = FetchRequestFederatedCredential(
      id: map['id'],
      name: map['name'],
      protocol: map['protocol'],
      provider: map['provider'],
      iconURL: map['iconURL'] != null ? Uri.parse(map['iconURL']) : null,
    );
    instance.type = map['type'];
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "type": type,
      "id": id,
      "name": name,
      "protocol": protocol,
      "provider": provider,
      "iconURL": iconURL?.toString(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'FetchRequestFederatedCredential{type: $type, id: $id, name: $name, protocol: $protocol, provider: $provider, iconURL: $iconURL}';
  }
}
