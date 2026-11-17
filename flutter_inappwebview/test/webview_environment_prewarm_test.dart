import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_ios/flutter_inappwebview_ios.dart';
import 'package:flutter_inappwebview_linux/flutter_inappwebview_linux.dart';
import 'package:flutter_inappwebview_macos/flutter_inappwebview_macos.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(
    'com.pichillilorenzo/flutter_webview_environment',
  );
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final originalPlatform =
      InAppWebViewPlatform.instance ?? AndroidInAppWebViewPlatform();

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    InAppWebViewPlatform.instance = originalPlatform;
  });

  test(
    'public prewarm API delegates to the registered Android implementation',
    () async {
      AndroidInAppWebViewPlatform.registerWith();
      MethodCall? dispatched;
      messenger.setMockMethodCallHandler(channel, (call) async {
        dispatched = call;
        return {'status': 'ok', 'durationMs': 12};
      });

      final result = await WebViewEnvironment.prewarm();
      expect(dispatched!.method, 'prewarm');
      expect(result!.succeeded, isTrue);
      expect(result.duration, const Duration(milliseconds: 12));
    },
  );

  test('prewarm support metadata includes Android and Windows only', () {
    AndroidInAppWebViewPlatform.registerWith();
    for (final platform in TargetPlatform.values) {
      expect(
        WebViewEnvironment.isMethodSupported(
          PlatformWebViewEnvironmentMethod.prewarm,
          platform: platform,
        ),
        platform == TargetPlatform.android ||
            platform == TargetPlatform.windows,
        reason: '$platform',
      );
    }
  });

  test(
    'unsupported iOS, macOS and Linux prewarm returns null without native work',
    () async {
      var nativeCalls = 0;
      messenger.setMockMethodCallHandler(channel, (call) async {
        nativeCalls++;
        throw StateError('unsupported prewarm must not invoke native startup');
      });
      for (final platform in <InAppWebViewPlatform>[
        IOSInAppWebViewPlatform(),
        MacOSInAppWebViewPlatform(),
        LinuxInAppWebViewPlatform(),
      ]) {
        InAppWebViewPlatform.instance = platform;
        expect(
          await WebViewEnvironment.prewarm(),
          isNull,
          reason: '${platform.runtimeType}',
        );
      }
      expect(nativeCalls, 0);
    },
  );
}
