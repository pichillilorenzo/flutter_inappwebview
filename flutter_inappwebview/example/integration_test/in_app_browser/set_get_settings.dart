part of 'main.dart';

void setGetSettings() {
  final shouldSkip = !InAppBrowser.isClassSupported();

  skippableTest('set/get settings', () async {
    var inAppBrowser = new MyInAppBrowser();
    await inAppBrowser.openUrlRequest(
      urlRequest: URLRequest(url: TEST_URL_1),
      settings: InAppBrowserClassSettings(
        browserSettings: InAppBrowserSettings(hideToolbarTop: true),
      ),
    );
    await inAppBrowser.browserCreated.future;
    await inAppBrowser.firstPageLoaded.future;

    InAppBrowserClassSettings? settings = await inAppBrowser.getSettings();
    expect(settings, isNotNull);
    expect(settings!.browserSettings.hideToolbarTop, true);

    await inAppBrowser.setSettings(
      settings: InAppBrowserClassSettings(
        browserSettings: InAppBrowserSettings(hideToolbarTop: false),
      ),
    );

    settings = await inAppBrowser.getSettings();
    expect(settings, isNotNull);
    expect(settings!.browserSettings.hideToolbarTop, false);

    await expectLater(inAppBrowser.close(), completes);
  }, skip: shouldSkip);
}
