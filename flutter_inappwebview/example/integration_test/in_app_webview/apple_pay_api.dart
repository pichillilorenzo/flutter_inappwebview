part of 'main.dart';

void applePayAPI() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  skippableTestWidgets('Apple Pay API enabled', (WidgetTester tester) async {
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<String> alertMessageCompleter = Completer<String>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialData: InAppWebViewInitialData(data: """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apple Pay API</title>
</head>
<body>
    <script>
      window.alert(window.ApplePaySession != null);
    </script>
</body>
</html>
                  """),
          initialSettings: InAppWebViewSettings(
            applePayAPIEnabled: true,
          ),
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
          onJsAlert: (controller, jsAlertRequest) async {
            alertMessageCompleter.complete(jsAlertRequest.message);
            return null;
          },
        ),
      ),
    );
    await pageLoaded.future;
    final message = await alertMessageCompleter.future;
    expect(message, 'true');
  }, skip: shouldSkip);
}
