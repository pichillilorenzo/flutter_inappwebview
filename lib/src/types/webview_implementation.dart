import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../in_app_webview/webview.dart';

part 'webview_implementation.g.dart';

///Class that represents the [WebView] native implementation to be used.
@ExchangeableEnum()
class WebViewImplementation_ {
  // ignore: unused_field
  final int _value;
  const WebViewImplementation_._internal(this._value);

  ///Default native implementation, such as `WKWebView` for iOS and `android.webkit.WebView` for Android.
  static const NATIVE = const WebViewImplementation_._internal(0);
}
