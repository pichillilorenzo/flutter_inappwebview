// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'url_credential_persistence.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents the constants that specify how long the credential will be kept.
class URLCredentialPersistence {
  final int _value;
  final int _nativeValue;
  const URLCredentialPersistence._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory URLCredentialPersistence._internalMultiPlatform(
          int value, Function nativeValue) =>
      URLCredentialPersistence._internal(value, nativeValue());

  ///The credential should be stored only for this session
  static const FOR_SESSION = URLCredentialPersistence._internal(1, 1);

  ///The credential should not be stored.
  static const NONE = URLCredentialPersistence._internal(0, 0);

  ///The credential should be stored in the keychain.
  static const PERMANENT = URLCredentialPersistence._internal(2, 2);

  ///The credential should be stored permanently in the keychain,
  ///and in addition should be distributed to other devices based on the owning Apple ID.
  static const SYNCHRONIZABLE = URLCredentialPersistence._internal(3, 3);

  ///Set of all values of [URLCredentialPersistence].
  static final Set<URLCredentialPersistence> values = [
    URLCredentialPersistence.FOR_SESSION,
    URLCredentialPersistence.NONE,
    URLCredentialPersistence.PERMANENT,
    URLCredentialPersistence.SYNCHRONIZABLE,
  ].toSet();

  ///Gets a possible [URLCredentialPersistence] instance from [int] value.
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

  ///Gets a possible [URLCredentialPersistence] instance from a native value.
  static URLCredentialPersistence? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return URLCredentialPersistence.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return 'FOR_SESSION';
      case 0:
        return 'NONE';
      case 2:
        return 'PERMANENT';
      case 3:
        return 'SYNCHRONIZABLE';
    }
    return _value.toString();
  }
}

///An iOS-specific class that represents the constants that specify how long the credential will be kept.
///Use [URLCredentialPersistence] instead.
@Deprecated('Use URLCredentialPersistence instead')
class IOSURLCredentialPersistence {
  final int _value;
  final int _nativeValue;
  const IOSURLCredentialPersistence._internal(this._value, this._nativeValue);
// ignore: unused_element
  factory IOSURLCredentialPersistence._internalMultiPlatform(
          int value, Function nativeValue) =>
      IOSURLCredentialPersistence._internal(value, nativeValue());

  ///The credential should be stored only for this session
  static const FOR_SESSION = IOSURLCredentialPersistence._internal(1, 1);

  ///The credential should not be stored.
  static const NONE = IOSURLCredentialPersistence._internal(0, 0);

  ///The credential should be stored in the keychain.
  static const PERMANENT = IOSURLCredentialPersistence._internal(2, 2);

  ///The credential should be stored permanently in the keychain,
  ///and in addition should be distributed to other devices based on the owning Apple ID.
  static const SYNCHRONIZABLE = IOSURLCredentialPersistence._internal(3, 3);

  ///Set of all values of [IOSURLCredentialPersistence].
  static final Set<IOSURLCredentialPersistence> values = [
    IOSURLCredentialPersistence.FOR_SESSION,
    IOSURLCredentialPersistence.NONE,
    IOSURLCredentialPersistence.PERMANENT,
    IOSURLCredentialPersistence.SYNCHRONIZABLE,
  ].toSet();

  ///Gets a possible [IOSURLCredentialPersistence] instance from [int] value.
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

  ///Gets a possible [IOSURLCredentialPersistence] instance from a native value.
  static IOSURLCredentialPersistence? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return IOSURLCredentialPersistence.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value.
  int toNativeValue() => _nativeValue;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return 'FOR_SESSION';
      case 0:
        return 'NONE';
      case 2:
        return 'PERMANENT';
      case 3:
        return 'SYNCHRONIZABLE';
    }
    return _value.toString();
  }
}
