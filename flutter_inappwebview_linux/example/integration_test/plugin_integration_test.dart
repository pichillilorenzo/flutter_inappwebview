// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_inappwebview_linux/flutter_inappwebview_linux.dart';
import 'package:flutter_inappwebview_linux/src/in_app_webview/custom_platform_view.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('LinuxInAppWebViewWidget can be created', (WidgetTester tester) async {
    LinuxInAppWebViewPlatform.registerWith();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => LinuxInAppWebViewWidget(
              LinuxInAppWebViewWidgetCreationParams(
                initialUrlRequest: URLRequest(url: WebUri('https://flutter.dev')),
              ),
            ).build(context),
          ),
        ),
      ),
    );

    // Wait for the widget to be created
    await tester.pump();

    // Verify that the custom platform view was created
    expect(find.byType(CustomPlatformView), findsOneWidget);
  });
}
