class OID {
  final String _value;

  const OID._internal(this._value);

  static final Set<OID> values = [
    OID.etsiQcsCompliance,
    OID.etsiQcsRetentionPeriod,
    OID.etsiQcsQcSSCD,
    OID.dsa,
    OID.ecPublicKey,
    OID.prime256v1,
    OID.ecdsaWithSHA256,
    OID.ecdsaWithSHA512,
    OID.rsaEncryption,
    OID.md2WithRSAEncryption,
    OID.md4WithRSAEncryption,
    OID.md5WithRSAEncryption,
    OID.sha1WithRSAEncryption,
    OID.RSAES_OAEP,
    OID.mgf1,
    OID.pSpecified,
    OID.RSASSA_PSS,
    OID.sha256WithRSAEncryption,
    OID.sha384WithRSAEncryption,
    OID.sha512WithRSAEncryption,
    OID.pkcs7data,
    OID.pkcs7signedData,
    OID.pkcs7envelopedData,
    OID.emailAddress,
    OID.signingCertificateV2,
    OID.contentType,
    OID.messageDigest,
    OID.signingTime,
    OID.dsaWithSha1,
    OID.certificateExtension,
    OID.jurisdictionOfIncorporationSP,
    OID.jurisdictionOfIncorporationC,
    OID.authorityInfoAccess,
    OID.qcStatements,
    OID.cps,
    OID.unotice,
    OID.serverAuth,
    OID.clientAuth,
    OID.ocsp,
    OID.caIssuers,
    OID.dateOfBirth,
    OID.desCBC,
    OID.sha1,
    OID.sha256,
    OID.sha384,
    OID.sha512,
    OID.md5,
    OID.VeriSignEVpolicy,
    OID.extendedValidation,
    OID.organizationValidated,
    OID.subjectKeyIdentifier,
    OID.keyUsage,
    OID.subjectAltName,
    OID.issuerAltName,
    OID.basicConstraints,
    OID.cRLDistributionPoints,
    OID.certificatePolicies,
    OID.authorityKeyIdentifier,
    OID.extKeyUsage,
    OID.subjectDirectoryAttributes,
    OID.organizationName,
    OID.organizationalUnitName,
    OID.businessCategory,
    OID.postalCode,
    OID.commonName,
    OID.surname,
    OID.givenName,
    OID.dnQualifier,
    OID.serialNumber,
    OID.countryName,
    OID.localityName,
    OID.stateOrProvinceName,
    OID.streetAddress,
    OID.desEDE3CBC,
    OID.aes128CBC,
    OID.aes192CBC,
    OID.aes256CBC,
    OID.nsCertType,
    OID.nsComment,
    OID.privateKeyUsagePeriod,
    OID.cRLNumber,
    OID.cRLReason,
    OID.expirationDate,
    OID.instructionCode,
    OID.invalidityDate,
    OID.deltaCRLIndicator,
    OID.issuingDistributionPoint,
    OID.certificateIssuer,
    OID.nameConstraints,
    OID.policyMappings,
    OID.policyConstraints,
    OID.freshestCRL,
    OID.inhibitAnyPolicy,
    OID.codeSigning,
    OID.emailProtection,
    OID.timeStamping,
  ].toSet();

  static OID fromValue(String value) {
    return OID.values.firstWhere((element) => element.toValue() == value,
        orElse: () => null);
  }

  String toValue() => _value;

  String name() => _oidMapName[this._value];

  @override
  String toString() => "($_value, ${name()})";

