import 'dart:convert';
import 'dart:typed_data';

import 'asn1_decoder.dart';
import 'asn1_object.dart';
import 'oid.dart';
import 'x509_public_key.dart';

import 'x509_extension.dart';
import 'asn1_distinguished_names.dart';

///Class that represents a X.509 certificate.
///This provides a standard way to access all the attributes of an X.509 certificate.
class X509Certificate {
  List<ASN1Object>? asn1;
  ASN1Object? block1;

  ///Returns the encoded form of this certificate. It is
  ///assumed that each certificate type would have only a single
  ///form of encoding; for example, X.509 certificates would
  ///be encoded as ASN.1 DER.
  Uint8List? encoded;

  static const beginPemBlock = "-----BEGIN CERTIFICATE-----";
  static const endPemBlock = "-----END CERTIFICATE-----";

  X509Certificate({ASN1Object? asn1}) {
    if (asn1 != null) {
      var block1 = asn1.subAtIndex(0);
      if (block1 == null) {
        throw ASN1ParseError();
      }
    }
  }

  static X509Certificate fromData({required Uint8List data}) {
    var decoded = utf8.decode(data, allowMalformed: true);
    if (decoded.contains(X509Certificate.beginPemBlock)) {
      return X509Certificate.fromPemData(pem: data);
    } else {
      return X509Certificate.fromDerData(der: data);
    }
  }

  static X509Certificate fromDerData({required Uint8List der}) {
    var asn1 = ASN1DERDecoder.decode(data: der.toList(growable: true));
    if (asn1.length > 0) {
      var block1 = asn1.first.subAtIndex(0);
      if (block1 != null) {
        var certificate = X509Certificate();
        certificate.asn1 = asn1;
        certificate.block1 = block1;
        certificate.encoded = der;
        return certificate;
      }
    }
    throw ASN1ParseError();
  }

  static X509Certificate fromPemData({required Uint8List pem}) {
    var derData = X509Certificate.decodeToDER(pemData: pem);
    if (derData == null) {
      throw ASN1ParseError();
    }
    return X509Certificate.fromDerData(der: derData);
  }

  ///Read possible PEM encoding
  static Uint8List? decodeToDER({required pemData}) {
    var pem = String.fromCharCodes(pemData);
    if (pem.contains(X509Certificate.beginPemBlock)) {
      var lines = pem.split("\n");
      var base64buffer = "";
      var certLine = false;
      for (var line in lines) {
        if (line == X509Certificate.endPemBlock) {
          certLine = false;
        }
        if (certLine) {
          base64buffer += line;
        }
        if (line == X509Certificate.beginPemBlock) {
          certLine = true;
        }
      }

      Uint8List? derDataDecoded;
      try {
        derDataDecoded = Uint8List.fromList(utf8.encode(base64buffer));
      } catch (e) {}
      if (derDataDecoded != null) {
        return derDataDecoded;
      }
    }
    return null;
  }

  String get description =>
      asn1?.fold(
          "", (value, element) => (value ?? '') + element.description + '\n') ??
      '';

  ///Checks that the given date is within the certificate's validity period.
  bool checkValidity({DateTime? date}) {
    if (date == null) {
      date = DateTime.now();
    }
    if (notBefore != null && notAfter != null) {
      return date.isAfter(notBefore!) && date.isBefore(notAfter!);
    }
    return false;
  }

  ///Gets the version (version number) value from the certificate.
  int? get version {
    if (block1 != null) {
      var v = firstLeafValue(block: block1!);
      if (v is List<int>) {
        var index = toIntValue(v);
        if (index != null) {
          return index.toInt() + 1;
        }
      }
    }
    return null;
  }

  ///Gets the serialNumber value from the certificate.
  List<int>? get serialNumber {
    var data = block1?.atIndex(X509BlockPosition.serialNumber)?.value;
    return data is List<int> ? data : null;
  }

