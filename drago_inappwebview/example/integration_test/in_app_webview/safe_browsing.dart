part of 'main.dart';

void safeBrowsing() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.onSafeBrowsingHit,
  );

  skippableGroup('safe browsing', () {
    skippableTestWidgets('onSafeBrowsingHit', (WidgetTester tester) async {
      final Completer<String> pageLoaded = Completer<String>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(
              url: TEST_CHROME_SAFE_BROWSING_MALWARE,
            ),
            initialSettings: InAppWebViewSettings(
              // if I set javaScriptEnabled to true, it will crash!
              javaScriptEnabled: false,
              clearCache: true,
              safeBrowsingEnabled: true,
            ),
            onWebViewCreated: (controller) {
              controller.startSafeBrowsing();
            },
            onLoadStop: (controller, url) {
              pageLoaded.complete(url!.toString());
            },
            onSafeBrowsingHit: (controller, url, threatType) async {
              return SafeBrowsingResponse(
                report: true,
                action: SafeBrowsingResponseAction.PROCEED,
              );
            },
          ),
        ),
      );

      final String url = await pageLoaded.future;
      expect(url, TEST_CHROME_SAFE_BROWSING_MALWARE.toString());
    });

    skippableTest('getSafeBrowsingPrivacyPolicyUrl', () async {
      expect(
        await InAppWebViewController.getSafeBrowsingPrivacyPolicyUrl(),
        isNotNull,
      );
    });

    skippableTest('setSafeBrowsingWhitelist', () async {
      expect(
        await InAppWebViewController.setSafeBrowsingAllowlist(
          hosts: ["flutter.dev", "github.com"],
        ),
        true,
      );
    });
  }, skip: shouldSkip);
}
