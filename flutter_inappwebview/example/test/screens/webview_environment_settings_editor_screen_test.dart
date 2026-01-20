import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_inappwebview_example/screens/webview_environment_settings_editor_screen.dart';

import '../test_helpers/mock_inappwebview_platform.dart';
import '../test_helpers/test_provider_wrapper.dart';

void main() {
  setUpAll(() {
    MockInAppWebViewPlatform.initialize();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WebViewEnvironmentSettingsEditorScreen', () {
    Widget createWidget() {
      return const MaterialApp(
        home: TestProviderWrapper(
          child: WebViewEnvironmentSettingsEditorScreen(),
        ),
      );
    }

    testWidgets('renders app bar title', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Environment Settings'), findsOneWidget);
    });

    testWidgets('shows unsupported platform banner after loading', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Limited Platform Support'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsWidgets);
    });
  });
}
