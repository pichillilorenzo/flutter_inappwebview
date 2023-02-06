import 'package:flutter/foundation.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';
import '../util.dart';

void sfSafariViewController() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.iOS,
        ].contains(defaultTargetPlatform);

  group('SF Safari View Controller', () {
    test('onCompletedInitialLoad did load successfully', () async {
      var chromeSafariBrowser = MyChromeSafariBrowser();
      expect(chromeSafariBrowser.isOpened(), false);

      await chromeSafariBrowser.open(url: TEST_URL_1);
      await expectLater(chromeSafariBrowser.opened.future, completes);
      expect(chromeSafariBrowser.isOpened(), true);
      expect(() async {
        await chromeSafariBrowser.open(url: TEST_CROSS_PLATFORM_URL_1);
      }, throwsA(isInstanceOf<ChromeSafariBrowserAlreadyOpenedException>()));

      expect(await chromeSafariBrowser.firstPageLoaded.future, true);
      await chromeSafariBrowser.close();
      await expectLater(chromeSafariBrowser.closed.future, completes);
      expect(chromeSafariBrowser.isOpened(), false);
    });

    // TODO: this test takes a lot of time to complete. Tested on iOS 16.0.
    // test('clearWebsiteData', () async {
    //   await expectLater(ChromeSafariBrowser.clearWebsiteData(), completes);
    // });

    test('create and invalidate Prewarming Token', () async {
      final prewarmingToken =
          await ChromeSafariBrowser.prewarmConnections([TEST_URL_1]);
      expect(prewarmingToken, isNotNull);
      await expectLater(
          ChromeSafariBrowser.invalidatePrewarmingToken(prewarmingToken!),
          completes);
    });
  }, skip: shouldSkip);
}
