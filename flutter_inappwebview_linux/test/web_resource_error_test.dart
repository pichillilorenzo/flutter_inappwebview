import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_linux/flutter_inappwebview_linux.dart';
import 'package:flutter_inappwebview_linux/src/in_app_webview/in_app_webview_controller.dart'
    show InternalInAppWebViewController;
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    LinuxInAppWebViewPlatform.registerWith();
  });
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  for (final code in [302, 399, -1, 987654]) {
    test('delivers load error code $code without throwing', () async {
      WebResourceError? received;
      final controller = LinuxInAppWebViewController(
        LinuxInAppWebViewControllerCreationParams(
          id: 'error-test',
          webviewParams: PlatformWebViewCreationParams(
            onReceivedError: (_, request, error) => received = error,
          ),
        ),
      );
      addTearDown(controller.dispose);

      await controller.handleMethod(MethodCall('onReceivedError', {
        'request': {'url': 'https://example.test/', 'isForMainFrame': true},
        'error': {'description': 'Original load failure', 'type': code},
      }));

      expect(received?.description, 'Original load failure');
      expect(
        received?.type,
        code == 302 ? WebResourceErrorType.CANCELLED : WebResourceErrorType.UNKNOWN,
      );
    });
  }
}
