import 'dart:typed_data';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../web_uri.dart';
import 'url_request_cache_policy.dart';
import 'url_request_network_service_type.dart';
import 'url_request_attribution.dart';
import 'enum_method.dart';

part 'url_request.g.dart';

///A URL load request that is independent of protocol or URL scheme.
@ExchangeableObject()
class URLRequest_ {
  ///The URL of the request. Setting this to `null` will load `about:blank`.
  WebUri? url;

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
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "URLRequest.allowsCellularAccess",
        apiUrl:
            "https://developer.apple.com/documentation/foundation/urlrequest/2011607-allowscellularaccess/",
      ),
      MacOSPlatform(
        apiName: "URLRequest.allowsCellularAccess",
        apiUrl:
            "https://developer.apple.com/documentation/foundation/urlrequest/2011607-allowscellularaccess/",
      ),
    ],
  )
  bool? allowsCellularAccess;

  ///Use [allowsConstrainedNetworkAccess] instead.
  @Deprecated("Use allowsConstrainedNetworkAccess instead")
  bool? iosAllowsConstrainedNetworkAccess;

  ///A Boolean value that indicates whether the request may use the network when the user has specified Low Data Mode.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "13.0",
        apiName: "URLRequest.allowsConstrainedNetworkAccess",
        apiUrl:
            "https://developer.apple.com/documentation/foundation/urlrequest/3358304-allowsconstrainednetworkaccess",
      ),
      MacOSPlatform(
        available: "10.15",
        apiName: "URLRequest.allowsConstrainedNetworkAccess",
        apiUrl:
            "https://developer.apple.com/documentation/foundation/urlrequest/3358304-allowsconstrainednetworkaccess",
      ),
    ],
  )
  bool? allowsConstrainedNetworkAccess;

  ///Use [allowsExpensiveNetworkAccess] instead.
  @Deprecated("Use allowsExpensiveNetworkAccess instead")
  bool? iosAllowsExpensiveNetworkAccess;

  ///A Boolean value that indicates whether connections may use a network interface that the system considers expensive.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "13.0",
        apiName: "URLRequest.allowsExpensiveNetworkAccess",
        apiUrl:
            "https://developer.apple.com/documentation/foundation/urlrequest/3358305-allowsexpensivenetworkaccess",
      ),
      MacOSPlatform(
        available: "10.15",
        apiName: "URLRequest.allowsExpensiveNetworkAccess",
        apiUrl:
            "https://developer.apple.com/documentation/foundation/urlrequest/3358305-allowsexpensivenetworkaccess",
      ),
    ],
  )
  bool? allowsExpensiveNetworkAccess;

  ///Use [cachePolicy] instead.
  @Deprecated("Use cachePolicy instead")
  IOSURLRequestCachePolicy_? iosCachePolicy;

  ///The request’s cache policy.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "URLRequest.cachePolicy",
        apiUrl:
            "https://developer.apple.com/documentation/foundation/urlrequest/2011593-cachepolicy",
      ),
      MacOSPlatform(
        apiName: "URLRequest.cachePolicy",
        apiUrl:
            "https://developer.apple.com/documentation/foundation/urlrequest/2011593-cachepolicy",
      ),
    ],
  )
  URLRequestCachePolicy_? cachePolicy;

  ///Use [httpShouldHandleCookies] instead.
  @Deprecated("Use httpShouldHandleCookies instead")
  bool? iosHttpShouldHandleCookies;

  ///A Boolean value indicating whether cookies will be sent with and set for this request.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "URLRequest.httpShouldHandleCookies",
        apiUrl:
            "https://developer.apple.com/documentation/foundation/urlrequest/2011548-httpshouldhandlecookies",
      ),
      MacOSPlatform(
        apiName: "URLRequest.httpShouldHandleCookies",
        apiUrl:
            "https://developer.apple.com/documentation/foundation/urlrequest/2011548-httpshouldhandlecookies",
      ),
    ],
  )
  bool? httpShouldHandleCookies;

  ///Use [httpShouldUsePipelining] instead.
  @Deprecated("Use httpShouldUsePipelining instead")
  bool? iosHttpShouldUsePipelining;

  ///A Boolean value indicating whether the request should transmit before the previous response is received.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "URLRequest.httpShouldUsePipelining",
        apiUrl:
            "https://developer.apple.com/documentation/foundation/urlrequest/2011508-httpshouldusepipelining",
      ),
      MacOSPlatform(
        apiName: "URLRequest.httpShouldUsePipelining",
        apiUrl:
            "https://developer.apple.com/documentation/foundation/urlrequest/2011508-httpshouldusepipelining",
      ),
    ],
  )
  bool? httpShouldUsePipelining;

  ///Use [networkServiceType] instead.
  @Deprecated("Use networkServiceType instead")
  IOSURLRequestNetworkServiceType_? iosNetworkServiceType;

  ///The service type associated with this request.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "URLRequest.networkServiceType",
        apiUrl:
            "https://developer.apple.com/documentation/foundation/urlrequest/2011409-networkservicetype",
      ),
      MacOSPlatform(
        apiName: "URLRequest.networkServiceType",
        apiUrl:
            "https://developer.apple.com/documentation/foundation/urlrequest/2011409-networkservicetype",
      ),
    ],
  )
  URLRequestNetworkServiceType_? networkServiceType;

  ///Use [timeoutInterval] instead.
  @Deprecated("Use timeoutInterval instead")
  double? iosTimeoutInterval;

  ///The timeout interval of the request.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "URLRequest.timeoutInterval",
        apiUrl:
            "https://developer.apple.com/documentation/foundation/urlrequest/2011509-timeoutinterval",
      ),
      MacOSPlatform(
        apiName: "URLRequest.timeoutInterval",
        apiUrl:
            "https://developer.apple.com/documentation/foundation/urlrequest/2011509-timeoutinterval",
      ),
    ],
  )
  double? timeoutInterval;

  ///Use [mainDocumentURL] instead.
  @Deprecated("Use mainDocumentURL instead")
  Uri? iosMainDocumentURL;

  ///The main document URL associated with this request.
  ///This URL is used for the cookie “same domain as main document” policy.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        apiName: "URLRequest.mainDocumentURL",
        apiUrl:
            "https://developer.apple.com/documentation/foundation/urlrequest/2011552-maindocumenturl",
      ),
      MacOSPlatform(
        apiName: "URLRequest.mainDocumentURL",
        apiUrl:
            "https://developer.apple.com/documentation/foundation/urlrequest/2011552-maindocumenturl",
      ),
    ],
  )
  WebUri? mainDocumentURL;

  ///`true` if server endpoint is known to support HTTP/3. Enables QUIC racing
  ///without HTTP/3 service discovery. Defaults to `false`.
  ///The default may be `true` in a future OS update.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "14.5",
        apiName: "URLRequest.assumesHTTP3Capable",
        apiUrl:
            "https://developer.apple.com/documentation/foundation/urlrequest/3738175-assumeshttp3capable",
      ),
      MacOSPlatform(
        available: "11.3",
        apiName: "URLRequest.assumesHTTP3Capable",
        apiUrl:
            "https://developer.apple.com/documentation/foundation/urlrequest/3738175-assumeshttp3capable",
      ),
    ],
  )
  bool? assumesHTTP3Capable;

  ///The entities that can make a network request.
  ///
  ///If you don’t set a value, the system assumes [URLRequestAttribution.DEVELOPER].
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(
        available: "15.0",
        apiName: "URLRequest.attribution",
        apiUrl:
            "https://developer.apple.com/documentation/foundation/urlrequest/3767318-attribution",
      ),
      MacOSPlatform(
        available: "12.0",
        apiName: "URLRequest.attribution",
        apiUrl:
            "https://developer.apple.com/documentation/foundation/urlrequest/3767318-attribution",
      ),
    ],
  )
  URLRequestAttribution_? attribution;

  URLRequest_({
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
    this.attribution,
  });
}