  ///Returns the issuer (issuer distinguished name) value from the certificate as a String.
  String? get issuerDistinguishedName {
    var issuerBlock = block1?.atIndex(X509BlockPosition.issuer);
    if (issuerBlock != null) {
      return ASN1DistinguishedNames.string(block: issuerBlock);
    }
    return null;
  }

  List<String> get issuerOIDs {
    var result = <String>[];
    var issuerBlock = block1?.atIndex(X509BlockPosition.issuer);
    if (issuerBlock != null) {
      for (var sub in (issuerBlock.sub ?? <ASN1Object>[])) {
        var value = firstLeafValue(block: sub);
        if (value is String) {
          result.add(value);
        }
      }
    }
    return result;
  }

  String? issuer({String? oid, ASN1DistinguishedNames? dn}) {
    if (oid == null && dn != null) {
      oid = dn.oid();
    }
    if (oid != null) {
      var issuerBlock = block1?.atIndex(X509BlockPosition.issuer);
      if (issuerBlock != null) {
        var oidBlock = issuerBlock.findOid(oidValue: oid);
        if (oidBlock != null) {
          var sub = oidBlock.parent?.sub;
          if (sub != null && sub.length > 0 && sub.last.value is String) {
            return sub.last.value;
          } else {
            return null;
          }
        }
      }
    }
    return null;
  }

  ///Returns the subject (subject distinguished name) value from the certificate as a String.
  String? get subjectDistinguishedName {
    var subjectBlock = block1?.atIndex(X509BlockPosition.subject);
    if (subjectBlock != null) {
      return ASN1DistinguishedNames.string(block: subjectBlock);
    }
    return null;
  }

  List<String> get subjectOIDs {
    var result = <String>[];
    var subjectBlock = block1?.atIndex(X509BlockPosition.subject);
    if (subjectBlock != null) {
      for (var sub in (subjectBlock.sub ?? <ASN1Object>[])) {
        var value = firstLeafValue(block: sub);
        if (value is String) {
          result.add(value);
        }
      }
    }
    return result;
  }

  String? subject({String? oid, ASN1DistinguishedNames? dn}) {
    if (oid == null && dn != null) {
      oid = dn.oid();
    }
    if (oid != null) {
      var subjectBlock = block1?.atIndex(X509BlockPosition.subject);
      if (subjectBlock != null) {
        var oidBlock = subjectBlock.findOid(oidValue: oid);
        if (oidBlock != null) {
          var sub = oidBlock.parent?.sub;
          if (sub != null && sub.length > 0 && sub.last.value is String) {
            return sub.last.value;
          } else {
            return null;
          }
        }
      }
    }
    return null;
  }

  ///Gets the notBefore date from the validity period of the certificate.
  DateTime? get notBefore {
    var data =
        block1?.atIndex(X509BlockPosition.dateValidity)?.subAtIndex(0)?.value;
    return data is DateTime ? data : null;
  }

  ///Gets the notAfter date from the validity period of the certificate.
  DateTime? get notAfter {
    var data =
        block1?.atIndex(X509BlockPosition.dateValidity)?.subAtIndex(1)?.value;
    return data is DateTime ? data : null;
  }

  ///Gets the signature value (the raw signature bits) from the certificate.
  List<int>? get signature {
    var data = asn1?[0].subAtIndex(2)?.value;
    return data is List<int> ? data : null;
  }

  ///Gets the signature algorithm name for the certificate signature algorithm.
  String? get sigAlgName => OID.fromValue(sigAlgOID ?? '')?.name();

  ///Gets the signature algorithm OID string from the certificate.
  String? get sigAlgOID {
    var data = block1?.subAtIndex(2)?.subAtIndex(0)?.value;
    return data is String ? data : null;
  }

  ///Gets the DER-encoded signature algorithm parameters from this certificate's signature algorithm.
  List<int>? get sigAlgParams => null;

