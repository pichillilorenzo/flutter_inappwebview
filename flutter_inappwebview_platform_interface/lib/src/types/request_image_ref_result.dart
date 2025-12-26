import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../in_app_webview/platform_inappwebview_controller.dart';
import '../web_uri.dart';
import 'enum_method.dart';

part 'request_image_ref_result.g.dart';

///Class that represents the result used by the [PlatformInAppWebViewController.requestImageRef] method.
@ExchangeableObject()
class RequestImageRefResult_ {
  ///The image's url.
  WebUri? url;

  RequestImageRefResult_({this.url});
}
