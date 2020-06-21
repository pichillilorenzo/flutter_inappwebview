import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'asn1_decoder.dart';
import 'asn1_object.dart';
import 'oid.dart';
import 'x509_public_key.dart';

import 'x509_extension.dart';
import 'asn1_distinguished_names.dart';

///Class that represents a X.509 certificate.
///This provides a standard way to access all the attributes of an X.509 certificate.
class X509Certificate {
  List<ASN1Object> asn1;
  ASN1Object block1;

  ///Returns the encoded form of this certificate. It is
  ///assumed that each certificate type would have only a single
  ///form of encoding; for example, X.509 certificates would
  ///be encoded as ASN.1 DER.
  Uint8List encoded;

  static const beginPemBlock = "-----BEGIN CERTIFICATE-----";
  static const endPemBlock = "-----END CERTIFICATE-----";

  X509Certificate({ASN1Object asn1}) {
    if (asn1 != null) {
      var block1 = asn1.subAtIndex(0);
      if (block1 == null) {
        throw ASN1ParseError();
      }
    }
  }

  static X509Certificate fromData({@required Uint8List data}) {
    var decoded = utf8.decode(data, allowMalformed: true);
    if (decoded.contains(X509Certificate.beginPemBlock)) {
      return X509Certificate.fromPemData(pem: data);
    } else {
      return X509Certificate.fromDerData(der: data);
    }
  }

