import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'enum_method.dart';

part 'proxy_relay_hop.g.dart';

///Relay servers are secure HTTP proxies that allow proxying TCP traffic using the
///CONNECT method and UDP traffic using the connect-udp protocol defined in [RFC 9298](https://www.rfc-editor.org/rfc/rfc9298.html).
///
///If [http3RelayEndpoint] is not null, it creates a configuration for a secure relay accessible using HTTP/3, with an optional HTTP/2 fallback using [http2RelayEndpoint].
///Otherwise, if [http2RelayEndpoint] is not null, it sreates a configuration for a secure relay accessible only using HTTP/2.
///
///At least one of [http3RelayEndpoint] or [http2RelayEndpoint] must be non-null.
@ExchangeableObject()
class ProxyRelayHop_ {
  ///A URL or host endpoint identifying the relay server accessible using HTTP/3.
  @SupportedPlatforms(platforms: [IOSPlatform(), MacOSPlatform()])
  String? http3RelayEndpoint;

  ///A URL or host endpoint identifying the relay server accessible using HTTP/2.
  @SupportedPlatforms(platforms: [IOSPlatform(), MacOSPlatform()])
  String? http2RelayEndpoint;

  ///A dictionary of additional HTTP headers to send as part of CONNECT requests to the relay.
  @SupportedPlatforms(platforms: [IOSPlatform(), MacOSPlatform()])
  Map<String, String>? additionalHTTPHeaders;

  @ExchangeableObjectConstructor()
  ProxyRelayHop_({
    this.http3RelayEndpoint,
    this.http2RelayEndpoint,
    this.additionalHTTPHeaders,
  }) {
    assert(
      http3RelayEndpoint != null || http2RelayEndpoint != null,
      "At least one of http3RelayEndpoint or http2RelayEndpoint must be non-null",
    );
  }
}
