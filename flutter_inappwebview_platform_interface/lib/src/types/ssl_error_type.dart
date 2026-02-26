import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'package:flutter/foundation.dart';

import 'server_trust_challenge.dart';

part 'ssl_error_type.g.dart';

///Class that represents the SSL Primary error associated to the server SSL certificate.
///Used by the [ServerTrustChallenge] class.
@ExchangeableEnum()
class SslErrorType_ {
  // ignore: unused_field
  final String _value;
  // ignore: unused_field
  final int? _nativeValue = null;
  const SslErrorType_._internal(this._value);

  ///The certificate is not yet valid.
  @EnumSupportedPlatforms(
    platforms: [
      EnumAndroidPlatform(
        apiName: 'SslError.SSL_NOTYETVALID',
        apiUrl:
            'https://developer.android.com/reference/android/net/http/SslError#SSL_NOTYETVALID',
        value: 0,
      ),
    ],
  )
  static const NOT_YET_VALID = SslErrorType_._internal('NOT_YET_VALID');

  ///The certificate has expired.
  @EnumSupportedPlatforms(
    platforms: [
      EnumAndroidPlatform(
        apiName: 'SslError.SSL_EXPIRED',
        apiUrl:
            'https://developer.android.com/reference/android/net/http/SslError#SSL_EXPIRED',
        value: 1,
      ),
      EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_WEB_ERROR_STATUS_CERTIFICATE_EXPIRED',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_web_error_status',
        value: 2,
      ),
    ],
  )
  static const EXPIRED = SslErrorType_._internal('EXPIRED');

  ///Hostname mismatch.
  @EnumSupportedPlatforms(
    platforms: [
      EnumAndroidPlatform(
        apiName: 'SslError.SSL_IDMISMATCH',
        apiUrl:
            'https://developer.android.com/reference/android/net/http/SslError#SSL_IDMISMATCH',
        value: 2,
      ),
    ],
  )
  static const IDMISMATCH = SslErrorType_._internal('IDMISMATCH');

  ///The certificate authority is not trusted.
  @EnumSupportedPlatforms(
    platforms: [
      EnumAndroidPlatform(
        apiName: 'SslError.SSL_UNTRUSTED',
        apiUrl:
            'https://developer.android.com/reference/android/net/http/SslError#SSL_UNTRUSTED',
        value: 3,
      ),
    ],
  )
  static const UNTRUSTED = SslErrorType_._internal('UNTRUSTED');

  ///The date of the certificate is invalid.
  @EnumSupportedPlatforms(
    platforms: [
      EnumAndroidPlatform(
        apiName: 'SslError.DATE_INVALID',
        apiUrl:
            'https://developer.android.com/reference/android/net/http/SslError#SSL_DATE_INVALID',
        value: 4,
      ),
    ],
  )
  static const DATE_INVALID = SslErrorType_._internal('DATE_INVALID');

  ///Indicates an invalid setting or result. A generic error occurred.
  @EnumSupportedPlatforms(
    platforms: [
      EnumAndroidPlatform(
        apiName: 'SslError.SSL_INVALID',
        apiUrl:
            'https://developer.android.com/reference/android/net/http/SslError#SSL_INVALID',
        value: 5,
      ),
      EnumIOSPlatform(
        apiName: 'SecTrustResultType.invalid',
        apiUrl:
            'https://developer.apple.com/documentation/security/sectrustresulttype/invalid',
        value: 0,
      ),
      EnumMacOSPlatform(
        apiName: 'SecTrustResultType.invalid',
        apiUrl:
            'https://developer.apple.com/documentation/security/sectrustresulttype/invalid',
        value: 0,
      ),
      EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_WEB_ERROR_STATUS_CERTIFICATE_IS_INVALID',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_web_error_status',
        value: 5,
      ),
    ],
  )
  static const INVALID = SslErrorType_._internal('INVALID');

  ///The user specified that the certificate should not be trusted.
  ///
  ///This value indicates that the user explicitly chose to not trust a certificate in the chain,
  ///usually by clicking the appropriate button in a certificate trust panel.
  ///Your app should not trust the chain.
  ///The Keychain Access utility refers to this value as "Never Trust."
  @EnumSupportedPlatforms(
    platforms: [
      EnumIOSPlatform(
        apiName: 'SecTrustResultType.deny',
        apiUrl:
            'https://developer.apple.com/documentation/security/sectrustresulttype/deny',
        value: 3,
      ),
      EnumMacOSPlatform(
        apiName: 'SecTrustResultType.deny',
        apiUrl:
            'https://developer.apple.com/documentation/security/sectrustresulttype/deny',
        value: 3,
      ),
    ],
  )
  static const DENY = SslErrorType_._internal('DENY');

  ///Indicates the evaluation succeeded and the certificate is implicitly trusted, but user intent was not explicitly specified.
  ///
  ///This value indicates that evaluation reached an (implicitly trusted) anchor certificate without any evaluation failures,
  ///but never encountered any explicitly stated user-trust preference.
  ///This is the most common return value.
  ///The Keychain Access utility refers to this value as the “Use System Policy,” which is the default user setting.
  ///
  ///When receiving this value, most apps should trust the chain.
  @EnumSupportedPlatforms(
    platforms: [
      EnumIOSPlatform(
        apiName: 'SecTrustResultType.unspecified',
        apiUrl:
            'https://developer.apple.com/documentation/security/sectrustresulttype/unspecified',
        value: 4,
      ),
      EnumMacOSPlatform(
        apiName: 'SecTrustResultType.unspecified',
        apiUrl:
            'https://developer.apple.com/documentation/security/sectrustresulttype/unspecified',
        value: 4,
      ),
    ],
  )
  static const UNSPECIFIED = SslErrorType_._internal('UNSPECIFIED');

  ///Trust is denied, but recovery may be possible.
  ///
  ///This value indicates that you should not trust the chain as is,
  ///but that the chain could be trusted with some minor change to the evaluation context,
  ///such as ignoring expired certificates or adding another anchor to the set of trusted anchors.
  ///
  ///The way you handle this depends on the situation.
  ///For example, if you are performing signature validation and you know when the message was originally received,
  ///you should check again using that date to see if the message was valid when you originally received it.
  @EnumSupportedPlatforms(
    platforms: [
      EnumIOSPlatform(
        apiName: 'SecTrustResultType.recoverableTrustFailure',
        apiUrl:
            'https://developer.apple.com/documentation/security/sectrustresulttype/recoverabletrustfailure',
        value: 5,
      ),
      EnumMacOSPlatform(
        apiName: 'SecTrustResultType.recoverableTrustFailure',
        apiUrl:
            'https://developer.apple.com/documentation/security/sectrustresulttype/recoverabletrustfailure',
        value: 5,
      ),
    ],
  )
  static const RECOVERABLE_TRUST_FAILURE = SslErrorType_._internal(
    'RECOVERABLE_TRUST_FAILURE',
  );

  ///Trust is denied and no simple fix is available.
  ///
  ///This value indicates that evaluation failed because a certificate in the chain is defective.
  ///This usually represents a fundamental defect in the certificate data, such as an invalid encoding for a critical subjectAltName extension,
  ///an unsupported critical extension, or some other critical portion of the certificate that couldn’t be interpreted.
  ///Changing parameter values and reevaluating is unlikely to succeed unless you provide different certificates.
  @EnumSupportedPlatforms(
    platforms: [
      EnumIOSPlatform(
        apiName: 'SecTrustResultType.fatalTrustFailure',
        apiUrl:
            'https://developer.apple.com/documentation/security/sectrustresulttype/fataltrustfailure',
        value: 6,
      ),
      EnumMacOSPlatform(
        apiName: 'SecTrustResultType.fatalTrustFailure',
        apiUrl:
            'https://developer.apple.com/documentation/security/sectrustresulttype/fataltrustfailure',
        value: 6,
      ),
    ],
  )
  static const FATAL_TRUST_FAILURE = SslErrorType_._internal(
    'FATAL_TRUST_FAILURE',
  );

  ///Indicates a failure other than that of trust evaluation.
  ///
  ///This value indicates that evaluation failed for some other reason.
  ///
  ///On iOS and macOS, this can be caused by either a revoked certificate or
  ///by OS-level errors that are unrelated to the certificates themselves.
  @EnumSupportedPlatforms(
    platforms: [
      EnumIOSPlatform(
        apiName: 'SecTrustResultType.otherError',
        apiUrl:
            'https://developer.apple.com/documentation/security/sectrustresulttype/othererror',
        value: 7,
      ),
      EnumMacOSPlatform(
        apiName: 'SecTrustResultType.otherError',
        apiUrl:
            'https://developer.apple.com/documentation/security/sectrustresulttype/othererror',
        value: 7,
      ),
      EnumWindowsPlatform(
        apiName:
            'COREWEBVIEW2_WEB_ERROR_STATUS_CLIENT_CERTIFICATE_CONTAINS_ERRORS',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_web_error_status',
        value: 3,
      ),
    ],
  )
  static const OTHER_ERROR = SslErrorType_._internal('OTHER_ERROR');

  ///Indicates that the SSL certificate common name does not match the web address.
  @EnumSupportedPlatforms(
    platforms: [
      EnumWindowsPlatform(
        apiName:
            'COREWEBVIEW2_WEB_ERROR_STATUS_CERTIFICATE_COMMON_NAME_IS_INCORRECT',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_web_error_status',
        value: 1,
      ),
    ],
  )
  static const COMMON_NAME_IS_INCORRECT = SslErrorType_._internal(
    'COMMON_NAME_IS_INCORRECT',
  );

  ///Indicates that the SSL certificate has been revoked.
  @EnumSupportedPlatforms(
    platforms: [
      EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_WEB_ERROR_STATUS_CERTIFICATE_REVOKED',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_web_error_status',
        value: 4,
      ),
    ],
  )
  static const REVOKED = SslErrorType_._internal('REVOKED');
}

