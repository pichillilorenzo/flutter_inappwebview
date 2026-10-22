/// Event types for logging
enum EventType {
  navigation,
  javascript,
  console,
  network,
  error,
  performance,
  storage,
  cookies,
  messaging,
  ui,
}

/// Represents an event log entry with timestamp and metadata
class EventLogEntry {
  final DateTime timestamp;
  final EventType eventType;
  final String message;
  final Map<String, dynamic>? data;

  const EventLogEntry({
    required this.timestamp,
    required this.eventType,
    required this.message,
    this.data,
  });

  /// Serialize to map
  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.millisecondsSinceEpoch,
      'eventType': eventType.name,
      'message': message,
      'data': data,
    };
  }

  /// Deserialize from map
  factory EventLogEntry.fromMap(Map<String, dynamic> map) {
    return EventLogEntry(
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      eventType: EventType.values.firstWhere((e) => e.name == map['eventType']),
      message: map['message'] as String,
      data: map['data'] as Map<String, dynamic>?,
    );
  }
}
