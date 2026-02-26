part of 'main.dart';

void customMenuItems() {
  final shouldSkip = !InAppBrowser.isClassSupported();

  skippableTest('custom menu items', () async {
    var inAppBrowser = new MyInAppBrowser();

    final data = (await rootBundle.load(
      'test_assets/images/flutter-logo.png',
    )).buffer.asUint8List();

    inAppBrowser.addMenuItem(
      InAppBrowserMenuItem(
        id: 0,
        title: 'Menu Item 0',
        iconColor: Colors.black,
        order: 0,
        onClick: () {
          inAppBrowser.webViewController?.reload();
        },
      ),
    );
    inAppBrowser.addMenuItem(
      InAppBrowserMenuItem(
        id: 1,
        title: 'Menu Item 1',
        icon: data,
        showAsAction: true,
        order: 2,
        onClick: () {
          inAppBrowser.webViewController?.reload();
        },
      ),
    );

    var icon = null;
    if ([
      TargetPlatform.iOS,
      TargetPlatform.macOS,
    ].contains(defaultTargetPlatform)) {
      icon = UIImage(systemName: 'ellipsis.circle');
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      icon = AndroidResource.drawable(
        name: 'ic_menu_edit',
        defPackage: 'android',
      );
    }
    inAppBrowser.addMenuItem(
      InAppBrowserMenuItem(
        id: 2,
        title: 'Menu Item 2',
        icon: icon,
        iconColor: Colors.red,
        showAsAction: true,
        order: 1,
        onClick: () {
          inAppBrowser.webViewController?.reload();
        },
      ),
    );

    await inAppBrowser.openUrlRequest(
      urlRequest: URLRequest(url: TEST_URL_1),
      settings: InAppBrowserClassSettings(
        browserSettings: InAppBrowserSettings(hideDefaultMenuItems: true),
      ),
    );
    await inAppBrowser.browserCreated.future;
    await inAppBrowser.firstPageLoaded.future;

    await expectLater(inAppBrowser.close(), completes);
  }, skip: shouldSkip);
}
