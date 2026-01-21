import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_inappwebview_example/screens/webview_environment_settings_editor_screen.dart';
import 'package:flutter_inappwebview_example/models/environment_setting_definition.dart';

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
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      try {
        await tester.pumpWidget(createWidget());
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Environment Settings'), findsOneWidget);
    });

    testWidgets('renders release channels as multi-select chips', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      try {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }

      await tester.ensureVisible(find.text('Release Channel'));
      await tester.tap(find.text('Release Channel'));
      await tester.pumpAndSettle();

      final stableLabel = EnvironmentSettingDefinition.enumDisplayName(
        EnvironmentReleaseChannels.STABLE,
      );

      expect(find.widgetWithText(FilterChip, stableLabel), findsOneWidget);
    });
  });
}