  static const etsiQcsCompliance = const OID._internal("0.4.0.1862.1.1");
  static const etsiQcsRetentionPeriod = const OID._internal("0.4.0.1862.1.3");
  static const etsiQcsQcSSCD = const OID._internal("0.4.0.1862.1.4");
  static const dsa = const OID._internal("1.2.840.10040.4.1");
  static const ecPublicKey = const OID._internal("1.2.840.10045.2.1");
  static const prime256v1 = const OID._internal("1.2.840.10045.3.1.7");
  static const ecdsaWithSHA256 = const OID._internal("1.2.840.10045.4.3.2");
  static const ecdsaWithSHA512 = const OID._internal("1.2.840.10045.4.3.4");
  static const rsaEncryption = const OID._internal("1.2.840.113549.1.1.1");
  static const md2WithRSAEncryption =
      const OID._internal("1.2.840.113549.1.1.2");
  static const md4WithRSAEncryption =
      const OID._internal("1.2.840.113549.1.1.3");
  static const md5WithRSAEncryption =
      const OID._internal("1.2.840.113549.1.1.4");
  static const sha1WithRSAEncryption =
      const OID._internal("1.2.840.113549.1.1.5");
  static const RSAES_OAEP = const OID._internal("1.2.840.113549.1.1.7");
  static const mgf1 = const OID._internal(".2.840.113549.1.1.8");
  static const pSpecified = const OID._internal(".2.840.113549.1.1.9");
  static const RSASSA_PSS = const OID._internal(".2.840.113549.1.1.10");
  static const sha256WithRSAEncryption =
      const OID._internal("1.2.840.113549.1.1.11");
  static const sha384WithRSAEncryption =
      const OID._internal("1.2.840.113549.1.1.12");
  static const sha512WithRSAEncryption =
      const OID._internal("1.2.840.113549.1.1.13");
  static const pkcs7data = const OID._internal("1.2.840.113549.1.7.1");
  static const pkcs7signedData = const OID._internal("1.2.840.113549.1.7.2");
  static const pkcs7envelopedData = const OID._internal("1.2.840.113549.1.7.3");
  static const emailAddress = const OID._internal("1.2.840.113549.1.9.1");
  static const signingCertificateV2 =
      const OID._internal("1.2.840.113549.1.9.16.2.47");
  static const contentType = const OID._internal("1.2.840.113549.1.9.3");
  static const messageDigest = const OID._internal("1.2.840.113549.1.9.4");
  static const signingTime = const OID._internal("1.2.840.113549.1.9.5");
  static const dsaWithSha1 = const OID._internal("1.2.840.10040.4.3");
  static const certificateExtension =
      const OID._internal("1.3.6.1.4.1.11129.2.4.2");
  static const jurisdictionOfIncorporationSP =
      const OID._internal("1.3.6.1.4.1.311.60.2.1.2");
  static const jurisdictionOfIncorporationC =
      const OID._internal("1.3.6.1.4.1.311.60.2.1.3");
  static const authorityInfoAccess = const OID._internal("1.3.6.1.5.5.7.1.1");
  static const qcStatements = const OID._internal("1.3.6.1.5.5.7.1.3");
  static const cps = const OID._internal("1.3.6.1.5.5.7.2.1");
  static const unotice = const OID._internal("1.3.6.1.5.5.7.2.2");
  static const serverAuth = const OID._internal("1.3.6.1.5.5.7.3.1");
  static const clientAuth = const OID._internal("1.3.6.1.5.5.7.3.2");
  static const ocsp = const OID._internal("1.3.6.1.5.5.7.48.1");
  static const caIssuers = const OID._internal("1.3.6.1.5.5.7.48.2");
  static const dateOfBirth = const OID._internal("1.3.6.1.5.5.7.9.1");
  static const desCBC = const OID._internal("1.3.14.3.2.7");
  static const sha1 = const OID._internal("1.3.14.3.2.26");
  static const sha256 = const OID._internal("2.16.840.1.101.3.4.2.1");
  static const sha384 = const OID._internal("2.16.840.1.101.3.4.2.2");
  static const sha512 = const OID._internal("2.16.840.1.101.3.4.2.3");
  static const md5 = const OID._internal("1.2.840.113549.2.5");
  static const VeriSignEVpolicy =
      const OID._internal("2.16.840.1.113733.1.7.23.6");
  static const extendedValidation = const OID._internal("2.23.140.1.1");
  static const organizationValidated = const OID._internal("2.23.140.1.2.2");
  static const subjectKeyIdentifier = const OID._internal("2.5.29.14");
  static const keyUsage = const OID._internal("2.5.29.15");
  static const subjectAltName = const OID._internal("2.5.29.17");
  static const issuerAltName = const OID._internal("2.5.29.18");
  static const basicConstraints = const OID._internal("2.5.29.19");
  static const cRLDistributionPoints = const OID._internal("2.5.29.31");
  static const certificatePolicies = const OID._internal("2.5.29.32");
  static const authorityKeyIdentifier = const OID._internal("2.5.29.35");
  static const extKeyUsage = const OID._internal("2.5.29.37");
  static const subjectDirectoryAttributes = const OID._internal("2.5.29.9");
  static const organizationName = const OID._internal("2.5.4.10");
  static const organizationalUnitName = const OID._internal("2.5.4.11");
  static const businessCategory = const OID._internal("2.5.4.15");
  static const postalCode = const OID._internal("2.5.4.17");
  static const commonName = const OID._internal("2.5.4.3");
  static const surname = const OID._internal("2.5.4.4");
  static const givenName = const OID._internal("2.5.4.42");
  static const dnQualifier = const OID._internal("2.5.4.46");
  static const serialNumber = const OID._internal("2.5.4.5");
  static const countryName = const OID._internal("2.5.4.6");
  static const localityName = const OID._internal("2.5.4.7");
  static const stateOrProvinceName = const OID._internal("2.5.4.8");
  static const streetAddress = const OID._internal("2.5.4.9");
  static const desEDE3CBC = const OID._internal("1.2.840.113549.3.7");
  static const aes128CBC = const OID._internal("2.16.840.1.101.3.4.1.2");
  static const aes192CBC = const OID._internal("2.16.840.1.101.3.4.1.22");
  static const aes256CBC = const OID._internal("2.16.840.1.101.3.4.1.42");
  static const nsCertType = const OID._internal("2.16.840.1.113730.1.1");
  static const nsComment = const OID._internal("2.16.840.1.113730.1.13");
  static const privateKeyUsagePeriod = const OID._internal("2.5.29.16");
  static const cRLNumber = const OID._internal("2.5.29.20");
  static const cRLReason = const OID._internal("2.5.29.21");
  static const expirationDate = const OID._internal("2.5.29.22");
  static const instructionCode = const OID._internal("2.5.29.23");
  static const invalidityDate = const OID._internal("2.5.29.24");
  static const deltaCRLIndicator = const OID._internal("2.5.29.27");
  static const issuingDistributionPoint = const OID._internal("2.5.29.28");
  static const certificateIssuer = const OID._internal("2.5.29.29");
  static const nameConstraints = const OID._internal("2.5.29.30");
  static const policyMappings = const OID._internal("2.5.29.33");
  static const policyConstraints = const OID._internal("2.5.29.36");
  static const freshestCRL = const OID._internal("2.5.29.46");
  static const inhibitAnyPolicy = const OID._internal("2.5.29.54");
  static const codeSigning = const OID._internal("1.3.6.1.5.5.7.3.3");
  static const emailProtection = const OID._internal("1.3.6.1.5.5.7.3.4");
  static const timeStamping = const OID._internal("1.3.6.1.5.5.7.3.8");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;

