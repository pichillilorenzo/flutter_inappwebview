import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_inappwebview_windows/flutter_inappwebview_windows.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(
    'com.pichillilorenzo/flutter_webview_environment',
  );
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final environment = WindowsWebViewEnvironment.static();

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('prewarm forwards settings and decodes the native result', () async {
    final settings = WebViewEnvironmentSettings(
      browserExecutableFolder: r'C:\runtime',
      userDataFolder: r'C:\profile',
      language: 'he',
    );
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'prewarm');
      expect(call.arguments['settings'], settings.toMap());
      return {'status': 'ok', 'errorCode': 0, 'durationMs': 12};
    });
    final result = (await environment.prewarm(settings: settings))!;
    expect(result.succeeded, isTrue);
    expect(result.duration, const Duration(milliseconds: 12));
    expect(result.errorCode, 0);
  });

  test('native errors are best effort results', () async {
    messenger.setMockMethodCallHandler(channel, (_) async {
      throw PlatformException(code: 'unavailable');
    });
    expect((await environment.prewarm())!.status, 'unavailable');
  });

  test('missing native method is best effort', () async {
    // An absent mock/native handler returns a missing-plugin envelope.
    expect((await environment.prewarm())!.status, 'unavailable');
  });

  test('malformed native result does not throw', () async {
    messenger.setMockMethodCallHandler(channel, (_) async => {'status': 12});
    expect((await environment.prewarm())!.status, 'unavailable');
  });

  test('native null stays unsupported', () async {
    messenger.setMockMethodCallHandler(channel, (_) async => null);
    expect(await environment.prewarm(), isNull);
  });

  testWidgets('an unresponsive native method cannot strand the Future', (
    tester,
  ) async {
    final native = Completer<Map<String, dynamic>>();
    messenger.setMockMethodCallHandler(channel, (_) => native.future);
    final result = environment.prewarm();
    await tester.pump(const Duration(seconds: 31));
    expect((await result)!.status, 'timeout');
    // Late native completion must not create a second Dart completion/error.
    native.complete({'status': 'ok', 'errorCode': 0, 'durationMs': 32000});
    await tester.pump();
  });
}
