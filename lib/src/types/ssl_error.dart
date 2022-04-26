import 'ssl_error_type.dart';

///Class that represents an SSL Error.
class SslError {
  ///Use [code] instead.
  @Deprecated('Use code instead')
  AndroidSslError? androidError;

  ///Use [code] instead.
  @Deprecated('Use code instead')
  IOSSslError? iosError;

  ///Primary code error associated to the server SSL certificate.
  ///It represents the most severe SSL error.
  SslErrorType? code;

  ///The message associated to the [code].
  String? message;

  SslError(
      {@Deprecated('Use code instead') this.androidError,
        @Deprecated('Use code instead') this.iosError,
        this.code,
        this.message}) {
    this.code = this.code ??
        // ignore: deprecated_member_use_from_same_package
        SslErrorType.fromValue(this.androidError?.toValue() ??
            // ignore: deprecated_member_use_from_same_package
            this.iosError?.toValue());
  }

  ///Gets a possible [SslError] instance from a [Map] value.
  static SslError? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return SslError(
      // ignore: deprecated_member_use_from_same_package
        androidError: AndroidSslError.fromValue(map["code"]),
        // ignore: deprecated_member_use_from_same_package
        iosError: IOSSslError.fromValue(map["code"]),
        code: SslErrorType.fromValue(map["code"]),
        message: map["message"]);
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      // ignore: deprecated_member_use_from_same_package
      "androidError": code?.toValue() ?? androidError?.toValue(),
      // ignore: deprecated_member_use_from_same_package
      "iosError": code?.toValue() ?? iosError?.toValue(),
      // ignore: deprecated_member_use_from_same_package
      "code": code?.toValue() ?? androidError?.toValue() ?? iosError?.toValue(),
      "message": message,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}