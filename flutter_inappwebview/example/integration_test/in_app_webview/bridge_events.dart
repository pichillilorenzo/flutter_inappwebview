part of 'main.dart';

class _BridgeEventsUserRequest {
  final String name;
  final int age;

  const _BridgeEventsUserRequest({required this.name, required this.age});

  factory _BridgeEventsUserRequest.fromJson(Map<String, dynamic> json) {
    return _BridgeEventsUserRequest(
      name: json["name"] as String? ?? "",
      age: json["age"] as int? ?? 0,
    );
  }
}

class _BridgeEventsUserResponse {
  final bool ok;
  final String message;

  const _BridgeEventsUserResponse({required this.ok, required this.message});

  Map<String, dynamic> toJson() {
    return {"ok": ok, "message": message};
  }
}

void bridgeEvents() {
  final shouldSkip =
      !InAppWebViewController.isMethodSupported(
        PlatformInAppWebViewControllerMethod.addJavaScriptHandler,
      ) ||
      !InAppWebViewController.isMethodSupported(
        PlatformInAppWebViewControllerMethod.removeJavaScriptHandler,
      ) ||
      !InAppWebViewController.isMethodSupported(
        PlatformInAppWebViewControllerMethod.hasJavaScriptHandler,
      ) ||
      !InAppWebViewController.isMethodSupported(
        PlatformInAppWebViewControllerMethod.evaluateJavascript,
      );

  skippableGroup('Bridge Events', () {
    skippableTestWidgets('bridgeEvents.emit JS -> Dart', (
      WidgetTester tester,
    ) async {
      final controllerCompleter = Completer<InAppWebViewController>();
      final pageLoaded = Completer<void>();
      final jsPayloadReceived = Completer<Map<String, dynamic>>();
      const eventName = "js_to_dart_ping";

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: TEST_URL_ABOUT_BLANK),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
              controller.bridgeEvents.on(
                eventName: eventName,
                listener: (data) {
                  if (!jsPayloadReceived.isCompleted && data is Map) {
                    jsPayloadReceived.complete(Map<String, dynamic>.from(data));
                  }
                  return {"ok": true};
                },
              );
            },
            onLoadStop: (controller, url) {
              if (!pageLoaded.isCompleted) {
                pageLoaded.complete();
              }
            },
          ),
        ),
      );

      final controller = await controllerCompleter.future;
      await pageLoaded.future;

      expect(controller.bridgeEvents.hasListener(eventName), true);

      final bridgeName = await InAppWebViewController.getJavaScriptBridgeName();
      final encodedBridgeName = jsonEncode(bridgeName);
      final encodedEventName = jsonEncode(eventName);
      await controller.evaluateJavascript(
        source:
            """
          (function() {
            var payload = {message: 'hello_from_js', value: 7};
            function sendEvent() {
              var bridge = window[$encodedBridgeName];
              if (bridge == null || bridge.bridgeEvents == null) {
                return;
              }
              bridge.bridgeEvents.emit($encodedEventName, payload);
            }
            var bridge = window[$encodedBridgeName];
            if (bridge != null && bridge._platformReady) {
              sendEvent();
              return;
            }
            window.addEventListener('flutterInAppWebViewPlatformReady', sendEvent, { once: true });
          })();
        """,
      );

      final payload = await jsPayloadReceived.future;
      expect(payload["message"], "hello_from_js");
      expect(payload["value"], 7);

      controller.bridgeEvents.off(eventName);
      expect(controller.bridgeEvents.hasListener(eventName), false);
    });

    skippableTestWidgets('bridgeEvents.emit Dart -> JS', (
      WidgetTester tester,
    ) async {
      final controllerCompleter = Completer<InAppWebViewController>();
      final pageLoaded = Completer<void>();
      final dartPayloadReceivedInJs = Completer<Map<String, dynamic>>();
      const eventName = "dart_to_js_ping";

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: TEST_URL_ABOUT_BLANK),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
              controller.addJavaScriptHandler(
                handlerName: "bridgeEventsAck",
                callback: (JavaScriptHandlerFunctionData data) {
                  if (!dartPayloadReceivedInJs.isCompleted &&
                      data.args.isNotEmpty &&
                      data.args[0] is Map) {
                    dartPayloadReceivedInJs.complete(
                      Map<String, dynamic>.from(data.args[0]),
                    );
                  }
                  return null;
                },
              );
            },
            onLoadStop: (controller, url) {
              if (!pageLoaded.isCompleted) {
                pageLoaded.complete();
              }
            },
          ),
        ),
      );

      final controller = await controllerCompleter.future;
      await pageLoaded.future;

      final bridgeName = await InAppWebViewController.getJavaScriptBridgeName();
      final encodedBridgeName = jsonEncode(bridgeName);
      final encodedEventName = jsonEncode(eventName);
      await controller.evaluateJavascript(
        source:
            """
          (function() {
            function registerListener() {
              var bridge = window[$encodedBridgeName];
              if (bridge == null || bridge.bridgeEvents == null) {
                return;
              }
              bridge.bridgeEvents.on($encodedEventName, function(data) {
                bridge.callHandler('bridgeEventsAck', data);
              });
            }
            var bridge = window[$encodedBridgeName];
            if (bridge != null && bridge._platformReady) {
              registerListener();
              return;
            }
            window.addEventListener('flutterInAppWebViewPlatformReady', registerListener, { once: true });
          })();
        """,
      );

      await controller.bridgeEvents.emit(eventName, {
        "message": "hello_from_dart",
        "value": 99,
      });

      final payload = await dartPayloadReceivedInJs.future;
      expect(payload["message"], "hello_from_dart");
      expect(payload["value"], 99);
    });

    skippableTestWidgets('addJsonJavaScriptHandler', (
      WidgetTester tester,
    ) async {
      final controllerCompleter = Completer<InAppWebViewController>();
      final pageLoaded = Completer<void>();
      final requestCompleter = Completer<_BridgeEventsUserRequest>();
      final resultCompleter = Completer<Map<String, dynamic>>();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: TEST_URL_ABOUT_BLANK),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);

              controller.addJsonJavaScriptHandler<
                _BridgeEventsUserRequest,
                _BridgeEventsUserResponse
              >(
                handlerName: "typedBridgeEvents",
                fromJson: _BridgeEventsUserRequest.fromJson,
                callback: (request, meta) async {
                  if (!requestCompleter.isCompleted) {
                    requestCompleter.complete(request);
                  }
                  return _BridgeEventsUserResponse(
                    ok: true,
                    message: "updated:${request.name}:${request.age}",
                  );
                },
                toJson: (value) => value.toJson(),
              );

              controller.addJavaScriptHandler(
                handlerName: "typedBridgeEventsResult",
                callback: (JavaScriptHandlerFunctionData data) {
                  if (!resultCompleter.isCompleted &&
                      data.args.isNotEmpty &&
                      data.args[0] is Map) {
                    resultCompleter.complete(
                      Map<String, dynamic>.from(data.args[0]),
                    );
                  }
                  return null;
                },
              );
            },
            onLoadStop: (controller, url) {
              if (!pageLoaded.isCompleted) {
                pageLoaded.complete();
              }
            },
          ),
        ),
      );

      final controller = await controllerCompleter.future;
      await pageLoaded.future;

      final bridgeName = await InAppWebViewController.getJavaScriptBridgeName();
      final encodedBridgeName = jsonEncode(bridgeName);
      await controller.evaluateJavascript(
        source:
            """
          (function() {
            function run() {
              var bridge = window[$encodedBridgeName];
              if (bridge == null) {
                return;
              }
              var input = JSON.stringify({name: 'Alice', age: 31});
              bridge.callHandler('typedBridgeEvents', input).then(function(result) {
                bridge.callHandler('typedBridgeEventsResult', result);
              });
            }
            var bridge = window[$encodedBridgeName];
            if (bridge != null && bridge._platformReady) {
              run();
              return;
            }
            window.addEventListener('flutterInAppWebViewPlatformReady', run, { once: true });
          })();
        """,
      );

      final request = await requestCompleter.future;
      final result = await resultCompleter.future;

      expect(request.name, "Alice");
      expect(request.age, 31);
      expect(result["ok"], true);
      expect(result["message"], "updated:Alice:31");
    });
  }, skip: shouldSkip);
}
