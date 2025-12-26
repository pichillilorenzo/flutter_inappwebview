import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'enum_method.dart';
import 'proxy_scheme_filter.dart';

part 'proxy_rule.g.dart';

///Class that holds a scheme filter and a proxy URL.
@ExchangeableObject()
class ProxyRule_ {
  ///Represents the scheme filter.
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
  ])
  ProxySchemeFilter_? schemeFilter;

  ///Represents the proxy URL.
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
  ])
  String url;

  ///A Boolean that indicates whether or not a proxy configuration allows failover to non-proxied connections.
  ///Failover isn’t allowed by default.
  @SupportedPlatforms(platforms: [
    IOSPlatform(),
    MacOSPlatform(),
  ])
  bool? allowFailover;

  ///Sets a username to use as authentication for a proxy configuration.
  @SupportedPlatforms(platforms: [
    IOSPlatform(),
    MacOSPlatform(),
  ])
  String? username;

  ///Sets a password to use as authentication for a proxy configuration.
  @SupportedPlatforms(platforms: [
    IOSPlatform(),
    MacOSPlatform(),
  ])
  String? password;

  ///Define an array of domains to determine which hosts should not use the proxy.
  ///If the array is empty, no domains are excluded.
  @SupportedPlatforms(platforms: [
    IOSPlatform(),
    MacOSPlatform(),
  ])
  List<String>? excludedDomains;

  ///Define an array of domains to determine which hosts should use the proxy. If the array is empty,
  ///all domains are allowed to use the proxy other than domains listed in [excludedDomains].
  @SupportedPlatforms(platforms: [
    IOSPlatform(),
    MacOSPlatform(),
  ])
  List<String>? matchDomains;

  ProxyRule_({
    required this.url,
    this.schemeFilter,
    this.allowFailover,
    this.username,
    this.password,
    this.excludedDomains,
    this.matchDomains,
  });
}
