import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview_example/screens/home_screen.dart';
import 'package:flutter_inappwebview_example/utils/test_registry.dart';
import 'package:flutter_inappwebview_example/providers/event_log_provider.dart';
import 'package:flutter_inappwebview_example/providers/settings_manager.dart';
import 'package:flutter_inappwebview_example/providers/test_runner.dart';
import 'package:flutter_inappwebview_example/providers/network_monitor.dart';
import 'package:flutter_inappwebview_example/utils/platform_utils.dart';

void main() {
  group('HomeScreen', () {
    setUp(() {
      TestRegistry.init();
    });

    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => EventLogProvider()),
          ChangeNotifierProvider(create: (_) => SettingsManager()),
          ChangeNotifierProvider(create: (_) => TestRunner()),
          ChangeNotifierProvider(create: (_) => NetworkMonitor()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      );
    }

    testWidgets('renders app title in AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('InAppWebView Test Suite'), findsOneWidget);
    });

    testWidgets('displays 6 category cards', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Look for category names
      expect(find.text('Navigation'), findsOneWidget);
      expect(find.text('JavaScript'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
      expect(find.text('Storage & Cookies'), findsOneWidget);
      expect(find.text('Advanced Features'), findsOneWidget);
      expect(find.text('Browsers'), findsOneWidget);
    });

    testWidgets('category cards show test counts', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Should display test counts (format: "X tests")
      expect(find.textContaining('test'), findsAtLeastNWidgets(6));
    });

    testWidgets('category cards are tappable', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find first category card
      final navigationCard = find.text('Navigation');
      expect(navigationCard, findsOneWidget);

      // Cards should be wrapped in InkWell or GestureDetector
      final inkWell = find.ancestor(
        of: navigationCard,
        matching: find.byType(InkWell),
      );
      expect(inkWell, findsOneWidget);
    });

    testWidgets('has floating action button for platform info', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('displays platform indicator', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Should show current platform somewhere
      final platformIcon = PlatformUtils.getPlatformIcon();
      expect(find.byIcon(platformIcon), findsAny);
    });

    testWidgets('category cards have icons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Navigation icon
      expect(find.byIcon(Icons.navigation), findsOneWidget);
      // JavaScript icon
      expect(find.byIcon(Icons.code), findsOneWidget);
      // Content icon
      expect(find.byIcon(Icons.article), findsOneWidget);
      // Storage icon
      expect(find.byIcon(Icons.storage), findsOneWidget);
      // Advanced icon
      expect(find.byIcon(Icons.settings), findsOneWidget);
      // Browsers icon
      expect(find.byIcon(Icons.web), findsOneWidget);
    });
  });
}
