import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'server_trust_auth_response.dart';

part 'server_trust_auth_response_action.g.dart';

///Class used by [ServerTrustAuthResponse] class.
@ExchangeableEnum()
class ServerTrustAuthResponseAction_ {
  // ignore: unused_field
  final int _value;
  const ServerTrustAuthResponseAction_._internal(this._value);

  ///Instructs the WebView to cancel the authentication challenge.
  static const CANCEL = const ServerTrustAuthResponseAction_._internal(0);

  ///Instructs the WebView to proceed with the authentication challenge.
  static const PROCEED = const ServerTrustAuthResponseAction_._internal(1);
}
