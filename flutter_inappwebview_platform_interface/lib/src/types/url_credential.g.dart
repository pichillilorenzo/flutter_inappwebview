// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'url_credential.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents an authentication credential consisting of information
///specific to the type of credential and the type of persistent storage to use, if any.
class URLCredential {
  ///The intermediate certificates of the credential, if it is a client certificate credential.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  List<X509Certificate>? certificates;

  ///Use [certificates] instead.
  @Deprecated('Use certificates instead')
  List<X509Certificate>? iosCertificates;

  ///Use [persistence] instead.
  @Deprecated('Use persistence instead')
  IOSURLCredentialPersistence? iosPersistence;

  ///The credential’s password.
  String? password;

  ///The credential’s persistence setting.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  URLCredentialPersistence? persistence;

  ///The credential’s user name.
  String? username;
  URLCredential(
      {this.certificates,
      @Deprecated('Use certificates instead') this.iosCertificates,
      @Deprecated('Use persistence instead') this.iosPersistence,
      this.password,
      this.persistence,
      this.username}) {
    certificates = certificates ?? iosCertificates;
    persistence = persistence ??
        URLCredentialPersistence.fromNativeValue(
            iosPersistence?.toNativeValue());
  }

  ///Gets a possible [URLCredential] instance from a [Map] value.
  static URLCredential? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = URLCredential(
      certificates: _certificatesDeserializer(map['certificates']),
      iosCertificates: _certificatesDeserializer(map['certificates']),
      iosPersistence:
          IOSURLCredentialPersistence.fromNativeValue(map['persistence']),
      password: map['password'],
      persistence: URLCredentialPersistence.fromNativeValue(map['persistence']),
      username: map['username'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "certificates": certificates?.map((e) => e.toMap()).toList(),
      "password": password,
      "persistence": persistence?.toNativeValue(),
      "username": username,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'URLCredential{certificates: $certificates, password: $password, persistence: $persistence, username: $username}';
  }
}
