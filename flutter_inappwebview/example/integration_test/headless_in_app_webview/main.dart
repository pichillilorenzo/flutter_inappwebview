import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import '../constants.dart';
import '../util.dart';

part 'supported.dart';
part 'convert_to_inappwebview.dart';
part 'take_screenshot.dart';
part 'custom_size.dart';
part 'run_and_dispose.dart';
part 'set_get_settings.dart';

void main() {
  skippableGroup('HeadlessInAppWebView', () {
    supported();
    runAndDispose();
    takeScreenshot();
    customSize();
    setGetSettings();
    convertToInAppWebView();
  });
}
