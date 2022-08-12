import 'dart:typed_data';

import 'x509_certificate.dart';

import 'asn1_identifier.dart';
import 'oid.dart';

class ASN1Object {
  /// This property contains the DER encoded object
  Uint8List encoded;

  /// This property contains the decoded Swift object whenever is possible
  dynamic value;

  ASN1Identifier identifier;

  List<ASN1Object> sub;

  ASN1Object parent;

  ASN1Object subAtIndex(int index) {
    if (sub != null && index >= 0 && index < sub.length) {
      return sub[index];
    }
    return null;
  }

  ASN1Object firstSub() {
    if (subCount() > 0) {
      return sub.first;
    }
    return null;
  }

  ASN1Object lastSub() {
    if (subCount() > 0) {
      return sub.last;
    }
    return null;
  }

  int subCount() {
    return sub?.length ?? 0;
  }

  ASN1Object findOid({OID oid, String oidValue}) {
    oidValue = oid != null ? oid.toValue() : oidValue;
    for (var child in (sub ?? <ASN1Object>[])) {
      if (child.identifier?.tagNumber() ==
          ASN1IdentifierTagNumber.OBJECT_IDENTIFIER) {
        if (child.value == oidValue) {
          return child;
        }
      } else {
        var result = child.findOid(oidValue: oidValue);
        if (result != null) {
          return result;
        }
      }
    }
    return null;
  }

  String get description {
    return printAsn1();
  }

  String printAsn1({insets = ""}) {
    var output = insets;
    output += identifier?.description?.toUpperCase() ?? "";
    output += (value != null ? ": $value" : "");
    if (identifier?.typeClass() == ASN1IdentifierClass.UNIVERSAL &&
        identifier?.tagNumber() == ASN1IdentifierTagNumber.OBJECT_IDENTIFIER) {
      var descr = OID.fromValue(value?.toString() ?? "")?.name();
      if (descr != null) {
        output += " ($descr)";
      }
    }
    output += sub != null && sub.length > 0 ? " {" : "";
    output += "\n";
    for (var item in (sub ?? <ASN1Object>[])) {
      output += item.printAsn1(insets: insets + "    ");
    }
    output += sub != null && sub.length > 0 ? "}\n" : "";
    return output;
  }

  @override
  String toString() {
    return description;
  }

  ASN1Object atIndex(X509BlockPosition x509blockPosition) {
    if (sub != null && x509blockPosition.index < sub.length) {
      return sub[x509blockPosition.index];
    }
    return null;
  }
}
