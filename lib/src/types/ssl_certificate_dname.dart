import 'ssl_certificate.dart';

///Distinguished name helper class. Used by [SslCertificate].
class SslCertificateDName {
  ///Common-name (CN) component of the name
  // ignore: non_constant_identifier_names
  String? CName;

  ///Distinguished name (normally includes CN, O, and OU names)
  // ignore: non_constant_identifier_names
  String? DName;

  ///Organization (O) component of the name
  // ignore: non_constant_identifier_names
  String? OName;

  ///Organizational Unit (OU) component of the name
  // ignore: non_constant_identifier_names
  String? UName;

  SslCertificateDName(
      // ignore: non_constant_identifier_names
          {this.CName = "",
        // ignore: non_constant_identifier_names
        this.DName = "",
        // ignore: non_constant_identifier_names
        this.OName = "",
        // ignore: non_constant_identifier_names
        this.UName = ""});

  ///Gets a possible [SslCertificateDName] instance from a [Map] value.
  static SslCertificateDName? fromMap(Map<String, dynamic>? map) {
    return map != null
        ? SslCertificateDName(
      CName: map["CName"] ?? "",
      DName: map["DName"] ?? "",
      OName: map["OName"] ?? "",
      UName: map["UName"] ?? "",
    )
        : null;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "CName": CName,
      "DName": DName,
      "OName": OName,
      "UName": UName,
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