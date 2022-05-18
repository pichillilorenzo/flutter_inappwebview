import 'fetch_request_credential.dart';

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
      {type, this.id, this.name, this.protocol, this.provider, this.iconURL})
      : super(type: type);

  ///Gets a possible [FetchRequestFederatedCredential] instance from a [Map] value.
  static FetchRequestFederatedCredential? fromMap(
      Map<String, dynamic>? credentialsMap) {
    if (credentialsMap == null) {
      return null;
    }
    return FetchRequestFederatedCredential(
        type: credentialsMap["type"],
        id: credentialsMap["id"],
        name: credentialsMap["name"],
        protocol: credentialsMap["protocol"],
        provider: credentialsMap["provider"],
        iconURL: credentialsMap["iconURL"] != null
            ? Uri.parse(credentialsMap["iconURL"])
            : null);
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "type": type,
      "id": id,
      "name": name,
      "protocol": protocol,
      "provider": provider,
      "iconURL": iconURL?.toString()
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}