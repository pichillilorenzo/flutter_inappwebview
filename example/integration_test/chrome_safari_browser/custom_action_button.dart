import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';
import '../util.dart';

void customActionButton() {
  final shouldSkip = kIsWeb ||
      ![
        TargetPlatform.android,
      ].contains(defaultTargetPlatform);

  test('add custom action button', () async {
    var chromeSafariBrowser = new MyChromeSafariBrowser();
    var actionButtonIcon =
    await rootBundle.load('test_assets/images/flutter-logo.png');
    chromeSafariBrowser.setActionButton(ChromeSafariBrowserActionButton(
        id: 1,
        description: 'Action Button description',
        icon: actionButtonIcon.buffer.asUint8List(),
        action: (url, title) {
          print('Action Button 1 clicked!');
        }));
    expect(chromeSafariBrowser.isOpened(), false);

    await chromeSafariBrowser.open(
        url: TEST_URL_1);
    await chromeSafariBrowser.browserCreated.future;
    expect(chromeSafariBrowser.isOpened(), true);
    expect(() async {
      await chromeSafariBrowser.open(url: TEST_CROSS_PLATFORM_URL_1);
    }, throwsA(isInstanceOf<ChromeSafariBrowserAlreadyOpenedException>()));

    await expectLater(
        chromeSafariBrowser.firstPageLoaded.future, completes);
    await chromeSafariBrowser.close();
    await chromeSafariBrowser.browserClosed.future;
    expect(chromeSafariBrowser.isOpened(), false);
  }, skip: shouldSkip);
}
