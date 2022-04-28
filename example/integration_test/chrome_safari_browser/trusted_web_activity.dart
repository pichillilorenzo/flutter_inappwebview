import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';
import '../util.dart';

void trustedWebActivity() {
  final shouldSkip = kIsWeb ||
      ![
        TargetPlatform.android,
      ].contains(defaultTargetPlatform);

  group('Trusted Web Activity', () async {
    test('basic', () async {
      var chromeSafariBrowser = new MyChromeSafariBrowser();
      expect(chromeSafariBrowser.isOpened(), false);

      await chromeSafariBrowser.open(
          url: TEST_URL_1,
          settings: ChromeSafariBrowserSettings(isTrustedWebActivity: true));
      await chromeSafariBrowser.browserCreated.future;
      expect(chromeSafariBrowser.isOpened(), true);
      expect(() async {
        await chromeSafariBrowser.open(url: TEST_CROSS_PLATFORM_URL_1);
      }, throwsA(isInstanceOf<ChromeSafariBrowserAlreadyOpenedException>()));

      await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
      await chromeSafariBrowser.close();
      await chromeSafariBrowser.browserClosed.future;
      expect(chromeSafariBrowser.isOpened(), false);
    });

    test('single instance', () async {
      var chromeSafariBrowser = new MyChromeSafariBrowser();
      expect(chromeSafariBrowser.isOpened(), false);

      await chromeSafariBrowser.open(
          url: TEST_URL_1,
          settings: ChromeSafariBrowserSettings(
              isTrustedWebActivity: true, isSingleInstance: true));
      await chromeSafariBrowser.browserCreated.future;
      expect(chromeSafariBrowser.isOpened(), true);
      expect(() async {
        await chromeSafariBrowser.open(url: TEST_CROSS_PLATFORM_URL_1);
      }, throwsA(isInstanceOf<ChromeSafariBrowserAlreadyOpenedException>()));

      await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
      await chromeSafariBrowser.close();
      await chromeSafariBrowser.browserClosed.future;
      expect(chromeSafariBrowser.isOpened(), false);
    });
  }, skip: shouldSkip);
}
