import 'proxy_scheme_filter.dart';

///Class that holds a scheme filter and a proxy URL.
class ProxyRule {
  ///Represents the scheme filter.
  ProxySchemeFilter? schemeFilter;

  ///Represents the proxy URL.
  String url;

  ProxyRule({required this.url, this.schemeFilter});

  ///Gets a possible [ProxyRule] instance from a [Map] value.
  static ProxyRule? fromMap(Map<String, dynamic>? map) {
    return map != null
        ? ProxyRule(
            url: map["url"],
            schemeFilter: ProxySchemeFilter.fromValue(map["schemeFilter"]))
        : null;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {"url": url, "schemeFilter": schemeFilter?.toValue()};
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
