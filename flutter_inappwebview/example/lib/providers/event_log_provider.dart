import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_example/models/event_log_entry.dart';

/// Provider for managing event logs with buffer management, filtering, and search
class EventLogProvider extends ChangeNotifier {
  static const int maxEvents = 1000;
  final List<EventLogEntry> _events = [];

  /// Get all events
  List<EventLogEntry> get events => List.unmodifiable(_events);

  /// Add an event to the log
  void addEvent(EventLogEntry event) {
    _events.add(event);

    // Maintain buffer limit
    if (_events.length > maxEvents) {
      _events.removeAt(0);
    }

    notifyListeners();
  }

  /// Filter events by type
  List<EventLogEntry> filterByType(EventType? eventType) {
    if (eventType == null) {
      return List.unmodifiable(_events);
    }
    return _events.where((event) => event.eventType == eventType).toList();
  }

  /// Search events by message content (case-insensitive)
  List<EventLogEntry> search(String query) {
    if (query.isEmpty) {
      return List.unmodifiable(_events);
    }

    final lowerQuery = query.toLowerCase();
    return _events
        .where((event) => event.message.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Clear all events
  void clear() {
    _events.clear();
    notifyListeners();
  }
}
