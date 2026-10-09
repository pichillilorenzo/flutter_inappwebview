class KeyUsage {
  final int _value;

  const KeyUsage._internal(this._value);

  static final Set<KeyUsage> values = {
    KeyUsage.digitalSignature,
    KeyUsage.nonRepudiation,
    KeyUsage.keyEncipherment,
    KeyUsage.dataEncipherment,
    KeyUsage.keyAgreement,
    KeyUsage.keyCertSign,
    KeyUsage.cRLSign,
    KeyUsage.encipherOnly,
    KeyUsage.decipherOnly,
  };

  static KeyUsage? fromIndex(int? value) {
    if (value != null) {
      try {
        return KeyUsage.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  int toValue() => _value;

  String name() => _KeyUsageMapName.containsKey(_value)
      ? _KeyUsageMapName[_value]!
      : "";

  @override
  String toString() => "($_value, ${name()})";

  static const digitalSignature = KeyUsage._internal(0);
  static const nonRepudiation = KeyUsage._internal(1);
  static const keyEncipherment = KeyUsage._internal(2);
  static const dataEncipherment = KeyUsage._internal(3);
  static const keyAgreement = KeyUsage._internal(4);
  static const keyCertSign = KeyUsage._internal(5);
  static const cRLSign = KeyUsage._internal(6);
  static const encipherOnly = KeyUsage._internal(7);
  static const decipherOnly = KeyUsage._internal(8);

  @override
  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;

  static const Map<int, String> _KeyUsageMapName = {
    0: "digitalSignature",
    1: "nonRepudiation",
    2: "keyEncipherment",
    3: "dataEncipherment",
    4: "keyAgreement",
    5: "keyCertSign",
    6: "cRLSign",
    7: "encipherOnly",
    8: "decipherOnly",
  };
}
