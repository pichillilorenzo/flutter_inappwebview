import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_example/widgets/webview/javascript_console_widget.dart';

void main() {
  group('JavaScriptConsoleWidget', () {
    testWidgets('renders JavaScript input field', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JavaScriptConsoleWidget(
              onExecute: (code) async => {'value': 'test result'},
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Enter JavaScript code'), findsOneWidget);
    });

    testWidgets('renders execute and async execute buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JavaScriptConsoleWidget(onExecute: (code) async => null),
          ),
        ),
      );

      expect(find.widgetWithText(ElevatedButton, 'Execute'), findsOneWidget);
      expect(
        find.widgetWithText(ElevatedButton, 'Execute Async'),
        findsOneWidget,
      );
    });

    testWidgets('executes JavaScript code on button press', (tester) async {
      String? executedCode;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JavaScriptConsoleWidget(
              onExecute: (code) async {
                executedCode = code;
                return {'value': 42};
              },
            ),
          ),
        ),
      );

      // Enter code
      await tester.enterText(find.byType(TextField), 'console.log("test")');
      await tester.pump();

      // Execute
      await tester.tap(find.widgetWithText(ElevatedButton, 'Execute'));
      await tester.pump();

      expect(executedCode, 'console.log("test")');
    });

    testWidgets('executes async JavaScript code', (tester) async {
      String? executedCode;
      bool isAsync = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JavaScriptConsoleWidget(
              onExecute: (code) async {
                executedCode = code;
                return {'value': 'sync result'};
              },
              onExecuteAsync: (code) async {
                executedCode = code;
                isAsync = true;
                return {'value': 'async result'};
              },
            ),
          ),
        ),
      );

      // Enter code
      await tester.enterText(find.byType(TextField), 'await fetch("/api")');
      await tester.pump();

      // Execute async
      await tester.tap(find.widgetWithText(ElevatedButton, 'Execute Async'));
      await tester.pump();

      expect(executedCode, 'await fetch("/api")');
      expect(isAsync, true);
    });

    testWidgets('displays execution result', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JavaScriptConsoleWidget(
              onExecute: (code) async {
                return {'value': 'Hello World'};
              },
            ),
          ),
        ),
      );

      // Enter and execute code
      await tester.enterText(find.byType(TextField), 'return "test"');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Execute'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Hello World'), findsOneWidget);
    });

    testWidgets('displays execution error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JavaScriptConsoleWidget(
              onExecute: (code) async {
                throw Exception('Syntax error');
              },
            ),
          ),
        ),
      );

      // Enter and execute code
      await tester.enterText(find.byType(TextField), 'invalid code');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Execute'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Error'), findsOneWidget);
      expect(find.textContaining('Syntax error'), findsOneWidget);
    });

    testWidgets('shows clear button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JavaScriptConsoleWidget(onExecute: (code) async => null),
          ),
        ),
      );

      expect(find.widgetWithIcon(IconButton, Icons.clear), findsOneWidget);
    });

    testWidgets('clear button clears input and results', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JavaScriptConsoleWidget(
              onExecute: (code) async {
                return {'value': 'result'};
              },
            ),
          ),
        ),
      );

      // Enter and execute code
      await tester.enterText(find.byType(TextField), 'test code');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Execute'));
      await tester.pumpAndSettle();

      expect(find.textContaining('result'), findsOneWidget);

      // Clear
      await tester.tap(find.byTooltip('Clear'));
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
      expect(find.text('Execute JavaScript to see results'), findsOneWidget);
    });

    testWidgets('maintains history of executed scripts', (tester) async {
      int executionCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JavaScriptConsoleWidget(
              onExecute: (code) async {
                executionCount++;
                return {'value': 'result $executionCount'};
              },
            ),
          ),
        ),
      );

      // Execute first script
      await tester.enterText(find.byType(TextField), 'script 1');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Execute'));
      await tester.pumpAndSettle();

      // Execute second script
      await tester.enterText(find.byType(TextField), 'script 2');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Execute'));
      await tester.pumpAndSettle();

      // Both results should be visible
      expect(find.textContaining('result 1'), findsOneWidget);
      expect(find.textContaining('result 2'), findsOneWidget);
    });

    testWidgets('disables buttons when no code entered', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JavaScriptConsoleWidget(onExecute: (code) async => null),
          ),
        ),
      );

      final executeButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Execute'),
      );

      expect(executeButton.onPressed, isNull);
    });

    testWidgets('enables buttons when code is entered', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JavaScriptConsoleWidget(onExecute: (code) async => null),
          ),
        ),
      );

      // Enter code
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      final executeButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Execute'),
      );

      expect(executeButton.onPressed, isNotNull);
    });

    testWidgets('formats JSON results', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JavaScriptConsoleWidget(
              onExecute: (code) async {
                return {
                  'value': {'name': 'John', 'age': 30, 'active': true},
                };
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'return user');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Execute'));
      await tester.pumpAndSettle();

      // Should display formatted JSON
      expect(find.textContaining('name'), findsOneWidget);
      expect(find.textContaining('John'), findsOneWidget);
    });
  });
}
