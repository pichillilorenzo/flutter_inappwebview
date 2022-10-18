import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'open_data_and_close.dart';
import 'open_file_and_close.dart';
import 'open_url_and_close.dart';
import 'set_get_settings.dart';
import 'hide_and_show.dart';

void main() {
  final shouldSkip = kIsWeb;

  group('InAppBrowser', () {
    openUrlAndClose();
    openFileAndClose();
    openDataAndClose();
    setGetSettings();
    hideAndShow();
  }, skip: shouldSkip);
}
