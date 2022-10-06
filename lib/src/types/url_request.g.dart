// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'url_request.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///A URL load request that is independent of protocol or URL scheme.
class URLRequest {
  ///The URL of the request. Setting this to `null` will load `about:blank`.
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
  @Deprecated('Use allowsCellularAccess instead')
  bool? iosAllowsCellularAccess;

  ///A Boolean value indicating whether the request is allowed to use the built-in cellular radios to satisfy the request.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLRequest.allowsCellularAccess](https://developer.apple.com/documentation/foundation/urlrequest/2011607-allowscellularaccess/))
  bool? allowsCellularAccess;

  ///Use [allowsConstrainedNetworkAccess] instead.
  @Deprecated('Use allowsConstrainedNetworkAccess instead')
  bool? iosAllowsConstrainedNetworkAccess;

  ///A Boolean value that indicates whether the request may use the network when the user has specified Low Data Mode.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS 13.0+ ([Official API - URLRequest.allowsConstrainedNetworkAccess](https://developer.apple.com/documentation/foundation/urlrequest/3358304-allowsconstrainednetworkaccess))
  bool? allowsConstrainedNetworkAccess;

  ///Use [allowsExpensiveNetworkAccess] instead.
  @Deprecated('Use allowsExpensiveNetworkAccess instead')
  bool? iosAllowsExpensiveNetworkAccess;

  ///A Boolean value that indicates whether connections may use a network interface that the system considers expensive.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS 13.0+ ([Official API - URLRequest.allowsExpensiveNetworkAccess](https://developer.apple.com/documentation/foundation/urlrequest/3358305-allowsexpensivenetworkaccess))
  bool? allowsExpensiveNetworkAccess;

  ///Use [cachePolicy] instead.
  @Deprecated('Use cachePolicy instead')
  IOSURLRequestCachePolicy? iosCachePolicy;

  ///The request’s cache policy.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLRequest.cachePolicy](https://developer.apple.com/documentation/foundation/urlrequest/2011593-cachepolicy))
  URLRequestCachePolicy? cachePolicy;

  ///Use [httpShouldHandleCookies] instead.
  @Deprecated('Use httpShouldHandleCookies instead')
  bool? iosHttpShouldHandleCookies;

  ///A Boolean value indicating whether cookies will be sent with and set for this request.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLRequest.httpShouldHandleCookies](https://developer.apple.com/documentation/foundation/urlrequest/2011548-httpshouldhandlecookies))
  bool? httpShouldHandleCookies;

  ///Use [httpShouldUsePipelining] instead.
  @Deprecated('Use httpShouldUsePipelining instead')
  bool? iosHttpShouldUsePipelining;

  ///A Boolean value indicating whether the request should transmit before the previous response is received.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLRequest.httpShouldUsePipelining](https://developer.apple.com/documentation/foundation/urlrequest/2011508-httpshouldusepipelining))
  bool? httpShouldUsePipelining;

  ///Use [networkServiceType] instead.
  @Deprecated('Use networkServiceType instead')
  IOSURLRequestNetworkServiceType? iosNetworkServiceType;

  ///The service type associated with this request.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLRequest.networkServiceType](https://developer.apple.com/documentation/foundation/urlrequest/2011409-networkservicetype))
  URLRequestNetworkServiceType? networkServiceType;

  ///Use [timeoutInterval] instead.
  @Deprecated('Use timeoutInterval instead')
  double? iosTimeoutInterval;

  ///The timeout interval of the request.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLRequest.timeoutInterval](https://developer.apple.com/documentation/foundation/urlrequest/2011509-timeoutinterval))
  double? timeoutInterval;

  ///Use [mainDocumentURL] instead.
  @Deprecated('Use mainDocumentURL instead')
  Uri? iosMainDocumentURL;

  ///The main document URL associated with this request.
  ///This URL is used for the cookie “same domain as main document” policy.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLRequest.mainDocumentURL](https://developer.apple.com/documentation/foundation/urlrequest/2011552-maindocumenturl))
  Uri? mainDocumentURL;

  ///`true` if server endpoint is known to support HTTP/3. Enables QUIC racing
  ///without HTTP/3 service discovery. Defaults to `false`.
  ///The default may be `true` in a future OS update.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS 14.5+ ([Official API - URLRequest.assumesHTTP3Capable](https://developer.apple.com/documentation/foundation/urlrequest/3738175-assumeshttp3capable))
  bool? assumesHTTP3Capable;

