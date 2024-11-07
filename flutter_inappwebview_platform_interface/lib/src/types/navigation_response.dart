import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../in_app_webview/platform_webview.dart';
import 'url_response.dart';
import 'enum_method.dart';

part 'navigation_response.g.dart';

///Class that represents the navigation response used by the [PlatformWebViewCreationParams.onNavigationResponse] event.
@ExchangeableObject()
class NavigationResponse_ {
  ///The URL for the response.
  URLResponse_? response;

  ///A Boolean value that indicates whether the response targets the web view’s main frame.
  bool isForMainFrame;

  ///A Boolean value that indicates whether WebKit is capable of displaying the response’s MIME type natively.
  bool canShowMIMEType;

  NavigationResponse_(
      {this.response,
      required this.isForMainFrame,
      required this.canShowMIMEType});
}

///An iOS-specific Class that represents the navigation response used by the [PlatformWebViewCreationParams.onNavigationResponse] event.
///Use [NavigationResponse] instead.
@Deprecated("Use NavigationResponse instead")
@ExchangeableObject()
class IOSWKNavigationResponse_ {
  ///The URL for the response.
  IOSURLResponse_? response;

  ///A Boolean value that indicates whether the response targets the web view’s main frame.
  bool isForMainFrame;

  ///A Boolean value that indicates whether WebKit is capable of displaying the response’s MIME type natively.
  bool canShowMIMEType;

  IOSWKNavigationResponse_(
      {this.response,
      required this.isForMainFrame,
      required this.canShowMIMEType});
}