  static X509Certificate fromDerData({@required Uint8List der}) {
    var asn1 = ASN1DERDecoder.decode(data: der.toList(growable: true));
    if (asn1.length > 0) {
      var block1 = asn1.first?.subAtIndex(0);
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

  static X509Certificate fromPemData({@required Uint8List pem}) {
    var derData = X509Certificate.decodeToDER(pemData: pem);
    if (derData == null) {
      throw ASN1ParseError();
    }
    return X509Certificate.fromDerData(der: derData);
  }

  ///Read possible PEM encoding
  static Uint8List decodeToDER({@required pemData}) {
    var pem = String.fromCharCodes(pemData);
    if (pem != null && pem.contains(X509Certificate.beginPemBlock)) {
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

      Uint8List derDataDecoded;
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
      asn1.fold("", (value, element) => value + element.description + "\n");

  ///Checks that the given date is within the certificate's validity period.
  bool checkValidity({DateTime date}) {
    if (date == null) {
      date = DateTime.now();
    }
    if (notBefore != null && notAfter != null) {
      return date.isAfter(notBefore) && date.isBefore(notAfter);
    }
    return false;
  }

  ///Gets the version (version number) value from the certificate.
  int get version {
    var v = firstLeafValue(block: block1) as List<int>;
    if (v != null) {
      var index = toIntValue(v);
      if (index != null) {
        return index.toInt() + 1;
      }
    }
    return null;
  }

  ///Gets the serialNumber value from the certificate.
  List<int> get serialNumber =>
      block1.atIndex(X509BlockPosition.serialNumber)?.value as List<int>;

  ///Returns the issuer (issuer distinguished name) value from the certificate as a String.
  String get issuerDistinguishedName {
    var issuerBlock = block1.atIndex(X509BlockPosition.issuer);
    if (issuerBlock != null) {
      return blockDistinguishedName(block: issuerBlock);
    }
    return null;
  }

  List<String> get issuerOIDs {
    var result = <String>[];
    var issuerBlock = block1.atIndex(X509BlockPosition.issuer);
    if (issuerBlock != null) {
      for (var sub in (issuerBlock.sub ?? <ASN1Object>[])) {
        var value = firstLeafValue(block: sub) as String;
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result;
  }

  String issuer({String oid, ASN1DistinguishedNames dn}) {
    if (oid == null && dn != null) {
      oid = dn.oid();
    }
    if (oid != null) {
      var issuerBlock = block1.atIndex(X509BlockPosition.issuer);
      if (issuerBlock != null) {
        var oidBlock = issuerBlock.findOid(oidValue: oid);
        if (oidBlock != null) {
          var sub = oidBlock.parent?.sub;
          if (sub != null && sub.length > 0) {
            return sub.last.value as String;
          } else {
            return null;
          }
        }
      }
    }
    return null;
  }

  ///Returns the subject (subject distinguished name) value from the certificate as a String.
  String get subjectDistinguishedName {
    var subjectBlock = block1.atIndex(X509BlockPosition.subject);
    if (subjectBlock != null) {
      return blockDistinguishedName(block: subjectBlock);
    }
    return null;
  }

  List<String> get subjectOIDs {
    var result = <String>[];
    var subjectBlock = block1.atIndex(X509BlockPosition.subject);
    if (subjectBlock != null) {
      for (var sub in (subjectBlock.sub ?? <ASN1Object>[])) {
        var value = firstLeafValue(block: sub) as String;
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result;
  }

  String subject({String oid, ASN1DistinguishedNames dn}) {
    if (oid == null && dn != null) {
      oid = dn.oid();
    }
    if (oid != null) {
      var subjectBlock = block1.atIndex(X509BlockPosition.subject);
      if (subjectBlock != null) {
        var oidBlock = subjectBlock.findOid(oidValue: oid);
        if (oidBlock != null) {
          var sub = oidBlock.parent?.sub;
          if (sub != null && sub.length > 0) {
            return sub.last.value as String;
          } else {
            return null;
          }
        }
      }
    }
    return null;
  }

  ///Gets the notBefore date from the validity period of the certificate.
  DateTime get notBefore =>
      block1.atIndex(X509BlockPosition.dateValidity)?.subAtIndex(0)?.value
          as DateTime;

  ///Gets the notAfter date from the validity period of the certificate.
  DateTime get notAfter {
    var value = block1
        .atIndex(X509BlockPosition.dateValidity)
        ?.subAtIndex(1)
        ?.value as DateTime;
    return value;
  }

  ///Gets the signature value (the raw signature bits) from the certificate.
  List<int> get signature => asn1[0].subAtIndex(2)?.value as List<int>;

  ///Gets the signature algorithm name for the certificate signature algorithm.
  String get sigAlgName => OID.fromValue(sigAlgOID ?? "")?.name();

  ///Gets the signature algorithm OID string from the certificate.
  String get sigAlgOID => block1.subAtIndex(2)?.subAtIndex(0)?.value as String;

  ///Gets the DER-encoded signature algorithm parameters from this certificate's signature algorithm.
  List<int> get sigAlgParams => null;

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
    var oidBlock = block1.findOid(oid: OID.keyUsage);
    if (oidBlock != null) {
      var sub = oidBlock.parent?.sub;
      if (sub != null && sub.length > 0) {
        var data = sub.last.subAtIndex(0)?.value as List<int>;
        int bits = (data != null && data.length > 0) ? data.first ?? 0 : 0;
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
      extensionObject(oid: OID.subjectAltName)?.valueAsStrings ?? <String>[];

  ///Gets a collection of issuer alternative names from the IssuerAltName extension, (OID = 2.5.29.18).
  List<String> get issuerAlternativeNames =>
      extensionObject(oid: OID.issuerAltName)?.valueAsStrings ?? <String>[];

  ///Gets the informations of the public key from this certificate.
  X509PublicKey get publicKey {
    var pkBlock = block1.atIndex(X509BlockPosition.publicKey);
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
        .map((extension) => extension.oid)
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
        .map((extension) => extension.oid)
        .toList();
  }

  ///Gets the certificate constraints path length from the
  ///critical BasicConstraints extension, (OID = 2.5.29.19).
  int get basicConstraints {
    var sub = extensionObject(oid: OID.basicConstraints)
        ?.block
        ?.lastSub()
        ?.lastSub()
        ?.lastSub();
    if (sub != null) {
      if (sub.value is List<int>) {
        return (sub.value as List<int>).length;
      }
    }
    return -1;
  }

  ///Gets the raw bits from the Subject Key Identifier (SKID) extension, (OID = 2.5.29.14).
  List<int> get subjectKeyIdentifier =>
      extensionObject(oid: OID.subjectKeyIdentifier)
          ?.block
          ?.lastSub()
          ?.lastSub()
          ?.value ??
      <int>[];

  ///Gets the raw bits from the Authority Key Identifier extension, (OID = 2.5.29.35).
  List<int> get authorityKeyIdentifier =>
      extensionObject(oid: OID.authorityKeyIdentifier)
          ?.block
          ?.lastSub()
          ?.lastSub()
          ?.firstSub()
          ?.value ??
      <int>[];

  ///Gets the list of certificate policies from the CertificatePolicies extension, (OID = 2.5.29.32).
  List<String> get certificatePolicies =>
      extensionObject(oid: OID.certificatePolicies)
          ?.block
          ?.lastSub()
          ?.firstSub()
          ?.sub
          ?.map((e) => e.firstSub()?.value as String)
          ?.toList() ??
      <String>[];

  ///Gets the list of CRL distribution points from the CRLDistributionPoints extension, (OID = 2.5.29.31).
  List<String> get cRLDistributionPoints =>
      extensionObject(oid: OID.cRLDistributionPoints)
          ?.block
          ?.lastSub()
          ?.firstSub()
          ?.sub
          ?.map((e) => e.firstSub()?.firstSub()?.firstSub()?.value as String)
          ?.toList() ??
      <String>[];

  ///Gets the map of the format (as a key) and location (as a value) of additional information
  ///about the CA who issued the certificate in which this extension appears
  ///from the AuthorityInfoAccess extension, (OID = 1.3.6.1.5.5.5.7.1.1).
  Map<String, String> get authorityInfoAccess {
    var result = <String, String>{};
    var sub = extensionObject(oid: OID.authorityInfoAccess)
        ?.block
        ?.lastSub()
        ?.firstSub()
        ?.sub;
    if (sub != null) {
      sub.forEach((element) {
        if (element.subCount() > 1) {
          result.putIfAbsent(
              element.subAtIndex(0).value, () => element.subAtIndex(1).value);
        }
      });
    }
    return result;
  }

  List<ASN1Object> get extensionBlocks =>
      block1.atIndex(X509BlockPosition.extensions)?.subAtIndex(0)?.sub;

  ///Gets the extension information of the given OID code or enum string value.
  X509Extension extensionObject({String oidValue, OID oid}) {
    if (oidValue == null && oid != null) {
      oidValue = oid.toValue();
    }
    if (oidValue != null) {
      var block = block1
          .atIndex(X509BlockPosition.extensions)
          ?.findOid(oidValue: oidValue)
          ?.parent;
      if (block != null) {
        return X509Extension(block: block);
      }
    }
    return null;
  }

  ///Format subject/issuer information in RFC1779
  String blockDistinguishedName({@required ASN1Object block}) {
    var result = "";
    for (var oidName in ASN1DistinguishedNames.values) {
      var oidBlock = block.findOid(oidValue: oidName.oid());
      if (oidBlock != null) {
        if (result.isNotEmpty) {
          result += ", ";
        }
        result += oidName.representation();
        result += "=";

        var sub = oidBlock.parent?.sub;
        if (sub != null && sub.length > 0) {
          var value = sub.last.value as String;
          if (value != null) {
            var specialChar = ",+=\n<>#;\\";
            var quote = "";
            for (var i = 0; i < value.length; i++) {
              var char = value[i];
              if (specialChar.contains(char)) {
                quote = "\"";
              }
            }
            result += quote;
            result += value;
            result += quote;
          }
        }
      }
    }
    return result;
  }

  @override
  String toString() {
    return description;
  }

  Map<String, dynamic> toMap() {
    return {
      "basicConstraints": basicConstraints,
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
      "subjectKeyIdentifier": subjectKeyIdentifier,
      "authorityKeyIdentifier": authorityKeyIdentifier,
      "certificatePolicies": certificatePolicies,
      "cRLDistributionPoints": cRLDistributionPoints,
      "authorityInfoAccess": authorityInfoAccess,
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }
}

dynamic firstLeafValue({@required ASN1Object block}) {
  var sub = block.sub;
  if (sub != null && sub.length > 0) {
    var subFirst = sub.first;
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
