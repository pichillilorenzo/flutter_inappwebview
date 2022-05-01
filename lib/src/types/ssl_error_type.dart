import 'package:flutter/foundation.dart';

import 'server_trust_challenge.dart';

///Class that represents the SSL Primary error associated to the server SSL certificate.
///Used by the [ServerTrustChallenge] class.
class SslErrorType {
  final String _value;
  final int _nativeValue;

  const SslErrorType._internal(this._value, this._nativeValue);

  ///Set of all values of [SslErrorType].
  static final Set<SslErrorType> values = [
    SslErrorType.NOT_YET_VALID,
    SslErrorType.EXPIRED,
    SslErrorType.IDMISMATCH,
    SslErrorType.UNTRUSTED,
    SslErrorType.DATE_INVALID,
    SslErrorType.INVALID,
    SslErrorType.DENY,
    SslErrorType.UNSPECIFIED,
    SslErrorType.RECOVERABLE_TRUST_FAILURE,
    SslErrorType.FATAL_TRUST_FAILURE,
    SslErrorType.OTHER_ERROR,
  ].toSet();

  ///Gets a possible [SslErrorType] instance from a [String] value.
  static SslErrorType? fromValue(String? value) {
    if (value != null) {
      try {
        return SslErrorType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [SslErrorType] instance from a value.
  static SslErrorType? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return SslErrorType.values
            .firstWhere((element) => element.toNativeValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets native [int] value.
  int toNativeValue() => _nativeValue;

  @override
  String toString() => _value;

  ///The certificate is not yet valid.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SslError.SSL_NOTYETVALID](https://developer.android.com/reference/android/net/http/SslError#SSL_NOTYETVALID))
  static final NOT_YET_VALID = SslErrorType._internal('NOT_YET_VALID',
      (defaultTargetPlatform != TargetPlatform.android) ? 0 : -1);

  ///The certificate has expired.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SslError.SSL_EXPIRED](https://developer.android.com/reference/android/net/http/SslError#SSL_EXPIRED))
  static final EXPIRED = SslErrorType._internal(
      'EXPIRED', (defaultTargetPlatform != TargetPlatform.android) ? 1 : -1);

  ///Hostname mismatch.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SslError.SSL_IDMISMATCH](https://developer.android.com/reference/android/net/http/SslError#SSL_IDMISMATCH))
  static final IDMISMATCH = SslErrorType._internal(
      'IDMISMATCH', (defaultTargetPlatform != TargetPlatform.android) ? 2 : -1);

  ///The certificate authority is not trusted.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SslError.SSL_UNTRUSTED](https://developer.android.com/reference/android/net/http/SslError#SSL_UNTRUSTED))
  static final UNTRUSTED = SslErrorType._internal(
      'UNTRUSTED', (defaultTargetPlatform != TargetPlatform.android) ? 3 : -1);

  ///The date of the certificate is invalid.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SslError.SSL_DATE_INVALID](https://developer.android.com/reference/android/net/http/SslError#SSL_DATE_INVALID))
  static final DATE_INVALID = SslErrorType._internal('DATE_INVALID',
      (defaultTargetPlatform != TargetPlatform.android) ? 4 : -1);

  ///Indicates an invalid setting or result. A generic error occurred.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - SslError.SSL_INVALID](https://developer.android.com/reference/android/net/http/SslError#SSL_INVALID))
  ///- iOS ([Official API - SecTrustResultType.invalid](https://developer.apple.com/documentation/security/sectrustresulttype/invalid))
  static final INVALID = SslErrorType._internal(
      'INVALID',
      (defaultTargetPlatform != TargetPlatform.android)
          ? 5
          : ((defaultTargetPlatform != TargetPlatform.iOS ||
                  defaultTargetPlatform != TargetPlatform.macOS)
              ? 0
              : -1));

  ///The user specified that the certificate should not be trusted.
  ///
  ///This value indicates that the user explicitly chose to not trust a certificate in the chain,
  ///usually by clicking the appropriate button in a certificate trust panel.
  ///Your app should not trust the chain.
  ///The Keychain Access utility refers to this value as "Never Trust."
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - SecTrustResultType.deny](https://developer.apple.com/documentation/security/sectrustresulttype/deny))
  static final DENY = SslErrorType._internal(
      'DENY',
      (defaultTargetPlatform != TargetPlatform.iOS ||
              defaultTargetPlatform != TargetPlatform.macOS)
          ? 3
          : -1);

  ///Indicates the evaluation succeeded and the certificate is implicitly trusted, but user intent was not explicitly specified.
  ///
  ///This value indicates that evaluation reached an (implicitly trusted) anchor certificate without any evaluation failures,
  ///but never encountered any explicitly stated user-trust preference.
  ///This is the most common return value.
  ///The Keychain Access utility refers to this value as the “Use System Policy,” which is the default user setting.
  ///
  ///When receiving this value, most apps should trust the chain.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - SecTrustResultType.unspecified](https://developer.apple.com/documentation/security/sectrustresulttype/unspecified))
  static final UNSPECIFIED = SslErrorType._internal(
      'UNSPECIFIED',
      (defaultTargetPlatform != TargetPlatform.iOS ||
              defaultTargetPlatform != TargetPlatform.macOS)
          ? 4
          : -1);

  ///Trust is denied, but recovery may be possible.
  ///
  ///This value indicates that you should not trust the chain as is,
  ///but that the chain could be trusted with some minor change to the evaluation context,
  ///such as ignoring expired certificates or adding another anchor to the set of trusted anchors.
  ///
  ///The way you handle this depends on the situation.
  ///For example, if you are performing signature validation and you know when the message was originally received,
  ///you should check again using that date to see if the message was valid when you originally received it.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - SecTrustResultType.recoverableTrustFailure](https://developer.apple.com/documentation/security/sectrustresulttype/recoverabletrustfailure))
  static final RECOVERABLE_TRUST_FAILURE = SslErrorType._internal(
      'RECOVERABLE_TRUST_FAILURE',
      (defaultTargetPlatform != TargetPlatform.iOS ||
              defaultTargetPlatform != TargetPlatform.macOS)
          ? 5
          : -1);

  ///Trust is denied and no simple fix is available.
  ///
  ///This value indicates that evaluation failed because a certificate in the chain is defective.
  ///This usually represents a fundamental defect in the certificate data, such as an invalid encoding for a critical subjectAltName extension,
  ///an unsupported critical extension, or some other critical portion of the certificate that couldn’t be interpreted.
  ///Changing parameter values and reevaluating is unlikely to succeed unless you provide different certificates.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - SecTrustResultType.fatalTrustFailure](https://developer.apple.com/documentation/security/sectrustresulttype/fataltrustfailure))
  static final FATAL_TRUST_FAILURE = SslErrorType._internal(
      'FATAL_TRUST_FAILURE',
      (defaultTargetPlatform != TargetPlatform.iOS ||
              defaultTargetPlatform != TargetPlatform.macOS)
          ? 6
          : -1);

  ///Indicates a failure other than that of trust evaluation.
  ///
  ///This value indicates that evaluation failed for some other reason.
  ///This can be caused by either a revoked certificate or by OS-level errors that are unrelated to the certificates themselves.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - SecTrustResultType.otherError](https://developer.apple.com/documentation/security/sectrustresulttype/othererror))
  static final OTHER_ERROR = SslErrorType._internal(
      'OTHER_ERROR',
      (defaultTargetPlatform != TargetPlatform.iOS ||
              defaultTargetPlatform != TargetPlatform.macOS)
          ? 7
          : -1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents the Android-specific primary error associated to the server SSL certificate.
///Used by the [ServerTrustChallenge] class.
///Use [SslErrorType] instead.
@Deprecated("Use SslErrorType instead")
class AndroidSslError {
  final int _value;

  const AndroidSslError._internal(this._value);

  ///Set of all values of [AndroidSslError].
  static final Set<AndroidSslError> values = [
    AndroidSslError.SSL_NOTYETVALID,
    AndroidSslError.SSL_EXPIRED,
    AndroidSslError.SSL_IDMISMATCH,
    AndroidSslError.SSL_UNTRUSTED,
    AndroidSslError.SSL_DATE_INVALID,
    AndroidSslError.SSL_INVALID,
  ].toSet();

  ///Gets a possible [AndroidSslError] instance from an [int] value.
  static AndroidSslError? fromValue(int? value) {
    if (value != null) {
      try {
        return AndroidSslError.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [int] value.
  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return "SSL_EXPIRED";
      case 2:
        return "SSL_IDMISMATCH";
      case 3:
        return "SSL_UNTRUSTED";
      case 4:
        return "SSL_DATE_INVALID";
      case 5:
        return "SSL_INVALID";
      case 0:
      default:
        return "SSL_NOTYETVALID";
    }
  }

  ///The certificate is not yet valid
  static const SSL_NOTYETVALID = const AndroidSslError._internal(0);

  ///The certificate has expired
  static const SSL_EXPIRED = const AndroidSslError._internal(1);

  ///Hostname mismatch
  static const SSL_IDMISMATCH = const AndroidSslError._internal(2);

  ///The certificate authority is not trusted
  static const SSL_UNTRUSTED = const AndroidSslError._internal(3);

  ///The date of the certificate is invalid
  static const SSL_DATE_INVALID = const AndroidSslError._internal(4);

  ///A generic error occurred
  static const SSL_INVALID = const AndroidSslError._internal(5);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents the iOS-specific primary error associated to the server SSL certificate.
///Used by the [ServerTrustChallenge] class.
///Use [SslErrorType] instead.
@Deprecated("Use SslErrorType instead")
class IOSSslError {
  final int _value;

  const IOSSslError._internal(this._value);

  ///Set of all values of [IOSSslError].
  static final Set<IOSSslError> values = [
    IOSSslError.INVALID,
    IOSSslError.DENY,
    IOSSslError.UNSPECIFIED,
    IOSSslError.RECOVERABLE_TRUST_FAILURE,
    IOSSslError.FATAL_TRUST_FAILURE,
    IOSSslError.OTHER_ERROR,
  ].toSet();

  ///Gets a possible [IOSSslError] instance from an [int] value.
  static IOSSslError? fromValue(int? value) {
    if (value != null) {
      try {
        return IOSSslError.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [int] value.
  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 3:
        return "DENY";
      case 4:
        return "UNSPECIFIED";
      case 5:
        return "RECOVERABLE_TRUST_FAILURE";
      case 6:
        return "FATAL_TRUST_FAILURE";
      case 7:
        return "OTHER_ERROR";
      case 0:
      default:
        return "INVALID";
    }
  }

  ///Indicates an invalid setting or result.
  static const INVALID = const IOSSslError._internal(0);

  ///Indicates a user-configured deny; do not proceed.
  static const DENY = const IOSSslError._internal(3);

  ///Indicates the evaluation succeeded and the certificate is implicitly trusted, but user intent was not explicitly specified.
  static const UNSPECIFIED = const IOSSslError._internal(4);

  ///Indicates a trust policy failure which can be overridden by the user.
  static const RECOVERABLE_TRUST_FAILURE = const IOSSslError._internal(5);

  ///Indicates a trust failure which cannot be overridden by the user.
  static const FATAL_TRUST_FAILURE = const IOSSslError._internal(6);

  ///Indicates a failure other than that of trust evaluation.
  static const OTHER_ERROR = const IOSSslError._internal(7);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}
