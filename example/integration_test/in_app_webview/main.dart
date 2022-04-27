import 'package:flutter_test/flutter_test.dart';

import 'initial_url_request.dart';
import 'set_get_settings.dart';
import 'javascript_code_evaluation.dart';
import 'load_url.dart';

void main() {
  group('InAppWebView', () {
    initialUrlRequest();
    setGetSettings();
    javascriptCodeEvaluation();
    loadUrl();
  });
}