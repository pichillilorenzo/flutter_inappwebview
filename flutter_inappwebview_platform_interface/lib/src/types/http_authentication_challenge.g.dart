// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'http_authentication_challenge.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the challenge of the [PlatformWebViewCreationParams.onReceivedHttpAuthRequest] event.
///It provides all the information about the challenge.
class HttpAuthenticationChallenge extends URLAuthenticationChallenge {
  ///The error object representing the last authentication failure.
  ///This value is `null` if the protocol doesn’t use errors to indicate an authentication failure.
  ///
  ///**NOTE**: available only on iOS.
  String? error;

  ///The URL response object representing the last authentication failure.
  ///This value is `null` if the protocol doesn’t use responses to indicate an authentication failure.
  ///
  ///**NOTE**: available only on iOS.
  URLResponse? failureResponse;

  ///Use [error] instead.
  @Deprecated('Use error instead')
  String? iosError;

  ///Use [failureResponse] instead.
  @Deprecated('Use failureResponse instead')
  IOSURLResponse? iosFailureResponse;

  ///A count of previous failed authentication attempts.
  int previousFailureCount;

  ///The proposed credential for this challenge.
  ///This method returns `null` if there is no default credential for this challenge.
  ///If you have previously attempted to authenticate and failed, this method returns the most recent failed credential.
  ///If the proposed credential is not nil and returns true when you call its hasPassword method, then the credential is ready to use as-is.
  ///If the proposed credential’s hasPassword method returns false, then the credential provides a default user name,
  ///and the client must prompt the user for a corresponding password.
  URLCredential? proposedCredential;
  HttpAuthenticationChallenge(
      {this.error,
      this.failureResponse,
      @Deprecated('Use error instead') this.iosError,
      @Deprecated('Use failureResponse instead') this.iosFailureResponse,
      required this.previousFailureCount,
      this.proposedCredential,
      required URLProtectionSpace protectionSpace})
      : super(protectionSpace: protectionSpace) {
    error = error ?? iosError;
    failureResponse =
        failureResponse ?? URLResponse.fromMap(iosFailureResponse?.toMap());
  }

  ///Gets a possible [HttpAuthenticationChallenge] instance from a [Map] value.
  static HttpAuthenticationChallenge? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = HttpAuthenticationChallenge(
      protectionSpace: URLProtectionSpace.fromMap(
          map['protectionSpace']?.cast<String, dynamic>(),
          enumMethod: enumMethod)!,
      error: map['error'],
      failureResponse: URLResponse.fromMap(
          map['failureResponse']?.cast<String, dynamic>(),
          enumMethod: enumMethod),
      iosError: map['error'],
      iosFailureResponse: IOSURLResponse.fromMap(
          map['failureResponse']?.cast<String, dynamic>(),
          enumMethod: enumMethod),
      previousFailureCount: map['previousFailureCount'],
      proposedCredential: URLCredential.fromMap(
          map['proposedCredential']?.cast<String, dynamic>(),
          enumMethod: enumMethod),
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "protectionSpace": protectionSpace.toMap(enumMethod: enumMethod),
      "error": error,
      "failureResponse": failureResponse?.toMap(enumMethod: enumMethod),
      "previousFailureCount": previousFailureCount,
      "proposedCredential": proposedCredential?.toMap(enumMethod: enumMethod),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'HttpAuthenticationChallenge{protectionSpace: $protectionSpace, error: $error, failureResponse: $failureResponse, previousFailureCount: $previousFailureCount, proposedCredential: $proposedCredential}';
  }
}
