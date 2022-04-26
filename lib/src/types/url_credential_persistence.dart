///Class that represents the constants that specify how long the credential will be kept.
class URLCredentialPersistence {
  final int _value;

  const URLCredentialPersistence._internal(this._value);

  static final Set<URLCredentialPersistence> values = [
    URLCredentialPersistence.NONE,
    URLCredentialPersistence.FOR_SESSION,
    URLCredentialPersistence.PERMANENT,
    URLCredentialPersistence.SYNCHRONIZABLE,
  ].toSet();

  ///Gets a possible [URLCredentialPersistence] instance from an [int] value.
  static URLCredentialPersistence? fromValue(int? value) {
    if (value != null) {
      try {
        return URLCredentialPersistence.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  ///Gets [int] value.
  int toValue() => _value;

  String toString() {
    switch (_value) {
      case 1:
        return "FOR_SESSION";
      case 2:
        return "PERMANENT";
      case 3:
        return "SYNCHRONIZABLE";
      case 0:
      default:
        return "NONE";
    }
  }

  ///The credential should not be stored.
  static const NONE = const URLCredentialPersistence._internal(0);

  ///The credential should be stored only for this session
  static const FOR_SESSION = const URLCredentialPersistence._internal(1);

  ///The credential should be stored in the keychain.
  static const PERMANENT = const URLCredentialPersistence._internal(2);

  ///The credential should be stored permanently in the keychain,
  ///and in addition should be distributed to other devices based on the owning Apple ID.
  static const SYNCHRONIZABLE = const URLCredentialPersistence._internal(3);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///An iOS-specific class that represents the constants that specify how long the credential will be kept.
///Use [URLCredentialPersistence] instead.
@Deprecated("Use URLCredentialPersistence instead")
class IOSURLCredentialPersistence {
  final int _value;

  const IOSURLCredentialPersistence._internal(this._value);

  static final Set<IOSURLCredentialPersistence> values = [
    IOSURLCredentialPersistence.NONE,
    IOSURLCredentialPersistence.FOR_SESSION,
    IOSURLCredentialPersistence.PERMANENT,
    IOSURLCredentialPersistence.SYNCHRONIZABLE,
  ].toSet();

  ///Gets a possible [IOSURLCredentialPersistence] instance from an [int] value.
  static IOSURLCredentialPersistence? fromValue(int? value) {
    if (value != null) {
      try {
        return IOSURLCredentialPersistence.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  ///Gets [int] value.
  int toValue() => _value;

  String toString() {
    switch (_value) {
      case 1:
        return "FOR_SESSION";
      case 2:
        return "PERMANENT";
      case 3:
        return "SYNCHRONIZABLE";
      case 0:
      default:
        return "NONE";
    }
  }

  ///The credential should not be stored.
  static const NONE = const IOSURLCredentialPersistence._internal(0);

  ///The credential should be stored only for this session
  static const FOR_SESSION = const IOSURLCredentialPersistence._internal(1);

  ///The credential should be stored in the keychain.
  static const PERMANENT = const IOSURLCredentialPersistence._internal(2);

  ///The credential should be stored permanently in the keychain,
  ///and in addition should be distributed to other devices based on the owning Apple ID.
  static const SYNCHRONIZABLE = const IOSURLCredentialPersistence._internal(3);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}