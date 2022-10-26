import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'custom_menu_item.dart';
import 'custom_tabs.dart';
import 'open_and_close.dart';
import 'trusted_web_activity.dart';
import 'sf_safari_view_controller.dart';

void main() {
  final shouldSkip =
      kIsWeb || [TargetPlatform.macOS].contains(defaultTargetPlatform);

  group('ChromeSafariBrowser', () {
    openAndClose();
    customMenuItem();
    customTabs();
    trustedWebActivity();
    sfSafariViewController();
  }, skip: shouldSkip);
}
