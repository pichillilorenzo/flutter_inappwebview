import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'web_authentication_session_error.g.dart';

///Class that represents the error code for a web authentication session error.
@ExchangeableEnum()
class WebAuthenticationSessionError_ {
  // ignore: unused_field
  final int _value;
  const WebAuthenticationSessionError_._internal(this._value);

  ///The login has been canceled.
  static const CANCELED_LOGIN = WebAuthenticationSessionError_._internal(1);

  ///A context wasn’t provided.
  static const PRESENTATION_CONTEXT_NOT_PROVIDED =
      WebAuthenticationSessionError_._internal(2);

  ///The context was invalid.
  static const PRESENTATION_CONTEXT_INVALID =
      WebAuthenticationSessionError_._internal(3);
}
