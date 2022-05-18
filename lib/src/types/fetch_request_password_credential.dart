import 'fetch_request_credential.dart';

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
      {type, this.id, this.name, this.password, this.iconURL})
      : super(type: type);

  ///Gets a possible [FetchRequestPasswordCredential] instance from a [Map] value.
  static FetchRequestPasswordCredential? fromMap(
      Map<String, dynamic>? credentialsMap) {
    if (credentialsMap == null) {
      return null;
    }
    return FetchRequestPasswordCredential(
        type: credentialsMap["type"],
        id: credentialsMap["id"],
        name: credentialsMap["name"],
        password: credentialsMap["password"],
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
      "password": password,
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