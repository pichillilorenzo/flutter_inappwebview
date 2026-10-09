part of 'main.dart';

void onProgressChanged() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.onProgressChanged,
  );

  skippableTestWidgets('onProgressChanged', (WidgetTester tester) async {
    final Completer<void> onProgressChangedCompleter = Completer<void>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_URL_1),
          initialSettings: InAppWebViewSettings(clearCache: true),
          onProgressChanged: (controller, progress) {
            if (progress == 100 && !onProgressChangedCompleter.isCompleted) {
              onProgressChangedCompleter.complete();
            }
          },
        ),
      ),
    );
    await expectLater(onProgressChangedCompleter.future, completes);
  }, skip: shouldSkip);
}
