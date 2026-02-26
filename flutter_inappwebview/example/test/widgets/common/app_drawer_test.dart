import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_example/widgets/common/app_drawer.dart';

class TestNavigatorObserver extends NavigatorObserver {
  int didReplaceCount = 0;

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    didReplaceCount += 1;
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

void main() {
  group('AppDrawer', () {
    testWidgets('renders drawer header and sections', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Home')),
            drawer: AppDrawer(),
          ),
        ),
      );

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();

      expect(find.text('Test Suite'), findsOneWidget);
      expect(find.text('WebView Tester'), findsOneWidget);
      expect(find.text('Storage & Cookies'), findsOneWidget);
      expect(find.text('Cookie Manager'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Browsers'),
        200,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('Browsers'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Documentation'),
        200,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('Documentation'), findsOneWidget);
    });

    testWidgets('navigates to settings editor', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/': (context) => Scaffold(
              appBar: AppBar(title: const Text('Home')),
              drawer: AppDrawer(),
            ),
            '/settings': (context) =>
                const Scaffold(body: Text('Settings Screen')),
          },
        ),
      );

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings Editor'));
      await tester.pumpAndSettle();

      expect(find.text('Settings Screen'), findsOneWidget);
    });

    testWidgets('uses replacement for webview tester', (
      WidgetTester tester,
    ) async {
      final observer = TestNavigatorObserver();

      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [observer],
          initialRoute: '/settings',
          routes: {
            '/': (context) => const Scaffold(body: Text('Home Screen')),
            '/settings': (context) => Scaffold(
              appBar: AppBar(title: const Text('Settings')),
              drawer: AppDrawer(),
            ),
          },
        ),
      );

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('WebView Tester'));
      await tester.pumpAndSettle();

      expect(find.text('Home Screen'), findsOneWidget);
      expect(observer.didReplaceCount, 1);
    });
  });
}
