// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fetch_request_password_credential.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents a [PasswordCredential](https://developer.mozilla.org/en-US/docs/Web/API/PasswordCredential) type of credentials.
class FetchRequestPasswordCredential extends FetchRequestCredential {
  ///URL pointing to an image for an icon. This image is intended for display in a credential chooser. The URL must be accessible without authentication.
  WebUri? iconURL;

  ///Credential's identifier.
  dynamic id;

  ///The name associated with a credential. It should be a human-readable, public name.
  String? name;

  ///The password of the credential.
  String? password;
  FetchRequestPasswordCredential(
      {this.iconURL, this.id, this.name, this.password, String? type})
      : super(type: type);

  ///Gets a possible [FetchRequestPasswordCredential] instance from a [Map] value.
  static FetchRequestPasswordCredential? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = FetchRequestPasswordCredential(
      iconURL: map['iconURL'] != null ? WebUri(map['iconURL']) : null,
      id: map['id'],
      name: map['name'],
      password: map['password'],
    );
    instance.type = map['type'];
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "type": type,
      "iconURL": iconURL?.toString(),
      "id": id,
      "name": name,
      "password": password,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'FetchRequestPasswordCredential{type: $type, iconURL: $iconURL, id: $id, name: $name, password: $password}';
  }
}
