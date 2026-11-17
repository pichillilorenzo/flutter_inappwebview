import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_linux/src/in_app_browser/in_app_browser.dart';

const _browserChannel = MethodChannel(
  'com.pichillilorenzo/flutter_inappbrowser',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('failed open resets state and permits a later retry', () async {
    var openCalls = 0;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(_browserChannel, (call) async {
      if (call.method == 'open') {
        openCalls++;
        if (openCalls == 1) {
          throw PlatformException(
            code: 'WEBVIEW_CREATION_FAILED',
            message: 'WebView initialization failed',
            details: <String, Object?>{'stage': 'InAppWebView.<init>'},
          );
        }
        return true;
      }
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(_browserChannel, null),
    );

    final browser = LinuxInAppBrowser(LinuxInAppBrowserCreationParams());
    await expectLater(
      browser.openFile(assetFilePath: 'index.html'),
      throwsA(isA<PlatformException>()),
    );
    expect(browser.isOpened(), isFalse);

    await browser.openFile(assetFilePath: 'index.html');
    expect(openCalls, 2);
    expect(browser.isOpened(), isTrue);
  });
}
