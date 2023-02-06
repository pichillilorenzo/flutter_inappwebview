import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';
import '../util.dart';

void customActionButton() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.android,
        ].contains(defaultTargetPlatform);

  test('add custom action button', () async {
    var chromeSafariBrowser = MyChromeSafariBrowser();
    var actionButtonIcon =
        await rootBundle.load('test_assets/images/flutter-logo.png');
    chromeSafariBrowser.setActionButton(ChromeSafariBrowserActionButton(
        id: 1,
        description: 'Action Button description',
        icon: actionButtonIcon.buffer.asUint8List(),
        action: (url, title) {}));
    expect(chromeSafariBrowser.isOpened(), false);

    await chromeSafariBrowser.open(url: TEST_URL_1);
    await chromeSafariBrowser.browserCreated.future;
    expect(chromeSafariBrowser.isOpened(), true);
    expect(() async {
      await chromeSafariBrowser.open(url: TEST_CROSS_PLATFORM_URL_1);
    }, throwsA(isInstanceOf<ChromeSafariBrowserAlreadyOpenedException>()));

    await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
    await chromeSafariBrowser.close();
    await chromeSafariBrowser.browserClosed.future;
    expect(chromeSafariBrowser.isOpened(), false);
  }, skip: shouldSkip);
}
