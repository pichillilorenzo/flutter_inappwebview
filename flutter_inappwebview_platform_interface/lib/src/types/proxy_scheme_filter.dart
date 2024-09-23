import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../platform_proxy_controller.dart';

part 'proxy_scheme_filter.g.dart';

///Class that represent scheme filters used by [PlatformProxyController].
@ExchangeableEnum()
class ProxySchemeFilter_ {
  // ignore: unused_field
  final String _value;
  const ProxySchemeFilter_._internal(this._value);

  ///Matches all schemes.
  static const MATCH_ALL_SCHEMES = const ProxySchemeFilter_._internal("*");

  ///HTTP scheme.
  static const MATCH_HTTP = const ProxySchemeFilter_._internal("http");

  ///HTTPS scheme.
  static const MATCH_HTTPS = const ProxySchemeFilter_._internal("https");
}
