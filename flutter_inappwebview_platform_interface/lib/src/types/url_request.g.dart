// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'url_request.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///A URL load request that is independent of protocol or URL scheme.
class URLRequest {
  ///A Boolean value indicating whether the request is allowed to use the built-in cellular radios to satisfy the request.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLRequest.allowsCellularAccess](https://developer.apple.com/documentation/foundation/urlrequest/2011607-allowscellularaccess/))
  ///- MacOS ([Official API - URLRequest.allowsCellularAccess](https://developer.apple.com/documentation/foundation/urlrequest/2011607-allowscellularaccess/))
  bool? allowsCellularAccess;

  ///A Boolean value that indicates whether the request may use the network when the user has specified Low Data Mode.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS 13.0+ ([Official API - URLRequest.allowsConstrainedNetworkAccess](https://developer.apple.com/documentation/foundation/urlrequest/3358304-allowsconstrainednetworkaccess))
  ///- MacOS 10.15+ ([Official API - URLRequest.allowsConstrainedNetworkAccess](https://developer.apple.com/documentation/foundation/urlrequest/3358304-allowsconstrainednetworkaccess))
  bool? allowsConstrainedNetworkAccess;

  ///A Boolean value that indicates whether connections may use a network interface that the system considers expensive.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS 13.0+ ([Official API - URLRequest.allowsExpensiveNetworkAccess](https://developer.apple.com/documentation/foundation/urlrequest/3358305-allowsexpensivenetworkaccess))
  ///- MacOS 10.15+ ([Official API - URLRequest.allowsExpensiveNetworkAccess](https://developer.apple.com/documentation/foundation/urlrequest/3358305-allowsexpensivenetworkaccess))
  bool? allowsExpensiveNetworkAccess;

  ///`true` if server endpoint is known to support HTTP/3. Enables QUIC racing
  ///without HTTP/3 service discovery. Defaults to `false`.
  ///The default may be `true` in a future OS update.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS 14.5+ ([Official API - URLRequest.assumesHTTP3Capable](https://developer.apple.com/documentation/foundation/urlrequest/3738175-assumeshttp3capable))
  ///- MacOS 11.3+ ([Official API - URLRequest.assumesHTTP3Capable](https://developer.apple.com/documentation/foundation/urlrequest/3738175-assumeshttp3capable))
  bool? assumesHTTP3Capable;

  ///The entities that can make a network request.
  ///
  ///If you don’t set a value, the system assumes [URLRequestAttribution.DEVELOPER].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS 15.0+ ([Official API - URLRequest.attribution](https://developer.apple.com/documentation/foundation/urlrequest/3767318-attribution))
  ///- MacOS 12.0+ ([Official API - URLRequest.attribution](https://developer.apple.com/documentation/foundation/urlrequest/3767318-attribution))
  URLRequestAttribution? attribution;

  ///The data sent as the message body of a request, such as for an HTTP POST request.
  Uint8List? body;

  ///The request’s cache policy.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLRequest.cachePolicy](https://developer.apple.com/documentation/foundation/urlrequest/2011593-cachepolicy))
  ///- MacOS ([Official API - URLRequest.cachePolicy](https://developer.apple.com/documentation/foundation/urlrequest/2011593-cachepolicy))
  URLRequestCachePolicy? cachePolicy;

  ///A dictionary containing all of the HTTP header fields for a request.
  Map<String, String>? headers;

  ///A Boolean value indicating whether cookies will be sent with and set for this request.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLRequest.httpShouldHandleCookies](https://developer.apple.com/documentation/foundation/urlrequest/2011548-httpshouldhandlecookies))
  ///- MacOS ([Official API - URLRequest.httpShouldHandleCookies](https://developer.apple.com/documentation/foundation/urlrequest/2011548-httpshouldhandlecookies))
  bool? httpShouldHandleCookies;

  ///A Boolean value indicating whether the request should transmit before the previous response is received.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLRequest.httpShouldUsePipelining](https://developer.apple.com/documentation/foundation/urlrequest/2011508-httpshouldusepipelining))
  ///- MacOS ([Official API - URLRequest.httpShouldUsePipelining](https://developer.apple.com/documentation/foundation/urlrequest/2011508-httpshouldusepipelining))
  bool? httpShouldUsePipelining;

  ///Use [allowsCellularAccess] instead.
  @Deprecated('Use allowsCellularAccess instead')
  bool? iosAllowsCellularAccess;

  ///Use [allowsConstrainedNetworkAccess] instead.
  @Deprecated('Use allowsConstrainedNetworkAccess instead')
  bool? iosAllowsConstrainedNetworkAccess;

