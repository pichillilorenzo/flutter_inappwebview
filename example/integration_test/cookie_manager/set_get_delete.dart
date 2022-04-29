import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void setGetDelete() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  testWidgets('set, get, delete', (WidgetTester tester) async {
    CookieManager cookieManager = CookieManager.instance();
    final Completer controllerCompleter = Completer<InAppWebViewController>();
    final Completer<String> pageLoaded = Completer<String>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_CROSS_PLATFORM_URL_1),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          initialSettings: InAppWebViewSettings(
            clearCache: true,
          ),
          onLoadStop: (controller, url) {
            pageLoaded.complete(url!.toString());
          },
        ),
      ),
    );

    final url = Uri.parse(await pageLoaded.future);

    await cookieManager.setCookie(url: url, name: "myCookie", value: "myValue");
    List<Cookie> cookies = await cookieManager.getCookies(url: url);
    expect(cookies, isNotEmpty);

    Cookie? cookie = await cookieManager.getCookie(url: url, name: "myCookie");
    expect(cookie?.value.toString(), "myValue");

    await cookieManager.deleteCookie(url: url, name: "myCookie");
    cookie = await cookieManager.getCookie(url: url, name: "myCookie");
    expect(cookie, isNull);

    await cookieManager.deleteCookies(url: url);
    cookies = await cookieManager.getCookies(url: url);
    expect(cookies, isEmpty);
  }, skip: shouldSkip);
}
