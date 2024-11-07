// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'url_authentication_challenge.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents a challenge from a server requiring authentication from the client.
///It provides all the information about the challenge.
class URLAuthenticationChallenge {
  ///The protection space requiring authentication.
  URLProtectionSpace protectionSpace;
  URLAuthenticationChallenge({required this.protectionSpace});

  ///Gets a possible [URLAuthenticationChallenge] instance from a [Map] value.
  static URLAuthenticationChallenge? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = URLAuthenticationChallenge(
      protectionSpace: URLProtectionSpace.fromMap(
          map['protectionSpace']?.cast<String, dynamic>(),
          enumMethod: enumMethod)!,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "protectionSpace": protectionSpace.toMap(enumMethod: enumMethod),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'URLAuthenticationChallenge{protectionSpace: $protectionSpace}';
  }
}
