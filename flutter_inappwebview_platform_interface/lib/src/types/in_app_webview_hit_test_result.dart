import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'in_app_webview_hit_test_result_type.dart';
import 'enum_method.dart';

part 'in_app_webview_hit_test_result.g.dart';

///Class that represents the hit result for hitting an HTML elements.
@ExchangeableObject()
class InAppWebViewHitTestResult_ {
  ///The type of the hit test result.
  InAppWebViewHitTestResultType_? type;

  ///Additional type-dependant information about the result.
  String? extra;

  InAppWebViewHitTestResult_({this.type, this.extra});
}
