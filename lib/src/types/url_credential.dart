import 'dart:typed_data';

import '../x509_certificate/x509_certificate.dart';

import 'url_credential_persistence.dart';

///Class that represents an authentication credential consisting of information
///specific to the type of credential and the type of persistent storage to use, if any.
class URLCredential {
  ///The credential’s user name.
  String? username;

  ///The credential’s password.
  String? password;

  ///Use [certificates] instead.
  @Deprecated("Use certificates instead")
  List<X509Certificate>? iosCertificates;

  ///The intermediate certificates of the credential, if it is a client certificate credential.
  ///
  ///**NOTE**: available only on iOS.
  List<X509Certificate>? certificates;

  ///Use [persistence] instead.
  @Deprecated("Use persistence instead")
  IOSURLCredentialPersistence? iosPersistence;

  ///The credential’s persistence setting.
  ///
  ///**NOTE**: available only on iOS.
  URLCredentialPersistence? persistence;

  URLCredential(
      {this.username,
        this.password,
        @Deprecated("Use certificates instead") this.iosPersistence,
        this.persistence,
        @Deprecated("Use persistence instead") this.iosCertificates,
        this.certificates}) {
    // ignore: deprecated_member_use_from_same_package
    this.persistence = this.persistence ??
        // ignore: deprecated_member_use_from_same_package
        URLCredentialPersistence.fromValue(this.iosPersistence?.toValue());
    // ignore: deprecated_member_use_from_same_package
    this.certificates = this.certificates ?? this.iosCertificates;
  }

  static URLCredential? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }

    List<X509Certificate>? certificates;
    if (map["certificates"] != null) {
      certificates = <X509Certificate>[];
      (map["certificates"].cast<Uint8List>() as List<Uint8List>)
          .forEach((data) {
        try {
          certificates!.add(X509Certificate.fromData(data: data));
        } catch (e, stacktrace) {
          print(e);
          print(stacktrace);
        }
      });
    }

    return URLCredential(
        username: map["user"],
        password: map["password"],
        // ignore: deprecated_member_use_from_same_package
        iosCertificates: certificates,
        certificates: certificates,
        persistence: URLCredentialPersistence.fromValue(map["persistence"]),
        // ignore: deprecated_member_use_from_same_package
        iosPersistence:
        // ignore: deprecated_member_use_from_same_package
        IOSURLCredentialPersistence.fromValue(map["persistence"]));
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "username": username,
      "password": password,
      "iosCertificates":
      // ignore: deprecated_member_use_from_same_package
      (certificates ?? iosCertificates)?.map((e) => e.toMap()).toList(),
      "certificates":
      // ignore: deprecated_member_use_from_same_package
      (certificates ?? iosCertificates)?.map((e) => e.toMap()).toList(),
      // ignore: deprecated_member_use_from_same_package
      "iosPersistence": persistence?.toValue() ?? iosPersistence?.toValue(),
      // ignore: deprecated_member_use_from_same_package
      "persistence": persistence?.toValue() ?? iosPersistence?.toValue(),
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