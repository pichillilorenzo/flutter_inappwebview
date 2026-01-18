import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview_example/providers/event_log_provider.dart';
import 'package:flutter_inappwebview_example/screens/advanced/controllers_screen.dart';

void main() {
  group('ControllersScreen', () {
    Widget createWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<EventLogProvider>(
            create: (_) => EventLogProvider(),
          ),
        ],
        child: const MaterialApp(home: ControllersScreen()),
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
