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
  URLProtectionSpaceHttpAuthCredentials({
    this.credentials,
    this.protectionSpace,
  });

  ///Gets a possible [URLProtectionSpaceHttpAuthCredentials] instance from a [Map] value.
  static URLProtectionSpaceHttpAuthCredentials? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = URLProtectionSpaceHttpAuthCredentials(
      credentials: map['credentials'] != null
          ? List<URLCredential>.from(
              map['credentials'].map(
                (e) => URLCredential.fromMap(
                  e?.cast<String, dynamic>(),
                  enumMethod: enumMethod,
                )!,
              ),
            )
          : null,
      protectionSpace: URLProtectionSpace.fromMap(
        map['protectionSpace']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "credentials": credentials
          ?.map((e) => e.toMap(enumMethod: enumMethod))
          .toList(),
      "protectionSpace": protectionSpace?.toMap(enumMethod: enumMethod),
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
