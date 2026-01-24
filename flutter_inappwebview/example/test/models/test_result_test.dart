import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_example/models/test_result.dart';

void main() {
  group('TestResult', () {
    test('fromMap should deserialize JSON correctly', () {
      final map = {
        'passed': true,
        'message': 'Test passed',
        'duration': 150,
        'data': {'key': 'value'},
      };

      final testResult = TestResult.fromMap(map);

      expect(testResult.passed, true);
      expect(testResult.message, 'Test passed');
      expect(testResult.duration, const Duration(milliseconds: 150));
      expect(testResult.data, {'key': 'value'});
    });

    test('toMap should serialize to JSON correctly', () {
      final testResult = TestResult(
        passed: false,
        message: 'Test failed',
        duration: const Duration(milliseconds: 250),
        data: {'error': 'timeout'},
      );

      final map = testResult.toMap();

      expect(map['passed'], false);
      expect(map['message'], 'Test failed');
      expect(map['duration'], 250);
      expect(map['data'], {'error': 'timeout'});
    });

    test('duration formatting should work correctly', () {
      final testResult1 = TestResult(
        passed: true,
        message: 'Test',
        duration: const Duration(milliseconds: 50),
      );

      final testResult2 = TestResult(
        passed: true,
        message: 'Test',
        duration: const Duration(milliseconds: 1500),
      );

      final testResult3 = TestResult(
        passed: true,
        message: 'Test',
        duration: const Duration(seconds: 65),
      );

      expect(testResult1.durationFormatted, '50ms');
      expect(testResult2.durationFormatted, '1.50s');
      expect(testResult3.durationFormatted, '1:05');
    });

    test('null data should be handled correctly', () {
      final testResult = TestResult(
        passed: true,
        message: 'Test passed',
        duration: const Duration(milliseconds: 100),
      );

      final map = testResult.toMap();

      expect(map['data'], null);
      expect(testResult.data, null);
    });
  });
}
