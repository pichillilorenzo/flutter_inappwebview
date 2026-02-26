import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/widgets/webview/user_script_tester_widget.dart';

void main() {
  group('UserScriptTesterWidget', () {
    testWidgets('renders add script form', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserScriptTesterWidget(
              onAddScript: (script) async {},
              onRemoveScript: (script) async {},
            ),
          ),
        ),
      );

      expect(find.text('Add User Script'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows injection time dropdown', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserScriptTesterWidget(
              onAddScript: (script) async {},
              onRemoveScript: (script) async {},
            ),
          ),
        ),
      );

      expect(find.text('Injection Time'), findsOneWidget);
      expect(
        find.byType(DropdownButton<UserScriptInjectionTime>),
        findsOneWidget,
      );
    });

    testWidgets('shows forMainFrameOnly switch', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserScriptTesterWidget(
              onAddScript: (script) async {},
              onRemoveScript: (script) async {},
            ),
          ),
        ),
      );

      expect(find.text('Main Frame Only'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('add button is disabled when source is empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserScriptTesterWidget(
              onAddScript: (script) async {},
              onRemoveScript: (script) async {},
            ),
          ),
        ),
      );

      final addButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Add Script'),
      );

      expect(addButton.onPressed, isNull);
    });

    testWidgets('add button is enabled when source is entered', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserScriptTesterWidget(
              onAddScript: (script) async {},
              onRemoveScript: (script) async {},
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'console.log("test")');
      await tester.pump();

      final addButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Add Script'),
      );

      expect(addButton.onPressed, isNotNull);
    });

    testWidgets('calls onAddScript when add button is pressed', (tester) async {
      UserScript? addedScript;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserScriptTesterWidget(
              onAddScript: (script) async {
                addedScript = script;
              },
              onRemoveScript: (script) async {},
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'alert("Hello")');
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Add Script'));
      await tester.pumpAndSettle();

      expect(addedScript, isNotNull);
      expect(addedScript!.source, 'alert("Hello")');
    });

    testWidgets('displays list of added scripts', (tester) async {
      final scripts = <UserScript>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserScriptTesterWidget(
              onAddScript: (script) async {
                scripts.add(script);
              },
              onRemoveScript: (script) async {},
              scripts: scripts,
            ),
          ),
        ),
      );

      // Add first script
      await tester.enterText(find.byType(TextField), 'script 1');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add Script'));
      await tester.pumpAndSettle();

      // Should show in list
      expect(find.textContaining('script 1'), findsOneWidget);
    });

    testWidgets('shows remove button for each script', (tester) async {
      final script = UserScript(
        source: 'console.log("test")',
        injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserScriptTesterWidget(
              onAddScript: (script) async {},
              onRemoveScript: (script) async {},
              scripts: [script],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('calls onRemoveScript when remove button is pressed', (
      tester,
    ) async {
      final script = UserScript(
        source: 'console.log("test")',
        injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
      );

      UserScript? removedScript;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserScriptTesterWidget(
              onAddScript: (script) async {},
              onRemoveScript: (script) async {
                removedScript = script;
              },
              scripts: [script],
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(removedScript, script);
    });

    testWidgets('clears form after adding script', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserScriptTesterWidget(
              onAddScript: (script) async {},
              onRemoveScript: (script) async {},
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'test code');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add Script'));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('displays script injection time', (tester) async {
      final script = UserScript(
        source: 'console.log("test")',
        injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserScriptTesterWidget(
              onAddScript: (script) async {},
              onRemoveScript: (script) async {},
              scripts: [script],
            ),
          ),
        ),
      );

      expect(find.text('AT_DOCUMENT_END'), findsOneWidget);
    });

    testWidgets('displays forMainFrameOnly status', (tester) async {
      final script = UserScript(
        source: 'console.log("test")',
        injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
        forMainFrameOnly: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserScriptTesterWidget(
              onAddScript: (script) async {},
              onRemoveScript: (script) async {},
              scripts: [script],
            ),
          ),
        ),
      );

      expect(find.text('Main Frame Only'), findsWidgets);
    });

    testWidgets('shows empty state when no scripts', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserScriptTesterWidget(
              onAddScript: (script) async {},
              onRemoveScript: (script) async {},
              scripts: [],
            ),
          ),
        ),
      );

      expect(find.text('No user scripts added'), findsOneWidget);
    });

    testWidgets('injection time dropdown works', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserScriptTesterWidget(
              onAddScript: (script) async {},
              onRemoveScript: (script) async {},
            ),
          ),
        ),
      );

      // Open dropdown
      await tester.tap(find.byType(DropdownButton<UserScriptInjectionTime>));
      await tester.pumpAndSettle();

      // Should show both options
      expect(find.text('AT_DOCUMENT_START').hitTestable(), findsOneWidget);
      expect(find.text('AT_DOCUMENT_END').hitTestable(), findsOneWidget);
    });
  });
}
