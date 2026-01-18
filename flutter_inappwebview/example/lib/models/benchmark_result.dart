import 'dart:convert';

/// Represents a single benchmark result
class BenchmarkResult {
  final String id;
  final String testName;
  final DateTime timestamp;
  final Duration duration;
  final Map<String, dynamic> metadata;

  const BenchmarkResult({
    required this.id,
    required this.testName,
    required this.timestamp,
    required this.duration,
    this.metadata = const {},
  });

  /// Format duration as a human-readable string
  String get durationFormatted {
    final ms = duration.inMilliseconds;
    if (ms < 1000) {
      return '${ms}ms';
    } else if (ms < 60000) {
      return '${(ms / 1000).toStringAsFixed(2)}s';
    } else {
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Serialize to map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'testName': testName,
      'timestamp': timestamp.toIso8601String(),
      'durationMs': duration.inMilliseconds,
      'metadata': metadata,
    };
  }

  /// Deserialize from map
  factory BenchmarkResult.fromJson(Map<String, dynamic> json) {
    return BenchmarkResult(
      id: json['id'] as String,
      testName: json['testName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      duration: Duration(milliseconds: json['durationMs'] as int),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  BenchmarkResult copyWith({
    String? id,
    String? testName,
    DateTime? timestamp,
    Duration? duration,
    Map<String, dynamic>? metadata,
  }) {
    return BenchmarkResult(
      id: id ?? this.id,
      testName: testName ?? this.testName,
      timestamp: timestamp ?? this.timestamp,
      duration: duration ?? this.duration,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Represents a complete benchmark session
class BenchmarkSession {
  final String id;
  final DateTime timestamp;
  final String deviceInfo;
  final String platformName;
  final List<BenchmarkResult> results;

  const BenchmarkSession({
    required this.id,
    required this.timestamp,
    required this.deviceInfo,
    required this.platformName,
    this.results = const [],
  });

  /// Get total duration of all benchmarks
  Duration get totalDuration {
    if (results.isEmpty) return Duration.zero;
    return results.fold(
      Duration.zero,
      (total, result) => total + result.duration,
    );
  }

  /// Get average duration across all benchmarks
  Duration get averageDuration {
    if (results.isEmpty) return Duration.zero;
    return Duration(
      milliseconds: totalDuration.inMilliseconds ~/ results.length,
    );
  }

  /// Get the fastest benchmark result
  BenchmarkResult? get fastestResult {
    if (results.isEmpty) return null;
    return results.reduce((a, b) => a.duration < b.duration ? a : b);
  }

  /// Get the slowest benchmark result
  BenchmarkResult? get slowestResult {
    if (results.isEmpty) return null;
    return results.reduce((a, b) => a.duration > b.duration ? a : b);
  }

  /// Serialize to map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'deviceInfo': deviceInfo,
      'platformName': platformName,
      'results': results.map((r) => r.toJson()).toList(),
    };
  }

  /// Deserialize from map
  factory BenchmarkSession.fromJson(Map<String, dynamic> json) {
    return BenchmarkSession(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      deviceInfo: json['deviceInfo'] as String,
      platformName: json['platformName'] as String,
      results:
          (json['results'] as List?)
              ?.map((r) => BenchmarkResult.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  BenchmarkSession copyWith({
    String? id,
    DateTime? timestamp,
    String? deviceInfo,
    String? platformName,
    List<BenchmarkResult>? results,
  }) {
    return BenchmarkSession(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      platformName: platformName ?? this.platformName,
      results: results ?? this.results,
    );
  }

  /// Encode session to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Decode session from JSON string
  factory BenchmarkSession.fromJsonString(String jsonString) {
    return BenchmarkSession.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }
}

/// Comparison result between two benchmark sessions
class BenchmarkComparison {
  final BenchmarkSession current;
  final BenchmarkSession previous;

  const BenchmarkComparison({required this.current, required this.previous});

  /// Get percentage change for a specific test
  double? getPercentageChange(String testName) {
    final currentResult = current.results
        .where((r) => r.testName == testName)
        .firstOrNull;
    final previousResult = previous.results
        .where((r) => r.testName == testName)
        .firstOrNull;

    if (currentResult == null || previousResult == null) return null;
    if (previousResult.duration.inMilliseconds == 0) return null;

    return ((currentResult.duration.inMilliseconds -
                previousResult.duration.inMilliseconds) /
            previousResult.duration.inMilliseconds) *
        100;
  }

  /// Get all test names that exist in both sessions
  List<String> get commonTestNames {
    final currentNames = current.results.map((r) => r.testName).toSet();
    final previousNames = previous.results.map((r) => r.testName).toSet();
    return currentNames.intersection(previousNames).toList();
  }

  /// Check if performance improved (lower duration is better)
  bool isImproved(String testName) {
    final change = getPercentageChange(testName);
    return change != null && change < 0;
  }

  /// Check if performance regressed
  bool isRegressed(String testName) {
    final change = getPercentageChange(testName);
    return change != null && change > 5; // 5% threshold for regression
  }
}
