import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_example/models/network_request.dart';
import 'package:flutter_inappwebview_example/providers/network_monitor.dart';

void main() {
  group('NetworkMonitor', () {
    late NetworkMonitor monitor;

    setUp(() {
      monitor = NetworkMonitor();
    });

    test('initial state has empty requests and monitoring disabled', () {
      expect(monitor.requests, isEmpty);
      expect(monitor.isMonitoring, false);
    });

    test('toggleMonitoring changes monitoring state', () {
      expect(monitor.isMonitoring, false);

      monitor.toggleMonitoring();
      expect(monitor.isMonitoring, true);

      monitor.toggleMonitoring();
      expect(monitor.isMonitoring, false);
    });

    test('addRequest adds request to list', () {
      final request = NetworkRequest(
        id: '1',
        method: 'GET',
        url: 'https://example.com',
        timestamp: DateTime.now(),
      );

      monitor.addRequest(request);

      expect(monitor.requests.length, 1);
      expect(monitor.requests.first, request);
    });

    test('addRequest notifies listeners', () {
      var notified = false;
      monitor.addListener(() {
        notified = true;
      });

      final request = NetworkRequest(
        id: '1',
        method: 'GET',
        url: 'https://example.com',
        timestamp: DateTime.now(),
      );

      monitor.addRequest(request);

      expect(notified, true);
    });

    test('updateRequest updates existing request', () {
      final request = NetworkRequest(
        id: '1',
        method: 'GET',
        url: 'https://example.com',
        timestamp: DateTime.now(),
      );

      monitor.addRequest(request);

      monitor.updateRequest(
        '1',
        response: '{"success": true}',
        statusCode: 200,
        duration: Duration(milliseconds: 150),
      );

      expect(monitor.requests.length, 1);
      expect(monitor.requests.first.id, '1');
      expect(monitor.requests.first.statusCode, 200);
      expect(monitor.requests.first.response, '{"success": true}');
      expect(monitor.requests.first.duration, Duration(milliseconds: 150));
    });

    test('updateRequest does nothing for non-existent request', () {
      monitor.updateRequest(
        'non-existent',
        response: '{"success": true}',
        statusCode: 200,
      );

      expect(monitor.requests, isEmpty);
    });

    test('updateRequest notifies listeners', () {
      final request = NetworkRequest(
        id: '1',
        method: 'GET',
        url: 'https://example.com',
        timestamp: DateTime.now(),
      );

      monitor.addRequest(request);

      var notified = false;
      monitor.addListener(() {
        notified = true;
      });

      monitor.updateRequest('1', statusCode: 200);

      expect(notified, true);
    });

    test('clearRequests removes all requests', () {
      final request1 = NetworkRequest(
        id: '1',
        method: 'GET',
        url: 'https://example.com',
        timestamp: DateTime.now(),
      );
      final request2 = NetworkRequest(
        id: '2',
        method: 'POST',
        url: 'https://example.com/api',
        timestamp: DateTime.now(),
      );

      monitor.addRequest(request1);
      monitor.addRequest(request2);

      expect(monitor.requests.length, 2);

      monitor.clearRequests();

      expect(monitor.requests, isEmpty);
    });

    test('clearRequests notifies listeners', () {
      final request = NetworkRequest(
        id: '1',
        method: 'GET',
        url: 'https://example.com',
        timestamp: DateTime.now(),
      );

      monitor.addRequest(request);

      var notified = false;
      monitor.addListener(() {
        notified = true;
      });

      monitor.clearRequests();

      expect(notified, true);
    });

    test('multiple requests are stored in order', () {
      final request1 = NetworkRequest(
        id: '1',
        method: 'GET',
        url: 'https://example.com/1',
        timestamp: DateTime.now(),
      );
      final request2 = NetworkRequest(
        id: '2',
        method: 'POST',
        url: 'https://example.com/2',
        timestamp: DateTime.now(),
      );
      final request3 = NetworkRequest(
        id: '3',
        method: 'PUT',
        url: 'https://example.com/3',
        timestamp: DateTime.now(),
      );

      monitor.addRequest(request1);
      monitor.addRequest(request2);
      monitor.addRequest(request3);

      expect(monitor.requests.length, 3);
      expect(monitor.requests[0].id, '1');
      expect(monitor.requests[1].id, '2');
      expect(monitor.requests[2].id, '3');
    });
  });
}
