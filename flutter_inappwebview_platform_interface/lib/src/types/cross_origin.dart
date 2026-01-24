import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'script_html_tag_attributes.dart';
import 'css_link_html_tag_attributes.dart';

part 'cross_origin.g.dart';

///Class that represents the `crossorigin` content attribute on media elements, which is a CORS settings attribute.
///It could be used with [ScriptHtmlTagAttributes] and [CSSLinkHtmlTagAttributes]
///when fetching a resource `<link>` or a `<script>` (or resources fetched by the `<script>`).
@ExchangeableEnum()
class CrossOrigin_ {
  // ignore: unused_field
  final String _value;
  const CrossOrigin_._internal(this._value);

  ///CORS requests for this element will have the credentials flag set to 'same-origin'.
  static const ANONYMOUS = const CrossOrigin_._internal("anonymous");

  ///CORS requests for this element will have the credentials flag set to 'include'.
  static const USE_CREDENTIALS = const CrossOrigin_._internal(
    "use-credentials",
  );
}
