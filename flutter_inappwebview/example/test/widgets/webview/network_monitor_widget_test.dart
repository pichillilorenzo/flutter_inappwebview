import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview_example/models/network_request.dart';
import 'package:flutter_inappwebview_example/providers/network_monitor.dart';
import 'package:flutter_inappwebview_example/widgets/webview/network_monitor_widget.dart';

void main() {
  group('NetworkMonitorWidget', () {
    late NetworkMonitor networkMonitor;

    setUp(() {
      networkMonitor = NetworkMonitor();
    });

    Widget createWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<NetworkMonitor>.value(
          value: networkMonitor,
          child: Scaffold(body: NetworkMonitorWidget()),
        ),
      );
    }

    testWidgets('renders toggle button', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(Switch), findsOneWidget);
      expect(find.text('Monitor Network'), findsOneWidget);
    });

    testWidgets('toggle button controls monitoring state', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(networkMonitor.isMonitoring, false);

      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(networkMonitor.isMonitoring, true);

      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(networkMonitor.isMonitoring, false);
    });

    testWidgets('shows empty state when no requests', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('No network requests yet'), findsOneWidget);
    });

    testWidgets('displays network requests in list', (tester) async {
      networkMonitor.addRequest(
        NetworkRequest(
          id: '1',
          method: 'GET',
          url: 'https://example.com/api',
          timestamp: DateTime.now(),
        ),
      );

      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.text('GET'), findsOneWidget);
      expect(find.textContaining('example.com'), findsOneWidget);
    });

    testWidgets('shows clear button', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.widgetWithIcon(IconButton, Icons.clear_all), findsOneWidget);
    });

    testWidgets('clear button clears requests', (tester) async {
      networkMonitor.addRequest(
        NetworkRequest(
          id: '1',
          method: 'GET',
          url: 'https://example.com',
          timestamp: DateTime.now(),
        ),
      );

      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.text('GET'), findsOneWidget);

      await tester.tap(find.widgetWithIcon(IconButton, Icons.clear_all));
      await tester.pump();

      expect(find.text('GET'), findsNothing);
      expect(find.text('No network requests yet'), findsOneWidget);
    });

    testWidgets('displays request method and URL', (tester) async {
      networkMonitor.addRequest(
        NetworkRequest(
          id: '1',
          method: 'POST',
          url: 'https://api.example.com/users',
          timestamp: DateTime.now(),
        ),
      );

      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.text('POST'), findsOneWidget);
      expect(find.textContaining('api.example.com'), findsOneWidget);
    });

    testWidgets('displays status code when available', (tester) async {
      networkMonitor.addRequest(
        NetworkRequest(
          id: '1',
          method: 'GET',
          url: 'https://example.com',
          timestamp: DateTime.now(),
          statusCode: 200,
        ),
      );

      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.text('200'), findsOneWidget);
    });

    testWidgets('displays duration when available', (tester) async {
      networkMonitor.addRequest(
        NetworkRequest(
          id: '1',
          method: 'GET',
          url: 'https://example.com',
          timestamp: DateTime.now(),
          duration: Duration(milliseconds: 150),
        ),
      );

      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.textContaining('150ms'), findsOneWidget);
    });

    testWidgets('pending requests show pending indicator', (tester) async {
      networkMonitor.addRequest(
        NetworkRequest(
          id: '1',
          method: 'GET',
          url: 'https://example.com',
          timestamp: DateTime.now(),
          // No status code = pending
        ),
      );

      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('request item can be expanded for details', (tester) async {
      networkMonitor.addRequest(
        NetworkRequest(
          id: '1',
          method: 'POST',
          url: 'https://example.com/api',
          timestamp: DateTime.now(),
          headers: {'Content-Type': 'application/json'},
          body: '{"test": true}',
          response: '{"success": true}',
          statusCode: 201,
        ),
      );

      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Initially details are hidden
      expect(find.text('Request Headers'), findsNothing);

      // Tap to expand
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      // Now details should be visible
      expect(find.text('Request Headers'), findsOneWidget);
      expect(find.textContaining('Content-Type'), findsOneWidget);
      expect(find.textContaining('application/json'), findsOneWidget);
    });

    testWidgets('multiple requests are displayed', (tester) async {
      networkMonitor.addRequest(
        NetworkRequest(
          id: '1',
          method: 'GET',
          url: 'https://example.com/1',
          timestamp: DateTime.now(),
        ),
      );
      networkMonitor.addRequest(
        NetworkRequest(
          id: '2',
          method: 'POST',
          url: 'https://example.com/2',
          timestamp: DateTime.now(),
        ),
      );
      networkMonitor.addRequest(
        NetworkRequest(
          id: '3',
          method: 'PUT',
          url: 'https://example.com/3',
          timestamp: DateTime.now(),
        ),
      );

      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.text('GET'), findsOneWidget);
      expect(find.text('POST'), findsOneWidget);
      expect(find.text('PUT'), findsOneWidget);
    });

    testWidgets('status code colors are correct', (tester) async {
      networkMonitor.addRequest(
        NetworkRequest(
          id: '1',
          method: 'GET',
          url: 'https://example.com',
          timestamp: DateTime.now(),
          statusCode: 200,
        ),
      );

      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Find the chip with status code
      final chip = tester.widget<Chip>(
        find.ancestor(of: find.text('200'), matching: find.byType(Chip)),
      );

      expect(chip.backgroundColor, Colors.green.shade100);
    });
  });
}
