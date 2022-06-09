// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'url_credential.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents an authentication credential consisting of information
///specific to the type of credential and the type of persistent storage to use, if any.
class URLCredential {
  ///The credential’s user name.
  String? username;

  ///The credential’s password.
  String? password;

  ///Use [certificates] instead.
  @Deprecated('Use certificates instead')
  List<X509Certificate>? iosCertificates;

  ///The intermediate certificates of the credential, if it is a client certificate credential.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  List<X509Certificate>? certificates;

  ///Use [persistence] instead.
  @Deprecated('Use persistence instead')
  IOSURLCredentialPersistence? iosPersistence;

  ///The credential’s persistence setting.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  URLCredentialPersistence? persistence;
  URLCredential(
      {this.username,
      this.password,
      @Deprecated('Use certificates instead') this.iosCertificates,
      this.certificates,
      @Deprecated('Use persistence instead') this.iosPersistence,
      this.persistence}) {
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
      username: map['username'],
      password: map['password'],
      iosCertificates: _certificatesDeserializer(map['certificates']),
      certificates: _certificatesDeserializer(map['certificates']),
      iosPersistence:
          IOSURLCredentialPersistence.fromNativeValue(map['persistence']),
      persistence: URLCredentialPersistence.fromNativeValue(map['persistence']),
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "username": username,
      "password": password,
      "certificates": certificates?.map((e) => e.toMap()).toList(),
      "persistence": persistence?.toNativeValue(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'URLCredential{username: $username, password: $password, certificates: $certificates, persistence: $persistence}';
  }
}
