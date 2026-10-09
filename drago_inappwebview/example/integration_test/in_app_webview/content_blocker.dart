part of 'main.dart';

void contentBlocker() {
  final shouldSkip = !InAppWebViewSettings.isPropertySupported(
    InAppWebViewSettingsProperty.contentBlockers,
  );

  skippableTestWidgets('Content Blocker', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
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
            contentBlockers: [
              ContentBlocker(
                trigger: ContentBlockerTrigger(
                  urlFilter: ".*",
                  resourceType: [
                    ContentBlockerTriggerResourceType.IMAGE,
                    ContentBlockerTriggerResourceType.STYLE_SHEET,
                  ],
                  ifTopUrl: [TEST_CROSS_PLATFORM_URL_1.toString()],
                ),
                action: ContentBlockerAction(
                  type: ContentBlockerActionType.BLOCK,
                ),
              ),
            ],
          ),
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
        ),
      ),
    );
    await expectLater(pageLoaded.future, completes);
  }, skip: shouldSkip);
}