  ///Gets a boolean array representing bits of the KeyUsage extension, (OID = 2.5.29.15).
  ///```
  ///KeyUsage ::= BIT STRING {
  ///digitalSignature        (0),
  ///nonRepudiation          (1),
  ///keyEncipherment         (2),
  ///dataEncipherment        (3),
  ///keyAgreement            (4),
  ///keyCertSign             (5),
  ///cRLSign                 (6),
  ///encipherOnly            (7),
  ///decipherOnly            (8)
  ///}
  ///```
  List<bool> get keyUsage {
    var result = <bool>[];
    var oidBlock = block1?.findOid(oid: OID.keyUsage);
    if (oidBlock != null) {
      var sub = oidBlock.parent?.sub;
      if (sub != null && sub.length > 0) {
        var data = sub.last.subAtIndex(0)?.value;
        int bits = (data is List<int> && data.length > 0) ? data.first : 0;
        for (var index = 0; index < 8; index++) {
          var value = bits & (1 << index).toUnsigned(8) != 0;
          result.insert(0, value);
        }
      }
    }
    return result;
  }

  ///Gets a list of Strings representing the OBJECT IDENTIFIERs of the ExtKeyUsageSyntax field of
  ///the extended key usage extension, (OID = 2.5.29.37).
  List<String> get extendedKeyUsage =>
      extensionObject(oid: OID.extKeyUsage)?.valueAsStrings ?? <String>[];

  ///Gets a collection of subject alternative names from the SubjectAltName extension, (OID = 2.5.29.17).
  List<String> get subjectAlternativeNames =>
      extensionObject(oid: OID.subjectAltName)?.alternativeNameAsStrings ??
      <String>[];

  ///Gets a collection of issuer alternative names from the IssuerAltName extension, (OID = 2.5.29.18).
  List<String> get issuerAlternativeNames =>
      extensionObject(oid: OID.issuerAltName)?.alternativeNameAsStrings ??
      <String>[];

  ///Gets the informations of the public key from this certificate.
  X509PublicKey? get publicKey {
    var pkBlock = block1?.atIndex(X509BlockPosition.publicKey);
    if (pkBlock != null) {
      return X509PublicKey(pkBlock: pkBlock);
    }
    return null;
  }

  ///Get a list of critical extension OID codes
  List<String> get criticalExtensionOIDs {
    var extensionBlocks = this.extensionBlocks;
    if (extensionBlocks == null) {
      return <String>[];
    }
    return extensionBlocks
        .map((block) => X509Extension(block: block))
        .where((extension) => extension.isCritical)
        .map((extension) => extension.oid ?? '')
        .toList();
  }

  ///Get a list of non critical extension OID codes
  List<String> get nonCriticalExtensionOIDs {
    var extensionBlocks = this.extensionBlocks;
    if (extensionBlocks == null) {
      return <String>[];
    }
    return extensionBlocks
        .map((block) => X509Extension(block: block))
        .where((extension) => !extension.isCritical)
        .map((extension) => extension.oid ?? '')
        .toList();
  }

  ///Gets the certificate constraints path length from the
  ///critical BasicConstraints extension, (OID = 2.5.29.19).
  BasicConstraintExtension? get basicConstraints =>
      extensionObject(oid: OID.basicConstraints) as BasicConstraintExtension?;

  ///Gets the raw bits from the Subject Key Identifier (SKID) extension, (OID = 2.5.29.14).
  SubjectKeyIdentifierExtension? get subjectKeyIdentifier =>
      extensionObject(oid: OID.subjectKeyIdentifier)
          as SubjectKeyIdentifierExtension?;

  ///Gets the raw bits from the Authority Key Identifier extension, (OID = 2.5.29.35).
  AuthorityKeyIdentifierExtension? get authorityKeyIdentifier =>
      extensionObject(oid: OID.authorityKeyIdentifier)
          as AuthorityKeyIdentifierExtension?;

  ///Gets the list of certificate policies from the CertificatePolicies extension, (OID = 2.5.29.32).
  CertificatePoliciesExtension? get certificatePolicies =>
      extensionObject(oid: OID.certificatePolicies)
          as CertificatePoliciesExtension?;

