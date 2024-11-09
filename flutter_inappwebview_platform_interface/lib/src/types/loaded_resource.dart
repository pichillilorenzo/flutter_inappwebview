import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../in_app_webview/platform_webview.dart';
import '../web_uri.dart';
import 'enum_method.dart';

part 'loaded_resource.g.dart';

///Class representing a resource response of the `WebView`.
///It is used by the method [PlatformWebViewCreationParams.onLoadResource].
@ExchangeableObject()
class LoadedResource_ {
  ///A string representing the type of resource.
  String? initiatorType;

  ///Resource URL.
  WebUri? url;

  ///Returns the [DOMHighResTimeStamp](https://developer.mozilla.org/en-US/docs/Web/API/DOMHighResTimeStamp) for the time a resource fetch started.
  double? startTime;

  ///Returns the [DOMHighResTimeStamp](https://developer.mozilla.org/en-US/docs/Web/API/DOMHighResTimeStamp) duration to fetch a resource.
  double? duration;

  LoadedResource_(
      {this.initiatorType, this.url, this.startTime, this.duration});
}
