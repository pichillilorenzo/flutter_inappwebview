// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'url_protection_space_http_auth_credentials.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents a [URLProtectionSpace] with all of its [URLCredential]s.
///It used by [PlatformHttpAuthCredentialDatabase.getAllAuthCredentials].
class URLProtectionSpaceHttpAuthCredentials {
  ///The list of all its http authentication credentials.
  List<URLCredential>? credentials;

  ///The protection space.
  URLProtectionSpace? protectionSpace;
  URLProtectionSpaceHttpAuthCredentials(
      {this.credentials, this.protectionSpace});

  ///Gets a possible [URLProtectionSpaceHttpAuthCredentials] instance from a [Map] value.
  static URLProtectionSpaceHttpAuthCredentials? fromMap(
      Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = URLProtectionSpaceHttpAuthCredentials(
      credentials: map['credentials'] != null
          ? List<URLCredential>.from(map['credentials']
              .map((e) => URLCredential.fromMap(e?.cast<String, dynamic>())!))
          : null,
      protectionSpace: URLProtectionSpace.fromMap(
          map['protectionSpace']?.cast<String, dynamic>()),
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "credentials": credentials?.map((e) => e.toMap()).toList(),
      "protectionSpace": protectionSpace?.toMap(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'URLProtectionSpaceHttpAuthCredentials{credentials: $credentials, protectionSpace: $protectionSpace}';
  }
}