///Class that represents the Android-specific primary error associated to the server SSL certificate.
///Used by the [ServerTrustChallenge] class.
///Use [SslErrorType] instead.
@Deprecated("Use SslErrorType instead")
@ExchangeableEnum()
class AndroidSslError_ {
  // ignore: unused_field
  final int _value;
  const AndroidSslError_._internal(this._value);

  ///The certificate is not yet valid
  static const SSL_NOTYETVALID = const AndroidSslError_._internal(0);

  ///The certificate has expired
  static const SSL_EXPIRED = const AndroidSslError_._internal(1);

  ///Hostname mismatch
  static const SSL_IDMISMATCH = const AndroidSslError_._internal(2);

  ///The certificate authority is not trusted
  static const SSL_UNTRUSTED = const AndroidSslError_._internal(3);

  ///The date of the certificate is invalid
  static const SSL_DATE_INVALID = const AndroidSslError_._internal(4);

  ///A generic error occurred
  static const SSL_INVALID = const AndroidSslError_._internal(5);
}

///Class that represents the iOS-specific primary error associated to the server SSL certificate.
///Used by the [ServerTrustChallenge] class.
///Use [SslErrorType] instead.
@Deprecated("Use SslErrorType instead")
@ExchangeableEnum()
class IOSSslError_ {
  // ignore: unused_field
  final int _value;

  const IOSSslError_._internal(this._value);

  ///Indicates an invalid setting or result.
  static const INVALID = const IOSSslError_._internal(0);

  ///Indicates a user-configured deny; do not proceed.
  static const DENY = const IOSSslError_._internal(3);

  ///Indicates the evaluation succeeded and the certificate is implicitly trusted, but user intent was not explicitly specified.
  static const UNSPECIFIED = const IOSSslError_._internal(4);

  ///Indicates a trust policy failure which can be overridden by the user.
  static const RECOVERABLE_TRUST_FAILURE = const IOSSslError_._internal(5);

  ///Indicates a trust failure which cannot be overridden by the user.
  static const FATAL_TRUST_FAILURE = const IOSSslError_._internal(6);

  ///Indicates a failure other than that of trust evaluation.
  static const OTHER_ERROR = const IOSSslError_._internal(7);
}
