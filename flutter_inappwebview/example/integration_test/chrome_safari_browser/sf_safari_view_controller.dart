part of 'main.dart';

void sfSafariViewController() {
  final shouldSkip = !ChromeSafariBrowser.isMethodSupported(
    PlatformChromeSafariBrowserMethod.prewarmConnections,
  );

  skippableGroup('SF Safari View Controller', () {
    skippableTest('onCompletedInitialLoad did load successfully', () async {
      var chromeSafariBrowser = MyChromeSafariBrowser();
      expect(chromeSafariBrowser.isOpened(), false);

      await chromeSafariBrowser.open(url: TEST_URL_1);
      await expectLater(chromeSafariBrowser.opened.future, completes);
      expect(chromeSafariBrowser.isOpened(), true);
      expect(() async {
        await chromeSafariBrowser.open(url: TEST_CROSS_PLATFORM_URL_1);
      }, throwsAssertionError);

      expect(await chromeSafariBrowser.firstPageLoaded.future, true);
      await chromeSafariBrowser.close();
      await expectLater(chromeSafariBrowser.closed.future, completes);
      expect(chromeSafariBrowser.isOpened(), false);
    });

    // TODO: this test takes a lot of time to complete. Tested on iOS 16.0.
    // skippableTest('clearWebsiteData', () async {
    //   await expectLater(ChromeSafariBrowser.clearWebsiteData(), completes);
    // });

    skippableTest('create and invalidate Prewarming Token', () async {
      final prewarmingToken = await ChromeSafariBrowser.prewarmConnections([
        TEST_URL_1,
      ]);
      expect(prewarmingToken, isNotNull);
      await expectLater(
        ChromeSafariBrowser.invalidatePrewarmingToken(prewarmingToken!),
        completes,
      );
    });
  }, skip: shouldSkip);
}
