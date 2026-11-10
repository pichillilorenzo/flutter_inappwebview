import 'package:flutter_inappwebview_macos/flutter_inappwebview_macos.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../../tool/javascript_handler_json_controller_test.dart';

void main() {
  testJavaScriptHandlerJsonController(
    () => MacOSInAppWebViewController(
      const PlatformInAppWebViewControllerCreationParams(id: 'json-result'),
    ),
  );
}
