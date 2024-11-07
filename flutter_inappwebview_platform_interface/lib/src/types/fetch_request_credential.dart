import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'fetch_request_credential_default.dart';
import 'fetch_request_federated_credential.dart';
import 'fetch_request_password_credential.dart';
import 'enum_method.dart';

part 'fetch_request_credential.g.dart';

///Class that is an interface for [FetchRequestCredentialDefault], [FetchRequestFederatedCredential] and [FetchRequestPasswordCredential] classes.
@ExchangeableObject()
class FetchRequestCredential_ {
  ///Type of credentials.
  String? type;

  FetchRequestCredential_({this.type});
}
