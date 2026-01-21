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
  });
}
