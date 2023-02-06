import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../env.dart';

void httpAuthCredentialDatabase() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  group('Http Auth Credential Database', () {
    testWidgets('use saved credentials', (WidgetTester tester) async {
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
              port: 8081),
          credential:
              URLCredential(username: "USERNAME", password: "PASSWORD"));

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(
                url: WebUri("http://${environment["NODE_SERVER_IP"]}:8081/")),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            initialSettings: InAppWebViewSettings(
              clearCache: true,
            ),
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
            onReceivedHttpAuthRequest: (controller, challenge) async {
              return new HttpAuthResponse(
                  action:
                      HttpAuthResponseAction.USE_SAVED_HTTP_AUTH_CREDENTIALS);
            },
          ),
        ),
      );
      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      final String h1Content = await controller.evaluateJavascript(
          source: "document.body.querySelector('h1').textContent");
      expect(h1Content, "Authorized");

      var credentials = await httpAuthCredentialDatabase.getHttpAuthCredentials(
          protectionSpace: URLProtectionSpace(
              host: environment["NODE_SERVER_IP"]!,
              protocol: "http",
              realm: "Node",
              port: 8081));
      expect(credentials.length, 1);

      await httpAuthCredentialDatabase.clearAllAuthCredentials();
      credentials = await httpAuthCredentialDatabase.getHttpAuthCredentials(
          protectionSpace: URLProtectionSpace(
              host: environment["NODE_SERVER_IP"]!,
              protocol: "http",
              realm: "Node",
              port: 8081));
      expect(credentials, isEmpty);
    });

    testWidgets('save credentials', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(
                url: WebUri("http://${environment["NODE_SERVER_IP"]}:8081/")),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            initialSettings: InAppWebViewSettings(
              clearCache: true,
            ),
            onLoadStop: (controller, url) {
              pageLoaded.complete();
            },
            onReceivedHttpAuthRequest: (controller, challenge) async {
              return new HttpAuthResponse(
                  username: "USERNAME",
                  password: "PASSWORD",
                  action: HttpAuthResponseAction.PROCEED,
                  permanentPersistence: true);
            },
          ),
        ),
      );
      final InAppWebViewController controller =
          await controllerCompleter.future;
      await pageLoaded.future;

      final String h1Content = await controller.evaluateJavascript(
          source: "document.body.querySelector('h1').textContent");
      expect(h1Content, "Authorized");
    });
  }, skip: shouldSkip);
}
