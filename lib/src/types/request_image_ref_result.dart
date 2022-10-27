import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../in_app_webview/in_app_webview_controller.dart';
import '../web_uri.dart';

part 'request_image_ref_result.g.dart';

///Class that represents the result used by the [InAppWebViewController.requestImageRef] method.
@ExchangeableObject()
class RequestImageRefResult_ {
  ///The image's url.
  WebUri? url;

  RequestImageRefResult_({this.url});
}
