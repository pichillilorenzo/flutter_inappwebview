import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_inappwebview_example/screens/settings_editor_screen.dart';
import 'package:flutter_inappwebview_example/widgets/settings/responsive_setting_tile.dart';

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
    Widget createWidget({Size size = const Size(800, 600)}) {
      return MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: size),
          child: const TestProviderWrapper(child: SettingsEditorScreen()),
        ),
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

    testWidgets('test_setting_tile_mobile_layout', (tester) async {
      await tester.pumpWidget(createWidget(size: const Size(375, 812)));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Expand All'));
      await tester.pumpAndSettle();

      final tileFinder = find.byType(ResponsiveSettingTile);
      expect(tileFinder, findsWidgets);

      final mobileLayoutFinder = find.descendant(
        of: tileFinder.first,
        matching: find.byKey(
          const ValueKey('responsive_setting_tile_mobile_layout'),
        ),
      );
      final inlineLayoutFinder = find.descendant(
        of: tileFinder.first,
        matching: find.byKey(
          const ValueKey('responsive_setting_tile_inline_control'),
        ),
      );

      expect(
        mobileLayoutFinder.evaluate().isNotEmpty ||
            inlineLayoutFinder.evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('test_settings_bottom_bar_wraps', (tester) async {
      await tester.pumpWidget(createWidget(size: const Size(375, 812)));
      await tester.pumpAndSettle();

      final actionsFinder = find.byKey(
        const ValueKey('settings_bottom_bar_actions'),
      );
      expect(actionsFinder, findsOneWidget);

      final actionsWidget = tester.widget(actionsFinder);
      expect(actionsWidget, isA<Wrap>());
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
