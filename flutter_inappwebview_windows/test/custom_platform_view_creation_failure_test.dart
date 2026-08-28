import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_inappwebview_windows/src/in_app_webview/_static_channel.dart';
import 'package:flutter_inappwebview_windows/src/in_app_webview/custom_platform_view.dart';
import 'package:flutter_inappwebview_windows/src/in_app_webview/webview_creation_failure.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<MethodCall> pluginChannelCalls;

  void mockCreation({required bool succeeds}) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(IN_APP_WEBVIEW_STATIC_CHANNEL, (call) async {
          pluginChannelCalls.add(call);
          if (call.method == 'createInAppWebView') {
            if (!succeeds) {
              throw PlatformException(
                code: '0',
                message:
                    'Creating an InAppWebView instance is not supported! '
                    'Graphics Context is not valid!',
              );
            }
            return 1;
          }
          return null;
        });
  }

  setUp(() {
    pluginChannelCalls = <MethodCall>[];
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(IN_APP_WEBVIEW_STATIC_CHANNEL, null);
  });

  test('dispose completes after a failed creation', () async {
    mockCreation(succeeds: false);
    final controller = CustomPlatformViewController();

    await expectLater(
      controller.initialize(),
      throwsA(isA<PlatformException>()),
    );

    await controller.dispose().timeout(const Duration(seconds: 5));

    // No texture was ever created, so no native view may be disposed.
    expect(pluginChannelCalls.map((call) => call.method), const [
      'createInAppWebView',
    ]);
  });

  test('ready does not block waiters after a failed creation', () async {
    mockCreation(succeeds: false);
    final controller = CustomPlatformViewController();
    final ready = controller.ready.timeout(const Duration(seconds: 5));

    await expectLater(
      controller.initialize(),
      throwsA(isA<PlatformException>()),
    );

    await ready;
    expect(controller.value.isInitialized, isFalse);

    await controller.dispose();
  });

  test('controller methods are no-ops after a failed creation', () async {
    mockCreation(succeeds: false);
    final controller = CustomPlatformViewController();

    await expectLater(
      controller.initialize(),
      throwsA(isA<PlatformException>()),
    );

    await controller.setFpsLimit(30);
    await controller.requestFocus();
    await controller.clearFocus();
    await controller.dispose();

    expect(pluginChannelCalls.map((call) => call.method), const [
      'createInAppWebView',
    ]);
  });

  test('dispose waiting on creation completes when creation fails', () async {
    final releaseCreation = Completer<void>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(IN_APP_WEBVIEW_STATIC_CHANNEL, (call) async {
          pluginChannelCalls.add(call);
          await releaseCreation.future;
          throw PlatformException(code: '0', message: 'creation failed');
        });
    final controller = CustomPlatformViewController();

    final creationExpectation = expectLater(
      controller.initialize(),
      throwsA(isA<PlatformException>()),
    );
    final disposeFuture = controller.dispose();
    releaseCreation.complete();

    await creationExpectation;
    await disposeFuture.timeout(const Duration(seconds: 5));
    expect(pluginChannelCalls.map((call) => call.method), const [
      'createInAppWebView',
    ]);
  });

  test('null native response also releases dispose', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(IN_APP_WEBVIEW_STATIC_CHANNEL, (call) async {
          pluginChannelCalls.add(call);
          return null;
        });
    final controller = CustomPlatformViewController();

    await expectLater(controller.initialize(), throwsA(anything));
    await controller.dispose().timeout(const Duration(seconds: 5));

    expect(pluginChannelCalls.map((call) => call.method), const [
      'createInAppWebView',
    ]);
  });

  test('a successful creation still disposes the native view', () async {
    mockCreation(succeeds: true);
    final controller = CustomPlatformViewController();

    await controller.initialize();
    expect(controller.value.isInitialized, isTrue);

    await controller.dispose().timeout(const Duration(seconds: 5));

    expect(pluginChannelCalls.map((call) => call.method), const [
      'createInAppWebView',
      'dispose',
    ]);
  });

  testWidgets('late creation does not update a disposed widget', (
    tester,
  ) async {
    final releaseCreation = Completer<void>();
    var creationCallbackCount = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(IN_APP_WEBVIEW_STATIC_CHANNEL, (call) async {
          pluginChannelCalls.add(call);
          if (call.method == 'createInAppWebView') {
            await releaseCreation.future;
            return 1;
          }
          return null;
        });

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: CustomPlatformView(
          onPlatformViewCreated: (_) => creationCallbackCount++,
        ),
      ),
    );
    await tester.pumpWidget(const SizedBox());

    releaseCreation.complete();
    await tester.pump();
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(creationCallbackCount, 0);
  });

  testWidgets(
    'widget reports a creation failure without an unhandled async error',
    (tester) async {
      mockCreation(succeeds: false);
      final failures = <WindowsWebViewCreationFailure>[];
      final subscription = WindowsWebViewCreationFailures.stream.listen(
        failures.add,
      );
      addTearDown(subscription.cancel);

      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: CustomPlatformView(),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(failures, hasLength(1));
      expect(failures.single.error, isA<PlatformException>());
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('creation errors are delivered only to the failed widget', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(IN_APP_WEBVIEW_STATIC_CHANNEL, (call) async {
          pluginChannelCalls.add(call);
          final arguments = call.arguments! as Map<dynamic, dynamic>;
          if (arguments['creation'] == 'fails') {
            throw PlatformException(code: '0', message: 'creation failed');
          }
          return 1;
        });
    final failed = <WindowsWebViewCreationFailure>[];
    final succeeded = <WindowsWebViewCreationFailure>[];

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            Expanded(
              child: CustomPlatformView(
                creationParams: const {
                  'creation': 'fails',
                  'initialUrlRequest': {'url': 'file:///plugins/a/index.html'},
                },
                onCreationFailure: failed.add,
              ),
            ),
            Expanded(
              child: CustomPlatformView(
                creationParams: const {
                  'creation': 'succeeds',
                  'initialUrlRequest': {'url': 'file:///plugins/a/index.html'},
                },
                onCreationFailure: succeeded.add,
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(failed, hasLength(1));
    expect(failed.single.requestedUrl, 'file:///plugins/a/index.html');
    expect(succeeded, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
