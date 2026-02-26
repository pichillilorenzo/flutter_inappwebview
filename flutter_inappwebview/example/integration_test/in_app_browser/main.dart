import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import '../constants.dart';
import '../util.dart';

part 'supported.dart';
part 'open_data_and_close.dart';
part 'open_file_and_close.dart';
part 'open_url_and_close.dart';
part 'set_get_settings.dart';
part 'hide_and_show.dart';
part 'custom_menu_items.dart';

void main() {
  final shouldSkip = !InAppBrowser.isClassSupported();

  skippableGroup('InAppBrowser', () {
    supported();
    openUrlAndClose();
    openFileAndClose();
    openDataAndClose();
    setGetSettings();
    hideAndShow();
    customMenuItems();
  }, skip: shouldSkip);
}
