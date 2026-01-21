import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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

    testWidgets('uses enum-like values for enumeration dropdowns', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Expand All'));
      await tester.pumpAndSettle();

      await tester.dragUntilVisible(
        find.text('Mixed Content Mode'),
        find.byType(ListView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      final dropdownFinder = find.byType(
        DropdownButton<dynamic>,
        skipOffstage: false,
      );
      expect(dropdownFinder, findsWidgets);

      final dropdown = tester.widget<DropdownButton<dynamic>>(
        dropdownFinder.first,
      );
      final items = dropdown.items ?? [];
      final nonNullItem = items.firstWhere((item) => item.value != null);
      final value = nonNullItem.value;
      final isEnumLike = value is Enum || _hasToNativeValue(value);

      expect(isEnumLike, isTrue);
    });
  });
}

bool _hasToNativeValue(dynamic value) {
  try {
    // Only care that the method exists and is callable.
    (value as dynamic).toNativeValue();
    return true;
  } catch (_) {
    return false;
  }
}
