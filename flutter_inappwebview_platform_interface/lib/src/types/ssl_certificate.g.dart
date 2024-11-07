// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ssl_certificate.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///SSL certificate info (certificate details) class.
class SslCertificate {
  ///Name of the entity this certificate is issued by.
  SslCertificateDName? issuedBy;

  ///Name of the entity this certificate is issued to.
  SslCertificateDName? issuedTo;

  ///Not-after date from the validity period.
  DateTime? validNotAfterDate;

  ///Not-before date from the validity period.
  DateTime? validNotBeforeDate;

  ///The original source certificate, if available.
  X509Certificate? x509Certificate;
  SslCertificate(
      {this.issuedBy,
      this.issuedTo,
      this.validNotAfterDate,
      this.validNotBeforeDate,
      this.x509Certificate});

  ///Gets a possible [SslCertificate] instance from a [Map] value.
  static SslCertificate? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    X509Certificate? x509Certificate;
    try {
      x509Certificate = X509Certificate.fromData(data: map["x509Certificate"]);
    } catch (e, stacktrace) {
      print(e);
      print(stacktrace);
    }
    if (Util.isIOS) {
      if (x509Certificate != null) {
        return SslCertificate(
            issuedBy: SslCertificateDName(
                CName: x509Certificate.issuer(dn: ASN1DistinguishedNames.COMMON_NAME) ??
                    "",
                DName: x509Certificate.issuerDistinguishedName ?? "",
                OName: x509Certificate.issuer(
                        dn: ASN1DistinguishedNames.ORGANIZATION_NAME) ??
                    "",
                UName: x509Certificate.issuer(
                        dn: ASN1DistinguishedNames.ORGANIZATIONAL_UNIT_NAME) ??
                    ""),
            issuedTo: SslCertificateDName(
                CName: x509Certificate.subject(dn: ASN1DistinguishedNames.COMMON_NAME) ??
                    "",
                DName: x509Certificate.subjectDistinguishedName ?? "",
                OName: x509Certificate.subject(
                        dn: ASN1DistinguishedNames.ORGANIZATION_NAME) ??
                    "",
                UName: x509Certificate.subject(
                        dn: ASN1DistinguishedNames.ORGANIZATIONAL_UNIT_NAME) ??
                    ""),
            validNotAfterDate: x509Certificate.notAfter,
            validNotBeforeDate: x509Certificate.notBefore,
            x509Certificate: x509Certificate);
      }
      return null;
    }
    return SslCertificate(
        issuedBy: SslCertificateDName.fromMap(
            map["issuedBy"]?.cast<String, dynamic>(),
            enumMethod: enumMethod),
        issuedTo: SslCertificateDName.fromMap(
            map["issuedTo"]?.cast<String, dynamic>(),
            enumMethod: enumMethod),
        validNotAfterDate: map["validNotAfterDate"] != null
            ? DateTime.fromMillisecondsSinceEpoch(map["validNotAfterDate"])
            : null,
        validNotBeforeDate: map["validNotBeforeDate"] != null
            ? DateTime.fromMillisecondsSinceEpoch(map["validNotBeforeDate"])
            : null,
        x509Certificate: x509Certificate);
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "issuedBy": issuedBy?.toMap(enumMethod: enumMethod),
      "issuedTo": issuedTo?.toMap(enumMethod: enumMethod),
      "validNotAfterDate": validNotAfterDate?.millisecondsSinceEpoch,
      "validNotBeforeDate": validNotBeforeDate?.millisecondsSinceEpoch,
      "x509Certificate": x509Certificate?.toMap(enumMethod: enumMethod),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'SslCertificate{issuedBy: $issuedBy, issuedTo: $issuedTo, validNotAfterDate: $validNotAfterDate, validNotBeforeDate: $validNotBeforeDate, x509Certificate: $x509Certificate}';
  }
}
