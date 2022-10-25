import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';
import '../util.dart';

void customActionButton() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.android,
        ].contains(defaultTargetPlatform);

  test('add custom action button and update icon', () async {
    var chromeSafariBrowser = MyChromeSafariBrowser();
    var actionButtonIcon =
        await rootBundle.load('test_assets/images/flutter-logo.png');
    var actionButtonIcon2 =
        await rootBundle.load('test_assets/images/flutter-logo.jpg');
    chromeSafariBrowser.setActionButton(ChromeSafariBrowserActionButton(
        id: 1,
        description: 'Action Button description',
        icon: actionButtonIcon.buffer.asUint8List(),
        action: (url, title) {}));
    expect(chromeSafariBrowser.isOpened(), false);

    await chromeSafariBrowser.open(url: TEST_URL_1);
    await chromeSafariBrowser.opened.future;
    expect(chromeSafariBrowser.isOpened(), true);
    expect(() async {
      await chromeSafariBrowser.open(url: TEST_CROSS_PLATFORM_URL_1);
    }, throwsA(isInstanceOf<ChromeSafariBrowserAlreadyOpenedException>()));

    await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
    await chromeSafariBrowser.updateActionButton(
        icon: actionButtonIcon2.buffer.asUint8List(),
        description: 'New Action Button description');
    await chromeSafariBrowser.close();
    await chromeSafariBrowser.closed.future;
    expect(chromeSafariBrowser.isOpened(), false);
  }, skip: shouldSkip);
}
