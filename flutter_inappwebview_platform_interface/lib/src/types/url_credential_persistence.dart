import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'url_credential_persistence.g.dart';

///Class that represents the constants that specify how long the credential will be kept.
@ExchangeableEnum()
class URLCredentialPersistence_ {
  // ignore: unused_field
  final int _value;
  const URLCredentialPersistence_._internal(this._value);

  ///The credential should not be stored.
  static const NONE = const URLCredentialPersistence_._internal(0);

  ///The credential should be stored only for this session
  static const FOR_SESSION = const URLCredentialPersistence_._internal(1);

  ///The credential should be stored in the keychain.
  static const PERMANENT = const URLCredentialPersistence_._internal(2);

  ///The credential should be stored permanently in the keychain,
  ///and in addition should be distributed to other devices based on the owning Apple ID.
  static const SYNCHRONIZABLE = const URLCredentialPersistence_._internal(3);
}

///An iOS-specific class that represents the constants that specify how long the credential will be kept.
///Use [URLCredentialPersistence] instead.
@Deprecated("Use URLCredentialPersistence instead")
@ExchangeableEnum()
class IOSURLCredentialPersistence_ {
  // ignore: unused_field
  final int _value;
  const IOSURLCredentialPersistence_._internal(this._value);

  ///The credential should not be stored.
  static const NONE = const IOSURLCredentialPersistence_._internal(0);

  ///The credential should be stored only for this session
  static const FOR_SESSION = const IOSURLCredentialPersistence_._internal(1);

  ///The credential should be stored in the keychain.
  static const PERMANENT = const IOSURLCredentialPersistence_._internal(2);

  ///The credential should be stored permanently in the keychain,
  ///and in addition should be distributed to other devices based on the owning Apple ID.
  static const SYNCHRONIZABLE = const IOSURLCredentialPersistence_._internal(3);
}
