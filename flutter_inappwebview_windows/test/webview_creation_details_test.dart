import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_inappwebview_windows/flutter_inappwebview_windows.dart';
import 'package:flutter_inappwebview_windows/src/in_app_webview/_static_channel.dart';
import 'package:flutter_inappwebview_windows/src/in_app_webview/custom_platform_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('native creation observation', () {
    final unverified = <Object>[
      7,
      {'id': 7},
      {'id': 7, 'renderMode': null},
      {'id': 7, 'renderMode': 'future-backend'},
      {'id': 7, 'renderMode': true},
      {'id': 7, 'fallbackStage': 'forced', 'fallbackHresult': 0},
    ];
    for (final value in unverified) {
      test('$value keeps the compatibility default unverified', () {
        final result = WindowsWebViewCreationResult.fromNative(value);
        expect(result.renderMode, WindowsWebViewRenderMode.composition);
        expect(result.creationDetails!.nativeViewId, 7);
        expect(result.creationDetails!.renderMode, isNull);
        expect(result.creationDetails!.isRenderModeVerified, isFalse);
      });
    }

    for (final mode in WindowsWebViewRenderMode.values) {
      test('${mode.name} is verified without inventing a reason', () {
        final details = WindowsWebViewCreationResult.fromNative({
          'id': 7,
          'renderMode': mode.name,
        }).creationDetails!;
        expect(details.renderMode, mode);
        expect(details.isRenderModeVerified, isTrue);
        expect(details.isFallbackReasonAvailable, isFalse);
        expect(details.fallbackStage, isNull);
        expect(details.fallbackHresult, isNull);
      });
    }

    for (final hresult in [-0x80000000, -2147019873, -1, 0, 0xFFFFFFFF]) {
      test('creation HRESULT $hresult is unsigned32', () {
        final details = WindowsWebViewCreationResult.fromNative({
          'id': 7,
          'renderMode': 'hwnd',
          'fallbackStage': 'CreateCaptureSession',
          'fallbackHresult': hresult,
        }).creationDetails!;
        expect(details.fallbackHresult, hresult & 0xFFFFFFFF);
        expect(details.isFallbackReasonAvailable, isTrue);
      });
    }

    final partialReasons = <Map<String, Object?>>[
      {'fallbackStage': 'forced'},
      {'fallbackHresult': 0},
      {'fallbackStage': '', 'fallbackHresult': 0},
      {'fallbackStage': false, 'fallbackHresult': 0},
      {'fallbackStage': 'forced', 'fallbackHresult': '0'},
      {'fallbackStage': 'forced', 'fallbackHresult': 0.5},
      {'fallbackStage': 'forced', 'fallbackHresult': -0x80000001},
      {'fallbackStage': 'forced', 'fallbackHresult': 0x100000000},
    ];
    for (final reason in partialReasons) {
      test('partial or invalid reason $reason stays unavailable', () {
        final details = WindowsWebViewCreationResult.fromNative({
          'id': 7,
          'renderMode': 'hwnd',
          ...reason,
        }).creationDetails!;
        expect(details.isRenderModeVerified, isTrue);
        expect(details.isFallbackReasonAvailable, isFalse);
      });
    }

    test('observation does not retain a mutable native map', () {
      final native = <String, Object?>{
        'id': 7,
        'renderMode': 'hwnd',
        'fallbackStage': 'forced',
        'fallbackHresult': 0,
      };
      final details = WindowsWebViewCreationResult.fromNative(
        native,
      ).creationDetails!;
      native
        ..['id'] = 8
        ..['renderMode'] = 'composition'
        ..['fallbackStage'] = 'changed'
        ..['fallbackHresult'] = -1;
      expect(details.nativeViewId, 7);
      expect(details.renderMode, WindowsWebViewRenderMode.hwnd);
      expect(details.fallbackStage, 'forced');
      expect(details.fallbackHresult, 0);
    });

    test('a manually built result is not a native observation', () {
      const result = WindowsWebViewCreationResult(id: 7);
      expect(result.creationDetails, isNull);
    });
  });

  group('creation callback lifetime', () {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const id = 7;
    const eventChannel = EventChannel(
      'com.pichillilorenzo/custom_platform_view_${id}_events',
    );
    const viewChannel = MethodChannel(
      'com.pichillilorenzo/custom_platform_view_$id',
    );
    late FutureOr<Object?> Function() create;
    late List<MethodCall> nativeCalls;

    setUp(() {
      create = () => {'id': id, 'renderMode': 'composition'};
      nativeCalls = [];
      messenger.setMockMethodCallHandler(IN_APP_WEBVIEW_STATIC_CHANNEL, (
        call,
      ) async {
        nativeCalls.add(call);
        if (call.method == 'createInAppWebView') return create();
        return null;
      });
      messenger.setMockMethodCallHandler(viewChannel, (_) async => null);
      messenger.setMockStreamHandler(
        eventChannel,
        MockStreamHandler.inline(onListen: (_, _) {}),
      );
    });

    tearDown(() {
      messenger.setMockMethodCallHandler(IN_APP_WEBVIEW_STATIC_CHANNEL, null);
      messenger.setMockMethodCallHandler(viewChannel, null);
      messenger.setMockStreamHandler(eventChannel, null);
    });

    test('details precede the unchanged integer callback', () async {
      final controller = CustomPlatformViewController();
      final order = <String>[];
      await controller.initialize(
        onPlatformViewCreationDetails: (details) {
          expect(controller.value.isInitialized, isTrue);
          expect(details.nativeViewId, id);
          expect(details.renderMode, WindowsWebViewRenderMode.composition);
          order.add('details');
        },
        onPlatformViewCreated: (int value) {
          expect(value, id);
          order.add('id');
        },
      );
      expect(order, ['details', 'id']);
      await controller.dispose();
    });

    test('existing callers need no details callback', () async {
      final controller = CustomPlatformViewController();
      int? received;
      await controller.initialize(onPlatformViewCreated: (id) => received = id);
      expect(received, id);
      await controller.dispose();
    });

    test('failure delivers neither callback and releases ready', () async {
      create = () => throw PlatformException(code: 'creation-failed');
      final controller = CustomPlatformViewController();
      await expectLater(
        controller.initialize(
          onPlatformViewCreationDetails: (_) => fail('Unexpected details'),
          onPlatformViewCreated: (_) => fail('Unexpected id'),
        ),
        throwsA(isA<PlatformException>()),
      );
      await controller.ready;
      await controller.dispose();
      expect(nativeCalls.map((call) => call.method), ['createInAppWebView']);
    });

    test(
      'disposal before initialization cannot create or publish later',
      () async {
        final controller = CustomPlatformViewController();
        await controller.dispose();
        await controller.initialize(
          onPlatformViewCreationDetails: (_) => fail('Unexpected details'),
          onPlatformViewCreated: (_) => fail('Unexpected id'),
        );
        await controller.ready;
        await controller.dispose();
        expect(nativeCalls, isEmpty);
      },
    );

    test('late success after disposal cleans up without callbacks', () async {
      final pending = Completer<Object?>();
      create = () => pending.future;
      final controller = CustomPlatformViewController();
      final initialization = controller.initialize(
        onPlatformViewCreationDetails: (_) => fail('Unexpected details'),
        onPlatformViewCreated: (_) => fail('Unexpected id'),
      );
      final disposal = controller.dispose();
      pending.complete({'id': id, 'renderMode': 'hwnd'});
      await initialization;
      await disposal;
      await controller.dispose();
      expect(nativeCalls.map((call) => call.method), [
        'createInAppWebView',
        'dispose',
      ]);
    });

    test(
      'details callback can abandon creation before integer callback',
      () async {
        final controller = CustomPlatformViewController();
        Future<void>? disposal;
        await controller.initialize(
          onPlatformViewCreationDetails: (_) => disposal = controller.dispose(),
          onPlatformViewCreated: (_) => fail('Unexpected id'),
        );
        await disposal;
        expect(nativeCalls.last.method, 'dispose');
      },
    );
  });

  for (final isKeepAlive in [false, true]) {
    test(
      'factory failure preserves its error and closes the partial owner, keepAlive=$isKeepAlive',
      () async {
        final messenger =
            TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
        final keepAlive = isKeepAlive ? InAppWebViewKeepAlive() : null;
        final dynamic id = keepAlive?.id ?? 71;
        final channel = MethodChannel(
          'com.pichillilorenzo/flutter_inappwebview_$id',
        );
        final nativeCalls = <MethodCall>[];
        messenger.setMockMethodCallHandler(channel, (call) async {
          nativeCalls.add(call);
          return null;
        });
        addTearDown(() {
          messenger.setMockMethodCallHandler(channel, null);
          messenger.setMessageHandler(channel.name, null);
        });
        final failure = StateError('wrapper-failed');
        final originalStack = StackTrace.fromString(
          'controller-wrapper-origin',
        );
        WindowsInAppWebViewController? captured;
        WindowsWebViewCreationDetails? observed;
        var lateLoads = 0;
        Object? caught;
        StackTrace? caughtStack;
        try {
          WindowsInAppWebViewController(
            WindowsInAppWebViewControllerCreationParams(
              id: id,
              creationDetails: WindowsWebViewCreationResult.fromNative({
                'id': 71,
                'renderMode': 'composition',
              }).creationDetails,
              webviewParams: WindowsInAppWebViewWidgetCreationParams(
                keepAlive: keepAlive,
                onConsoleMessage: (_, _) {},
                onLoadStart: (_, _) => lateLoads++,
                controllerFromPlatform: (platform) {
                  captured = platform as WindowsInAppWebViewController;
                  observed = captured!.creationDetails;
                  Error.throwWithStackTrace(failure, originalStack);
                },
              ),
            ),
          );
        } catch (error, stack) {
          caught = error;
          caughtStack = stack;
        }
        expect(caught, same(failure));
        expect(caughtStack.toString(), originalStack.toString());
        expect(observed!.nativeViewId, 71);
        expect(captured!.creationDetails, isNull);
        expect(captured!.disposed, isTrue);
        expect(captured!.handler, isNull);
        // Cleanup of a captured failed controller must not read late webStorage
        // or send a native keepAlive unsubscribe after the original exception.
        captured!.dispose(isKeepAlive: isKeepAlive);
        captured!.dispose();
        await messenger.handlePlatformMessage(
          channel.name,
          const StandardMethodCodec().encodeMethodCall(
            const MethodCall('onLoadStart', {
              'url': 'https://example.invalid/late',
            }),
          ),
          null,
        );
        expect(lateLoads, 0);
        expect(nativeCalls, isEmpty);
      },
    );

    test(
      'a failed factory cannot remove or unsubscribe its replacement, keepAlive=$isKeepAlive',
      () async {
        final messenger =
            TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
        final keepAlive = isKeepAlive ? InAppWebViewKeepAlive() : null;
        final dynamic id = keepAlive?.id ?? 72;
        final channel = MethodChannel(
          'com.pichillilorenzo/flutter_inappwebview_$id',
        );
        final nativeCalls = <MethodCall>[];
        messenger.setMockMethodCallHandler(channel, (call) async {
          nativeCalls.add(call);
          return null;
        });
        messenger.setMockMethodCallHandler(
          IN_APP_WEBVIEW_STATIC_CHANNEL,
          (_) async => null,
        );
        addTearDown(() {
          messenger.setMockMethodCallHandler(channel, null);
          messenger.setMessageHandler(channel.name, null);
          messenger.setMockMethodCallHandler(
            IN_APP_WEBVIEW_STATIC_CHANNEL,
            null,
          );
        });
        final failure = StateError('old-wrapper-failed');
        WindowsInAppWebViewController? abandoned;
        late WindowsInAppWebViewController current;
        var oldLoads = 0;
        var currentLoads = 0;
        var currentConsoleMessages = 0;
        expect(
          () => WindowsInAppWebViewController(
            WindowsInAppWebViewControllerCreationParams(
              id: id,
              creationDetails: WindowsWebViewCreationResult.fromNative({
                'id': 71,
                'renderMode': 'hwnd',
              }).creationDetails,
              webviewParams: WindowsInAppWebViewWidgetCreationParams(
                keepAlive: keepAlive,
                onConsoleMessage: (_, _) {},
                onLoadStart: (_, _) => oldLoads++,
                controllerFromPlatform: (platform) {
                  abandoned = platform as WindowsInAppWebViewController;
                  // Reentrant registration on the same native channel is newer
                  // than the factory whose construction is about to fail.
                  current = WindowsInAppWebViewController(
                    WindowsInAppWebViewControllerCreationParams(
                      id: id,
                      creationDetails: WindowsWebViewCreationResult.fromNative({
                        'id': 72,
                        'renderMode': 'composition',
                      }).creationDetails,
                      webviewParams: WindowsInAppWebViewWidgetCreationParams(
                        keepAlive: keepAlive,
                        onLoadStart: (_, _) => currentLoads++,
                        onConsoleMessage: (_, _) => currentConsoleMessages++,
                      ),
                    ),
                  );
                  current.addJavaScriptHandler(
                    handlerName: 'current-owner',
                    callback: (_) => true,
                  );
                  throw failure;
                },
              ),
            ),
          ),
          throwsA(same(failure)),
        );
        expect(abandoned!.creationDetails, isNull);
        abandoned!.dispose(isKeepAlive: isKeepAlive);
        expect(current.creationDetails!.nativeViewId, 72);
        expect(
          current.hasJavaScriptHandler(handlerName: 'current-owner'),
          isTrue,
        );
        for (final call in const [
          MethodCall('onLoadStart', {'url': 'https://example.invalid/current'}),
          MethodCall('onConsoleMessage', {
            'message': 'current',
            'messageLevel': 1,
          }),
        ]) {
          await messenger.handlePlatformMessage(
            channel.name,
            const StandardMethodCodec().encodeMethodCall(call),
            null,
          );
        }
        expect(oldLoads, 0);
        expect(currentLoads, 1);
        expect(currentConsoleMessages, 1);
        expect(nativeCalls, isEmpty);
        current.dispose();
        if (keepAlive != null) {
          await WindowsInAppWebViewController.static().disposeKeepAlive(
            keepAlive,
          );
        }
      },
    );
  }

  test('controllers without widget observations remain unavailable', () async {
    final direct = WindowsInAppWebViewController(
      const PlatformInAppWebViewControllerCreationParams(id: 7),
    );
    expect(direct.creationDetails, isNull);
    direct.dispose();
    expect(direct.creationDetails, isNull);
    expect(WindowsInAppWebViewController.static().creationDetails, isNull);

    const browserManager = MethodChannel(
      'com.pichillilorenzo/flutter_inappbrowser',
    );
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(browserManager, (_) async => null);
    addTearDown(() => messenger.setMockMethodCallHandler(browserManager, null));
    final browser = WindowsInAppBrowser(
      const PlatformInAppBrowserCreationParams(),
    );
    expect(browser.webViewController, isNull);
    await browser.openUrlRequest(
      urlRequest: URLRequest(url: WebUri('about:blank')),
    );
    expect(browser.webViewController!.creationDetails, isNull);
    browser.dispose();
  });
}
