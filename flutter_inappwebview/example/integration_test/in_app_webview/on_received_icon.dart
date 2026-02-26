part of 'main.dart';

void onReceivedIcon() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.onReceivedIcon,
  );

  skippableTestWidgets('onReceivedIcon', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<Uint8List> onReceivedIconCompleter = Completer<Uint8List>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_URL_1),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
          onReceivedIcon: (controller, icon) {
            if (!onReceivedIconCompleter.isCompleted) {
              onReceivedIconCompleter.complete(icon);
            }
          },
        ),
      ),
    );

    await pageLoaded.future;
    final Uint8List icon = await onReceivedIconCompleter.future;
    expect(icon, isNotNull);
  }, skip: shouldSkip);
}
