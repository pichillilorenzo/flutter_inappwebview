import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'url_protection_space.dart';
import 'url_credential.dart';
import '../platform_http_auth_credentials_database.dart';
import 'enum_method.dart';

part 'url_protection_space_http_auth_credentials.g.dart';

///Class that represents a [URLProtectionSpace] with all of its [URLCredential]s.
///It used by [PlatformHttpAuthCredentialDatabase.getAllAuthCredentials].
@ExchangeableObject()
class URLProtectionSpaceHttpAuthCredentials_ {
  ///The protection space.
  URLProtectionSpace_? protectionSpace;

  ///The list of all its http authentication credentials.
  List<URLCredential_>? credentials;

  URLProtectionSpaceHttpAuthCredentials_(
      {this.protectionSpace, this.credentials});
}
