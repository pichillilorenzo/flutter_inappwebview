// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'http_authentication_challenge.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the challenge of the [WebView.onReceivedHttpAuthRequest] event.
///It provides all the information about the challenge.
class HttpAuthenticationChallenge extends URLAuthenticationChallenge {
  ///A count of previous failed authentication attempts.
  int previousFailureCount;

  ///The proposed credential for this challenge.
  ///This method returns `null` if there is no default credential for this challenge.
  ///If you have previously attempted to authenticate and failed, this method returns the most recent failed credential.
  ///If the proposed credential is not nil and returns true when you call its hasPassword method, then the credential is ready to use as-is.
  ///If the proposed credential’s hasPassword method returns false, then the credential provides a default user name,
  ///and the client must prompt the user for a corresponding password.
  URLCredential? proposedCredential;

  ///Use [failureResponse] instead.
  @Deprecated('Use failureResponse instead')
  IOSURLResponse? iosFailureResponse;

  ///The URL response object representing the last authentication failure.
  ///This value is `null` if the protocol doesn’t use responses to indicate an authentication failure.
  ///
  ///**NOTE**: available only on iOS.
  URLResponse? failureResponse;

  ///Use [error] instead.
  @Deprecated('Use error instead')
  String? iosError;

  ///The error object representing the last authentication failure.
  ///This value is `null` if the protocol doesn’t use errors to indicate an authentication failure.
  ///
  ///**NOTE**: available only on iOS.
  String? error;
  HttpAuthenticationChallenge(
      {required this.previousFailureCount,
      this.proposedCredential,
      @Deprecated('Use failureResponse instead') this.iosFailureResponse,
      this.failureResponse,
      @Deprecated('Use error instead') this.iosError,
      this.error,
      required URLProtectionSpace protectionSpace})
      : super(protectionSpace: protectionSpace) {
    failureResponse =
        failureResponse ?? URLResponse.fromMap(iosFailureResponse?.toMap());
    error = error ?? iosError;
  }

  ///Gets a possible [HttpAuthenticationChallenge] instance from a [Map] value.
  static HttpAuthenticationChallenge? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = HttpAuthenticationChallenge(
      protectionSpace: URLProtectionSpace.fromMap(
          map['protectionSpace']?.cast<String, dynamic>())!,
      previousFailureCount: map['previousFailureCount'],
      proposedCredential: URLCredential.fromMap(
          map['proposedCredential']?.cast<String, dynamic>()),
      iosFailureResponse: IOSURLResponse.fromMap(
          map['failureResponse']?.cast<String, dynamic>()),
      failureResponse:
          URLResponse.fromMap(map['failureResponse']?.cast<String, dynamic>()),
      iosError: map['error'],
      error: map['error'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "protectionSpace": protectionSpace.toMap(),
      "previousFailureCount": previousFailureCount,
      "proposedCredential": proposedCredential?.toMap(),
      "failureResponse": failureResponse?.toMap(),
      "error": error,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'HttpAuthenticationChallenge{protectionSpace: $protectionSpace, previousFailureCount: $previousFailureCount, proposedCredential: $proposedCredential, failureResponse: $failureResponse, error: $error}';
  }
}
