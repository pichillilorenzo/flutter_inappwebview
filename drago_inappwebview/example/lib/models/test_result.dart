/// Represents the result of a test execution
class TestResult {
  final bool passed;
  final String message;
  final Duration duration;
  final Map<String, dynamic>? data;

  const TestResult({
    required this.passed,
    required this.message,
    required this.duration,
    this.data,
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
  Map<String, dynamic> toMap() {
    return {
      'passed': passed,
      'message': message,
      'duration': duration.inMilliseconds,
      'data': data,
    };
  }

  /// Deserialize from map
  factory TestResult.fromMap(Map<String, dynamic> map) {
    return TestResult(
      passed: map['passed'] as bool,
      message: map['message'] as String,
      duration: Duration(milliseconds: map['duration'] as int),
      data: map['data'] as Map<String, dynamic>?,
    );
  }
}
