import 'dart:convert';

import 'x509_certificate.dart';
import 'asn1_object.dart';
import 'oid.dart';
import 'asn1_distinguished_names.dart';
import 'asn1_decoder.dart';

class X509Extension {
  ASN1Object? block;

  X509Extension({required this.block});

  String? get oid => block?.subAtIndex(0)?.value;

  String? get name => OID.fromValue(oid)?.name();

  bool get isCritical {
    if ((block?.sub?.length ?? 0) > 2) {
      return block?.subAtIndex(1)?.value ?? false;
    }
    return false;
  }

  dynamic get value {
    var sub = block?.sub;
    if (sub != null && sub.length > 0) {
      ASN1Object? valueBlock;
      try {
        valueBlock = sub.last;
      } catch (e) {}
      if (valueBlock != null) {
        return firstLeafValue(block: valueBlock);
      }
    }
    return null;
  }

  ASN1Object? get valueAsBlock {
    var sub = block?.sub;
    if (sub != null && sub.length > 0) {
      ASN1Object? valueBlock;
      try {
        valueBlock = sub.last;
      } catch (e) {}
      return valueBlock;
    }
    return null;
  }

  List<String> get valueAsStrings {
    var result = <String>[];
    var sub = <ASN1Object>[];
    try {
      sub = block?.sub?.last.sub?.last.sub ?? <ASN1Object>[];
    } catch (e) {}

    for (var item in sub) {
      var name = item.value;
      if (name != null) {
        result.add(name);
      }
    }
    return result;
  }

  // Used for SubjectAltName and IssuerAltName
  // Every name can be one of these subtype:
  //  - otherName      [0] INSTANCE OF OTHER-NAME,
  //  - rfc822Name     [1] IA5String,
  //  - dNSName        [2] IA5String,
  //  - x400Address    [3] ORAddress,
  //  - directoryName  [4] Name,
  //  - ediPartyName   [5] EDIPartyName,
  //  - uniformResourceIdentifier [6] IA5String,
  //  - IPAddress      [7] OCTET STRING,
  //  - registeredID   [8] OBJECT IDENTIFIER
  //
  // Result does not support: x400Address and ediPartyName
  //
  List<String> get alternativeNameAsStrings {
    List<String> result = [];
    var sub = <ASN1Object>[];
    try {
      sub = block?.sub?.last.sub?.last.sub ?? <ASN1Object>[];
    } catch (e) {}
    for (var item in sub) {
      var name = generalName(item: item);
      if (name != null) {
        result.add(name);
      }
    }
    return result;
  }

  String? generalName({required ASN1Object item}) {
    var nameType = item.identifier?.tagNumber().toValue();
    if (nameType == null) {
      return null;
    }
    switch (nameType) {
      case 0:
        String? name;
        try {
          name = item.sub?.last.sub?.last.value as String?;
        } catch (e) {}
        return name;
      case 1:
      case 2:
      case 6:
        var name = item.value is String ? item.value : null;
        return name;
      case 4:
        return ASN1DistinguishedNames.string(block: item);
      case 7:
        var ip = item.value is List<int> ? item.value : null;
        if (ip != null) {
          return ip.map((e) => e.toString()).join(".");
        }
        break;
      case 8:
        var value = item.value is String ? item.value : null;
        if (value != null) {
          try {
            var data = utf8.encode(value);
            var oid = ASN1DERDecoder.decodeOid(contentData: data);
            return oid;
          } catch (e) {}
        }
        break;
      default:
        return null;
    }
    return null;
  }
}

/// Recognition for Basic Constraint Extension (2.5.29.19)
class BasicConstraintExtension extends X509Extension {
  BasicConstraintExtension({required block}) : super(block: block);

  bool get isCA {
    var data = valueAsBlock?.subAtIndex(0)?.subAtIndex(0)?.value;
    return data is bool ? data : false;
  }

  int? get pathLenConstraint {
    var data = valueAsBlock?.subAtIndex(0)?.subAtIndex(0)?.value;
    if (data is List<int>) {
      return data.length;
    }
    return null;
  }

  @override
  String toString() {
    return toMap().toString();
  }

  Map<String, dynamic> toMap() {
    return {
      "isCA": isCA,
      "pathLenConstraint": pathLenConstraint,
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }
}

/// Recognition for Subject Key Identifier Extension (2.5.29.14)
class SubjectKeyIdentifierExtension extends X509Extension {
  SubjectKeyIdentifierExtension({required block}) : super(block: block);

  @override
  List<int>? get value {
    var rawValue = valueAsBlock?.encoded;
    if (rawValue != null) {
      return ASN1DERDecoder.sequenceContent(data: rawValue.toList());
    }
    return null;
  }

  @override
  String toString() {
    return toMap().toString();
  }

  Map<String, dynamic> toMap() {
    return {
      "value": value,
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }
}

class AuthorityInfoAccess {
  String method;
  String location;

  AuthorityInfoAccess({required this.method, required this.location});

  @override
  String toString() {
    return toMap().toString();
  }

  Map<String, dynamic> toMap() {
    return {
      "method": method,
      "location": location,
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }
}

/// Recognition for Authority Info Access Extension (1.3.6.1.5.5.7.1.1)
class AuthorityInfoAccessExtension extends X509Extension {
  AuthorityInfoAccessExtension({required block}) : super(block: block);

  List<AuthorityInfoAccess>? get infoAccess {
    if (valueAsBlock == null) {
      return null;
    }
    var subs = valueAsBlock!.subAtIndex(0)?.sub ?? <ASN1Object>[];
    List<AuthorityInfoAccess> result = <AuthorityInfoAccess>[];
    subs.forEach((sub) {
      var oidData = sub.subAtIndex(0)?.encoded;
      var nameBlock = sub.subAtIndex(1);
      if (oidData == null || nameBlock == null) {
        return;
      }
      var oid = ASN1DERDecoder.decodeOid(contentData: oidData.toList());
      var location = generalName(item: nameBlock);
      if (oid != null && location != null) {
        result.add(AuthorityInfoAccess(method: oid, location: location));
      }
    });
    return result;
  }

