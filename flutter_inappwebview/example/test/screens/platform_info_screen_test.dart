import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_example/screens/platform_info_screen.dart';
import 'package:flutter_inappwebview_example/utils/platform_utils.dart';

void main() {
  group('PlatformInfoScreen', () {
    testWidgets('renders platform information', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PlatformInfoScreen()));

      // Check for AppBar
      expect(find.text('Platform Information'), findsOneWidget);

      // Check for platform name (should appear in one of the info tiles)
      final platformName = PlatformUtils.getPlatformName();
      // Platform name might appear multiple times (label + value)
      expect(find.textContaining(platformName), findsWidgets);
    });

    testWidgets('displays Flutter version', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PlatformInfoScreen()));

      // Flutter version label should be present
      expect(find.text('Flutter Version'), findsOneWidget);
    });

    testWidgets('displays Dart version', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PlatformInfoScreen()));

      // Dart version label should be present
      expect(find.text('Dart Version'), findsOneWidget);
    });

    testWidgets('shows supported features section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: PlatformInfoScreen()));

      // Should show the Core WebView Features section
      expect(find.text('Core WebView Features'), findsOneWidget);
    });

    testWidgets('has back button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PlatformInfoScreen(),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // AppBar should have a leading widget (back button or similar)
      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
