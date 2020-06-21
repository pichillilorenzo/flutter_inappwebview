import 'dart:typed_data';

import 'asn1_decoder.dart';
import 'asn1_object.dart';
import 'oid.dart';

class X509PublicKey {
  ASN1Object pkBlock;

  X509PublicKey({this.pkBlock});

  String get algOid => pkBlock?.subAtIndex(0)?.subAtIndex(0)?.value;

  String get algName => OID.fromValue(algOid ?? "")?.name();

  String get algParams => pkBlock?.subAtIndex(0)?.subAtIndex(1)?.value;

  Uint8List get encoded {
    var oid = OID.fromValue(algOid);
    var keyData = pkBlock?.subAtIndex(1)?.value ?? null;

    if (oid != null && algOid != null && keyData != null) {
      if (oid == OID.ecPublicKey) {
        return Uint8List.fromList(keyData);
      } else if (oid == OID.rsaEncryption) {
        List<ASN1Object> publicKeyAsn1Objects;
        try {
          publicKeyAsn1Objects =
              ASN1DERDecoder.decode(data: keyData.toList(growable: true));
        } catch (e) {}

        if (publicKeyAsn1Objects != null && publicKeyAsn1Objects.length > 0) {
          var publicKeyModulus =
              publicKeyAsn1Objects.first?.subAtIndex(0)?.value;
          if (publicKeyModulus != null) {
            return Uint8List.fromList(publicKeyModulus);
          }
        }
      }
    }
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      "algOid": algOid,
      "algName": algName,
      "algParams": algParams,
      "encoded": encoded,
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }
}