  @override
  String toString() {
    return toMap().toString();
  }

  Map<String, dynamic> toMap() {
    return {
      "infoAccess": infoAccess?.map((e) => e.toMap()).toList(),
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }
}

/// Recognition for Authority Key Identifier Extension (2.5.29.35)
class AuthorityKeyIdentifierExtension extends X509Extension {
  AuthorityKeyIdentifierExtension({required block}) : super(block: block);

  ///AuthorityKeyIdentifier ::= SEQUENCE {
  ///   keyIdentifier             [0] KeyIdentifier           OPTIONAL,
  ///   authorityCertIssuer       [1] GeneralNames            OPTIONAL,
  ///   authorityCertSerialNumber [2] CertificateSerialNumber OPTIONAL  }
  List<int>? get keyIdentifier {
    var sequence = valueAsBlock?.subAtIndex(0)?.sub;
    if (sequence == null) {
      return null;
    }
    ASN1Object? sub;
    try {
      sub = sequence.firstWhere(
          (element) => element.identifier?.tagNumber().toValue() == 0);
      return sub.encoded;
    } catch (e) {}
    return null;
  }

  List<String>? get certificateIssuer {
    var sequence = valueAsBlock?.subAtIndex(0)?.sub;
    if (sequence == null) {
      return null;
    }
    ASN1Object? sub;
    try {
      sub = sequence.firstWhere(
          (element) => element.identifier?.tagNumber().toValue() == 1);
      List<String>? result;
      if (sub.sub != null) {
        result = <String>[];
        sub.sub?.forEach((e) {
          var name = generalName(item: e);
          if (name != null) {
            result!.add(name);
          }
        });
      }
      return result;
    } catch (e) {}
    return null;
  }

  List<int>? get serialNumber {
    var sequence = valueAsBlock?.subAtIndex(0)?.sub;
    if (sequence == null) {
      return null;
    }
    ASN1Object? sub;
    try {
      sub = sequence.firstWhere(
          (element) => element.identifier?.tagNumber().toValue() == 2);
      return sub.encoded;
    } catch (e) {}
    return null;
  }

  @override
  String toString() {
    return toMap().toString();
  }

  Map<String, dynamic> toMap() {
    return {
      "keyIdentifier": keyIdentifier,
      "certificateIssuer": certificateIssuer,
      "serialNumber": serialNumber,
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }
}

class CertificatePolicyQualifier {
  String oid;
  String? value;

  CertificatePolicyQualifier({required this.oid, this.value});

  @override
  String toString() {
    return toMap().toString();
  }

  Map<String, dynamic> toMap() {
    return {
      "oid": oid,
      "value": value,
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }
}

class CertificatePolicy {
  String oid;
  List<CertificatePolicyQualifier>? qualifiers;

  CertificatePolicy({required this.oid, this.qualifiers});

  @override
  String toString() {
    return toMap().toString();
  }

  Map<String, dynamic> toMap() {
    return {
      "oid": oid,
      "qualifiers": qualifiers?.map((e) => e.toMap()).toList(),
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }
}

/// Recognition for Certificate Policies Extension (2.5.29.32)
class CertificatePoliciesExtension extends X509Extension {
  CertificatePoliciesExtension({required block}) : super(block: block);

  List<CertificatePolicy>? get policies {
    if (valueAsBlock == null) {
      return null;
    }
    var subs = valueAsBlock!.subAtIndex(0)?.sub ?? <ASN1Object>[];

    List<CertificatePolicy> result = <CertificatePolicy>[];
    subs.forEach((sub) {
      var data = sub.subAtIndex(0)?.encoded;
      String? oid;
      if (data != null) {
        oid = ASN1DERDecoder.decodeOid(contentData: data.toList());
        if (oid == null) {
          return;
        }
      } else {
        return;
      }

      List<CertificatePolicyQualifier>? qualifiers;
      var subQualifiers = sub.subAtIndex(1);
      if (subQualifiers != null && subQualifiers.sub != null) {
        qualifiers = <CertificatePolicyQualifier>[];
        subQualifiers.sub!.forEach((sub) {
          var rawValue = sub.subAtIndex(0)?.encoded;
          String? oid;
          if (rawValue != null) {
            oid = ASN1DERDecoder.decodeOid(contentData: rawValue.toList());
            if (oid == null) {
              return;
            }
            var value = sub.subAtIndex(1)?.asString;
            qualifiers!.add(CertificatePolicyQualifier(oid: oid, value: value));
          }
        });
      }
      result.add(CertificatePolicy(oid: oid, qualifiers: qualifiers));
    });
    return result;
  }

  @override
  String toString() {
    return toMap().toString();
  }

  Map<String, dynamic> toMap() {
    return {
      "policies": policies?.map((e) => e.toMap()).toList(),
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }
}

class CRLDistributionPointsExtension extends X509Extension {
  CRLDistributionPointsExtension({required block}) : super(block: block);

  List<String>? get crls {
    if (valueAsBlock == null) {
      return null;
    }
    var subs = valueAsBlock!.subAtIndex(0)?.sub ?? <ASN1Object>[];
    List<String> result = <String>[];
    subs.forEach((sub) {
      var asString = sub.asString;
      if (asString != null) {
        result.add(asString);
      }
    });
    return result;
  }

  @override
  String toString() {
    return toMap().toString();
  }

  Map<String, dynamic> toMap() {
    return {
      "crls": crls,
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }
}
