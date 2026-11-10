import 'package:flutter_inappwebview_windows/flutter_inappwebview_windows.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../../tool/javascript_handler_json_controller_test.dart';

void main() {
  testJavaScriptHandlerJsonController(
    () => WindowsInAppWebViewController(
      const PlatformInAppWebViewControllerCreationParams(id: 'json-result'),
    ),
  );
}
