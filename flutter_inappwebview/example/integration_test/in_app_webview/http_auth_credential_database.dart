part of 'main.dart';

void httpAuthCredentialDatabase() {
  final shouldSkip = !HttpAuthCredentialDatabase.isClassSupported();

  skippableGroup('Http Auth Credential Database', () {
    skippableTestWidgets('use saved credentials', (WidgetTester tester) async {
      HttpAuthCredentialDatabase httpAuthCredentialDatabase =
          HttpAuthCredentialDatabase.instance();
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      httpAuthCredentialDatabase.setHttpAuthCredential(
        protectionSpace: URLProtectionSpace(
          host: environment["NODE_SERVER_IP"]!,
          protocol: "http",
          realm: "Node",
          port: 8081,
        ),
        credential: URLCredential(username: "USERNAME", password: "PASSWORD"),
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(
              url: WebUri("http://${environment["NODE_SERVER_IP"]}:8081/"),
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            initialSettings: InAppWebViewSettings(clearCache: true),
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
            onReceivedHttpAuthRequest: (controller, challenge) async {
              return new HttpAuthResponse(
                action: HttpAuthResponseAction.USE_SAVED_HTTP_AUTH_CREDENTIALS,
              );
            },
          ),
        ),
      );
      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      final String h1Content = await controller.evaluateJavascript(
        source: "document.body.querySelector('h1').textContent",
      );
      expect(h1Content, "Authorized");

      var credentials = await httpAuthCredentialDatabase.getHttpAuthCredentials(
        protectionSpace: URLProtectionSpace(
          host: environment["NODE_SERVER_IP"]!,
          protocol: "http",
          realm: "Node",
          port: 8081,
        ),
      );
      expect(credentials.length, 1);

      await httpAuthCredentialDatabase.clearAllAuthCredentials();
      credentials = await httpAuthCredentialDatabase.getHttpAuthCredentials(
        protectionSpace: URLProtectionSpace(
          host: environment["NODE_SERVER_IP"]!,
          protocol: "http",
          realm: "Node",
          port: 8081,
        ),
      );
      expect(credentials, isEmpty);
    });

    skippableTestWidgets('save credentials', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(
              url: WebUri("http://${environment["NODE_SERVER_IP"]}:8081/"),
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            initialSettings: InAppWebViewSettings(clearCache: true),
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
            onReceivedHttpAuthRequest: (controller, challenge) async {
              return new HttpAuthResponse(
                username: "USERNAME",
                password: "PASSWORD",
                action: HttpAuthResponseAction.PROCEED,
                permanentPersistence: true,
              );
            },
          ),
        ),
      );
      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      final String h1Content = await controller.evaluateJavascript(
        source: "document.body.querySelector('h1').textContent",
      );
      expect(h1Content, "Authorized");
    });
  }, skip: shouldSkip);
}
