// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy_relay_hop.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Relay servers are secure HTTP proxies that allow proxying TCP traffic using the
///CONNECT method and UDP traffic using the connect-udp protocol defined in [RFC 9298](https://www.rfc-editor.org/rfc/rfc9298.html).
///
///If [http3RelayEndpoint] is not null, it creates a configuration for a secure relay accessible using HTTP/3, with an optional HTTP/2 fallback using [http2RelayEndpoint].
///Otherwise, if [http2RelayEndpoint] is not null, it sreates a configuration for a secure relay accessible only using HTTP/2.
///
///At least one of [http3RelayEndpoint] or [http2RelayEndpoint] must be non-null.
class ProxyRelayHop {
  ///A dictionary of additional HTTP headers to send as part of CONNECT requests to the relay.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  Map<String, String>? additionalHTTPHeaders;

  ///A URL or host endpoint identifying the relay server accessible using HTTP/2.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  String? http2RelayEndpoint;

  ///A URL or host endpoint identifying the relay server accessible using HTTP/3.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///- macOS WKWebView
  String? http3RelayEndpoint;
  ProxyRelayHop(
      {this.http3RelayEndpoint,
      this.http2RelayEndpoint,
      this.additionalHTTPHeaders}) {
    assert(http3RelayEndpoint != null || http2RelayEndpoint != null,
        "At least one of http3RelayEndpoint or http2RelayEndpoint must be non-null");
  }

  ///Gets a possible [ProxyRelayHop] instance from a [Map] value.
  static ProxyRelayHop? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = ProxyRelayHop(
      additionalHTTPHeaders:
          map['additionalHTTPHeaders']?.cast<String, String>(),
      http2RelayEndpoint: map['http2RelayEndpoint'],
      http3RelayEndpoint: map['http3RelayEndpoint'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "additionalHTTPHeaders": additionalHTTPHeaders,
      "http2RelayEndpoint": http2RelayEndpoint,
      "http3RelayEndpoint": http3RelayEndpoint,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'ProxyRelayHop{additionalHTTPHeaders: $additionalHTTPHeaders, http2RelayEndpoint: $http2RelayEndpoint, http3RelayEndpoint: $http3RelayEndpoint}';
  }
}
