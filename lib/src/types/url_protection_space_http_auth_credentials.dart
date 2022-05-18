import 'url_protection_space.dart';
import 'url_credential.dart';
import '../http_auth_credentials_database.dart';

///Class that represents a [URLProtectionSpace] with all of its [URLCredential]s.
///It used by [HttpAuthCredentialDatabase.getAllAuthCredentials].
class URLProtectionSpaceHttpAuthCredentials {
  ///The protection space.
  URLProtectionSpace? protectionSpace;

  ///The list of all its http authentication credentials.
  List<URLCredential>? credentials;

  URLProtectionSpaceHttpAuthCredentials(
      {this.protectionSpace, this.credentials});

  ///Gets a possible [URLProtectionSpaceHttpAuthCredentials] instance from a [Map] value.
  static URLProtectionSpaceHttpAuthCredentials? fromMap(
      Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }

    List<URLCredential>? credentials;
    if (map["credentials"] != null) {
      credentials = <URLCredential>[];
      (map["credentials"].cast<Map<String, dynamic>>()
      as List<Map<String, dynamic>>)
          .forEach((element) {
        var credential = URLCredential.fromMap(element);
        if (credential != null) {
          credentials!.add(credential);
        }
      });
    }

    return URLProtectionSpaceHttpAuthCredentials(
      protectionSpace: map["protectionSpace"] != null
          ? URLProtectionSpace.fromMap(
          map["protectionSpace"]?.cast<String, dynamic>())
          : null,
      credentials: credentials,
    );
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "protectionSpace": protectionSpace?.toMap(),
      "credentials": credentials != null
          ? credentials!.map((credential) => credential.toMap()).toList()
          : null
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