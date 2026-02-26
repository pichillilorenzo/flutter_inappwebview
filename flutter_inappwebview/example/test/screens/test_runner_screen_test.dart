import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_inappwebview_example/models/test_configuration.dart';
import 'package:flutter_inappwebview_example/providers/test_runner.dart';
import 'package:flutter_inappwebview_example/screens/test_automation/test_runner_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TestRunnerScreen', () {
    Future<void> pumpScreen(
      WidgetTester tester, {
      required double width,
    }) async {
      final now = DateTime(2024, 1, 1);
      final config = TestConfiguration(
        id: 'mobile_config',
        name: 'Mobile Config',
        createdAt: now,
        modifiedAt: now,
        webViewType: TestWebViewType.headless,
        customSteps: const [],
      );

      SharedPreferences.setMockInitialValues({
        'test_runner_last_config': config.toJsonString(),
        'test_runner_last_webview_type': TestWebViewType.headless.name,
        'test_saved_configs': <String>[],
        'test_current_config': config.toJsonString(),
      });

      await tester.binding.setSurfaceSize(Size(width, 800));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => TestRunner()),
            ChangeNotifierProvider(create: (_) => TestConfigurationManager()),
          ],
          child: MaterialApp(home: const TestRunnerScreen()),
        ),
      );

      await tester.pumpAndSettle();
    }

    testWidgets('test_test_runner_stacks_on_mobile', (tester) async {
      await pumpScreen(tester, width: 500);

      final panels = find.byKey(const ValueKey('testRunnerPanels'));
      expect(panels, findsOneWidget);
      final flex = tester.widget<Flex>(panels);
      expect(flex.direction, Axis.vertical);
    });

    testWidgets('test_control_bar_wraps_on_mobile', (tester) async {
      await pumpScreen(tester, width: 500);

      final wrapFinder = find.byKey(const ValueKey('testRunnerControlBarWrap'));
      expect(wrapFinder, findsOneWidget);
      final wrapWidget = tester.widget<Wrap>(wrapFinder);
      expect(wrapWidget.spacing, 8);
      expect(wrapWidget.runSpacing, 8);
    });
  });
}
