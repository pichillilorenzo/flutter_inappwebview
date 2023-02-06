import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';
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
    test('custom referrer', () async {
      var chromeSafariBrowser = MyChromeSafariBrowser();
      expect(chromeSafariBrowser.isOpened(), false);

      await chromeSafariBrowser.open(
          url: TEST_URL_1,
          referrer: WebUri("android-app://custom-referrer"),
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
          onClick: (url, title) {}));
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

    test('add and update secondary toolbar', () async {
      var chromeSafariBrowser = MyChromeSafariBrowser();
      chromeSafariBrowser.setSecondaryToolbar(
          ChromeSafariBrowserSecondaryToolbar(
              layout: AndroidResource.layout(
                  name: "remote_view",
                  defPackage:
                      "com.pichillilorenzo.flutter_inappwebviewexample"),
              clickableIDs: [
            ChromeSafariBrowserSecondaryToolbarClickableID(
                id: AndroidResource.id(
                    name: "button1",
                    defPackage:
                        "com.pichillilorenzo.flutter_inappwebviewexample"),
                onClick: (WebUri? url) {
                  print("Button 1 with $url");
                }),
            ChromeSafariBrowserSecondaryToolbarClickableID(
                id: AndroidResource.id(
                    name: "button2",
                    defPackage:
                        "com.pichillilorenzo.flutter_inappwebviewexample"),
                onClick: (WebUri? url) {
                  print("Button 2 with $url");
                }),
          ]));
      expect(chromeSafariBrowser.isOpened(), false);

      await chromeSafariBrowser.open(url: TEST_URL_1);
      await chromeSafariBrowser.opened.future;
      expect(chromeSafariBrowser.isOpened(), true);

      await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
      await chromeSafariBrowser.updateSecondaryToolbar(
          ChromeSafariBrowserSecondaryToolbar(
              layout: AndroidResource.layout(
                  name: "remote_view_2",
                  defPackage:
                      "com.pichillilorenzo.flutter_inappwebviewexample"),
              clickableIDs: [
            ChromeSafariBrowserSecondaryToolbarClickableID(
                id: AndroidResource.id(
                    name: "button3",
                    defPackage:
                        "com.pichillilorenzo.flutter_inappwebviewexample"),
                onClick: (WebUri? url) {
                  print("Button 3 with $url");
                }),
          ]));
      await chromeSafariBrowser.close();
      await chromeSafariBrowser.browserClosed.future;
      expect(chromeSafariBrowser.isOpened(), false);
    });

    test('getMaxToolbarItems', () async {
      expect(await ChromeSafariBrowser.getMaxToolbarItems(),
          greaterThanOrEqualTo(0));
    });
  }, skip: shouldSkip);
}
