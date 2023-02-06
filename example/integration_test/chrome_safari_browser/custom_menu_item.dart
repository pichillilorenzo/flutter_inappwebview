import 'package:flutter/foundation.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';
import '../util.dart';

void customMenuItem() {
  final shouldSkip = kIsWeb
      ? true
      : ![TargetPlatform.android, TargetPlatform.iOS]
          .contains(defaultTargetPlatform);

  test('add custom menu item', () async {
    var chromeSafariBrowser = MyChromeSafariBrowser();
    chromeSafariBrowser.addMenuItem(ChromeSafariBrowserMenuItem(
        id: 2,
        label: 'Custom item menu 1',
        image: UIImage(systemName: "pencil"),
        onClick: (url, title) {}));
    expect(chromeSafariBrowser.isOpened(), false);

    await chromeSafariBrowser.open(url: TEST_URL_1);
    await chromeSafariBrowser.opened.future;
    expect(chromeSafariBrowser.isOpened(), true);
    expect(() async {
      await chromeSafariBrowser.open(url: TEST_CROSS_PLATFORM_URL_1);
    }, throwsA(isInstanceOf<ChromeSafariBrowserAlreadyOpenedException>()));

    await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
    await chromeSafariBrowser.close();
    await chromeSafariBrowser.closed.future;
    expect(chromeSafariBrowser.isOpened(), false);
  }, skip: shouldSkip);
}
