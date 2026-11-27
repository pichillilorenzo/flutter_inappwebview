part of 'main.dart';

void setGetDelete() {
  final shouldSkip = !CookieManager.isClassSupported();

  skippableTestWidgets('set, get, delete', (WidgetTester tester) async {
    CookieManager cookieManager = CookieManager.instance();
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
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
          initialSettings: InAppWebViewSettings(clearCache: true),
          onLoadStop: (controller, url) {
            pageLoaded.complete(url!.toString());
          },
        ),
      ),
    );

    final url = WebUri(await pageLoaded.future);

    if (CookieManager.isMethodSupported(
      PlatformCookieManagerMethod.removeSessionCookies,
    )) {
      await cookieManager.setCookie(
        url: url,
        name: "myCookie",
        value: "myValue",
      );
      expect(await cookieManager.removeSessionCookies(), isTrue);
    }

    // Empty cookie-value is allowed according to https://datatracker.ietf.org/doc/html/rfc6265#section-4.1.1
    await cookieManager.setCookie(url: url, name: "myCookie", value: "");
    List<Cookie> cookies = await cookieManager.getCookies(url: url);
    expect(cookies, isNotEmpty);

    Cookie? cookie = await cookieManager.getCookie(url: url, name: "myCookie");
    expect(cookie?.value.toString(), "");

    await cookieManager.setCookie(url: url, name: "myCookie", value: "myValue");
    cookies = await cookieManager.getCookies(url: url);
    expect(cookies, isNotEmpty);

    cookie = await cookieManager.getCookie(url: url, name: "myCookie");
    expect(cookie?.value.toString(), "myValue");

    expect(
      await cookieManager.deleteCookie(url: url, name: "myCookie"),
      isTrue,
    );
    cookie = await cookieManager.getCookie(url: url, name: "myCookie");
    expect(cookie, isNull);

    expect(
      await cookieManager.deleteCookies(
        url: url,
        domain: ".${TEST_CROSS_PLATFORM_URL_1.host}",
      ),
      isTrue,
    );
    cookies = await cookieManager.getCookies(url: url);
    expect(cookies, isEmpty);

    await cookieManager.setCookie(url: url, name: "myCookie", value: "myValue");
    expect(await cookieManager.deleteAllCookies(), isTrue);
    cookies = await cookieManager.getCookies(url: url);
    expect(cookies, isEmpty);
  }, skip: shouldSkip);
}
