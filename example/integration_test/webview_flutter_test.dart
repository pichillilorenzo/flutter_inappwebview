import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:integration_test/integration_test.dart';

import 'in_app_webview/main.dart' as in_app_webview_tests;
import 'service_worker/main.dart' as service_worker_tests;
import 'headless_in_app_webview/main.dart' as headless_in_app_webview_tests;
import 'cookie_manager/main.dart' as cookie_manager_tests;
import 'in_app_browser/main.dart' as in_app_browser_tests;
import 'chrome_safari_browser/main.dart' as chrome_safari_browser_tests;
import 'in_app_localhost_server/main.dart' as in_app_localhost_server_tests;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  if (defaultTargetPlatform == TargetPlatform.android) {
    InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  in_app_webview_tests.main();
  service_worker_tests.main();
  headless_in_app_webview_tests.main();
  cookie_manager_tests.main();
  in_app_browser_tests.main();
  chrome_safari_browser_tests.main();
  in_app_localhost_server_tests.main();
}