  ///Use [allowsExpensiveNetworkAccess] instead.
  @Deprecated('Use allowsExpensiveNetworkAccess instead')
  bool? iosAllowsExpensiveNetworkAccess;

  ///Use [cachePolicy] instead.
  @Deprecated('Use cachePolicy instead')
  IOSURLRequestCachePolicy? iosCachePolicy;

  ///Use [httpShouldHandleCookies] instead.
  @Deprecated('Use httpShouldHandleCookies instead')
  bool? iosHttpShouldHandleCookies;

  ///Use [httpShouldUsePipelining] instead.
  @Deprecated('Use httpShouldUsePipelining instead')
  bool? iosHttpShouldUsePipelining;

  ///Use [mainDocumentURL] instead.
  @Deprecated('Use mainDocumentURL instead')
  Uri? iosMainDocumentURL;

  ///Use [networkServiceType] instead.
  @Deprecated('Use networkServiceType instead')
  IOSURLRequestNetworkServiceType? iosNetworkServiceType;

  ///Use [timeoutInterval] instead.
  @Deprecated('Use timeoutInterval instead')
  double? iosTimeoutInterval;

  ///The main document URL associated with this request.
  ///This URL is used for the cookie “same domain as main document” policy.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLRequest.mainDocumentURL](https://developer.apple.com/documentation/foundation/urlrequest/2011552-maindocumenturl))
  ///- MacOS ([Official API - URLRequest.mainDocumentURL](https://developer.apple.com/documentation/foundation/urlrequest/2011552-maindocumenturl))
  WebUri? mainDocumentURL;

  ///The HTTP request method.
  ///
  ///**NOTE for Android**: it supports only "GET" and "POST" methods.
  String? method;

  ///The service type associated with this request.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLRequest.networkServiceType](https://developer.apple.com/documentation/foundation/urlrequest/2011409-networkservicetype))
  ///- MacOS ([Official API - URLRequest.networkServiceType](https://developer.apple.com/documentation/foundation/urlrequest/2011409-networkservicetype))
  URLRequestNetworkServiceType? networkServiceType;

  ///The timeout interval of the request.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - URLRequest.timeoutInterval](https://developer.apple.com/documentation/foundation/urlrequest/2011509-timeoutinterval))
  ///- MacOS ([Official API - URLRequest.timeoutInterval](https://developer.apple.com/documentation/foundation/urlrequest/2011509-timeoutinterval))
  double? timeoutInterval;

  ///The URL of the request. Setting this to `null` will load `about:blank`.
  WebUri? url;
  URLRequest(
      {this.allowsCellularAccess,
      this.allowsConstrainedNetworkAccess,
      this.allowsExpensiveNetworkAccess,
      this.assumesHTTP3Capable,
      this.attribution,
      this.body,
      this.cachePolicy,
      this.headers,
      this.httpShouldHandleCookies,
      this.httpShouldUsePipelining,
      @Deprecated('Use allowsCellularAccess instead')
      this.iosAllowsCellularAccess,
      @Deprecated('Use allowsConstrainedNetworkAccess instead')
      this.iosAllowsConstrainedNetworkAccess,
      @Deprecated('Use allowsExpensiveNetworkAccess instead')
      this.iosAllowsExpensiveNetworkAccess,
      @Deprecated('Use cachePolicy instead') this.iosCachePolicy,
      @Deprecated('Use httpShouldHandleCookies instead')
      this.iosHttpShouldHandleCookies,
      @Deprecated('Use httpShouldUsePipelining instead')
      this.iosHttpShouldUsePipelining,
      @Deprecated('Use mainDocumentURL instead') this.iosMainDocumentURL,
      @Deprecated('Use networkServiceType instead') this.iosNetworkServiceType,
      @Deprecated('Use timeoutInterval instead') this.iosTimeoutInterval,
      this.mainDocumentURL,
      this.method,
      this.networkServiceType,
      this.timeoutInterval,
      this.url}) {
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
    mainDocumentURL = mainDocumentURL ??
        (iosMainDocumentURL != null ? WebUri.uri(iosMainDocumentURL!) : null);
    networkServiceType = networkServiceType ??
        URLRequestNetworkServiceType.fromNativeValue(
            iosNetworkServiceType?.toNativeValue());
    timeoutInterval = timeoutInterval ?? iosTimeoutInterval;
  }

