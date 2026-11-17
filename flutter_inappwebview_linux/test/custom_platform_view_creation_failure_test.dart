import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_linux/src/in_app_webview/custom_platform_view.dart';
import 'package:flutter_test/flutter_test.dart';

const _channel = MethodChannel(
  'com.pichillilorenzo/flutter_inappwebview_manager',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late List<MethodCall> calls;
  late List<LinuxWebViewCreationFailure> failures;
  late StreamSubscription<LinuxWebViewCreationFailure> subscription;

  void mockCreation(Future<Object?> Function() create) {
    messenger.setMockMethodCallHandler(_channel, (call) async {
      calls.add(call);
      return call.method == 'createInAppWebView' ? create() : null;
    });
  }

  setUp(() {
    calls = [];
    failures = [];
    subscription = LinuxWebViewCreationDiagnostics.creationErrors.listen(
      failures.add,
    );
  });

  tearDown(() async {
    await subscription.cancel();
    messenger.setMockMethodCallHandler(_channel, null);
  });

  test('native failure releases ready and preserves native diagnostics', () async {
    mockCreation(() async {
      throw PlatformException(
        code: 'WEBVIEW_CREATION_FAILED',
        message: 'connection refused',
        details: {'stage': 'wpe_display_connect', 'nativeCode': 12},
      );
    });
    final controller = CustomPlatformViewController();
    await expectLater(controller.initialize(), throwsA(isA<PlatformException>()));
    await controller.ready.timeout(const Duration(seconds: 1));
    await Future<void>.delayed(Duration.zero);
    expect(controller.value.isInitialized, isFalse);
    expect(failures, hasLength(1));
    final error = failures.single.error as PlatformException;
    expect(error.message, 'connection refused');
    expect(error.details['stage'], 'wpe_display_connect');
    expect(error.details['nativeCode'], 12);
    await controller.dispose();
    expect(calls.map((call) => call.method), ['createInAppWebView']);
  });

  test('dispose waiting for creation completes after failure', () async {
    final creation = Completer<Object?>();
    mockCreation(() => creation.future);
    final controller = CustomPlatformViewController();
    final initialization = expectLater(
      controller.initialize(),
      throwsA(isA<PlatformException>()),
    );
    final disposal = controller.dispose();
    creation.completeError(PlatformException(code: 'WEBVIEW_CREATION_FAILED'));
    await initialization;
    await disposal.timeout(const Duration(seconds: 1));
    expect(calls.map((call) => call.method), ['createInAppWebView']);
  });

  test('unexpected null reply remains observable and releases waiters', () async {
    mockCreation(() async => null);
    final reports = <FlutterErrorDetails>[];
    final previousHandler = FlutterError.onError;
    FlutterError.onError = reports.add;
    addTearDown(() => FlutterError.onError = previousHandler);
    final controller = CustomPlatformViewController();
    await expectLater(controller.initialize(), throwsA(isA<TypeError>()));
    await controller.ready.timeout(const Duration(seconds: 1));
    await Future<void>.delayed(Duration.zero);
    expect(failures, hasLength(1));
    expect(failures.single.error, isA<TypeError>());
    expect(reports, hasLength(1));
    expect(reports.single.exception, same(failures.single.error));
    await controller.dispose();
    expect(calls.map((call) => call.method), ['createInAppWebView']);
  });
}
