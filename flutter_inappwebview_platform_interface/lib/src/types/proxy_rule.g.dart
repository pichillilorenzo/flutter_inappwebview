// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy_rule.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that holds a scheme filter and a proxy URL.
class ProxyRule {
  ///Represents the scheme filter.
  ProxySchemeFilter? schemeFilter;

  ///Represents the proxy URL.
  String url;
  ProxyRule({this.schemeFilter, required this.url});

  ///Gets a possible [ProxyRule] instance from a [Map] value.
  static ProxyRule? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = ProxyRule(
      schemeFilter: ProxySchemeFilter.fromNativeValue(map['schemeFilter']),
      url: map['url'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "schemeFilter": schemeFilter?.toNativeValue(),
      "url": url,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'ProxyRule{schemeFilter: $schemeFilter, url: $url}';
  }
}
