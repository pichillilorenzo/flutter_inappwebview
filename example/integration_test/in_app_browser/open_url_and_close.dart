import 'package:flutter/foundation.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';
import '../util.dart';

void openUrlAndClose() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  test('open url and close', () async {
    var inAppBrowser = new MyInAppBrowser();
    expect(inAppBrowser.isOpened(), false);
    expect(() async {
      await inAppBrowser.show();
    }, throwsA(isInstanceOf<InAppBrowserNotOpenedException>()));

    await inAppBrowser.openUrlRequest(urlRequest: URLRequest(url: TEST_URL_1));
    await inAppBrowser.browserCreated.future;
    expect(inAppBrowser.isOpened(), true);
    expect(() async {
      await inAppBrowser.openUrlRequest(
          urlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1));
    }, throwsA(isInstanceOf<InAppBrowserAlreadyOpenedException>()));

    await inAppBrowser.firstPageLoaded.future;
    var controller = inAppBrowser.webViewController;

    expect(controller, isNotNull);
    final String? url = (await controller!.getUrl())?.toString();
    expect(url, TEST_URL_1.toString());

    await inAppBrowser.close();
    expect(inAppBrowser.isOpened(), false);
    expect(inAppBrowser.webViewController, isNull);
  }, skip: shouldSkip);
}
