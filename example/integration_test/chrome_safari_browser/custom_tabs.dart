import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';
import '../util.dart';

void customTabs() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.android,
        ].contains(defaultTargetPlatform);

  group('Custom Tabs', () {
    test('single instance', () async {
      var chromeSafariBrowser = MyChromeSafariBrowser();
      expect(chromeSafariBrowser.isOpened(), false);

      await chromeSafariBrowser.open(
          url: TEST_URL_1,
          settings: ChromeSafariBrowserSettings(isSingleInstance: true));
      await expectLater(chromeSafariBrowser.opened.future, completes);
      expect(chromeSafariBrowser.isOpened(), true);
      expect(() async {
        await chromeSafariBrowser.open(url: TEST_CROSS_PLATFORM_URL_1);
      }, throwsA(isInstanceOf<ChromeSafariBrowserAlreadyOpenedException>()));

      await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
      await chromeSafariBrowser.close();
      await expectLater(chromeSafariBrowser.closed.future, completes);
      expect(chromeSafariBrowser.isOpened(), false);
    });

    test('mayLaunchUrl and launchUrl', () async {
      var chromeSafariBrowser = MyChromeSafariBrowser();
      expect(chromeSafariBrowser.isOpened(), false);

      await chromeSafariBrowser.open();
      await expectLater(chromeSafariBrowser.serviceConnected.future, completes);
      expect(chromeSafariBrowser.isOpened(), true);
      expect(
          await chromeSafariBrowser.mayLaunchUrl(
              url: TEST_URL_1, otherLikelyURLs: [TEST_CROSS_PLATFORM_URL_1]),
          true);
      await chromeSafariBrowser.launchUrl(
          url: TEST_URL_1,
          headers: {'accept-language': 'it-IT'},
          otherLikelyURLs: [TEST_CROSS_PLATFORM_URL_1]);
      await expectLater(chromeSafariBrowser.opened.future, completes);
      await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
      await chromeSafariBrowser.close();
      await expectLater(chromeSafariBrowser.closed.future, completes);
      expect(chromeSafariBrowser.isOpened(), false);
    });

    test('onNavigationEvent', () async {
      var chromeSafariBrowser = MyChromeSafariBrowser();
      expect(chromeSafariBrowser.isOpened(), false);

      await chromeSafariBrowser.open(url: TEST_URL_1);
      await expectLater(chromeSafariBrowser.opened.future, completes);
      expect(chromeSafariBrowser.isOpened(), true);
      await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
      expect(await chromeSafariBrowser.navigationEvent.future, isNotNull);
      await chromeSafariBrowser.close();
      await expectLater(chromeSafariBrowser.closed.future, completes);
      expect(chromeSafariBrowser.isOpened(), false);
    });
  }, skip: shouldSkip);
}
