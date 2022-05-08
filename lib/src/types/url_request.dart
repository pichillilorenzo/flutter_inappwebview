import 'dart:typed_data';
import 'package:flutter_inappwebview/src/types/url_request_attribution.dart';

import 'url_request_cache_policy.dart';
import 'url_request_network_service_type.dart';

///A URL load request that is independent of protocol or URL scheme.
class URLRequest {
  ///The URL of the request. Setting this to `null` will load `about:blank`.
  Uri? url;

  ///The HTTP request method.
  ///
  ///**NOTE for Android**: it supports only "GET" and "POST" methods.
  String? method;

  ///The data sent as the message body of a request, such as for an HTTP POST request.
  Uint8List? body;

  ///A dictionary containing all of the HTTP header fields for a request.
  Map<String, String>? headers;

  ///Use [allowsCellularAccess] instead.
  @Deprecated("Use allowsCellularAccess instead")
  bool? iosAllowsCellularAccess;

  ///A Boolean value indicating whether the request is allowed to use the built-in cellular radios to satisfy the request.
  ///
  ///**NOTE**: available only on iOS.
  bool? allowsCellularAccess;

  ///Use [allowsConstrainedNetworkAccess] instead.
  @Deprecated("Use allowsConstrainedNetworkAccess instead")
  bool? iosAllowsConstrainedNetworkAccess;

  ///A Boolean value that indicates whether the request may use the network when the user has specified Low Data Mode.
  ///
  ///**NOTE**: available only on iOS 13.0+.
  bool? allowsConstrainedNetworkAccess;

  ///Use [allowsExpensiveNetworkAccess] instead.
  @Deprecated("Use allowsExpensiveNetworkAccess instead")
  bool? iosAllowsExpensiveNetworkAccess;

  ///A Boolean value that indicates whether connections may use a network interface that the system considers expensive.
  ///
  ///**NOTE**: available only on iOS 13.0+.
  bool? allowsExpensiveNetworkAccess;

  ///Use [cachePolicy] instead.
  @Deprecated("Use cachePolicy instead")
  IOSURLRequestCachePolicy? iosCachePolicy;

  ///The request’s cache policy.
  ///
  ///**NOTE**: available only on iOS.
  URLRequestCachePolicy? cachePolicy;

  ///Use [httpShouldHandleCookies] instead.
  @Deprecated("Use httpShouldHandleCookies instead")
  bool? iosHttpShouldHandleCookies;

  ///A Boolean value indicating whether cookies will be sent with and set for this request.
  ///
  ///**NOTE**: available only on iOS.
  bool? httpShouldHandleCookies;

  ///Use [httpShouldUsePipelining] instead.
  @Deprecated("Use httpShouldUsePipelining instead")
  bool? iosHttpShouldUsePipelining;

  ///A Boolean value indicating whether the request should transmit before the previous response is received.
  ///
  ///**NOTE**: available only on iOS.
  bool? httpShouldUsePipelining;

  ///Use [networkServiceType] instead.
  @Deprecated("Use networkServiceType instead")
  IOSURLRequestNetworkServiceType? iosNetworkServiceType;

  ///The service type associated with this request.
  ///
  ///**NOTE**: available only on iOS.
  URLRequestNetworkServiceType? networkServiceType;

  ///Use [timeoutInterval] instead.
  @Deprecated("Use timeoutInterval instead")
  double? iosTimeoutInterval;

  ///The timeout interval of the request.
  ///
  ///**NOTE**: available only on iOS.
  double? timeoutInterval;

  ///Use [mainDocumentURL] instead.
  @Deprecated("Use mainDocumentURL instead")
  Uri? iosMainDocumentURL;

  ///The main document URL associated with this request.
  ///This URL is used for the cookie “same domain as main document” policy.
  ///
  ///**NOTE**: available only on iOS.
  Uri? mainDocumentURL;

  ///`true` if server endpoint is known to support HTTP/3. Enables QUIC racing
  ///without HTTP/3 service discovery. Defaults to `false`.
  ///The default may be `true` in a future OS update.
  ///
  ///**NOTE**: available only on iOS 14.5+.
  bool? assumesHTTP3Capable;

  ///The entities that can make a network request.
  ///
  ///If you don’t set a value, the system assumes [URLRequestAttribution.DEVELOPER].
  ///
  ///**NOTE**: available only on iOS 15.0+.
  URLRequestAttribution? attribution;

