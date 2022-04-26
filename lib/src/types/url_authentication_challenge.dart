import 'url_protection_space.dart';

///Class that represents a challenge from a server requiring authentication from the client.
///It provides all the information about the challenge.
class URLAuthenticationChallenge {
  ///The protection space requiring authentication.
  URLProtectionSpace protectionSpace;

  URLAuthenticationChallenge({
    required this.protectionSpace,
  });

  ///Gets a possible [URLAuthenticationChallenge] instance from a [Map] value.
  static URLAuthenticationChallenge? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return URLAuthenticationChallenge(
      protectionSpace: URLProtectionSpace.fromMap(
          map["protectionSpace"].cast<String, dynamic>())!,
    );
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "protectionSpace": protectionSpace.toMap(),
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