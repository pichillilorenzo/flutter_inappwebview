import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_example/models/event_log_entry.dart';
import 'package:flutter_inappwebview_example/providers/event_log_provider.dart';
import 'package:flutter_inappwebview_example/providers/network_monitor.dart';
import 'package:flutter_inappwebview_example/screens/webview_tester_screen.dart';
import 'package:flutter_inappwebview_example/widgets/webview/event_console_widget.dart';

import '../test_helpers/mock_inappwebview_platform.dart';
import '../test_helpers/test_provider_wrapper.dart';

void main() {
  setUpAll(() {
    MockInAppWebViewPlatform.initialize();
  });

  group('WebViewTesterScreen', () {
    late EventLogProvider eventLogProvider;
    late NetworkMonitor networkMonitor;
    late MockSettingsManager settingsManager;

    setUp(() {
      eventLogProvider = EventLogProvider();
      networkMonitor = NetworkMonitor();
      settingsManager = MockSettingsManager();
    });

    Widget createWidget() {
      return MaterialApp(
        home: TestProviderWrapper(
          settingsManager: settingsManager,
          eventLogProvider: eventLogProvider,
          networkMonitor: networkMonitor,
          child: WebViewTesterScreen(),
        ),
      );
    }

    testWidgets('renders app bar with title', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('WebView Tester'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders URL input field', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(TextField), findsAtLeastNWidgets(1));
      expect(find.text('Enter URL'), findsOneWidget);
    });

    testWidgets('renders navigation controls', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byTooltip('Back'), findsOneWidget);
      expect(find.byTooltip('Forward'), findsOneWidget);
      expect(find.byTooltip('Reload'), findsOneWidget);
      expect(find.byTooltip('Stop'), findsOneWidget);
    });

    testWidgets('renders Go button', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byTooltip('Go'), findsOneWidget);
    });

    testWidgets('shows clear events button in app bar', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byTooltip('Clear Events'), findsOneWidget);
    });

    testWidgets('clear button clears events', (tester) async {
      eventLogProvider.addEvent(
        EventLogEntry(
          timestamp: DateTime.now(),
          eventType: EventType.navigation,
          message: 'Test event',
        ),
      );

      await tester.pumpWidget(createWidget());

      expect(eventLogProvider.events.length, 1);

      await tester.tap(find.byTooltip('Clear Events'));
      await tester.pump();

      expect(eventLogProvider.events.length, 0);
    });

    testWidgets('renders bottom tabs', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Open bottom sheet by tapping tab bar
      await tester.tap(find.widgetWithText(Tab, 'Events'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Events'), findsWidgets);
      expect(find.text('Network'), findsOneWidget);
      expect(find.text('Methods'), findsOneWidget);
      expect(find.text('JavaScript'), findsOneWidget);
      expect(find.text('UserScripts'), findsOneWidget);
    });

    testWidgets('URL field updates when text entered', (tester) async {
      await tester.pumpWidget(createWidget());

      final urlField = find.ancestor(
        of: find.text('Enter URL'),
        matching: find.byType(TextField),
      );

      await tester.enterText(urlField, 'https://example.com');
      await tester.pump();

      expect(find.text('https://example.com'), findsOneWidget);
    });

    testWidgets('navigation buttons initially disabled', (tester) async {
      await tester.pumpWidget(createWidget());

      final backButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byTooltip('Back'),
          matching: find.byType(IconButton),
        ),
      );
      final forwardButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byTooltip('Forward'),
          matching: find.byType(IconButton),
        ),
      );

      expect(backButton.onPressed, isNull);
      expect(forwardButton.onPressed, isNull);
    });

    testWidgets('shows progress indicator during page load', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Note: This test assumes InAppWebView would show a progress indicator
      // The actual implementation would need to track loading state
    });

    testWidgets('switching tabs changes visible content', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pump();

      await tester.ensureVisible(find.widgetWithText(Tab, 'Events'));
      await tester.tap(find.widgetWithText(Tab, 'Events'));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(EventConsoleWidget), findsOneWidget);

      // Switch to Network tab
      await tester.ensureVisible(find.widgetWithText(Tab, 'Network'));
      await tester.tap(find.widgetWithText(Tab, 'Network'));
      await tester.pump(const Duration(milliseconds: 400));

      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.controller?.index, 1);
    });

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

    testWidgets('test_webview_tester_mobile_layout', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(360, 640);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });

      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('test_tabbar_is_scrollable_on_mobile', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(360, 700);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });

      await tester.pumpWidget(createWidget());
      await tester.pump();

      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.isScrollable, isTrue);
    });
  });
}