  URLRequest({
    required this.url,
    this.method,
    this.headers,
    this.body,
    @Deprecated("Use allowsCellularAccess instead")
    this.iosAllowsCellularAccess,
    this.allowsCellularAccess,
    @Deprecated("Use allowsConstrainedNetworkAccess instead")
    this.iosAllowsConstrainedNetworkAccess,
    this.allowsConstrainedNetworkAccess,
    @Deprecated("Use allowsExpensiveNetworkAccess instead")
    this.iosAllowsExpensiveNetworkAccess,
    this.allowsExpensiveNetworkAccess,
    @Deprecated("Use cachePolicy instead") this.iosCachePolicy,
    this.cachePolicy,
    @Deprecated("Use httpShouldHandleCookies instead")
    this.iosHttpShouldHandleCookies,
    this.httpShouldHandleCookies,
    @Deprecated("Use httpShouldUsePipelining instead")
    this.iosHttpShouldUsePipelining,
    this.httpShouldUsePipelining,
    @Deprecated("Use networkServiceType instead") this.iosNetworkServiceType,
    this.networkServiceType,
    @Deprecated("Use timeoutInterval instead") this.iosTimeoutInterval,
    this.timeoutInterval,
    @Deprecated("Use mainDocumentURL instead") this.iosMainDocumentURL,
    this.mainDocumentURL,
    this.assumesHTTP3Capable,
    this.attribution
  }) {
    this.allowsCellularAccess =
    // ignore: deprecated_member_use_from_same_package
    this.allowsCellularAccess ?? this.iosAllowsCellularAccess;
    this.allowsConstrainedNetworkAccess = this.allowsConstrainedNetworkAccess ??
        // ignore: deprecated_member_use_from_same_package
        this.iosAllowsConstrainedNetworkAccess;
    this.allowsExpensiveNetworkAccess = this.allowsExpensiveNetworkAccess ??
        // ignore: deprecated_member_use_from_same_package
        this.iosAllowsExpensiveNetworkAccess;
    this.cachePolicy = this.cachePolicy ??
        // ignore: deprecated_member_use_from_same_package
        URLRequestCachePolicy.fromValue(this.iosCachePolicy?.toValue());
    this.httpShouldHandleCookies =
    // ignore: deprecated_member_use_from_same_package
    this.httpShouldHandleCookies ?? this.iosHttpShouldHandleCookies;
    this.httpShouldUsePipelining =
    // ignore: deprecated_member_use_from_same_package
    this.httpShouldUsePipelining ?? this.iosHttpShouldUsePipelining;
    this.networkServiceType =
        this.networkServiceType ?? URLRequestNetworkServiceType.fromValue(
          // ignore: deprecated_member_use_from_same_package
            this.iosNetworkServiceType?.toValue());
    // ignore: deprecated_member_use_from_same_package
    this.timeoutInterval = this.timeoutInterval ?? this.iosTimeoutInterval;
    // ignore: deprecated_member_use_from_same_package
    this.mainDocumentURL = this.mainDocumentURL ?? this.iosMainDocumentURL;
  }

