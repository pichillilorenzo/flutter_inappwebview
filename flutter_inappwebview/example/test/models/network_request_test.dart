import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_example/models/network_request.dart';

void main() {
  group('NetworkRequest', () {
    test('creates instance with required fields', () {
      final request = NetworkRequest(
        id: '1',
        method: 'GET',
        url: 'https://example.com',
        timestamp: DateTime(2025, 1, 1),
      );

      expect(request.id, '1');
      expect(request.method, 'GET');
      expect(request.url, 'https://example.com');
      expect(request.timestamp, DateTime(2025, 1, 1));
      expect(request.headers, isNull);
      expect(request.body, isNull);
      expect(request.response, isNull);
      expect(request.statusCode, isNull);
      expect(request.duration, isNull);
    });

    test('creates instance with all fields', () {
      final request = NetworkRequest(
        id: '2',
        method: 'POST',
        url: 'https://example.com/api',
        timestamp: DateTime(2025, 1, 1),
        headers: {'Content-Type': 'application/json'},
        body: '{"test": true}',
        response: '{"success": true}',
        statusCode: 200,
        duration: Duration(milliseconds: 150),
      );

      expect(request.id, '2');
      expect(request.method, 'POST');
      expect(request.url, 'https://example.com/api');
      expect(request.headers?['Content-Type'], 'application/json');
      expect(request.body, '{"test": true}');
      expect(request.response, '{"success": true}');
      expect(request.statusCode, 200);
      expect(request.duration, Duration(milliseconds: 150));
    });

    test('copyWith creates new instance with updated fields', () {
      final original = NetworkRequest(
        id: '3',
        method: 'GET',
        url: 'https://example.com',
        timestamp: DateTime(2025, 1, 1),
      );

      final updated = original.copyWith(
        statusCode: 200,
        response: '{"data": []}',
        duration: Duration(milliseconds: 200),
      );

      expect(updated.id, original.id);
      expect(updated.method, original.method);
      expect(updated.url, original.url);
      expect(updated.timestamp, original.timestamp);
      expect(updated.statusCode, 200);
      expect(updated.response, '{"data": []}');
      expect(updated.duration, Duration(milliseconds: 200));
    });

    test('toMap serializes correctly', () {
      final request = NetworkRequest(
        id: '4',
        method: 'GET',
        url: 'https://example.com',
        timestamp: DateTime(2025, 1, 1),
        headers: {'Accept': 'application/json'},
        statusCode: 200,
        duration: Duration(milliseconds: 100),
      );

      final map = request.toMap();

      expect(map['id'], '4');
      expect(map['method'], 'GET');
      expect(map['url'], 'https://example.com');
      expect(map['timestamp'], DateTime(2025, 1, 1).millisecondsSinceEpoch);
      expect(map['headers'], {'Accept': 'application/json'});
      expect(map['statusCode'], 200);
      expect(map['duration'], 100);
    });

    test('fromMap deserializes correctly', () {
      final map = {
        'id': '5',
        'method': 'POST',
        'url': 'https://example.com/api',
        'timestamp': DateTime(2025, 1, 1).millisecondsSinceEpoch,
        'headers': {'Content-Type': 'application/json'},
        'body': '{"test": true}',
        'response': '{"success": true}',
        'statusCode': 201,
        'duration': 250,
      };

      final request = NetworkRequest.fromMap(map);

      expect(request.id, '5');
      expect(request.method, 'POST');
      expect(request.url, 'https://example.com/api');
      expect(request.timestamp, DateTime(2025, 1, 1));
      expect(request.headers?['Content-Type'], 'application/json');
      expect(request.body, '{"test": true}');
      expect(request.response, '{"success": true}');
      expect(request.statusCode, 201);
      expect(request.duration, Duration(milliseconds: 250));
    });

    test('fromMap handles missing optional fields', () {
      final map = {
        'id': '6',
        'method': 'GET',
        'url': 'https://example.com',
        'timestamp': DateTime(2025, 1, 1).millisecondsSinceEpoch,
      };

      final request = NetworkRequest.fromMap(map);

      expect(request.id, '6');
      expect(request.method, 'GET');
      expect(request.url, 'https://example.com');
      expect(request.headers, isNull);
      expect(request.body, isNull);
      expect(request.response, isNull);
      expect(request.statusCode, isNull);
      expect(request.duration, isNull);
    });
  });
}
