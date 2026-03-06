import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

class _BridgeUserRequest {
  final String name;
  final int age;

  const _BridgeUserRequest({required this.name, required this.age});

  factory _BridgeUserRequest.fromJson(Map<String, dynamic> json) {
    return _BridgeUserRequest(
      name: json['name'] as String? ?? '',
      age: (json['age'] as num?)?.toInt() ?? 0,
    );
  }
}

class _BridgeUserResponse {
  final bool ok;
  final String message;

  const _BridgeUserResponse({required this.ok, required this.message});

  Map<String, dynamic> toJson() => {'ok': ok, 'message': message};
}

Future<T> _waitWithTimeout<T>(Future<T> future, String label) {
  return future.timeout(
    const Duration(seconds: 20),
    onTimeout: () => throw TimeoutException('Timed out: $label'),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('bridgeEvents and addJsonJavaScriptHandler smoke test', (
    WidgetTester tester,
  ) async {
    final supportsBridgeEvents =
        InAppWebViewController.isMethodSupported(
          PlatformInAppWebViewControllerMethod.addJavaScriptHandler,
        ) &&
        InAppWebViewController.isMethodSupported(
          PlatformInAppWebViewControllerMethod.removeJavaScriptHandler,
        ) &&
        InAppWebViewController.isMethodSupported(
          PlatformInAppWebViewControllerMethod.hasJavaScriptHandler,
        ) &&
        InAppWebViewController.isMethodSupported(
          PlatformInAppWebViewControllerMethod.evaluateJavascript,
        );

    if (!supportsBridgeEvents) {
      return;
    }

    const jsToDartEvent = 'smoke_js_to_dart';
    const dartToJsEvent = 'smoke_dart_to_js';
    const ackHandler = 'smokeAck';
    const typedHandler = 'smokeTyped';
    const typedResultHandler = 'smokeTypedResult';

    final controllerCompleter = Completer<InAppWebViewController>();
    final loadedCompleter = Completer<void>();
    final jsToDartPayloadCompleter = Completer<Map<String, dynamic>>();
    final dartToJsAckCompleter = Completer<Map<String, dynamic>>();
    final typedResultCompleter = Completer<Map<String, dynamic>>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InAppWebView(
            key: GlobalKey(),
            initialUrlRequest: URLRequest(url: WebUri('about:blank')),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);

              controller.bridgeEvents.on(
                eventName: jsToDartEvent,
                listener: (data) {
                  if (!jsToDartPayloadCompleter.isCompleted && data is Map) {
                    jsToDartPayloadCompleter.complete(
                      Map<String, dynamic>.from(data),
                    );
                  }
                  return {'ok': true};
                },
              );

              controller.addJavaScriptHandler(
                handlerName: ackHandler,
                callback: (JavaScriptHandlerFunctionData data) {
                  final payload = data.args.isNotEmpty ? data.args[0] : null;
                  if (!dartToJsAckCompleter.isCompleted && payload is Map) {
                    dartToJsAckCompleter.complete(
                      Map<String, dynamic>.from(payload),
                    );
                  }
                  return null;
                },
              );

              controller.addJsonJavaScriptHandler<
                _BridgeUserRequest,
                _BridgeUserResponse
              >(
                handlerName: typedHandler,
                fromJson: _BridgeUserRequest.fromJson,
                callback: (request, meta) async {
                  return _BridgeUserResponse(
                    ok: true,
                    message: 'updated:${request.name}:${request.age}',
                  );
                },
                toJson: (value) => value.toJson(),
              );

              controller.addJavaScriptHandler(
                handlerName: typedResultHandler,
                callback: (JavaScriptHandlerFunctionData data) {
                  dynamic payload = data.args.isNotEmpty ? data.args[0] : null;
                  if (payload is String && payload.isNotEmpty) {
                    try {
                      payload = jsonDecode(payload);
                    } catch (_) {
                      // Keep original value when decoding is not possible.
                    }
                  }
                  if (!typedResultCompleter.isCompleted && payload is Map) {
                    typedResultCompleter.complete(
                      Map<String, dynamic>.from(payload),
                    );
                  }
                  return null;
                },
              );
            },
            onLoadStop: (controller, url) {
              if (!loadedCompleter.isCompleted) {
                loadedCompleter.complete();
              }
            },
          ),
        ),
      ),
    );

    final controller = await _waitWithTimeout(
      controllerCompleter.future,
      'webview controller creation',
    );
    await _waitWithTimeout(loadedCompleter.future, 'page load');

    final bridgeName = await InAppWebViewController.getJavaScriptBridgeName();
    final encodedBridgeName = jsonEncode(bridgeName);

    await controller.evaluateJavascript(
      source:
          """
        (function() {
          function run() {
            var bridge = window[$encodedBridgeName];
            if (bridge == null || bridge.bridgeEvents == null) {
              return;
            }
            bridge.bridgeEvents.emit('${jsToDartEvent}', {
              message: 'from_js',
              value: 7
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

    final jsToDartPayload = await _waitWithTimeout(
      jsToDartPayloadCompleter.future,
      'js -> dart payload',
    );
    expect(jsToDartPayload['message'], 'from_js');
    expect(jsToDartPayload['value'], 7);

    await controller.evaluateJavascript(
      source:
          """
        (function() {
          function register() {
            var bridge = window[$encodedBridgeName];
            if (bridge == null || bridge.bridgeEvents == null) {
              return;
            }
            bridge.bridgeEvents.off('${dartToJsEvent}');
            bridge.bridgeEvents.on('${dartToJsEvent}', function(data) {
              bridge.callHandler('${ackHandler}', data);
            });
          }
          var bridge = window[$encodedBridgeName];
          if (bridge != null && bridge._platformReady) {
            register();
            return;
          }
          window.addEventListener('flutterInAppWebViewPlatformReady', register, { once: true });
        })();
      """,
    );

    await controller.bridgeEvents.emit(dartToJsEvent, {
      'message': 'from_dart',
      'value': 99,
    });

    final dartToJsAck = await _waitWithTimeout(
      dartToJsAckCompleter.future,
      'dart -> js ack',
    );
    expect(dartToJsAck['message'], 'from_dart');
    expect(dartToJsAck['value'], 99);

    await controller.evaluateJavascript(
      source:
          """
        (function() {
          function run() {
            var bridge = window[$encodedBridgeName];
            if (bridge == null || bridge.callHandler == null) {
              return;
            }
            var request = JSON.stringify({name: 'Alice', age: 31});
            bridge.callHandler('${typedHandler}', request).then(function(result) {
              bridge.callHandler('${typedResultHandler}', result);
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

    final typedResult = await _waitWithTimeout(
      typedResultCompleter.future,
      'typed handler result',
    );
    expect(typedResult['ok'], true);
    expect(typedResult['message'], 'updated:Alice:31');

    controller.bridgeEvents.off(jsToDartEvent);
    controller.removeJavaScriptHandler(handlerName: ackHandler);
    controller.removeJavaScriptHandler(handlerName: typedResultHandler);
    controller.removeJavaScriptHandler(handlerName: typedHandler);
  });
}
