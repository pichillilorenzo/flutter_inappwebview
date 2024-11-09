import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'enum_method.dart';
import 'ssl_error_type.dart';

part 'ssl_error.g.dart';

///Class that represents an SSL Error.
@ExchangeableObject()
class SslError_ {
  ///Use [code] instead.
  @Deprecated('Use code instead')
  AndroidSslError_? androidError;

  ///Use [code] instead.
  @Deprecated('Use code instead')
  IOSSslError_? iosError;

  ///Primary code error associated to the server SSL certificate.
  ///It represents the most severe SSL error.
  SslErrorType_? code;

  ///The message associated to the [code].
  String? message;

  SslError_(
      {@Deprecated('Use code instead') this.androidError,
      @Deprecated('Use code instead') this.iosError,
      this.code,
      this.message}) {}
}