  static const Map<String, String> _oidMapName = {
    "0.4.0.1862.1.1": "etsiQcsCompliance",
    "0.4.0.1862.1.3": "etsiQcsRetentionPeriod",
    "0.4.0.1862.1.4": "etsiQcsQcSSCD",
    "1.2.840.10040.4.1": "dsa",
    "1.2.840.10045.2.1": "ecPublicKey",
    "1.2.840.10045.3.1.7": "prime256v1",
    "1.2.840.10045.4.3.2": "ecdsaWithSHA256",
    "1.2.840.10045.4.3.4": "ecdsaWithSHA512",
    "1.2.840.113549.1.1.1": "rsaEncryption",
    "1.2.840.113549.1.1.2": "md2WithRSAEncryption",
    "1.2.840.113549.1.1.3": "md4WithRSAEncryption",
    "1.2.840.113549.1.1.4": "md5WithRSAEncryption",
    "1.2.840.113549.1.1.5": "sha1WithRSAEncryption",
    "1.2.840.113549.1.1.7": "RSAES-OAEP",
    ".2.840.113549.1.1.8": "mgf1",
    ".2.840.113549.1.1.9": "pSpecified",
    ".2.840.113549.1.1.10": "RSASSA-PSS",
    "1.2.840.113549.1.1.11": "sha256WithRSAEncryption",
    "1.2.840.113549.1.1.12": "sha384WithRSAEncryption",
    "1.2.840.113549.1.1.13": "sha512WithRSAEncryption",
    "1.2.840.113549.1.7.1": "pkcs7data",
    "1.2.840.113549.1.7.2": "pkcs7signedData",
    "1.2.840.113549.1.7.3": "pkcs7envelopedData",
    "1.2.840.113549.1.9.1": "emailAddress",
    "1.2.840.113549.1.9.16.2.47": "signingCertificateV2",
    "1.2.840.113549.1.9.3": "contentType",
    "1.2.840.113549.1.9.4": "messageDigest",
    "1.2.840.113549.1.9.5": "signingTime",
    "1.2.840.10040.4.3": "dsaWithSha1",
    "1.3.6.1.4.1.11129.2.4.2": "certificateExtension",
    "1.3.6.1.4.1.311.60.2.1.2": "jurisdictionOfIncorporationSP",
    "1.3.6.1.4.1.311.60.2.1.3": "jurisdictionOfIncorporationC",
    "1.3.6.1.5.5.7.1.1": "authorityInfoAccess",
    "1.3.6.1.5.5.7.1.3": "qcStatements",
    "1.3.6.1.5.5.7.2.1": "cps",
    "1.3.6.1.5.5.7.2.2": "unotice",
    "1.3.6.1.5.5.7.3.1": "serverAuth",
    "1.3.6.1.5.5.7.3.2": "clientAuth",
    "1.3.6.1.5.5.7.48.1": "ocsp",
    "1.3.6.1.5.5.7.48.2": "caIssuers",
    "1.3.6.1.5.5.7.9.1": "dateOfBirth",
    "1.3.14.3.2.7": "desCBC",
    "1.3.14.3.2.26": "sha1",
    "2.16.840.1.101.3.4.2.1": "sha256",
    "2.16.840.1.101.3.4.2.2": "sha384",
    "2.16.840.1.101.3.4.2.3": "sha512",
    "1.2.840.113549.2.5": "md5",
    "2.16.840.1.113733.1.7.23.6": "VeriSign EV policy",
    "2.23.140.1.1": "extendedValidation",
    "2.23.140.1.2.2": "organizationValidated",
    "2.5.29.14": "subjectKeyIdentifier",
    "2.5.29.15": "keyUsage",
    "2.5.29.17": "subjectAltName",
    "2.5.29.18": "issuerAltName",
    "2.5.29.19": "basicConstraints",
    "2.5.29.31": "cRLDistributionPoints",
    "2.5.29.32": "certificatePolicies",
    "2.5.29.35": "authorityKeyIdentifier",
    "2.5.29.37": "extKeyUsage",
    "2.5.29.9": "subjectDirectoryAttributes",
    "2.5.4.10": "organizationName",
    "2.5.4.11": "organizationalUnitName",
    "2.5.4.15": "businessCategory",
    "2.5.4.17": "postalCode",
    "2.5.4.3": "commonName",
    "2.5.4.4": "surname",
    "2.5.4.42": "givenName",
    "2.5.4.46": "dnQualifier",
    "2.5.4.5": "serialNumber",
    "2.5.4.6": "countryName",
    "2.5.4.7": "localityName",
    "2.5.4.8": "stateOrProvinceName",
    "2.5.4.9": "streetAddress",
    "1.2.840.113549.3.7": "des-EDE3-CBC",
    "2.16.840.1.101.3.4.1.2": "aes128-CBC",
    "2.16.840.1.101.3.4.1.22": "aes192-CBC",
    "2.16.840.1.101.3.4.1.42": "aes256-CBC",
    "2.16.840.1.113730.1.1": "nsCertType",
    "2.16.840.1.113730.1.13": "nsComment",
    "2.5.29.16": "privateKeyUsagePeriod",
    "2.5.29.20": "cRLNumber",
    "2.5.29.21": "cRLReason",
    "2.5.29.22": "expirationDate",
    "2.5.29.23": "instructionCode",
    "2.5.29.24": "invalidityDate",
    "2.5.29.27": "deltaCRLIndicator",
    "2.5.29.28": "issuingDistributionPoint",
    "2.5.29.29": "certificateIssuer",
    "2.5.29.30": "nameConstraints",
    "2.5.29.33": "policyMappings",
    "2.5.29.36": "policyConstraints",
    "2.5.29.46": "freshestCRL",
    "2.5.29.54": "inhibitAnyPolicy",
    "1.3.6.1.5.5.7.3.3": "codeSigning",
    "1.3.6.1.5.5.7.3.4": "emailProtection",
    "1.3.6.1.5.5.7.3.8": "timeStamping",
  };
}
