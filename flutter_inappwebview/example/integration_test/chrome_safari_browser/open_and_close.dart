part of 'main.dart';

void openAndClose() {
  final shouldSkip = !ChromeSafariBrowser.isMethodSupported(
    PlatformChromeSafariBrowserMethod.open,
  );

  skippableTest('open and close', () async {
    var chromeSafariBrowser = MyChromeSafariBrowser();
    expect(chromeSafariBrowser.isOpened(), false);

    await chromeSafariBrowser.open(
      url: TEST_URL_1,
      settings: ChromeSafariBrowserSettings(
        shareState: CustomTabsShareState.SHARE_STATE_OFF,
        startAnimations: [
          AndroidResource.anim(name: "slide_in_left", defPackage: "android"),
          AndroidResource.anim(name: "slide_out_right", defPackage: "android"),
        ],
        exitAnimations: [
          AndroidResource.anim(
            name: "abc_slide_in_top",
            defPackage: "com.pichillilorenzo.flutter_inappwebviewexample",
          ),
          AndroidResource.anim(
            name: "abc_slide_out_top",
            defPackage: "com.pichillilorenzo.flutter_inappwebviewexample",
          ),
        ],
        keepAliveEnabled: true,
        dismissButtonStyle: DismissButtonStyle.CLOSE,
        presentationStyle: ModalPresentationStyle.OVER_FULL_SCREEN,
        eventAttribution: UIEventAttribution(
          sourceIdentifier: 4,
          destinationURL: WebUri("https://shop.example/test.html"),
          sourceDescription: "Banner ad for Test.",
          purchaser: "Shop Example, Inc.",
        ),
        activityButton: ActivityButton(
          templateImage: UIImage(systemName: "sun.max"),
          extensionIdentifier:
              "com.pichillilorenzo.flutterinappwebview-ios-example5.test",
        ),
      ),
    );
    await chromeSafariBrowser.opened.future;
    expect(chromeSafariBrowser.isOpened(), true);
    expect(() async {
      await chromeSafariBrowser.open(url: TEST_CROSS_PLATFORM_URL_1);
    }, throwsAssertionError);

    await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
    await chromeSafariBrowser.close();
    await chromeSafariBrowser.closed.future;
    expect(chromeSafariBrowser.isOpened(), false);
  }, skip: shouldSkip);
}
