import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'enum_method.dart';

part 'webview_package_info.g.dart';

///Class that represents a `WebView` package info.
@ExchangeableObject()
class WebViewPackageInfo_ {
  ///The version name of this WebView package.
  String? versionName;

  ///The name of this WebView package.
  String? packageName;

  WebViewPackageInfo_({this.versionName, this.packageName});
}

///Class that represents an Android `WebView` package info.
///Use [WebViewPackageInfo] instead.
@Deprecated("Use WebViewPackageInfo instead")
@ExchangeableObject()
class AndroidWebViewPackageInfo_ {
  ///The version name of this WebView package.
  String? versionName;

  ///The name of this WebView package.
  String? packageName;

  AndroidWebViewPackageInfo_({this.versionName, this.packageName});
}
