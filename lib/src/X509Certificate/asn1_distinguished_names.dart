class ASN1DistinguishedNames {
  final String _oid;
  final String _representation;

  const ASN1DistinguishedNames._internal(this._oid, this._representation);

  static final Set<ASN1DistinguishedNames> values = [
    ASN1DistinguishedNames.COMMON_NAME,
    ASN1DistinguishedNames.DN_QUALIFIER,
    ASN1DistinguishedNames.SERIAL_NUMBER,
    ASN1DistinguishedNames.GIVEN_NAME,
    ASN1DistinguishedNames.SURNAME,
    ASN1DistinguishedNames.ORGANIZATIONAL_UNIT_NAME,
    ASN1DistinguishedNames.ORGANIZATION_NAME,
    ASN1DistinguishedNames.STREET_ADDRESS,
    ASN1DistinguishedNames.LOCALITY_NAME,
    ASN1DistinguishedNames.STATE_OR_PROVINCE_NAME,
    ASN1DistinguishedNames.COUNTRY_NAME,
    ASN1DistinguishedNames.EMAIL,
  ].toSet();

  static ASN1DistinguishedNames fromValue(String oid) {
    if (oid != null)
      return ASN1DistinguishedNames.values
          .firstWhere((element) => element.oid() == oid, orElse: () => null);
    return null;
  }

  String oid() => _oid;

  String representation() => _representation;

  @override
  String toString() => "($_oid, $_representation)";

  static const COMMON_NAME =
      const ASN1DistinguishedNames._internal("2.5.4.3", "CN");
  static const DN_QUALIFIER =
      const ASN1DistinguishedNames._internal("2.5.4.46", "DNQ");
  static const SERIAL_NUMBER =
      const ASN1DistinguishedNames._internal("2.5.4.5", "SERIALNUMBER");
  static const GIVEN_NAME =
      const ASN1DistinguishedNames._internal("2.5.4.42", "GIVENNAME");
  static const SURNAME =
      const ASN1DistinguishedNames._internal("2.5.4.4", "SURNAME");
  static const ORGANIZATIONAL_UNIT_NAME =
      const ASN1DistinguishedNames._internal("2.5.4.11", "OU");
  static const ORGANIZATION_NAME =
      const ASN1DistinguishedNames._internal("2.5.4.10", "O");
  static const STREET_ADDRESS =
      const ASN1DistinguishedNames._internal("2.5.4.9", "STREET");
  static const LOCALITY_NAME =
      const ASN1DistinguishedNames._internal("2.5.4.7", "L");
  static const STATE_OR_PROVINCE_NAME =
      const ASN1DistinguishedNames._internal("2.5.4.8", "ST");
  static const COUNTRY_NAME =
      const ASN1DistinguishedNames._internal("2.5.4.6", "C");
  static const EMAIL =
      const ASN1DistinguishedNames._internal("1.2.840.113549.1.9.1", "E");

  bool operator ==(value) => value == _oid;

  @override
  int get hashCode => _oid.hashCode;
}
