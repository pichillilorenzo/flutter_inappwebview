import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_example/models/event_log_entry.dart';

void main() {
  group('EventLogEntry', () {
    test('fromMap should deserialize JSON correctly', () {
      final now = DateTime.now();
      final map = {
        'timestamp': now.millisecondsSinceEpoch,
        'eventType': 'navigation',
        'message': 'Page loaded',
        'data': {'url': 'https://example.com'},
      };

      final entry = EventLogEntry.fromMap(map);

      expect(
        entry.timestamp.millisecondsSinceEpoch,
        now.millisecondsSinceEpoch,
      );
      expect(entry.eventType, EventType.navigation);
      expect(entry.message, 'Page loaded');
      expect(entry.data, {'url': 'https://example.com'});
    });

    test('toMap should serialize to JSON correctly', () {
      final now = DateTime.now();
      final entry = EventLogEntry(
        timestamp: now,
        eventType: EventType.javascript,
        message: 'Script executed',
        data: {'result': 'success'},
      );

      final map = entry.toMap();

      expect(map['timestamp'], now.millisecondsSinceEpoch);
      expect(map['eventType'], 'javascript');
      expect(map['message'], 'Script executed');
      expect(map['data'], {'result': 'success'});
    });

    test('all EventType values should be serializable', () {
      final now = DateTime.now();

      for (final eventType in EventType.values) {
        final entry = EventLogEntry(
          timestamp: now,
          eventType: eventType,
          message: 'Test',
        );

        final map = entry.toMap();
        final deserialized = EventLogEntry.fromMap(map);

        expect(deserialized.eventType, eventType);
      }
    });

    test('null data should be handled correctly', () {
      final now = DateTime.now();
      final entry = EventLogEntry(
        timestamp: now,
        eventType: EventType.error,
        message: 'Error occurred',
      );

      final map = entry.toMap();

      expect(map['data'], null);
      expect(entry.data, null);
    });

    test('filtering by event type should work correctly', () {
      final entries = [
        EventLogEntry(
          timestamp: DateTime.now(),
          eventType: EventType.navigation,
          message: 'Nav 1',
        ),
        EventLogEntry(
          timestamp: DateTime.now(),
          eventType: EventType.javascript,
          message: 'JS 1',
        ),
        EventLogEntry(
          timestamp: DateTime.now(),
          eventType: EventType.navigation,
          message: 'Nav 2',
        ),
      ];

      final navigationEntries =
          entries.where((e) => e.eventType == EventType.navigation).toList();

      expect(navigationEntries.length, 2);
      expect(navigationEntries[0].message, 'Nav 1');
      expect(navigationEntries[1].message, 'Nav 2');
    });
  });
}
