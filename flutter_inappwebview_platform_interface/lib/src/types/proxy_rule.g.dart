// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy_rule.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that holds a scheme filter and a proxy URL.
class ProxyRule {
  ///A Boolean that indicates whether or not a proxy configuration allows failover to non-proxied connections.
  ///Failover isn’t allowed by default.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  bool? allowFailover;

  ///Define an array of domains to determine which hosts should not use the proxy.
  ///If the array is empty, no domains are excluded.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  List<String>? excludedDomains;

  ///Define an array of domains to determine which hosts should use the proxy. If the array is empty,
  ///all domains are allowed to use the proxy other than domains listed in [excludedDomains].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  List<String>? matchDomains;

  ///Sets a password to use as authentication for a proxy configuration.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  String? password;

  ///Represents the scheme filter.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ProxySchemeFilter? schemeFilter;

  ///Represents the proxy URL.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  String url;

  ///Sets a username to use as authentication for a proxy configuration.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///- MacOS
  String? username;
  ProxyRule(
      {this.allowFailover,
      this.excludedDomains,
      this.matchDomains,
      this.password,
      this.schemeFilter,
      required this.url,
      this.username});

  ///Gets a possible [ProxyRule] instance from a [Map] value.
  static ProxyRule? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = ProxyRule(
      allowFailover: map['allowFailover'],
      excludedDomains: map['excludedDomains'] != null
          ? List<String>.from(map['excludedDomains']!.cast<String>())
          : null,
      matchDomains: map['matchDomains'] != null
          ? List<String>.from(map['matchDomains']!.cast<String>())
          : null,
      password: map['password'],
      schemeFilter: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          ProxySchemeFilter.fromNativeValue(map['schemeFilter']),
        EnumMethod.value => ProxySchemeFilter.fromValue(map['schemeFilter']),
        EnumMethod.name => ProxySchemeFilter.byName(map['schemeFilter'])
      },
      url: map['url'],
      username: map['username'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "allowFailover": allowFailover,
      "excludedDomains": excludedDomains,
      "matchDomains": matchDomains,
      "password": password,
      "schemeFilter": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => schemeFilter?.toNativeValue(),
        EnumMethod.value => schemeFilter?.toValue(),
        EnumMethod.name => schemeFilter?.name()
      },
      "url": url,
      "username": username,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'ProxyRule{allowFailover: $allowFailover, excludedDomains: $excludedDomains, matchDomains: $matchDomains, password: $password, schemeFilter: $schemeFilter, url: $url, username: $username}';
  }
}
