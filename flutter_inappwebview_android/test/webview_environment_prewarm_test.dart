import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(
    'com.pichillilorenzo/flutter_webview_environment',
  );
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  PlatformWebViewEnvironment environment() =>
      AndroidInAppWebViewPlatform().createPlatformWebViewEnvironmentStatic();

  test(
    'prewarm dispatches through Android static environment and decodes result',
    () async {
      MethodCall? dispatched;
      messenger.setMockMethodCallHandler(channel, (call) async {
        dispatched = call;
        return {'status': 'ok', 'durationMs': 17};
      });

      final result = await environment().prewarm(
        settings: WebViewEnvironmentSettings(userDataFolder: 'windows-only'),
      );

      expect(dispatched!.method, 'prewarm');
      expect(dispatched!.arguments, isNull);
      expect(result!.succeeded, isTrue);
      expect(result.duration, const Duration(milliseconds: 17));
      expect(result.errorCode, isNull);
    },
  );

  test('startup failure is returned without throwing', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      return {'status': 'create_failed', 'durationMs': 8};
    });
    final result = await environment().prewarm();
    expect(result!.status, 'create_failed');
    expect(result.succeeded, isFalse);
  });

  test('older native plugin and channel failures remain best effort', () async {
    expect((await environment().prewarm())!.status, 'unavailable');
    messenger.setMockMethodCallHandler(channel, (call) async {
      throw PlatformException(code: 'engine_detached');
    });
    expect((await environment().prewarm())!.status, 'unavailable');
  });

  test('malformed native replies remain best effort', () async {
    for (final reply in <Object>[
      'not a map',
      {'status': 42, 'durationMs': 8},
      {'status': 'ok', 'durationMs': 'not a duration'},
    ]) {
      messenger.setMockMethodCallHandler(channel, (call) async => reply);
      expect((await environment().prewarm())!.status, 'unavailable');
    }
  });

  testWidgets('channel deadline completes if native never replies', (
    tester,
  ) async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      await Future<void>.delayed(const Duration(days: 1));
      return null;
    });
    WebViewEnvironmentPrewarmResult? result;
    environment().prewarm().then((value) => result = value);
    await tester.pump(const Duration(seconds: 36));
    expect(result!.status, 'timeout');
    await tester.pump(const Duration(days: 1));
  });
}
