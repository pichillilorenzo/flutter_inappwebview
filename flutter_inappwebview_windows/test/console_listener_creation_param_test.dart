import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_inappwebview_windows/src/in_app_webview/_static_channel.dart';
import 'package:flutter_inappwebview_windows/src/in_app_webview/custom_platform_view.dart';
import 'package:flutter_inappwebview_windows/src/in_app_webview/in_app_webview.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final createdWith = <Map<Object?, Object?>>[];

  setUp(() {
    createdWith.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(IN_APP_WEBVIEW_STATIC_CHANNEL, (call) async {
          if (call.method == 'createInAppWebView') {
            createdWith.add(call.arguments as Map<Object?, Object?>);
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(IN_APP_WEBVIEW_STATIC_CHANNEL, null);
  });

  // Creation starts with no Dart controller. The widget attaches its listener
  // in onPlatformViewCreated; an abandoned keepAlive creation stays silent.
  Future<Object?> consoleFlag(
    WidgetTester tester,
    WindowsInAppWebViewWidgetCreationParams params,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) =>
              WindowsInAppWebViewWidget(params).build(context),
        ),
      ),
    );
    await tester.pump();
    final view = tester.widget<CustomPlatformView>(
      find.byType(CustomPlatformView),
    );
    return (view.creationParams as Map)['hasConsoleMessageListener'];
  }

  testWidgets('a pending console listener waits for its Dart owner', (
    tester,
  ) async {
    expect(
      await consoleFlag(
        tester,
        WindowsInAppWebViewWidgetCreationParams(
          onConsoleMessage: (controller, message) {},
        ),
      ),
      isFalse,
    );
  });

  testWidgets('no console listener is announced as such', (tester) async {
    expect(
      await consoleFlag(tester, WindowsInAppWebViewWidgetCreationParams()),
      isFalse,
    );
  });
}