  ///Gets the list of CRL distribution points from the CRLDistributionPoints extension, (OID = 2.5.29.31).
  CRLDistributionPointsExtension? get cRLDistributionPoints =>
      extensionObject(oid: OID.cRLDistributionPoints)
          as CRLDistributionPointsExtension?;

  ///Gets the map of the format (as a key) and location (as a value) of additional information
  ///about the CA who issued the certificate in which this extension appears
  ///from the AuthorityInfoAccess extension, (OID = 1.3.6.1.5.5.5.7.1.1).
  AuthorityInfoAccessExtension? get authorityInfoAccess =>
      extensionObject(oid: OID.authorityInfoAccess)
          as AuthorityInfoAccessExtension?;

  List<ASN1Object>? get extensionBlocks =>
      block1?.atIndex(X509BlockPosition.extensions)?.subAtIndex(0)?.sub;

  ///Gets the extension information of the given OID code or enum string value.
  X509Extension? extensionObject({String? oidValue, OID? oid}) {
    if (oidValue == null && oid != null) {
      oidValue = oid.toValue();
    }
    if (oidValue != null) {
      var block = block1
          ?.atIndex(X509BlockPosition.extensions)
          ?.findOid(oidValue: oidValue)
          ?.parent;
      if (block != null) {
        if (oidValue == OID.basicConstraints.toValue()) {
          return BasicConstraintExtension(block: block);
        } else if (oidValue == OID.subjectKeyIdentifier.toValue()) {
          return SubjectKeyIdentifierExtension(block: block);
        } else if (oidValue == OID.authorityInfoAccess.toValue()) {
          return AuthorityInfoAccessExtension(block: block);
        } else if (oidValue == OID.authorityKeyIdentifier.toValue()) {
          return AuthorityKeyIdentifierExtension(block: block);
        } else if (oidValue == OID.certificatePolicies.toValue()) {
          return CertificatePoliciesExtension(block: block);
        } else if (oidValue == OID.cRLDistributionPoints.toValue()) {
          return CRLDistributionPointsExtension(block: block);
        }
        return X509Extension(block: block);
      }
    }
    return null;
  }

  @override
  String toString() {
    return description;
  }

  Map<String, dynamic> toMap() {
    return {
      "basicConstraints": basicConstraints?.toMap(),
      "subjectAlternativeNames": subjectAlternativeNames,
      "issuerAlternativeNames": issuerAlternativeNames,
      "extendedKeyUsage": extendedKeyUsage,
      "issuerDistinguishedName": issuerDistinguishedName,
      "keyUsage": keyUsage,
      "notAfter": notAfter,
      "notBefore": notBefore,
      "serialNumber": serialNumber,
      "sigAlgName": sigAlgName,
      "sigAlgOID": sigAlgOID,
      "sigAlgParams": sigAlgParams,
      "signature": signature,
      "subjectDistinguishedName": subjectDistinguishedName,
      "version": version,
      "criticalExtensionOIDs": criticalExtensionOIDs,
      "nonCriticalExtensionOIDs": nonCriticalExtensionOIDs,
      "encoded": encoded,
      "publicKey": publicKey?.toMap(),
      "subjectKeyIdentifier": subjectKeyIdentifier?.toMap(),
      "authorityKeyIdentifier": authorityKeyIdentifier?.toMap(),
      "certificatePolicies": certificatePolicies?.toMap(),
      "cRLDistributionPoints": cRLDistributionPoints?.toMap(),
      "authorityInfoAccess": authorityInfoAccess?.toMap(),
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }
}

dynamic firstLeafValue({required ASN1Object block}) {
  var sub = block.sub;
  if (sub != null && sub.length > 0) {
    ASN1Object? subFirst;
    try {
      subFirst = sub.first;
    } catch (e) {}
    if (subFirst != null) {
      return firstLeafValue(block: subFirst);
    }
  }
  return block.value;
}

enum X509BlockPosition {
  version,
  serialNumber,
  signatureAlg,
  issuer,
  dateValidity,
  subject,
  publicKey,
  extensions
}
