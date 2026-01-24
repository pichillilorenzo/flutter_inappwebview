import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../web_uri.dart';
import 'fetch_request_credential.dart';
import 'enum_method.dart';

part 'fetch_request_password_credential.g.dart';

///Class that represents a [PasswordCredential](https://developer.mozilla.org/en-US/docs/Web/API/PasswordCredential) type of credentials.
@ExchangeableObject()
class FetchRequestPasswordCredential_ extends FetchRequestCredential_ {
  ///Credential's identifier.
  dynamic id;

  ///The name associated with a credential. It should be a human-readable, public name.
  String? name;

  ///The password of the credential.
  String? password;

  ///URL pointing to an image for an icon. This image is intended for display in a credential chooser. The URL must be accessible without authentication.
  WebUri? iconURL;

  FetchRequestPasswordCredential_({
    type,
    this.id,
    this.name,
    this.password,
    this.iconURL,
  }) : super(type: type);
}
