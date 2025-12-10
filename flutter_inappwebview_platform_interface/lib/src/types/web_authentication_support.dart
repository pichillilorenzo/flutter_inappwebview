import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'web_authentication_support.g.dart';

///Class that describes the Web Authentication support level for a WebView instance.
@ExchangeableEnum()
class WebAuthenticationSupport_ {
  // ignore: unused_field
  final int _value;
  const WebAuthenticationSupport_._internal(this._value);

  ///Disable Web Authentication support in WebView.
  static const NONE = WebAuthenticationSupport_._internal(0);

  ///Enable Web Authentication support for the embedding app (for example, passkeys).
  static const FOR_APP = WebAuthenticationSupport_._internal(1);

  ///Enable Web Authentication support for browser delegations.
  static const FOR_BROWSER = WebAuthenticationSupport_._internal(2);
}