  ///The entities that can make a network request.
  ///
  ///If you don’t set a value, the system assumes [URLRequestAttribution.DEVELOPER].
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS 15.0+ ([Official API - URLRequest.attribution](https://developer.apple.com/documentation/foundation/urlrequest/3767318-attribution))
  URLRequestAttribution? attribution;
  URLRequest(
      {this.url,
      this.method,
      this.body,
      this.headers,
      @Deprecated('Use allowsCellularAccess instead')
          this.iosAllowsCellularAccess,
      this.allowsCellularAccess,
      @Deprecated('Use allowsConstrainedNetworkAccess instead')
          this.iosAllowsConstrainedNetworkAccess,
      this.allowsConstrainedNetworkAccess,
      @Deprecated('Use allowsExpensiveNetworkAccess instead')
          this.iosAllowsExpensiveNetworkAccess,
      this.allowsExpensiveNetworkAccess,
      @Deprecated('Use cachePolicy instead')
          this.iosCachePolicy,
      this.cachePolicy,
      @Deprecated('Use httpShouldHandleCookies instead')
          this.iosHttpShouldHandleCookies,
      this.httpShouldHandleCookies,
      @Deprecated('Use httpShouldUsePipelining instead')
          this.iosHttpShouldUsePipelining,
      this.httpShouldUsePipelining,
      @Deprecated('Use networkServiceType instead')
          this.iosNetworkServiceType,
      this.networkServiceType,
      @Deprecated('Use timeoutInterval instead')
          this.iosTimeoutInterval,
      this.timeoutInterval,
      @Deprecated('Use mainDocumentURL instead')
          this.iosMainDocumentURL,
      this.mainDocumentURL,
      this.assumesHTTP3Capable,
      this.attribution}) {
    allowsCellularAccess = allowsCellularAccess ?? iosAllowsCellularAccess;
    allowsConstrainedNetworkAccess =
        allowsConstrainedNetworkAccess ?? iosAllowsConstrainedNetworkAccess;
    allowsExpensiveNetworkAccess =
        allowsExpensiveNetworkAccess ?? iosAllowsExpensiveNetworkAccess;
    cachePolicy = cachePolicy ??
        URLRequestCachePolicy.fromNativeValue(iosCachePolicy?.toNativeValue());
    httpShouldHandleCookies =
        httpShouldHandleCookies ?? iosHttpShouldHandleCookies;
    httpShouldUsePipelining =
        httpShouldUsePipelining ?? iosHttpShouldUsePipelining;
    networkServiceType = networkServiceType ??
        URLRequestNetworkServiceType.fromNativeValue(
            iosNetworkServiceType?.toNativeValue());
    timeoutInterval = timeoutInterval ?? iosTimeoutInterval;
    mainDocumentURL = mainDocumentURL ?? iosMainDocumentURL;
  }

  ///Gets a possible [URLRequest] instance from a [Map] value.
  static URLRequest? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = URLRequest(
      url: map['url'] != null ? Uri.parse(map['url']) : null,
      method: map['method'],
      body: map['body'],
      headers: map['headers']?.cast<String, String>(),
      iosAllowsCellularAccess: map['allowsCellularAccess'],
      allowsCellularAccess: map['allowsCellularAccess'],
      iosAllowsConstrainedNetworkAccess: map['allowsConstrainedNetworkAccess'],
      allowsConstrainedNetworkAccess: map['allowsConstrainedNetworkAccess'],
      iosAllowsExpensiveNetworkAccess: map['allowsExpensiveNetworkAccess'],
      allowsExpensiveNetworkAccess: map['allowsExpensiveNetworkAccess'],
      iosCachePolicy:
          IOSURLRequestCachePolicy.fromNativeValue(map['cachePolicy']),
      cachePolicy: URLRequestCachePolicy.fromNativeValue(map['cachePolicy']),
      iosHttpShouldHandleCookies: map['httpShouldHandleCookies'],
      httpShouldHandleCookies: map['httpShouldHandleCookies'],
      iosHttpShouldUsePipelining: map['httpShouldUsePipelining'],
      httpShouldUsePipelining: map['httpShouldUsePipelining'],
      iosNetworkServiceType: IOSURLRequestNetworkServiceType.fromNativeValue(
          map['networkServiceType']),
      networkServiceType: URLRequestNetworkServiceType.fromNativeValue(
          map['networkServiceType']),
      iosTimeoutInterval: map['timeoutInterval'],
      timeoutInterval: map['timeoutInterval'],
      iosMainDocumentURL: map['mainDocumentURL'] != null
          ? Uri.parse(map['mainDocumentURL'])
          : null,
      mainDocumentURL: map['mainDocumentURL'] != null
          ? Uri.parse(map['mainDocumentURL'])
          : null,
      assumesHTTP3Capable: map['assumesHTTP3Capable'],
      attribution: URLRequestAttribution.fromNativeValue(map['attribution']),
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "url": url?.toString(),
      "method": method,
      "body": body,
      "headers": headers,
      "allowsCellularAccess": allowsCellularAccess,
      "allowsConstrainedNetworkAccess": allowsConstrainedNetworkAccess,
      "allowsExpensiveNetworkAccess": allowsExpensiveNetworkAccess,
      "cachePolicy": cachePolicy?.toNativeValue(),
      "httpShouldHandleCookies": httpShouldHandleCookies,
      "httpShouldUsePipelining": httpShouldUsePipelining,
      "networkServiceType": networkServiceType?.toNativeValue(),
      "timeoutInterval": timeoutInterval,
      "mainDocumentURL": mainDocumentURL?.toString(),
      "assumesHTTP3Capable": assumesHTTP3Capable,
      "attribution": attribution?.toNativeValue(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'URLRequest{url: $url, method: $method, body: $body, headers: $headers, allowsCellularAccess: $allowsCellularAccess, allowsConstrainedNetworkAccess: $allowsConstrainedNetworkAccess, allowsExpensiveNetworkAccess: $allowsExpensiveNetworkAccess, cachePolicy: $cachePolicy, httpShouldHandleCookies: $httpShouldHandleCookies, httpShouldUsePipelining: $httpShouldUsePipelining, networkServiceType: $networkServiceType, timeoutInterval: $timeoutInterval, mainDocumentURL: $mainDocumentURL, assumesHTTP3Capable: $assumesHTTP3Capable, attribution: $attribution}';
  }
}
