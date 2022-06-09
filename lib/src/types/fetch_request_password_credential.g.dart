// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fetch_request_password_credential.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents a [PasswordCredential](https://developer.mozilla.org/en-US/docs/Web/API/PasswordCredential) type of credentials.
class FetchRequestPasswordCredential extends FetchRequestCredential {
  ///Credential's identifier.
  dynamic id;

  ///The name associated with a credential. It should be a human-readable, public name.
  String? name;

  ///The password of the credential.
  String? password;

  ///URL pointing to an image for an icon. This image is intended for display in a credential chooser. The URL must be accessible without authentication.
  Uri? iconURL;
  FetchRequestPasswordCredential(
      {this.id, this.name, this.password, this.iconURL, String? type})
      : super(type: type);

  ///Gets a possible [FetchRequestPasswordCredential] instance from a [Map] value.
  static FetchRequestPasswordCredential? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = FetchRequestPasswordCredential(
      id: map['id'],
      name: map['name'],
      password: map['password'],
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
      "password": password,
      "iconURL": iconURL?.toString(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'FetchRequestPasswordCredential{type: $type, id: $id, name: $name, password: $password, iconURL: $iconURL}';
  }
}
