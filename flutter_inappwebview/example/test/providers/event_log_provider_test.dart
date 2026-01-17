import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_example/providers/event_log_provider.dart';
import 'package:flutter_inappwebview_example/models/event_log_entry.dart';

void main() {
  group('EventLogProvider', () {
    late EventLogProvider provider;

    setUp(() {
      provider = EventLogProvider();
    });

    test('addEvent should add event to list', () {
      final entry = EventLogEntry(
        timestamp: DateTime.now(),
        eventType: EventType.navigation,
        message: 'Test event',
      );

      provider.addEvent(entry);

      expect(provider.events.length, 1);
      expect(provider.events[0], entry);
    });

    test('adding 1001 events should keep only last 1000', () {
      for (int i = 0; i < 1001; i++) {
        provider.addEvent(
          EventLogEntry(
            timestamp: DateTime.now(),
            eventType: EventType.navigation,
            message: 'Event $i',
          ),
        );
      }

      expect(provider.events.length, 1000);
      expect(provider.events[0].message, 'Event 1');
      expect(provider.events[999].message, 'Event 1000');
    });

    test('filterByType should filter events by type', () {
      provider.addEvent(
        EventLogEntry(
          timestamp: DateTime.now(),
          eventType: EventType.navigation,
          message: 'Nav 1',
        ),
      );
      provider.addEvent(
        EventLogEntry(
          timestamp: DateTime.now(),
          eventType: EventType.javascript,
          message: 'JS 1',
        ),
      );
      provider.addEvent(
        EventLogEntry(
          timestamp: DateTime.now(),
          eventType: EventType.navigation,
          message: 'Nav 2',
        ),
      );

      final filtered = provider.filterByType(EventType.navigation);

      expect(filtered.length, 2);
      expect(filtered[0].message, 'Nav 1');
      expect(filtered[1].message, 'Nav 2');
    });

    test('filterByType with null should return all events', () {
      provider.addEvent(
        EventLogEntry(
          timestamp: DateTime.now(),
          eventType: EventType.navigation,
          message: 'Nav 1',
        ),
      );
      provider.addEvent(
        EventLogEntry(
          timestamp: DateTime.now(),
          eventType: EventType.javascript,
          message: 'JS 1',
        ),
      );

      final filtered = provider.filterByType(null);

      expect(filtered.length, 2);
    });

    test('search should filter events by message content', () {
      provider.addEvent(
        EventLogEntry(
          timestamp: DateTime.now(),
          eventType: EventType.navigation,
          message: 'Page loaded successfully',
        ),
      );
      provider.addEvent(
        EventLogEntry(
          timestamp: DateTime.now(),
          eventType: EventType.error,
          message: 'Network error occurred',
        ),
      );
      provider.addEvent(
        EventLogEntry(
          timestamp: DateTime.now(),
          eventType: EventType.navigation,
          message: 'Navigation started',
        ),
      );

      final searchResults = provider.search('error');

      expect(searchResults.length, 1);
      expect(searchResults[0].message, 'Network error occurred');
    });

    test('search should be case-insensitive', () {
      provider.addEvent(
        EventLogEntry(
          timestamp: DateTime.now(),
          eventType: EventType.navigation,
          message: 'Page Loaded Successfully',
        ),
      );

      final searchResults = provider.search('loaded');

      expect(searchResults.length, 1);
      expect(searchResults[0].message, 'Page Loaded Successfully');
    });

    test('search with empty string should return all events', () {
      provider.addEvent(
        EventLogEntry(
          timestamp: DateTime.now(),
          eventType: EventType.navigation,
          message: 'Event 1',
        ),
      );
      provider.addEvent(
        EventLogEntry(
          timestamp: DateTime.now(),
          eventType: EventType.javascript,
          message: 'Event 2',
        ),
      );

      final searchResults = provider.search('');

      expect(searchResults.length, 2);
    });

    test('clear should remove all events', () {
      provider.addEvent(
        EventLogEntry(
          timestamp: DateTime.now(),
          eventType: EventType.navigation,
          message: 'Event 1',
        ),
      );
      provider.addEvent(
        EventLogEntry(
          timestamp: DateTime.now(),
          eventType: EventType.javascript,
          message: 'Event 2',
        ),
      );

      expect(provider.events.length, 2);

      provider.clear();

      expect(provider.events.length, 0);
    });

    test('provider should notify listeners on addEvent', () {
      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      provider.addEvent(
        EventLogEntry(
          timestamp: DateTime.now(),
          eventType: EventType.navigation,
          message: 'Test',
        ),
      );

      expect(notifyCount, 1);
    });

    test('provider should notify listeners on clear', () {
      int notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      provider.addEvent(
        EventLogEntry(
          timestamp: DateTime.now(),
          eventType: EventType.navigation,
          message: 'Test',
        ),
      );

      provider.clear();

      expect(notifyCount, 2); // Once for add, once for clear
    });
  });
}
