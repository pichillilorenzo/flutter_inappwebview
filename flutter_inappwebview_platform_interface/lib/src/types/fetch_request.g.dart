// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fetch_request.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents a HTTP request created with JavaScript using the [Fetch API](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch).
class FetchRequest {
  ///Indicates the [FetchRequestAction] that can be used to control the request.
  FetchRequestAction? action;

  ///Body of the request.
  dynamic body;

  ///The cache mode used by the request.
  String? cache;

  ///The request credentials used by the request.
  FetchRequestCredential? credentials;

  ///The HTTP request headers.
  Map<String, dynamic>? headers;

  ///Contains the subresource integrity value of the request.
  String? integrity;

  ///The keepalive option used to allow the request to outlive the page.
  bool? keepalive;

  ///The HTTP request method used of the request.
  String? method;

  ///The mode used by the request.
  String? mode;

  ///The redirect mode used by the request.
  String? redirect;

  ///A String specifying no-referrer, client, or a URL.
  String? referrer;

  ///The value of the referer HTTP header.
  ReferrerPolicy? referrerPolicy;

  ///The URL of the request.
  WebUri? url;
  FetchRequest(
      {this.action = FetchRequestAction.PROCEED,
      this.body,
      this.cache,
      this.credentials,
      this.headers,
      this.integrity,
      this.keepalive,
      this.method,
      this.mode,
      this.redirect,
      this.referrer,
      this.referrerPolicy,
      this.url});

  ///Gets a possible [FetchRequest] instance from a [Map] value.
  static FetchRequest? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = FetchRequest(
      body: map['body'],
      cache: map['cache'],
      credentials: _fetchRequestCredentialDeserializer(map['credentials']),
      headers: map['headers']?.cast<String, dynamic>(),
      integrity: map['integrity'],
      keepalive: map['keepalive'],
      method: map['method'],
      mode: map['mode'],
      redirect: map['redirect'],
      referrer: map['referrer'],
      referrerPolicy: ReferrerPolicy.fromNativeValue(map['referrerPolicy']),
      url: map['url'] != null ? WebUri(map['url']) : null,
    );
    instance.action = FetchRequestAction.fromNativeValue(map['action']);
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "action": action?.toNativeValue(),
      "body": body,
      "cache": cache,
      "credentials": credentials?.toMap(),
      "headers": headers,
      "integrity": integrity,
      "keepalive": keepalive,
      "method": method,
      "mode": mode,
      "redirect": redirect,
      "referrer": referrer,
      "referrerPolicy": referrerPolicy?.toNativeValue(),
      "url": url?.toString(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'FetchRequest{action: $action, body: $body, cache: $cache, credentials: $credentials, headers: $headers, integrity: $integrity, keepalive: $keepalive, method: $method, mode: $mode, redirect: $redirect, referrer: $referrer, referrerPolicy: $referrerPolicy, url: $url}';
  }
}
