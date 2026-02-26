part of 'main.dart';

void trustedWebActivity() {
  final shouldSkip = !ChromeSafariBrowser.isMethodSupported(
    PlatformChromeSafariBrowserMethod.validateRelationship,
  );

  skippableGroup('Trusted Web Activity', () {
    skippableTest('basic', () async {
      var chromeSafariBrowser = MyChromeSafariBrowser();
      expect(chromeSafariBrowser.isOpened(), false);

      await chromeSafariBrowser.open(
        url: TEST_TWA_URL,
        settings: ChromeSafariBrowserSettings(isTrustedWebActivity: true),
      );
      await chromeSafariBrowser.opened.future;
      expect(chromeSafariBrowser.isOpened(), true);
      expect(() async {
        await chromeSafariBrowser.open(url: TEST_TWA_URL);
      }, throwsAssertionError);

      await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
      await chromeSafariBrowser.close();
      await chromeSafariBrowser.closed.future;
      expect(chromeSafariBrowser.isOpened(), false);
    });

    skippableTest('single instance', () async {
      var chromeSafariBrowser = MyChromeSafariBrowser();
      expect(chromeSafariBrowser.isOpened(), false);

      await chromeSafariBrowser.open(
        url: TEST_TWA_URL,
        settings: ChromeSafariBrowserSettings(
          isTrustedWebActivity: true,
          isSingleInstance: true,
        ),
      );
      await chromeSafariBrowser.opened.future;
      expect(chromeSafariBrowser.isOpened(), true);
      expect(() async {
        await chromeSafariBrowser.open(url: TEST_TWA_URL);
      }, throwsAssertionError);

      await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
      await chromeSafariBrowser.close();
      await chromeSafariBrowser.closed.future;
      expect(chromeSafariBrowser.isOpened(), false);
    });

    skippableTest('validate relationship', () async {
      var chromeSafariBrowser = MyChromeSafariBrowser();
      expect(chromeSafariBrowser.isOpened(), false);

      await chromeSafariBrowser.open(
        settings: ChromeSafariBrowserSettings(isTrustedWebActivity: true),
      );
      await chromeSafariBrowser.serviceConnected.future;
      expect(
        await chromeSafariBrowser.validateRelationship(
          relation: CustomTabsRelationType.USE_AS_ORIGIN,
          origin: TEST_TWA_URL,
        ),
        true,
      );
      expect(
        await chromeSafariBrowser.relationshipValidationResult.future,
        true,
      );
      await chromeSafariBrowser.launchUrl(url: TEST_TWA_URL);
      await chromeSafariBrowser.opened.future;
      expect(chromeSafariBrowser.isOpened(), true);
      await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
      await chromeSafariBrowser.close();
      await chromeSafariBrowser.closed.future;
      expect(chromeSafariBrowser.isOpened(), false);
    });
  }, skip: shouldSkip);
}
