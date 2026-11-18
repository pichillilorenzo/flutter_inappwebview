part of 'main.dart';

void onReceivedTouchIconUrl() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.onReceivedTouchIconUrl,
  );

  skippableTestWidgets('onReceivedTouchIconUrl', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<String> onReceivedTouchIconUrlCompleter =
        Completer<String>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialData: InAppWebViewInitialData(
            data: """
<!doctype html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <link rel="apple-touch-icon" sizes="72x72" href="https://placehold.it/72x72">
    </head>
    <body></body>
</html>
                    """,
          ),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onReceivedTouchIconUrl: (controller, url, precomposed) {
            onReceivedTouchIconUrlCompleter.complete(url.toString());
          },
        ),
      ),
    );

    final String url = await onReceivedTouchIconUrlCompleter.future;

    expect(url, "https://placehold.it/72x72");
  }, skip: shouldSkip);
}
