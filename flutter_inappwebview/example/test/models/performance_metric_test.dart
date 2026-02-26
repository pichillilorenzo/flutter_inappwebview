import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_example/models/performance_metric.dart';

void main() {
  group('PerformanceMetric', () {
    test('fromMap should deserialize JSON correctly', () {
      final now = DateTime.now();
      final map = {
        'methodName': 'loadUrl',
        'duration': 250,
        'timestamp': now.millisecondsSinceEpoch,
        'metadata': {'url': 'https://example.com'},
      };

      final metric = PerformanceMetric.fromMap(map);

      expect(metric.methodName, 'loadUrl');
      expect(metric.duration, const Duration(milliseconds: 250));
      expect(
        metric.timestamp.millisecondsSinceEpoch,
        now.millisecondsSinceEpoch,
      );
      expect(metric.metadata, {'url': 'https://example.com'});
    });

    test('toMap should serialize to JSON correctly', () {
      final now = DateTime.now();
      final metric = PerformanceMetric(
        methodName: 'evaluateJavascript',
        duration: const Duration(milliseconds: 50),
        timestamp: now,
        metadata: {'script': 'console.log("test")'},
      );

      final map = metric.toMap();

      expect(map['methodName'], 'evaluateJavascript');
      expect(map['duration'], 50);
      expect(map['timestamp'], now.millisecondsSinceEpoch);
      expect(map['metadata'], {'script': 'console.log("test")'});
    });

    test('null metadata should be handled correctly', () {
      final now = DateTime.now();
      final metric = PerformanceMetric(
        methodName: 'reload',
        duration: const Duration(milliseconds: 100),
        timestamp: now,
      );

      final map = metric.toMap();

      expect(map['metadata'], null);
      expect(metric.metadata, null);
    });

    test('timestamp handling should preserve milliseconds', () {
      final originalTimestamp = DateTime.parse('2026-01-17 10:30:45.123');
      final metric = PerformanceMetric(
        methodName: 'test',
        duration: const Duration(milliseconds: 10),
        timestamp: originalTimestamp,
      );

      final map = metric.toMap();
      final deserializedMetric = PerformanceMetric.fromMap(map);

      expect(
        deserializedMetric.timestamp.millisecondsSinceEpoch,
        originalTimestamp.millisecondsSinceEpoch,
      );
    });
  });
}
