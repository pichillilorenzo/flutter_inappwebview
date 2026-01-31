part of 'main.dart';

void customTabs() {
  final shouldSkip = !ChromeSafariBrowser.isMethodSupported(
    PlatformChromeSafariBrowserMethod.launchUrl,
  );

  skippableGroup('Custom Tabs', () {
    skippableTest('custom referrer', () async {
      var chromeSafariBrowser = MyChromeSafariBrowser();
      expect(chromeSafariBrowser.isOpened(), false);

      await chromeSafariBrowser.open(
        url: TEST_URL_1,
        referrer: WebUri("android-app://custom-referrer"),
        settings: ChromeSafariBrowserSettings(isSingleInstance: true),
      );
      await expectLater(chromeSafariBrowser.opened.future, completes);
      expect(chromeSafariBrowser.isOpened(), true);
      expect(() async {
        await chromeSafariBrowser.open(url: TEST_CROSS_PLATFORM_URL_1);
      }, throwsAssertionError);

      await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
      await chromeSafariBrowser.close();
      await expectLater(chromeSafariBrowser.closed.future, completes);
      expect(chromeSafariBrowser.isOpened(), false);
    });

    skippableTest('single instance', () async {
      var chromeSafariBrowser = MyChromeSafariBrowser();
      expect(chromeSafariBrowser.isOpened(), false);

      await chromeSafariBrowser.open(
        url: TEST_URL_1,
        settings: ChromeSafariBrowserSettings(isSingleInstance: true),
      );
      await expectLater(chromeSafariBrowser.opened.future, completes);
      expect(chromeSafariBrowser.isOpened(), true);
      expect(() async {
        await chromeSafariBrowser.open(url: TEST_CROSS_PLATFORM_URL_1);
      }, throwsAssertionError);

      await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
      await chromeSafariBrowser.close();
      await expectLater(chromeSafariBrowser.closed.future, completes);
      expect(chromeSafariBrowser.isOpened(), false);
    });

    skippableTest('add custom action button and update icon', () async {
      var chromeSafariBrowser = MyChromeSafariBrowser();
      var actionButtonIcon = await rootBundle.load(
        'test_assets/images/flutter-logo.png',
      );
      var actionButtonIcon2 = await rootBundle.load(
        'test_assets/images/flutter-logo.jpg',
      );
      chromeSafariBrowser.setActionButton(
        ChromeSafariBrowserActionButton(
          id: 1,
          description: 'Action Button description',
          icon: actionButtonIcon.buffer.asUint8List(),
          onClick: (url, title) {},
        ),
      );
      expect(chromeSafariBrowser.isOpened(), false);

      await chromeSafariBrowser.open(url: TEST_URL_1);
      await chromeSafariBrowser.opened.future;
      expect(chromeSafariBrowser.isOpened(), true);
      expect(() async {
        await chromeSafariBrowser.open(url: TEST_CROSS_PLATFORM_URL_1);
      }, throwsAssertionError);

      await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
      await chromeSafariBrowser.updateActionButton(
        icon: actionButtonIcon2.buffer.asUint8List(),
        description: 'New Action Button description',
      );
      await chromeSafariBrowser.close();
      await chromeSafariBrowser.closed.future;
      expect(chromeSafariBrowser.isOpened(), false);
    }, skip: shouldSkip);

    skippableTest('mayLaunchUrl and launchUrl', () async {
      var chromeSafariBrowser = MyChromeSafariBrowser();
      expect(chromeSafariBrowser.isOpened(), false);

      await chromeSafariBrowser.open();
      await expectLater(chromeSafariBrowser.serviceConnected.future, completes);
      expect(chromeSafariBrowser.isOpened(), true);
      expect(
        await chromeSafariBrowser.mayLaunchUrl(
          url: TEST_URL_1,
          otherLikelyURLs: [TEST_CROSS_PLATFORM_URL_1],
        ),
        true,
      );
      await chromeSafariBrowser.launchUrl(
        url: TEST_URL_1,
        headers: {'accept-language': 'it-IT'},
        otherLikelyURLs: [TEST_CROSS_PLATFORM_URL_1],
      );
      await expectLater(chromeSafariBrowser.opened.future, completes);
      await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
      await chromeSafariBrowser.close();
      await expectLater(chromeSafariBrowser.closed.future, completes);
      expect(chromeSafariBrowser.isOpened(), false);
    });

    skippableTest('onNavigationEvent', () async {
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

    skippableTest('add and update secondary toolbar', () async {
      var chromeSafariBrowser = MyChromeSafariBrowser();
      chromeSafariBrowser.setSecondaryToolbar(
        ChromeSafariBrowserSecondaryToolbar(
          layout: AndroidResource.layout(
            name: "remote_view",
            defPackage: "com.pichillilorenzo.flutter_inappwebviewexample",
          ),
          clickableIDs: [
            ChromeSafariBrowserSecondaryToolbarClickableID(
              id: AndroidResource.id(
                name: "button1",
                defPackage: "com.pichillilorenzo.flutter_inappwebviewexample",
              ),
              onClick: (WebUri? url) {
                print("Button 1 with $url");
              },
            ),
            ChromeSafariBrowserSecondaryToolbarClickableID(
              id: AndroidResource.id(
                name: "button2",
                defPackage: "com.pichillilorenzo.flutter_inappwebviewexample",
              ),
              onClick: (WebUri? url) {
                print("Button 2 with $url");
              },
            ),
          ],
        ),
      );
      expect(chromeSafariBrowser.isOpened(), false);

      await chromeSafariBrowser.open(url: TEST_URL_1);
      await chromeSafariBrowser.opened.future;
      expect(chromeSafariBrowser.isOpened(), true);

      await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
      await chromeSafariBrowser.updateSecondaryToolbar(
        ChromeSafariBrowserSecondaryToolbar(
          layout: AndroidResource.layout(
            name: "remote_view_2",
            defPackage: "com.pichillilorenzo.flutter_inappwebviewexample",
          ),
          clickableIDs: [
            ChromeSafariBrowserSecondaryToolbarClickableID(
              id: AndroidResource.id(
                name: "button3",
                defPackage: "com.pichillilorenzo.flutter_inappwebviewexample",
              ),
              onClick: (WebUri? url) {
                print("Button 3 with $url");
              },
            ),
          ],
        ),
      );
      await chromeSafariBrowser.close();
      await chromeSafariBrowser.closed.future;
      expect(chromeSafariBrowser.isOpened(), false);
    });

    skippableTest('request and send post messages', () async {
      var chromeSafariBrowser = MyChromeSafariBrowser();
      expect(chromeSafariBrowser.isOpened(), false);

      await chromeSafariBrowser.open(
        url: TEST_CUSTOM_TABS_POST_MESSAGE_URL,
        settings: ChromeSafariBrowserSettings(isSingleInstance: true),
      );
      await expectLater(chromeSafariBrowser.opened.future, completes);
      expect(chromeSafariBrowser.isOpened(), true);

      await expectLater(
        chromeSafariBrowser.navigationFinished.future,
        completes,
      );
      expect(
        await chromeSafariBrowser.requestPostMessageChannel(
          sourceOrigin: WebUri(TEST_CUSTOM_TABS_POST_MESSAGE_URL.origin),
        ),
        true,
      );
      await expectLater(
        chromeSafariBrowser.messageChannelReady.future,
        completes,
      );
      expect(
        await chromeSafariBrowser.postMessage("Message from Flutter"),
        CustomTabsPostMessageResultType.SUCCESS,
      );
      await expectLater(
        chromeSafariBrowser.postMessageReceived.future,
        completion("Message from JavaScript"),
      );

      await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
      await chromeSafariBrowser.close();
      await expectLater(chromeSafariBrowser.closed.future, completes);
      expect(chromeSafariBrowser.isOpened(), false);
    });

    skippableTest('Engagement Signals Api', () async {
      var chromeSafariBrowser = MyChromeSafariBrowser();
      expect(chromeSafariBrowser.isOpened(), false);

      await chromeSafariBrowser.open(
        url: TEST_URL_1,
        settings: ChromeSafariBrowserSettings(isSingleInstance: true),
      );
      await expectLater(chromeSafariBrowser.opened.future, completes);

      await expectLater(
        chromeSafariBrowser.isEngagementSignalsApiAvailable(),
        completes,
      );

      await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
      await chromeSafariBrowser.close();
      await expectLater(chromeSafariBrowser.closed.future, completes);
      expect(chromeSafariBrowser.isOpened(), false);
    });

    skippableTest('getMaxToolbarItems', () async {
      expect(
        await ChromeSafariBrowser.getMaxToolbarItems(),
        greaterThanOrEqualTo(0),
      );
    });

    skippableTest('getPackageName', () async {
      expect(await ChromeSafariBrowser.getPackageName(), isNotNull);
    });
  }, skip: shouldSkip);
}
