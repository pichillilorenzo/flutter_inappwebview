part of 'main.dart';

void webMessage() {
  final shouldSkip = !WebMessageChannel.isClassSupported();

  skippableGroup('WebMessage', () {
    skippableTestWidgets('WebMessageChannel post String', (
      WidgetTester tester,
    ) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer webMessageCompleter = Completer<String>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialData: InAppWebViewInitialData(
              data: """
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
                      """,
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onConsoleMessage: (controller, consoleMessage) {
              webMessageCompleter.complete(consoleMessage.message);
            },
            onLoadStop: (controller, url) async {
              var webMessageChannel = await controller
                  .createWebMessageChannel();
              var port1 = webMessageChannel!.port1;
              var port2 = webMessageChannel.port2;

              await port1.setWebMessageCallback((message) async {
                await port1.postMessage(
                  WebMessage(data: message!.data + " and back"),
                );
              });
              await controller.postWebMessage(
                message: WebMessage(data: "capturePort", ports: [port2]),
                targetOrigin: WebUri("*"),
              );
              await controller.evaluateJavascript(
                source: "document.getElementById('button').click();",
              );
            },
          ),
        ),
      );
      await controllerCompleter.future;

      final String message = await webMessageCompleter.future;
      expect(message, 'JavaScript To Native and back');
    });

    skippableTestWidgets('WebMessageChannel post ArrayBuffer', (
      WidgetTester tester,
    ) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer webMessageCompleter = Completer<String>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialData: InAppWebViewInitialData(
              data: """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WebMessageChannel Test</title>
</head>
<body>
    <button id="button" onclick="port.postMessage(stringToBuffer(input.value));" />Send</button>
    <br />
    <input id="input" type="text" value="JavaScript To Native" />

    <script>
      function bufferToString(buffer) {
          return String.fromCharCode.apply(null, Array.from(new Uint8Array(buffer)));
      }
      
      function stringToBuffer(value) {
          var buffer = new ArrayBuffer(value.length);
          var view = new Uint8Array(buffer);
          for (var i = 0, length = value.length; i < length; i++) {
              view[i] = value.charCodeAt(i);
          }
          return buffer;
      }
      
      var port;
      window.addEventListener('message', function(event) {
          if (bufferToString(event.data) == 'capturePort') {
              if (event.ports[0] != null) {
                  port = event.ports[0];
                  port.onmessage = function (event) {
                      console.log(bufferToString(event.data));
                  };
              }
          }
      }, false);
    </script>
</body>
</html>
                      """,
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            onConsoleMessage: (controller, consoleMessage) {
              webMessageCompleter.complete(consoleMessage.message);
            },
            onLoadStop: (controller, url) async {
              var webMessageChannel = await controller
                  .createWebMessageChannel();
              var port1 = webMessageChannel!.port1;
              var port2 = webMessageChannel.port2;

              await port1.setWebMessageCallback((message) async {
                await port1.postMessage(
                  WebMessage(
                    data: utf8.encode(utf8.decode(message!.data) + " and back"),
                    type: WebMessageType.ARRAY_BUFFER,
                  ),
                );
              });
              await controller.postWebMessage(
                message: WebMessage(
                  data: utf8.encode("capturePort"),
                  type: WebMessageType.ARRAY_BUFFER,
                  ports: [port2],
                ),
                targetOrigin: WebUri("*"),
              );
              await controller.evaluateJavascript(
                source: "document.getElementById('button').click();",
              );
            },
          ),
        ),
      );
      await controllerCompleter.future;

      final String message = await webMessageCompleter.future;
      expect(message, 'JavaScript To Native and back');
    });

    skippableTestWidgets('WebMessageListener post String', (
      WidgetTester tester,
    ) async {
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
              await controller.addWebMessageListener(
                WebMessageListener(
                  jsObjectName: "myTestObj",
                  allowedOriginRules: Set.from(["https://*.example.com"]),
                  onPostMessage:
                      (message, sourceOrigin, isMainFrame, replyProxy) {
                        if (isMainFrame &&
                            (sourceOrigin.toString() + '/') ==
                                TEST_URL_EXAMPLE.toString()) {
                          replyProxy.postMessage(
                            WebMessage(data: message!.data + " and back"),
                          );
                        } else {
                          replyProxy.postMessage(WebMessage(data: "Nope"));
                        }
                      },
                ),
              );
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

      await controller.evaluateJavascript(
        source: """
          myTestObj.addEventListener('message', function(event) {
            console.log(event.data);
          });
          myTestObj.postMessage('JavaScript To Native');
        """,
      );

      final String message = await webMessageCompleter.future;
      expect(message, 'JavaScript To Native and back');
    });

    skippableTestWidgets('WebMessageListener post ArrayBuffer', (
      WidgetTester tester,
    ) async {
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
              await controller.addWebMessageListener(
                WebMessageListener(
                  jsObjectName: "myTestObj",
                  allowedOriginRules: Set.from(["https://*.example.com"]),
                  onPostMessage:
                      (message, sourceOrigin, isMainFrame, replyProxy) {
                        if (isMainFrame &&
                            (sourceOrigin.toString() + '/') ==
                                TEST_URL_EXAMPLE.toString()) {
                          replyProxy.postMessage(
                            WebMessage(
                              data: utf8.encode(
                                utf8.decode(message!.data) + " and back",
                              ),
                              type: WebMessageType.ARRAY_BUFFER,
                            ),
                          );
                        } else {
                          replyProxy.postMessage(
                            WebMessage(
                              data: utf8.encode("Nope"),
                              type: WebMessageType.ARRAY_BUFFER,
                            ),
                          );
                        }
                      },
                ),
              );
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

      await controller.evaluateJavascript(
        source: """
          function bufferToString(buffer) {
              return String.fromCharCode.apply(null, Array.from(new Uint8Array(buffer)));
          }
          
          function stringToBuffer(value) {
              var buffer = new ArrayBuffer(value.length);
              var view = new Uint8Array(buffer);
              for (var i = 0, length = value.length; i < length; i++) {
                  view[i] = value.charCodeAt(i);
              }
              return buffer;
          }
          
          myTestObj.addEventListener('message', function(event) {
            console.log(bufferToString(event.data));
          });
          myTestObj.postMessage(stringToBuffer('JavaScript To Native'));
        """,
      );

      final String message = await webMessageCompleter.future;
      expect(message, 'JavaScript To Native and back');
    });
  }, skip: shouldSkip);
}
