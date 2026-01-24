import 'dart:typed_data';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../x509_certificate/x509_certificate.dart';
import 'url_credential_persistence.dart';
import 'enum_method.dart';

part 'url_credential.g.dart';

List<X509Certificate>? _certificatesDeserializer(
  dynamic value, {
  EnumMethod? enumMethod,
}) {
  List<X509Certificate>? certificates;
  if (value != null) {
    certificates = <X509Certificate>[];
    (value.cast<Uint8List>() as List<Uint8List>).forEach((data) {
      try {
        certificates!.add(X509Certificate.fromData(data: data));
      } catch (e, stacktrace) {
        print(e);
        print(stacktrace);
      }
    });
  }
  return certificates;
}

///Class that represents an authentication credential consisting of information
///specific to the type of credential and the type of persistent storage to use, if any.
@ExchangeableObject()
class URLCredential_ {
  ///The credential’s user name.
  String? username;

  ///The credential’s password.
  String? password;

  ///Use [certificates] instead.
  @Deprecated("Use certificates instead")
  @ExchangeableObjectProperty(deserializer: _certificatesDeserializer)
  List<X509Certificate>? iosCertificates;

  ///The intermediate certificates of the credential, if it is a client certificate credential.
  @ExchangeableObjectProperty(deserializer: _certificatesDeserializer)
  @SupportedPlatforms(platforms: [IOSPlatform(), MacOSPlatform()])
  List<X509Certificate>? certificates;

  ///Use [persistence] instead.
  @Deprecated("Use persistence instead")
  IOSURLCredentialPersistence_? iosPersistence;

  ///The credential’s persistence setting.
  @SupportedPlatforms(platforms: [IOSPlatform(), MacOSPlatform()])
  URLCredentialPersistence_? persistence;

  URLCredential_({
    this.username,
    this.password,
    @Deprecated("Use certificates instead") this.iosPersistence,
    this.persistence,
    @Deprecated("Use persistence instead") this.iosCertificates,
    this.certificates,
  });
}
