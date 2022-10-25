import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';
import '../util.dart';

void openAndClose() {
  final shouldSkip = kIsWeb
      ? true
      : ![TargetPlatform.android, TargetPlatform.iOS]
          .contains(defaultTargetPlatform);

  test('open and close', () async {
    var chromeSafariBrowser = MyChromeSafariBrowser();
    expect(chromeSafariBrowser.isOpened(), false);

    await chromeSafariBrowser.open(
        url: TEST_URL_1,
        settings: ChromeSafariBrowserSettings(
            shareState: CustomTabsShareState.SHARE_STATE_OFF,
            startAnimations: [
              AndroidResource(
                  name: "slide_in_left",
                  defType: "anim",
                  defPackage: "android"),
              AndroidResource(
                  name: "slide_out_right",
                  defType: "anim",
                  defPackage: "android")
            ],
            exitAnimations: [
              AndroidResource(
                  name: "abc_slide_in_top",
                  defType: "anim",
                  defPackage:
                      "com.pichillilorenzo.flutter_inappwebviewexample"),
              AndroidResource(
                  name: "abc_slide_out_top",
                  defType: "anim",
                  defPackage: "com.pichillilorenzo.flutter_inappwebviewexample")
            ],
            keepAliveEnabled: true,
            dismissButtonStyle: DismissButtonStyle.CLOSE,
            presentationStyle: ModalPresentationStyle.OVER_FULL_SCREEN));
    await chromeSafariBrowser.opened.future;
    expect(chromeSafariBrowser.isOpened(), true);
    expect(() async {
      await chromeSafariBrowser.open(url: TEST_CROSS_PLATFORM_URL_1);
    }, throwsA(isInstanceOf<ChromeSafariBrowserAlreadyOpenedException>()));

    await expectLater(chromeSafariBrowser.firstPageLoaded.future, completes);
    await chromeSafariBrowser.close();
    await chromeSafariBrowser.closed.future;
    expect(chromeSafariBrowser.isOpened(), false);
  }, skip: shouldSkip);
}
