// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'url_protection_space_http_auth_credentials.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

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
    final instance = URLProtectionSpaceHttpAuthCredentials(
      protectionSpace: URLProtectionSpace.fromMap(
          map['protectionSpace']?.cast<String, dynamic>()),
      credentials: map['credentials'] != null
          ? List<URLCredential>.from(map['credentials']
              .map((e) => URLCredential.fromMap(e?.cast<String, dynamic>())!))
          : null,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "protectionSpace": protectionSpace?.toMap(),
      "credentials": credentials?.map((e) => e.toMap()).toList(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'URLProtectionSpaceHttpAuthCredentials{protectionSpace: $protectionSpace, credentials: $credentials}';
  }
}
