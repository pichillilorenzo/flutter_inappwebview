class ASN1IdentifierClass {
  final int _value;

  const ASN1IdentifierClass._internal(this._value);

  static final Set<ASN1IdentifierClass> values = [
    ASN1IdentifierClass.UNIVERSAL,
    ASN1IdentifierClass.APPLICATION,
    ASN1IdentifierClass.CONTEXT_SPECIFIC,
    ASN1IdentifierClass.PRIVATE,
  ].toSet();

  static ASN1IdentifierClass fromValue(int value) {
    if (value != null)
      return ASN1IdentifierClass.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  int toValue() => _value;

  static const UNIVERSAL = const ASN1IdentifierClass._internal(0x00);
  static const APPLICATION = const ASN1IdentifierClass._internal(0x40);
  static const CONTEXT_SPECIFIC = const ASN1IdentifierClass._internal(0x80);
  static const PRIVATE = const ASN1IdentifierClass._internal(0xC0);

  @override
  String toString() {
    switch (this.toValue()) {
      case 0x00:
        return "UNIVERSAL";
      case 0x40:
        return "APPLICATION";
      case 0x80:
        return "CONTEXT_SPECIFIC";
      case 0xC0:
        return "PRIVATE";
    }
    return "";
  }

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

class ASN1IdentifierTagNumber {
  final int _value;

  const ASN1IdentifierTagNumber._internal(this._value);

  static final Set<ASN1IdentifierTagNumber> values = [
    ASN1IdentifierTagNumber.END_OF_CONTENT,
    ASN1IdentifierTagNumber.BOOLEAN,
    ASN1IdentifierTagNumber.INTEGER,
    ASN1IdentifierTagNumber.BIT_STRING,
    ASN1IdentifierTagNumber.OCTET_STRING,
    ASN1IdentifierTagNumber.NULL,
    ASN1IdentifierTagNumber.OBJECT_IDENTIFIER,
    ASN1IdentifierTagNumber.OBJECT_DESCRIPTOR,
    ASN1IdentifierTagNumber.EXTERNAL,
    ASN1IdentifierTagNumber.READ,
    ASN1IdentifierTagNumber.ENUMERATED,
    ASN1IdentifierTagNumber.EMBEDDED_PDV,
    ASN1IdentifierTagNumber.UTF8_STRING,
    ASN1IdentifierTagNumber.RELATIVE_OID,
    ASN1IdentifierTagNumber.SEQUENCE,
    ASN1IdentifierTagNumber.SET,
    ASN1IdentifierTagNumber.NUMERIC_STRING,
    ASN1IdentifierTagNumber.PRINTABLE_STRING,
    ASN1IdentifierTagNumber.T61_STRING,
    ASN1IdentifierTagNumber.VIDEOTEX_STRING,
    ASN1IdentifierTagNumber.IA5_STRING,
    ASN1IdentifierTagNumber.UTC_TIME,
    ASN1IdentifierTagNumber.GENERALIZED_TIME,
    ASN1IdentifierTagNumber.GRAPHIC_STRING,
    ASN1IdentifierTagNumber.VISIBLE_STRING,
    ASN1IdentifierTagNumber.GENERAL_STRING,
    ASN1IdentifierTagNumber.UNIVERSAL_STRING,
    ASN1IdentifierTagNumber.CHARACTER_STRING,
    ASN1IdentifierTagNumber.BMP_STRING,
  ].toSet();

  static ASN1IdentifierTagNumber fromValue(int value) {
    if (value != null)
      return ASN1IdentifierTagNumber.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  int toValue() => _value;

  static const END_OF_CONTENT = const ASN1IdentifierTagNumber._internal(0x00);
  static const BOOLEAN = const ASN1IdentifierTagNumber._internal(0x01);
  static const INTEGER = const ASN1IdentifierTagNumber._internal(0x02);
  static const BIT_STRING = const ASN1IdentifierTagNumber._internal(0x03);
  static const OCTET_STRING = const ASN1IdentifierTagNumber._internal(0x04);
  static const NULL = const ASN1IdentifierTagNumber._internal(0x05);
  static const OBJECT_IDENTIFIER =
      const ASN1IdentifierTagNumber._internal(0x06);
  static const OBJECT_DESCRIPTOR =
      const ASN1IdentifierTagNumber._internal(0x07);
  static const EXTERNAL = const ASN1IdentifierTagNumber._internal(0x08);
  static const READ = const ASN1IdentifierTagNumber._internal(0x09);
  static const ENUMERATED = const ASN1IdentifierTagNumber._internal(0x0A);
  static const EMBEDDED_PDV = const ASN1IdentifierTagNumber._internal(0x0B);
  static const UTF8_STRING = const ASN1IdentifierTagNumber._internal(0x0C);
  static const RELATIVE_OID = const ASN1IdentifierTagNumber._internal(0x0D);
  static const SEQUENCE = const ASN1IdentifierTagNumber._internal(0x10);
  static const SET = const ASN1IdentifierTagNumber._internal(0x11);
  static const NUMERIC_STRING = const ASN1IdentifierTagNumber._internal(0x12);
  static const PRINTABLE_STRING = const ASN1IdentifierTagNumber._internal(0x13);
  static const T61_STRING = const ASN1IdentifierTagNumber._internal(0x14);
  static const VIDEOTEX_STRING = const ASN1IdentifierTagNumber._internal(0x15);
  static const IA5_STRING = const ASN1IdentifierTagNumber._internal(0x16);
  static const UTC_TIME = const ASN1IdentifierTagNumber._internal(0x17);
  static const GENERALIZED_TIME = const ASN1IdentifierTagNumber._internal(0x18);
  static const GRAPHIC_STRING = const ASN1IdentifierTagNumber._internal(0x19);
  static const VISIBLE_STRING = const ASN1IdentifierTagNumber._internal(0x1A);
  static const GENERAL_STRING = const ASN1IdentifierTagNumber._internal(0x1B);
  static const UNIVERSAL_STRING = const ASN1IdentifierTagNumber._internal(0x1C);
  static const CHARACTER_STRING = const ASN1IdentifierTagNumber._internal(0x1D);
  static const BMP_STRING = const ASN1IdentifierTagNumber._internal(0x1E);

  @override
  String toString() {
    switch (this.toValue()) {
      case 0x00:
        return "END_OF_CONTENT";
      case 0x01:
        return "BOOLEAN";
      case 0x02:
        return "INTEGER";
      case 0x03:
        return "BIT_STRING";
      case 0x04:
        return "OCTET_STRING";
      case 0x05:
        return "NULL";
      case 0x06:
        return "OBJECT_IDENTIFIER";
      case 0x07:
        return "OBJECT_DESCRIPTOR";
      case 0x08:
        return "EXTERNAL";
      case 0x09:
        return "READ";
      case 0x0A:
        return "ENUMERATED";
      case 0x0B:
        return "EMBEDDED_PDV";
      case 0x0C:
        return "UTF8_STRING";
      case 0x0D:
        return "RELATIVE_OID";
      case 0x10:
        return "SEQUENCE";
      case 0x11:
        return "SET";
      case 0x12:
        return "NUMERIC_STRING";
      case 0x13:
        return "PRINTABLE_STRING";
      case 0x14:
        return "T61_STRING";
      case 0x15:
        return "VIDEOTEX_STRING";
      case 0x16:
        return "IA5_STRING";
      case 0x17:
        return "UTC_TIME";
      case 0x18:
        return "GENERALIZED_TIME";
      case 0x19:
        return "GRAPHIC_STRING";
      case 0x1A:
        return "VISIBLE_STRING";
      case 0x1B:
        return "GENERAL_STRING";
      case 0x1C:
        return "UNIVERSAL_STRING";
      case 0x1D:
        return "CHARACTER_STRING";
      case 0x1E:
        return "BMP_STRING";
    }
    return "";
  }

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

class ASN1Identifier {
  int rawValue;

  ASN1Identifier(this.rawValue);

  bool isPrimitive() {
    return (rawValue & 0x20) == 0;
  }

  bool isConstructed() {
    return (rawValue & 0x20) != 0;
  }

  ASN1IdentifierTagNumber tagNumber() {
    return ASN1IdentifierTagNumber.fromValue(rawValue & 0x1F) ??
        ASN1IdentifierTagNumber.END_OF_CONTENT;
  }

  ASN1IdentifierClass typeClass() {
    for (var tc in [
      ASN1IdentifierClass.APPLICATION,
      ASN1IdentifierClass.CONTEXT_SPECIFIC,
      ASN1IdentifierClass.PRIVATE
    ]) {
      if ((rawValue & tc.toValue()) == tc.toValue()) {
        return tc;
      }
    }
    return ASN1IdentifierClass.UNIVERSAL;
  }

  String get description {
    var tc = typeClass();
    var tn = tagNumber();
    if (tc == ASN1IdentifierClass.UNIVERSAL) {
      return tn.toString();
    } else {
      return "$tc(${tn.toValue()})";
    }
  }

  @override
  String toString() {
    return description;
  }
}
