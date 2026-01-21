import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview_example/models/event_log_entry.dart';
import 'package:flutter_inappwebview_example/providers/event_log_provider.dart';
import 'package:flutter_inappwebview_example/widgets/webview/event_console_widget.dart';

void main() {
  group('EventConsoleWidget', () {
    late EventLogProvider eventLogProvider;

    setUp(() {
      eventLogProvider = EventLogProvider();
    });

    Widget createWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<EventLogProvider>.value(
          value: eventLogProvider,
          child: Scaffold(body: EventConsoleWidget()),
        ),
      );
    }

    testWidgets('renders empty state when no events', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('No events logged yet'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('displays events in list', (tester) async {
      eventLogProvider.addEvent(
        EventLogEntry(
          timestamp: DateTime.now(),
          eventType: EventType.navigation,
          message: 'Page loaded',
        ),
      );

      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.text('Page loaded'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('shows clear button in header', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byTooltip('Clear'), findsOneWidget);
    });

    testWidgets('clear button clears events', (tester) async {
      eventLogProvider.addEvent(
        EventLogEntry(
          timestamp: DateTime.now(),
          eventType: EventType.navigation,
          message: 'Event 1',
        ),
      );

      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.text('Event 1'), findsOneWidget);

      await tester.tap(find.byTooltip('Clear'));
      await tester.pump();

      expect(find.text('Event 1'), findsNothing);
      expect(find.text('No events logged yet'), findsOneWidget);
    });

    testWidgets('displays filter dropdown', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(DropdownButton<EventType?>), findsOneWidget);
    });

    testWidgets('filter dropdown shows all event types', (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.byType(DropdownButton<EventType?>));
      await tester.pumpAndSettle();

      expect(find.text('All Events'), findsWidgets);
      for (final type in EventType.values) {
        expect(find.text(type.name), findsOneWidget);
      }
    });

    testWidgets('filters events by type', (tester) async {
      eventLogProvider.addEvent(
        EventLogEntry(
          timestamp: DateTime.now(),
          eventType: EventType.navigation,
          message: 'Navigation event',
        ),
      );
      eventLogProvider.addEvent(
        EventLogEntry(
          timestamp: DateTime.now(),
          eventType: EventType.error,
          message: 'Error event',
        ),
      );

      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Initially shows both
      expect(find.text('Navigation event'), findsOneWidget);
      expect(find.text('Error event'), findsOneWidget);

      // Filter by navigation
      await tester.tap(find.byType(DropdownButton<EventType?>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('navigation').last);
      await tester.pumpAndSettle();

      expect(find.text('Navigation event'), findsOneWidget);
      expect(find.text('Error event'), findsNothing);
    });

    testWidgets('event item displays timestamp and type', (tester) async {
      final timestamp = DateTime(2025, 1, 1, 12, 30);
      eventLogProvider.addEvent(
        EventLogEntry(
          timestamp: timestamp,
          eventType: EventType.javascript,
          message: 'JS executed',
        ),
      );

      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.text('JS executed'), findsOneWidget);
      expect(find.textContaining('12:30'), findsOneWidget);
      expect(find.text('javascript'), findsOneWidget);
    });

    testWidgets('event item can be expanded for details', (tester) async {
      final data = {'url': 'https://example.com', 'duration': '150ms'};
      eventLogProvider.addEvent(
        EventLogEntry(
          timestamp: DateTime.now(),
          eventType: EventType.network,
          message: 'Request completed',
          data: data,
        ),
      );

      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Initially data is hidden
      expect(find.text('url'), findsNothing);

      // Find and tap the expansion tile
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      // Now data should be visible
      expect(find.textContaining('url'), findsOneWidget);
      expect(find.textContaining('https://example.com'), findsOneWidget);
    });

    testWidgets('multiple events are displayed in order', (tester) async {
      eventLogProvider.addEvent(
        EventLogEntry(
          timestamp: DateTime.now(),
          eventType: EventType.navigation,
          message: 'Event 1',
        ),
      );
      eventLogProvider.addEvent(
        EventLogEntry(
          timestamp: DateTime.now(),
          eventType: EventType.navigation,
          message: 'Event 2',
        ),
      );
      eventLogProvider.addEvent(
        EventLogEntry(
          timestamp: DateTime.now(),
          eventType: EventType.navigation,
          message: 'Event 3',
        ),
      );

      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.text('Event 1'), findsOneWidget);
      expect(find.text('Event 2'), findsOneWidget);
      expect(find.text('Event 3'), findsOneWidget);
    });

    testWidgets('event types have different colors', (tester) async {
      eventLogProvider.addEvent(
        EventLogEntry(
          timestamp: DateTime.now(),
          eventType: EventType.error,
          message: 'Error message',
        ),
      );

      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Find Container with error color
      final container = tester.widget<Container>(
        find
            .ancestor(of: find.text('error'), matching: find.byType(Container))
            .first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.red.shade50);
    });
  });
}
