import 'package:flutter_test/flutter_test.dart';

import 'convert_to_inappwebview.dart';
import 'take_screenshot.dart';
import 'custom_size.dart';
import 'run_and_dispose.dart';
import 'set_get_settings.dart';

void main() {
  group('HeadlessInAppWebView', () {
    runAndDispose();
    takeScreenshot();
    customSize();
    setGetSettings();
    convertToInAppWebView();
  });
}
