import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview_example/providers/event_log_provider.dart';
import 'package:flutter_inappwebview_example/providers/settings_manager.dart';
import 'package:flutter_inappwebview_example/screens/browsers/inapp_browser_screen.dart';
import '../test_helpers/test_settings_manager.dart';

void main() {
  group('InAppBrowserScreen', () {
    Widget createWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<EventLogProvider>(
            create: (_) => EventLogProvider(),
          ),
          ChangeNotifierProvider<SettingsManager>(
            create: (_) => TestSettingsManager(),
          ),
        ],
        child: const MaterialApp(home: InAppBrowserScreen()),
      );
    }

    testWidgets('does not overflow on small height', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(320, 280);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });

      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('test_inapp_browser_mobile_layout', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(320, 640);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });

      await tester.pumpWidget(createWidget());
      await tester.pump();

      final idField = find.byKey(const Key('inapp_browser_menu_id_field'));
      final titleField = find.byKey(
        const Key('inapp_browser_menu_title_field'),
      );
      final addButton = find.byKey(const Key('inapp_browser_menu_add_button'));

      final mainScrollView = find
          .descendant(
            of: find.byKey(const Key('inapp_browser_main_list')),
            matching: find.byType(Scrollable),
          )
          .first;

      await tester.scrollUntilVisible(idField, 200, scrollable: mainScrollView);
      await tester.pump();

      expect(idField, findsOneWidget);
      expect(titleField, findsOneWidget);
      expect(addButton, findsOneWidget);

      final idTop = tester.getTopLeft(idField).dy;
      final titleTop = tester.getTopLeft(titleField).dy;
      final addTop = tester.getTopLeft(addButton).dy;

      expect(titleTop, greaterThan(idTop));
      expect(addTop, greaterThan(titleTop));
      expect(tester.takeException(), isNull);
    });
  });
}
