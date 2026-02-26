import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../web_uri.dart';
import 'enum_method.dart';
import 'fetch_request_action.dart';
import 'fetch_request_credential.dart';
import 'fetch_request_credential_default.dart';
import 'fetch_request_federated_credential.dart';
import 'fetch_request_password_credential.dart';
import 'referrer_policy.dart';

part 'fetch_request.g.dart';

FetchRequestCredential? _fetchRequestCredentialDeserializer(
  dynamic value, {
  EnumMethod? enumMethod,
}) {
  Map<String, dynamic>? credentialMap = value?.cast<String, dynamic>();
  FetchRequestCredential? credentials;
  if (credentialMap != null) {
    if (credentialMap["type"] == "default") {
      credentials = FetchRequestCredentialDefault.fromMap(
        credentialMap,
        enumMethod: enumMethod,
      );
    } else if (credentialMap["type"] == "federated") {
      credentials = FetchRequestFederatedCredential.fromMap(
        credentialMap,
        enumMethod: enumMethod,
      );
    } else if (credentialMap["type"] == "password") {
      credentials = FetchRequestPasswordCredential.fromMap(
        credentialMap,
        enumMethod: enumMethod,
      );
    }
  }
  return credentials;
}

///Class that represents a HTTP request created with JavaScript using the [Fetch API](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch).
@ExchangeableObject()
class FetchRequest_ {
  ///The URL of the request.
  WebUri? url;

  ///The HTTP request method used of the request.
  String? method;

  ///The HTTP request headers.
  Map<String, dynamic>? headers;

  ///Body of the request.
  dynamic body;

  ///The mode used by the request.
  String? mode;

  ///The request credentials used by the request.
  @ExchangeableObjectProperty(deserializer: _fetchRequestCredentialDeserializer)
  FetchRequestCredential_? credentials;

  ///The cache mode used by the request.
  String? cache;

  ///The redirect mode used by the request.
  String? redirect;

  ///A String specifying no-referrer, client, or a URL.
  String? referrer;

  ///The value of the referer HTTP header.
  ReferrerPolicy_? referrerPolicy;

  ///Contains the subresource integrity value of the request.
  String? integrity;

  ///The keepalive option used to allow the request to outlive the page.
  bool? keepalive;

  ///Indicates the [FetchRequestAction] that can be used to control the request.
  FetchRequestAction_? action;

  FetchRequest_({
    this.url,
    this.method,
    this.headers,
    this.body,
    this.mode,
    this.credentials,
    this.cache,
    this.redirect,
    this.referrer,
    this.referrerPolicy,
    this.integrity,
    this.keepalive,
    this.action = FetchRequestAction_.PROCEED,
  });
}
