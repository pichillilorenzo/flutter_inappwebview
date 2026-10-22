part of 'main.dart';

void pullToRefresh() {
  final shouldSkip = !PullToRefreshController.isClassSupported();

  skippableTestWidgets('launches with pull-to-refresh feature', (
    WidgetTester tester,
  ) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(
        color: Colors.blue,
        size: PullToRefreshSize.DEFAULT,
        backgroundColor: Colors.grey,
        enabled: true,
        slingshotDistance: 150,
        distanceToTriggerSync: 150,
        attributedTitle: AttributedString(string: "test"),
      ),
      onRefresh: () {},
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_URL_1),
          pullToRefreshController: pullToRefreshController,
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
        ),
      ),
    );
    final InAppWebViewController controller = await controllerCompleter.future;
    final String? currentUrl = (await controller.getUrl())?.toString();
    expect(currentUrl, TEST_URL_1.toString());
  }, skip: shouldSkip);
}
