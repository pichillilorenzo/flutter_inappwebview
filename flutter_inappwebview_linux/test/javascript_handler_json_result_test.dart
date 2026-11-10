import 'package:flutter_inappwebview_linux/flutter_inappwebview_linux.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../../tool/javascript_handler_json_controller_test.dart';

void main() {
  testJavaScriptHandlerJsonController(
    () => LinuxInAppWebViewController(
      const PlatformInAppWebViewControllerCreationParams(id: 'json-result'),
    ),
  );
}