  ///Gets a possible [URLRequest] instance from a [Map] value.
  static URLRequest? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = URLRequest(
      allowsCellularAccess: map['allowsCellularAccess'],
      allowsConstrainedNetworkAccess: map['allowsConstrainedNetworkAccess'],
      allowsExpensiveNetworkAccess: map['allowsExpensiveNetworkAccess'],
      assumesHTTP3Capable: map['assumesHTTP3Capable'],
      attribution: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          URLRequestAttribution.fromNativeValue(map['attribution']),
        EnumMethod.value => URLRequestAttribution.fromValue(map['attribution']),
        EnumMethod.name => URLRequestAttribution.byName(map['attribution'])
      },
      body: map['body'] != null
          ? Uint8List.fromList(map['body'].cast<int>())
          : null,
      cachePolicy: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          URLRequestCachePolicy.fromNativeValue(map['cachePolicy']),
        EnumMethod.value => URLRequestCachePolicy.fromValue(map['cachePolicy']),
        EnumMethod.name => URLRequestCachePolicy.byName(map['cachePolicy'])
      },
      headers: map['headers']?.cast<String, String>(),
      httpShouldHandleCookies: map['httpShouldHandleCookies'],
      httpShouldUsePipelining: map['httpShouldUsePipelining'],
      iosAllowsCellularAccess: map['allowsCellularAccess'],
      iosAllowsConstrainedNetworkAccess: map['allowsConstrainedNetworkAccess'],
      iosAllowsExpensiveNetworkAccess: map['allowsExpensiveNetworkAccess'],
      iosCachePolicy: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          IOSURLRequestCachePolicy.fromNativeValue(map['cachePolicy']),
        EnumMethod.value =>
          IOSURLRequestCachePolicy.fromValue(map['cachePolicy']),
        EnumMethod.name => IOSURLRequestCachePolicy.byName(map['cachePolicy'])
      },
      iosHttpShouldHandleCookies: map['httpShouldHandleCookies'],
      iosHttpShouldUsePipelining: map['httpShouldUsePipelining'],
      iosMainDocumentURL: map['mainDocumentURL'] != null
          ? Uri.tryParse(map['mainDocumentURL'])
          : null,
      iosNetworkServiceType: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          IOSURLRequestNetworkServiceType.fromNativeValue(
              map['networkServiceType']),
        EnumMethod.value =>
          IOSURLRequestNetworkServiceType.fromValue(map['networkServiceType']),
        EnumMethod.name =>
          IOSURLRequestNetworkServiceType.byName(map['networkServiceType'])
      },
      iosTimeoutInterval: map['timeoutInterval'],
      mainDocumentURL: map['mainDocumentURL'] != null
          ? WebUri(map['mainDocumentURL'])
          : null,
      method: map['method'],
      networkServiceType: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => URLRequestNetworkServiceType.fromNativeValue(
            map['networkServiceType']),
        EnumMethod.value =>
          URLRequestNetworkServiceType.fromValue(map['networkServiceType']),
        EnumMethod.name =>
          URLRequestNetworkServiceType.byName(map['networkServiceType'])
      },
      timeoutInterval: map['timeoutInterval'],
      url: map['url'] != null ? WebUri(map['url']) : null,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "allowsCellularAccess": allowsCellularAccess,
      "allowsConstrainedNetworkAccess": allowsConstrainedNetworkAccess,
      "allowsExpensiveNetworkAccess": allowsExpensiveNetworkAccess,
      "assumesHTTP3Capable": assumesHTTP3Capable,
      "attribution": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => attribution?.toNativeValue(),
        EnumMethod.value => attribution?.toValue(),
        EnumMethod.name => attribution?.name()
      },
      "body": body,
      "cachePolicy": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => cachePolicy?.toNativeValue(),
        EnumMethod.value => cachePolicy?.toValue(),
        EnumMethod.name => cachePolicy?.name()
      },
      "headers": headers,
      "httpShouldHandleCookies": httpShouldHandleCookies,
      "httpShouldUsePipelining": httpShouldUsePipelining,
      "mainDocumentURL": mainDocumentURL?.toString(),
      "method": method,
      "networkServiceType": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => networkServiceType?.toNativeValue(),
        EnumMethod.value => networkServiceType?.toValue(),
        EnumMethod.name => networkServiceType?.name()
      },
      "timeoutInterval": timeoutInterval,
      "url": url?.toString(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'URLRequest{allowsCellularAccess: $allowsCellularAccess, allowsConstrainedNetworkAccess: $allowsConstrainedNetworkAccess, allowsExpensiveNetworkAccess: $allowsExpensiveNetworkAccess, assumesHTTP3Capable: $assumesHTTP3Capable, attribution: $attribution, body: $body, cachePolicy: $cachePolicy, headers: $headers, httpShouldHandleCookies: $httpShouldHandleCookies, httpShouldUsePipelining: $httpShouldUsePipelining, mainDocumentURL: $mainDocumentURL, method: $method, networkServiceType: $networkServiceType, timeoutInterval: $timeoutInterval, url: $url}';
  }
}
