import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'fetch_request.dart';
import 'fetch_request_credential.dart';
import 'enum_method.dart';

part 'fetch_request_credential_default.g.dart';

///Class that represents the default credentials used by an [FetchRequest].
@ExchangeableObject()
class FetchRequestCredentialDefault_ extends FetchRequestCredential_ {
  ///The value of the credentials.
  String? value;

  FetchRequestCredentialDefault_({type, this.value}) : super(type: type);
}
