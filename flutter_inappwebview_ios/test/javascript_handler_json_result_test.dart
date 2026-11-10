import 'package:flutter_inappwebview_ios/flutter_inappwebview_ios.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../../tool/javascript_handler_json_controller_test.dart';

void main() {
  testJavaScriptHandlerJsonController(
    () => IOSInAppWebViewController(
      const PlatformInAppWebViewControllerCreationParams(id: 'json-result'),
    ),
  );
}
