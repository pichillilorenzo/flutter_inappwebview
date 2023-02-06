import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constants.dart';

void webMessage() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  group('WebMessage', () {
    testWidgets('WebMessageChannel', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer webMessageCompleter = Completer<String>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialData: InAppWebViewInitialData(data: """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WebMessageChannel Test</title>
</head>
<body>
    <button id="button" onclick="port.postMessage(input.value);" />Send</button>
    <br />
    <input id="input" type="text" value="JavaScript To Native" />

    <script>
      var port;
      window.addEventListener('message', function(event) {
          if (event.data == 'capturePort') {
              if (event.ports[0] != null) {
                  port = event.ports[0];
                  port.onmessage = function (event) {
                      console.log(event.data);
                  };
              }
          }
      }, false);
    </script>
</body>
</html>
                      """),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onConsoleMessage: (controller, consoleMessage) {
              webMessageCompleter.complete(consoleMessage.message);
            },
            onLoadStop: (controller, url) async {
              var webMessageChannel =
                  await controller.createWebMessageChannel();
              var port1 = webMessageChannel!.port1;
              var port2 = webMessageChannel.port2;

              await port1.setWebMessageCallback((message) async {
                await port1
                    .postMessage(WebMessage(data: message! + " and back"));
              });
              await controller.postWebMessage(
                  message: WebMessage(data: "capturePort", ports: [port2]),
                  targetOrigin: WebUri("*"));
              await controller.evaluateJavascript(
                  source: "document.getElementById('button').click();");
            },
          ),
        ),
      );
      await controllerCompleter.future;

      final String message = await webMessageCompleter.future;
      expect(message, 'JavaScript To Native and back');
    });

    testWidgets('WebMessageListener', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<void> pageLoaded = Completer<void>();
      final Completer webMessageCompleter = Completer<String>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            onWebViewCreated: (controller) async {
              await controller.addWebMessageListener(WebMessageListener(
                jsObjectName: "myTestObj",
                allowedOriginRules: Set.from(["https://*.example.com"]),
                onPostMessage:
                    (message, sourceOrigin, isMainFrame, replyProxy) {
                  if (isMainFrame &&
                      (sourceOrigin.toString() + '/') ==
                          TEST_URL_EXAMPLE.toString()) {
                    replyProxy.postMessage(message! + " and back");
                  } else {
                    replyProxy.postMessage("Nope");
                  }
                },
              ));
              controllerCompleter.complete(controller);
            },
            onConsoleMessage: (controller, consoleMessage) {
              webMessageCompleter.complete(consoleMessage.message);
            },
            onLoadStop: (controller, url) async {
              if (url.toString() == TEST_URL_EXAMPLE.toString()) {
                pageLoaded.complete();
              }
            },
          ),
        ),
      );
      final controller = await controllerCompleter.future;
      await controller.loadUrl(urlRequest: URLRequest(url: TEST_URL_EXAMPLE));
      await pageLoaded.future;

      await controller.evaluateJavascript(source: """
          myTestObj.addEventListener('message', function(event) {
            console.log(event.data);
          });
          myTestObj.postMessage('JavaScript To Native');
        """);

      final String message = await webMessageCompleter.future;
      expect(message, 'JavaScript To Native and back');
    });
  }, skip: shouldSkip);
}