  ///Gets a possible [URLRequest] instance from a [Map] value.
  static URLRequest? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return URLRequest(
      url: map["url"] != null ? Uri.parse(map["url"]) : null,
      headers: map["headers"]?.cast<String, String>(),
      method: map["method"],
      body: map["body"],
      // ignore: deprecated_member_use_from_same_package
      iosAllowsCellularAccess: map["allowsCellularAccess"],
      allowsCellularAccess: map["allowsCellularAccess"],
      // ignore: deprecated_member_use_from_same_package
      iosAllowsConstrainedNetworkAccess: map["allowsConstrainedNetworkAccess"],
      allowsConstrainedNetworkAccess: map["allowsConstrainedNetworkAccess"],
      // ignore: deprecated_member_use_from_same_package
      iosAllowsExpensiveNetworkAccess: map["allowsExpensiveNetworkAccess"],
      allowsExpensiveNetworkAccess: map["allowsExpensiveNetworkAccess"],
      // ignore: deprecated_member_use_from_same_package
      iosCachePolicy: IOSURLRequestCachePolicy.fromValue(map["cachePolicy"]),
      cachePolicy: URLRequestCachePolicy.fromValue(map["cachePolicy"]),
      // ignore: deprecated_member_use_from_same_package
      iosHttpShouldHandleCookies: map["httpShouldHandleCookies"],
      httpShouldHandleCookies: map["httpShouldHandleCookies"],
      // ignore: deprecated_member_use_from_same_package
      iosHttpShouldUsePipelining: map["httpShouldUsePipelining"],
      httpShouldUsePipelining: map["httpShouldUsePipelining"],
      // ignore: deprecated_member_use_from_same_package
      iosNetworkServiceType:
      // ignore: deprecated_member_use_from_same_package
      IOSURLRequestNetworkServiceType.fromValue(map["networkServiceType"]),
      networkServiceType:
      URLRequestNetworkServiceType.fromValue(map["networkServiceType"]),
      // ignore: deprecated_member_use_from_same_package
      iosTimeoutInterval: map["timeoutInterval"],
      timeoutInterval: map["timeoutInterval"],
      // ignore: deprecated_member_use_from_same_package
      iosMainDocumentURL: map["mainDocumentURL"] != null
          ? Uri.parse(map["mainDocumentURL"])
          : null,
      mainDocumentURL: map["mainDocumentURL"] != null
          ? Uri.parse(map["mainDocumentURL"])
          : null,
      assumesHTTP3Capable: map["assumesHTTP3Capable"],
      attribution: URLRequestAttribution.fromValue(map["attribution"])
    );
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "url": url?.toString(),
      "headers": headers,
      "method": method,
      "body": body,
      "iosAllowsCellularAccess":
      // ignore: deprecated_member_use_from_same_package
      allowsCellularAccess ?? iosAllowsCellularAccess,
      // ignore: deprecated_member_use_from_same_package
      "allowsCellularAccess": allowsCellularAccess ?? iosAllowsCellularAccess,
      "iosAllowsConstrainedNetworkAccess":
      // ignore: deprecated_member_use_from_same_package
      allowsConstrainedNetworkAccess ?? iosAllowsConstrainedNetworkAccess,
      "allowsConstrainedNetworkAccess":
      // ignore: deprecated_member_use_from_same_package
      allowsConstrainedNetworkAccess ?? iosAllowsConstrainedNetworkAccess,
      "iosAllowsExpensiveNetworkAccess":
      // ignore: deprecated_member_use_from_same_package
      allowsExpensiveNetworkAccess ?? iosAllowsExpensiveNetworkAccess,
      "allowsExpensiveNetworkAccess":
      // ignore: deprecated_member_use_from_same_package
      allowsExpensiveNetworkAccess ?? iosAllowsExpensiveNetworkAccess,
      // ignore: deprecated_member_use_from_same_package
      "iosCachePolicy": cachePolicy?.toValue() ?? iosCachePolicy?.toValue(),
      // ignore: deprecated_member_use_from_same_package
      "cachePolicy": cachePolicy?.toValue() ?? iosCachePolicy?.toValue(),
      "iosHttpShouldHandleCookies":
      // ignore: deprecated_member_use_from_same_package
      httpShouldHandleCookies ?? iosHttpShouldHandleCookies,
      "httpShouldHandleCookies":
      // ignore: deprecated_member_use_from_same_package
      httpShouldHandleCookies ?? iosHttpShouldHandleCookies,
      "iosHttpShouldUsePipelining":
      // ignore: deprecated_member_use_from_same_package
      httpShouldUsePipelining ?? iosHttpShouldUsePipelining,
      "httpShouldUsePipelining":
      // ignore: deprecated_member_use_from_same_package
      httpShouldUsePipelining ?? iosHttpShouldUsePipelining,
      "iosNetworkServiceType":
      // ignore: deprecated_member_use_from_same_package
      networkServiceType?.toValue() ?? iosNetworkServiceType?.toValue(),
      "networkServiceType":
      // ignore: deprecated_member_use_from_same_package
      networkServiceType?.toValue() ?? iosNetworkServiceType?.toValue(),
      // ignore: deprecated_member_use_from_same_package
      "iosTimeoutInterval": timeoutInterval ?? iosTimeoutInterval,
      // ignore: deprecated_member_use_from_same_package
      "timeoutInterval": timeoutInterval ?? iosTimeoutInterval,
      // ignore: deprecated_member_use_from_same_package
      "iosMainDocumentURL": (mainDocumentURL ?? iosMainDocumentURL)?.toString(),
      // ignore: deprecated_member_use_from_same_package
      "mainDocumentURL": (mainDocumentURL ?? iosMainDocumentURL)?.toString(),
      "assumesHTTP3Capable": assumesHTTP3Capable,
      "attribution": attribution?.toValue(),
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