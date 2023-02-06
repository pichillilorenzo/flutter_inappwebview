import 'package:flutter/foundation.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';
import '../util.dart';

void hideAndShow() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  test('hide and show', () async {
    var inAppBrowser = new MyInAppBrowser();
    await inAppBrowser.openUrlRequest(
        urlRequest: URLRequest(url: TEST_URL_1),
        settings: InAppBrowserClassSettings(
            browserSettings: InAppBrowserSettings(hidden: true)));
    await inAppBrowser.browserCreated.future;
    await inAppBrowser.firstPageLoaded.future;

    expect(await inAppBrowser.isHidden(), true);
    await expectLater(inAppBrowser.show(), completes);
    expect(await inAppBrowser.isHidden(), false);
    await expectLater(inAppBrowser.hide(), completes);
    expect(await inAppBrowser.isHidden(), true);
  }, skip: shouldSkip);
}
