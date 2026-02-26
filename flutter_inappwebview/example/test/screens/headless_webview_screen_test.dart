import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview_example/providers/event_log_provider.dart';
import 'package:flutter_inappwebview_example/providers/settings_manager.dart';
import 'package:flutter_inappwebview_example/screens/browsers/headless_webview_screen.dart';
import '../test_helpers/test_settings_manager.dart';

void main() {
  group('HeadlessWebViewScreen', () {
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
        child: const MaterialApp(home: HeadlessWebViewScreen()),
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

    testWidgets('test_headless_config_stacks_on_mobile', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(320, 640);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });

      await tester.pumpWidget(createWidget());
      await tester.pump();

      final widthField = find.byKey(const Key('headless_webview_width_field'));
      final heightField = find.byKey(
        const Key('headless_webview_height_field'),
      );

      final mainScrollView = find
          .descendant(
            of: find.byKey(const Key('headless_webview_main_list')),
            matching: find.byType(Scrollable),
          )
          .first;

      await tester.scrollUntilVisible(
        widthField,
        200,
        scrollable: mainScrollView,
      );
      await tester.pump();

      expect(widthField, findsOneWidget);
      expect(heightField, findsOneWidget);

      final widthTop = tester.getTopLeft(widthField).dy;
      final heightTop = tester.getTopLeft(heightField).dy;

      expect(heightTop, greaterThan(widthTop));
      expect(tester.takeException(), isNull);
    });
  });
}
