import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../../tool/javascript_handler_json_controller_test.dart';

void main() {
  testJavaScriptHandlerJsonController(
    () => AndroidInAppWebViewController(
      const PlatformInAppWebViewControllerCreationParams(id: 'json-result'),
    ),
  );
}
