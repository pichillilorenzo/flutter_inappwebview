import 'fetch_request_action.dart';
import 'fetch_request_credential.dart';
import 'fetch_request_credential_default.dart';
import 'fetch_request_federated_credential.dart';
import 'fetch_request_password_credential.dart';
import 'referrer_policy.dart';

///Class that represents a HTTP request created with JavaScript using the [Fetch API](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch).
class FetchRequest {
  ///The URL of the request.
  Uri? url;

  ///The HTTP request method used of the request.
  String? method;

  ///The HTTP request headers.
  Map<String, dynamic>? headers;

  ///Body of the request.
  dynamic body;

  ///The mode used by the request.
  String? mode;

  ///The request credentials used by the request.
  FetchRequestCredential? credentials;

  ///The cache mode used by the request.
  String? cache;

  ///The redirect mode used by the request.
  String? redirect;

  ///A String specifying no-referrer, client, or a URL.
  String? referrer;

  ///The value of the referer HTTP header.
  ReferrerPolicy? referrerPolicy;

  ///Contains the subresource integrity value of the request.
  String? integrity;

  ///The keepalive option used to allow the request to outlive the page.
  bool? keepalive;

  ///Indicates the [FetchRequestAction] that can be used to control the request.
  FetchRequestAction? action;

  FetchRequest(
      {this.url,
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
        this.action = FetchRequestAction.PROCEED});

  ///Gets a possible [FetchRequest] instance from a [Map] value.
  static FetchRequest? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }

    Map<String, dynamic>? credentialMap =
    map["credentials"]?.cast<String, dynamic>();
    FetchRequestCredential? credentials;
    if (credentialMap != null) {
      if (credentialMap["type"] == "default") {
        credentials = FetchRequestCredentialDefault.fromMap(credentialMap);
      } else if (credentialMap["type"] == "federated") {
        credentials = FetchRequestFederatedCredential.fromMap(credentialMap);
      } else if (credentialMap["type"] == "password") {
        credentials = FetchRequestPasswordCredential.fromMap(credentialMap);
      }
    }

    return FetchRequest(
        url: map["url"] != null ? Uri.parse(map["url"]) : null,
        method: map["method"],
        headers: map["headers"]?.cast<String, dynamic>(),
        body: map["body"],
        mode: map["mode"],
        credentials: credentials,
        cache: map["cache"],
        redirect: map["redirect"],
        referrer: map["referrer"],
        referrerPolicy: ReferrerPolicy.fromValue(map["referrerPolicy"]),
        integrity: map["integrity"],
        keepalive: map["keepalive"]);
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "url": url?.toString(),
      "method": method,
      "headers": headers,
      "body": body,
      "mode": mode,
      "credentials": credentials?.toMap(),
      "cache": cache,
      "redirect": redirect,
      "referrer": referrer,
      "referrerPolicy": referrerPolicy?.toValue(),
      "integrity": integrity,
      "keepalive": keepalive,
      "action": action?.toValue()
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