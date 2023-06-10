import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import '../constants.dart';
import '../util.dart';

part 'custom_menu_item.dart';
part 'custom_tabs.dart';
part 'open_and_close.dart';
part 'trusted_web_activity.dart';
part 'sf_safari_view_controller.dart';

void main() {
  final shouldSkip =
      kIsWeb || [TargetPlatform.macOS].contains(defaultTargetPlatform);

  skippableGroup('ChromeSafariBrowser', () {
    openAndClose();
    customMenuItem();
    customTabs();
    trustedWebActivity();
    sfSafariViewController();
  }, skip: shouldSkip);
}
