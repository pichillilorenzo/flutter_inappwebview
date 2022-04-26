import 'package:flutter/foundation.dart';

import 'server_trust_challenge.dart';

///Class that represents the SSL Primary error associated to the server SSL certificate.
///Used by the [ServerTrustChallenge] class.
class SslErrorType {
  final int _value;

  const SslErrorType._internal(this._value);

  ///Set of all values of [SslErrorType].
  static final Set<SslErrorType> values = [
    SslErrorType.SSL_NOTYETVALID,
    SslErrorType.SSL_EXPIRED,
    SslErrorType.SSL_IDMISMATCH,
    SslErrorType.SSL_UNTRUSTED,
    SslErrorType.SSL_DATE_INVALID,
    SslErrorType.SSL_INVALID,
    SslErrorType.INVALID,
    SslErrorType.DENY,
    SslErrorType.UNSPECIFIED,
    SslErrorType.RECOVERABLE_TRUST_FAILURE,
    SslErrorType.FATAL_TRUST_FAILURE,
    SslErrorType.OTHER_ERROR,
  ].toSet();

  static final Set<SslErrorType> _androidValues = [
    SslErrorType.SSL_NOTYETVALID,
    SslErrorType.SSL_EXPIRED,
    SslErrorType.SSL_IDMISMATCH,
    SslErrorType.SSL_UNTRUSTED,
    SslErrorType.SSL_DATE_INVALID,
    SslErrorType.SSL_INVALID,
  ].toSet();

  static final Set<SslErrorType> _appleValues = [
    SslErrorType.INVALID,
    SslErrorType.DENY,
    SslErrorType.UNSPECIFIED,
    SslErrorType.RECOVERABLE_TRUST_FAILURE,
    SslErrorType.FATAL_TRUST_FAILURE,
    SslErrorType.OTHER_ERROR,
  ].toSet();

  ///Gets a possible [SslErrorType] instance from an [int] value.
  static SslErrorType? fromValue(int? value) {
    if (value != null) {
      try {
        Set<SslErrorType> valueList = <SslErrorType>[].toSet();
        if (defaultTargetPlatform == TargetPlatform.android) {
          valueList = SslErrorType._androidValues;
        } else if (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS) {
          valueList = SslErrorType._appleValues;
        }
        return valueList.firstWhere((element) => element.toValue() == value);
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
    if (defaultTargetPlatform == TargetPlatform.android) {
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
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
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
    return "";
  }

  ///The certificate is not yet valid
  ///
  ///**NOTE**: available only on Android
  static const SSL_NOTYETVALID = const SslErrorType._internal(0);

  ///The certificate has expired
  ///
  ///**NOTE**: available only on Android
  static const SSL_EXPIRED = const SslErrorType._internal(1);

  ///Hostname mismatch
  ///
  ///**NOTE**: available only on Android
  static const SSL_IDMISMATCH = const SslErrorType._internal(2);

  ///The certificate authority is not trusted
  ///
  ///**NOTE**: available only on Android
  static const SSL_UNTRUSTED = const SslErrorType._internal(3);

  ///The date of the certificate is invalid
  ///
  ///**NOTE**: available only on Android
  static const SSL_DATE_INVALID = const SslErrorType._internal(4);

  ///A generic error occurred
  ///
  ///**NOTE**: available only on Android
  static const SSL_INVALID = const SslErrorType._internal(5);

  ///Indicates an invalid setting or result.
  ///
  ///**NOTE**: available only on iOS
  static const INVALID = const SslErrorType._internal(0);

  ///Indicates a user-configured deny; do not proceed.
  ///
  ///**NOTE**: available only on iOS
  static const DENY = const SslErrorType._internal(3);

  ///Indicates the evaluation succeeded and the certificate is implicitly trusted, but user intent was not explicitly specified.
  ///
  ///**NOTE**: available only on iOS
  static const UNSPECIFIED = const SslErrorType._internal(4);

  ///Indicates a trust policy failure which can be overridden by the user.
  ///
  ///**NOTE**: available only on iOS
  static const RECOVERABLE_TRUST_FAILURE = const SslErrorType._internal(5);

  ///Indicates a trust failure which cannot be overridden by the user.
  ///
  ///**NOTE**: available only on iOS
  static const FATAL_TRUST_FAILURE = const SslErrorType._internal(6);

  ///Indicates a failure other than that of trust evaluation.
  ///
  ///**NOTE**: available only on iOS
  static const OTHER_ERROR = const SslErrorType._internal(7);

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