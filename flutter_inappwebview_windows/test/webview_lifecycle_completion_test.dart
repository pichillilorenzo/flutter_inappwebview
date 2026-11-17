import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart'
    show InternalChannelController;
import 'package:flutter_inappwebview_windows/flutter_inappwebview_windows.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(
    'com.pichillilorenzo/flutter_inappwebview_lifecycle-test',
  );
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late WindowsInAppWebViewController controller;

  setUp(() {
    controller = WindowsInAppWebViewController(
      const WindowsInAppWebViewControllerCreationParams(id: 'lifecycle-test'),
    );
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    if (!controller.disposed) controller.dispose();
  });

  for (final method in ['pause', 'resume']) {
    Future<void> perform() =>
        method == 'pause' ? controller.pause() : controller.resume();

    testWidgets('$method awaits native completion', (tester) async {
      final native = Completer<bool>();
      messenger.setMockMethodCallHandler(channel, (call) {
        expect(call.method, method);
        expect(call.arguments, isEmpty);
        return native.future;
      });
      var completed = false;
      final result = perform().then((_) => completed = true);
      await tester.pump();
      expect(completed, isFalse);
      native.complete(true);
      await tester.pump();
      await result;
      expect(completed, isTrue);
    });

    for (final code in [
      'WEBVIEW_SUSPEND_REJECTED',
      'WEBVIEW_LIFECYCLE_CANCELLED',
      'WEBVIEW_LIFECYCLE_FAILED',
      'WEBVIEW_LIFECYCLE_TIMEOUT',
      'WEBVIEW_LIFECYCLE_UNAVAILABLE',
      'WEBVIEW_DISPOSED',
    ]) {
      test('$method propagates $code', () async {
        messenger.setMockMethodCallHandler(channel, (_) async {
          throw PlatformException(code: code, details: -1);
        });
        await expectLater(
          perform(),
          throwsA(
            isA<PlatformException>()
                .having((error) => error.code, 'code', code)
                .having((error) => error.details, 'details', -1),
          ),
        );
      });
    }

    for (final unconfirmed in [null, false]) {
      test('$method rejects unconfirmed native reply $unconfirmed', () async {
        messenger.setMockMethodCallHandler(channel, (_) async => unconfirmed);
        await expectLater(
          perform(),
          throwsA(
            isA<PlatformException>().having(
              (error) => error.code,
              'code',
              'WEBVIEW_LIFECYCLE_FAILED',
            ),
          ),
        );
      });
    }

    test('$method after dispose fails without calling native', () async {
      var calls = 0;
      messenger.setMockMethodCallHandler(channel, (_) async {
        calls++;
        return true;
      });
      controller.dispose();
      await expectLater(
        perform(),
        throwsA(
          isA<PlatformException>().having(
            (error) => error.code,
            'code',
            'WEBVIEW_DISPOSED',
          ),
        ),
      );
      expect(calls, 0);
    });

    testWidgets('$method cannot succeed after disposal', (tester) async {
      final native = Completer<bool>();
      messenger.setMockMethodCallHandler(channel, (_) => native.future);
      final expectation = expectLater(
        perform(),
        throwsA(
          isA<PlatformException>().having(
            (error) => error.code,
            'code',
            'WEBVIEW_DISPOSED',
          ),
        ),
      );
      await tester.pump();
      controller.dispose();
      native.complete(true);
      await tester.pump();
      await expectation;
    });
  }
}
