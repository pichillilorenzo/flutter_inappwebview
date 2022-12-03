// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ssl_error.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents an SSL Error.
class SslError {
  ///Use [code] instead.
  @Deprecated('Use code instead')
  AndroidSslError? androidError;

  ///Primary code error associated to the server SSL certificate.
  ///It represents the most severe SSL error.
  SslErrorType? code;

  ///Use [code] instead.
  @Deprecated('Use code instead')
  IOSSslError? iosError;

  ///The message associated to the [code].
  String? message;
  SslError(
      {@Deprecated('Use code instead') this.androidError,
      this.code,
      @Deprecated('Use code instead') this.iosError,
      this.message}) {
    code = code ?? SslErrorType.fromNativeValue(androidError?.toNativeValue());
    code = code ?? SslErrorType.fromNativeValue(iosError?.toNativeValue());
  }

  ///Gets a possible [SslError] instance from a [Map] value.
  static SslError? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = SslError(
      androidError: AndroidSslError.fromNativeValue(map['code']),
      code: SslErrorType.fromNativeValue(map['code']),
      iosError: IOSSslError.fromNativeValue(map['code']),
      message: map['message'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "code": code?.toNativeValue(),
      "message": message,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'SslError{code: $code, message: $message}';
  }
}
