part of 'main.dart';

void hideAndShow() {
  final shouldSkip = !InAppBrowser.isClassSupported();

  skippableTest('hide and show', () async {
    var inAppBrowser = new MyInAppBrowser();
    await inAppBrowser.openUrlRequest(
      urlRequest: URLRequest(url: TEST_URL_1),
      settings: InAppBrowserClassSettings(
        browserSettings: InAppBrowserSettings(hidden: true),
      ),
    );
    await inAppBrowser.browserCreated.future;
    await inAppBrowser.firstPageLoaded.future;

    expect(await inAppBrowser.isHidden(), true);
    await expectLater(inAppBrowser.show(), completes);
    expect(await inAppBrowser.isHidden(), false);
    await expectLater(inAppBrowser.hide(), completes);
    expect(await inAppBrowser.isHidden(), true);

    await expectLater(inAppBrowser.close(), completes);
  }, skip: shouldSkip);
}
