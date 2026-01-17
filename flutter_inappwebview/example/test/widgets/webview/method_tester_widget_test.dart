import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_example/widgets/webview/method_tester_widget.dart';

void main() {
  group('MethodTesterWidget', () {
    testWidgets('renders method dropdown', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MethodTesterWidget(
              onExecuteMethod: (method, params) async => null,
            ),
          ),
        ),
      );

      expect(find.text('Select Method'), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });

    testWidgets('shows available methods in dropdown', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MethodTesterWidget(
              onExecuteMethod: (method, params) async => null,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Should show common methods
      expect(find.text('getUrl').hitTestable(), findsOneWidget);
      expect(find.text('getTitle').hitTestable(), findsOneWidget);
      expect(find.text('canGoBack').hitTestable(), findsOneWidget);
    });

    testWidgets('execute button is disabled when no method selected',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MethodTesterWidget(
              onExecuteMethod: (method, params) async => null,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Execute'),
      );

      expect(button.onPressed, isNull);
    });

    testWidgets('execute button is enabled when method selected',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MethodTesterWidget(
              onExecuteMethod: (method, params) async => null,
            ),
          ),
        ),
      );

      // Select a method
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('getUrl').hitTestable());
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Execute'),
      );

      expect(button.onPressed, isNotNull);
    });

    testWidgets('calls onExecuteMethod when execute button pressed',
        (tester) async {
      String? executedMethod;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MethodTesterWidget(
              onExecuteMethod: (method, params) async {
                executedMethod = method;
                return 'https://example.com';
              },
            ),
          ),
        ),
      );

      // Select method
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('getUrl').hitTestable());
      await tester.pumpAndSettle();

      // Execute
      await tester.tap(find.widgetWithText(ElevatedButton, 'Execute'));
      await tester.pumpAndSettle();

      expect(executedMethod, 'getUrl');
    });

    testWidgets('displays result after execution', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MethodTesterWidget(
              onExecuteMethod: (method, params) async {
                return 'https://example.com';
              },
            ),
          ),
        ),
      );

      // Select and execute
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('getUrl').hitTestable());
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Execute'));
      await tester.pumpAndSettle();

      expect(find.textContaining('https://example.com'), findsOneWidget);
    });

    testWidgets('displays error when execution fails', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MethodTesterWidget(
              onExecuteMethod: (method, params) async {
                throw Exception('Method failed');
              },
            ),
          ),
        ),
      );

      // Select and execute
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('getUrl').hitTestable());
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Execute'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Error'), findsOneWidget);
      expect(find.textContaining('Method failed'), findsOneWidget);
    });

    testWidgets('shows parameter inputs for methods with parameters',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MethodTesterWidget(
              onExecuteMethod: (method, params) async => null,
            ),
          ),
        ),
      );

      // Select method with parameter
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('evaluateJavascript').hitTestable());
      await tester.pumpAndSettle();

      // Should show parameter input
      expect(find.text('source'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows method support indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MethodTesterWidget(
              onExecuteMethod: (method, params) async => null,
              isMethodSupported: (method) async => true,
            ),
          ),
        ),
      );

      // Select method
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('getUrl').hitTestable());
      await tester.pumpAndSettle();

      // Should show supported indicator
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows unsupported indicator when method not supported',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MethodTesterWidget(
              onExecuteMethod: (method, params) async => null,
              isMethodSupported: (method) async => false,
            ),
          ),
        ),
      );

      // Select method
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('getUrl').hitTestable());
      await tester.pumpAndSettle();

      // Should show unsupported indicator
      expect(find.byIcon(Icons.cancel), findsOneWidget);
    });

    testWidgets('clears result when selecting different method',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MethodTesterWidget(
              onExecuteMethod: (method, params) async {
                return 'Result for $method';
              },
            ),
          ),
        ),
      );

      // Execute first method
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('getUrl').hitTestable());
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Execute'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Result for getUrl'), findsOneWidget);

      // Select different method
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('getTitle').hitTestable());
      await tester.pumpAndSettle();

      // Previous result should be cleared
      expect(find.textContaining('Result for getUrl'), findsNothing);
    });

    testWidgets('shows loading indicator during execution', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MethodTesterWidget(
              onExecuteMethod: (method, params) async {
                await Future.delayed(Duration(seconds: 1));
                return 'result';
              },
            ),
          ),
        ),
      );

      // Select and execute
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('getUrl').hitTestable());
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Execute'));
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
