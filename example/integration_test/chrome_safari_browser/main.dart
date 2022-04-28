import 'package:flutter_test/flutter_test.dart';

import 'custom_action_button.dart';
import 'custom_menu_item.dart';
import 'custom_tabs.dart';
import 'open_and_close.dart';
import 'trusted_web_activity.dart';

void main() {
  group('ChromeSafariBrowser', () {
    openAndClose();
    customMenuItem();
    customActionButton();
    customTabs();
    trustedWebActivity();
  });
}
