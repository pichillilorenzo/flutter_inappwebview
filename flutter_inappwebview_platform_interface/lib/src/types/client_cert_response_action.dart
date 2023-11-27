import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'client_cert_response.dart';

part 'client_cert_response_action.g.dart';

///Class used by [ClientCertResponse] class.
@ExchangeableEnum()
class ClientCertResponseAction_ {
  // ignore: unused_field
  final int _value;
  const ClientCertResponseAction_._internal(this._value);

  ///Cancel this request.
  static const CANCEL = const ClientCertResponseAction_._internal(0);

  ///Proceed with the specified certificate.
  static const PROCEED = const ClientCertResponseAction_._internal(1);

  ///Ignore the request for now.
  static const IGNORE = const ClientCertResponseAction_._internal(2);
}
