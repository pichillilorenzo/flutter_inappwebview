import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../env.dart';

void postRequests() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  group('POST requests', () {
    testWidgets('initialUrlRequest', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> postPageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(
                url: WebUri(
                    "http://${environment["NODE_SERVER_IP"]}:8082/test-post"),
                method: 'POST',
                body: Uint8List.fromList(utf8.encode("name=FooBar")),
                headers: {'Content-Type': 'application/x-www-form-urlencoded'}),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              postPageLoaded.complete();
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;
      await postPageLoaded.future;

      final String? currentUrl = (await controller.getUrl())?.toString();
      expect(
          currentUrl, 'http://${environment["NODE_SERVER_IP"]}:8082/test-post');

      final String? pContent = await controller.evaluateJavascript(
          source: "document.querySelector('p').innerHTML;");
      expect(pContent, "HELLO FooBar!");
    });

    testWidgets('loadUrl', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> postPageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: WebUri('about:blank')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              if (url?.scheme != "about") {
                postPageLoaded.complete();
              }
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;

      var postData = Uint8List.fromList(utf8.encode("name=FooBar"));
      await controller.loadUrl(
          urlRequest: URLRequest(
              url: WebUri(
                  "http://${environment["NODE_SERVER_IP"]}:8082/test-post"),
              method: 'POST',
              body: postData,
              headers: {'Content-Type': 'application/x-www-form-urlencoded'}));

      await postPageLoaded.future;

      final String? currentUrl = (await controller.getUrl())?.toString();
      expect(
          currentUrl, 'http://${environment["NODE_SERVER_IP"]}:8082/test-post');

      final String? pContent = await controller.evaluateJavascript(
          source: "document.querySelector('p').innerHTML;");
      expect(pContent, "HELLO FooBar!");
    });

    testWidgets('postUrl', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> postPageLoaded = Completer<void>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: WebUri('about:blank')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onLoadStop: (controller, url) {
              if (url?.scheme != "about") {
                postPageLoaded.complete();
              }
            },
          ),
        ),
      );

      final InAppWebViewController controller =
          await controllerCompleter.future;

      var postData = Uint8List.fromList(utf8.encode("name=FooBar"));
      await controller.postUrl(
          url: WebUri("http://${environment["NODE_SERVER_IP"]}:8082/test-post"),
          postData: postData);

      await postPageLoaded.future;

      final String? currentUrl = (await controller.getUrl())?.toString();
      expect(
          currentUrl, 'http://${environment["NODE_SERVER_IP"]}:8082/test-post');

      final String? pContent = await controller.evaluateJavascript(
          source: "document.querySelector('p').innerHTML;");
      expect(pContent, "HELLO FooBar!");
    });
  }, skip: shouldSkip);
}
