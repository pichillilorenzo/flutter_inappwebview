/// Represents a performance metric for a WebView operation
class PerformanceMetric {
  final String methodName;
  final Duration duration;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const PerformanceMetric({
    required this.methodName,
    required this.duration,
    required this.timestamp,
    this.metadata,
  });

  /// Serialize to map
  Map<String, dynamic> toMap() {
    return {
      'methodName': methodName,
      'duration': duration.inMilliseconds,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }

  /// Deserialize from map
  factory PerformanceMetric.fromMap(Map<String, dynamic> map) {
    return PerformanceMetric(
      methodName: map['methodName'] as String,
      duration: Duration(milliseconds: map['duration'] as int),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }
}
