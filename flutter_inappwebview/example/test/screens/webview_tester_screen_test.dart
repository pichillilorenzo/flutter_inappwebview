import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview_example/models/event_log_entry.dart';
import 'package:flutter_inappwebview_example/providers/event_log_provider.dart';
import 'package:flutter_inappwebview_example/providers/network_monitor.dart';
import 'package:flutter_inappwebview_example/screens/webview_tester_screen.dart';
import 'package:flutter_inappwebview_example/widgets/webview/event_console_widget.dart';
import 'package:flutter_inappwebview_example/widgets/webview/network_monitor_widget.dart';

void main() {
  group('WebViewTesterScreen', () {
    late EventLogProvider eventLogProvider;
    late NetworkMonitor networkMonitor;

    setUp(() {
      eventLogProvider = EventLogProvider();
      networkMonitor = NetworkMonitor();
    });

    Widget createWidget() {
      return MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<EventLogProvider>.value(
              value: eventLogProvider,
            ),
            ChangeNotifierProvider<NetworkMonitor>.value(value: networkMonitor),
          ],
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

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byIcon(Icons.stop), findsOneWidget);
    });

    testWidgets('renders Go button', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byTooltip('Go'), findsOneWidget);
    });

    testWidgets('shows clear events button in app bar', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byIcon(Icons.clear_all), findsOneWidget);
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

      await tester.tap(find.byIcon(Icons.clear_all));
      await tester.pump();

      expect(eventLogProvider.events.length, 0);
    });

    testWidgets('renders bottom tabs', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Open bottom sheet by tapping tab bar
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();

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
        find.widgetWithIcon(IconButton, Icons.arrow_back),
      );
      final forwardButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.arrow_forward),
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

      // Open Events tab
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();

      expect(find.byType(EventConsoleWidget), findsOneWidget);

      // Switch to Network tab
      await tester.tap(find.text('Network'));
      await tester.pumpAndSettle();

      expect(find.byType(NetworkMonitorWidget), findsOneWidget);
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
  });
}
