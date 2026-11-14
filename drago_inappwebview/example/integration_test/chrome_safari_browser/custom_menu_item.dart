part of 'main.dart';

void customMenuItem() {
  final shouldSkip = !ChromeSafariBrowser.isMethodSupported(
    PlatformChromeSafariBrowserMethod.addMenuItem,
  );

  skippableTest('add custom menu item', () async {
    var chromeSafariBrowser = MyChromeSafariBrowser();
    chromeSafariBrowser.addMenuItem(
      ChromeSafariBrowserMenuItem(
        id: 2,
        label: 'Custom item menu 1',
        image: UIImage(systemName: "pencil"),
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
    await chromeSafariBrowser.close();
    await chromeSafariBrowser.closed.future;
    expect(chromeSafariBrowser.isOpened(), false);
  }, skip: shouldSkip);
}
