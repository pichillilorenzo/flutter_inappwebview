import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_inappwebview_example/screens/settings_editor_screen.dart';

import '../test_helpers/mock_inappwebview_platform.dart';
import '../test_helpers/test_provider_wrapper.dart';

void main() {
  setUpAll(() {
    MockInAppWebViewPlatform.initialize();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SettingsEditorScreen', () {
    Widget createWidget() {
      return const MaterialApp(
        home: TestProviderWrapper(child: SettingsEditorScreen()),
      );
    }

    testWidgets('renders app bar title', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Settings Editor'), findsOneWidget);
    });

    testWidgets('shows search field after loading', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Search settings...'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });
}
