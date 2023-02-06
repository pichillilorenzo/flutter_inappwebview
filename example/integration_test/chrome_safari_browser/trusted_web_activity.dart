import 'package:flutter/foundation.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';
import '../util.dart';

void trustedWebActivity() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.android,
        ].contains(defaultTargetPlatform);

  group('Trusted Web Activity', () {
    test('basic', () async {
      var chromeSafariBrowser = MyChromeSafariBrowser();
      expect(chromeSafariBrowser.isOpened(), false);

      await chromeSafariBrowser.open(
          url: TEST_URL_1,
          settings: ChromeSafariBrowserSettings(isTrustedWebActivity: true));
      await chromeSafariBrowser.opened.future;
      expect(chromeSafariBrowser.isOpened(), true);
      expect(() async {
        await chromeSafariBrowser.open(url: TEST_CROSS_PLATFORM_URL_1);
      }, throwsA(isInstanceOf<ChromeSafariBrowserAlreadyOpenedException>()));

      await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
      await chromeSafariBrowser.close();
      await chromeSafariBrowser.closed.future;
      expect(chromeSafariBrowser.isOpened(), false);
    });

    test('single instance', () async {
      var chromeSafariBrowser = MyChromeSafariBrowser();
      expect(chromeSafariBrowser.isOpened(), false);

      await chromeSafariBrowser.open(
          url: TEST_URL_1,
          settings: ChromeSafariBrowserSettings(
              isTrustedWebActivity: true, isSingleInstance: true));
      await chromeSafariBrowser.opened.future;
      expect(chromeSafariBrowser.isOpened(), true);
      expect(() async {
        await chromeSafariBrowser.open(url: TEST_CROSS_PLATFORM_URL_1);
      }, throwsA(isInstanceOf<ChromeSafariBrowserAlreadyOpenedException>()));

      await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
      await chromeSafariBrowser.close();
      await chromeSafariBrowser.closed.future;
      expect(chromeSafariBrowser.isOpened(), false);
    });

    test('validate relationship', () async {
      var chromeSafariBrowser = MyChromeSafariBrowser();
      expect(chromeSafariBrowser.isOpened(), false);

      await chromeSafariBrowser.open(
          settings: ChromeSafariBrowserSettings(isTrustedWebActivity: true));
      await chromeSafariBrowser.serviceConnected.future;
      expect(
          await chromeSafariBrowser.validateRelationship(
              relation: CustomTabsRelationType.USE_AS_ORIGIN,
              origin: TEST_CROSS_PLATFORM_URL_1),
          true);
      expect(
          await chromeSafariBrowser.relationshipValidationResult.future, true);
      await chromeSafariBrowser.launchUrl(url: TEST_CROSS_PLATFORM_URL_1);
      await chromeSafariBrowser.opened.future;
      expect(chromeSafariBrowser.isOpened(), true);
      await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
      await chromeSafariBrowser.close();
      await chromeSafariBrowser.closed.future;
      expect(chromeSafariBrowser.isOpened(), false);
    });
  }, skip: shouldSkip);
}
