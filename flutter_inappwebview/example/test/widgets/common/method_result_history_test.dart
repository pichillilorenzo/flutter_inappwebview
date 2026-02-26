import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_example/widgets/common/method_result_history.dart';

void main() {
  const platformChannel = SystemChannels.platform;
  String? clipboardText;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(platformChannel, (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboardText = call.arguments['text'] as String?;
            return null;
          }
          if (call.method == 'Clipboard.getData') {
            return <String, dynamic>{'text': clipboardText};
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(platformChannel, null);
    clipboardText = null;
  });

  testWidgets('renders collapsed by default with latest result summary', (
    tester,
  ) async {
    final entries = [
      MethodResultEntry(
        message: 'latest result',
        isError: false,
        timestamp: DateTime(2024, 1, 1),
        value: {'key': 'json_value', 'number': 42},
      ),
      MethodResultEntry(
        message: 'older result',
        isError: true,
        timestamp: DateTime(2023, 12, 31),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: MethodResultHistory(entries: entries)),
      ),
    );

    // Latest result should be visible in collapsed state as summary
    expect(find.text('latest result'), findsOneWidget);
    // Older result should NOT be visible when collapsed
    expect(find.text('older result'), findsNothing);
  });

  testWidgets('expands to show all entries when tapped', (tester) async {
    final entries = [
      MethodResultEntry(
        message: 'latest result',
        isError: false,
        timestamp: DateTime(2024, 1, 1),
        value: {'key': 'json_value', 'number': 42},
      ),
      MethodResultEntry(
        message: 'older result',
        isError: true,
        timestamp: DateTime(2023, 12, 31),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: MethodResultHistory(entries: entries)),
      ),
    );

    // Tap to expand
    await tester.tap(find.text('History'));
    await tester.pump();

    // Both entries should now be visible
    expect(find.text('latest result'), findsOneWidget);
    expect(find.text('older result'), findsOneWidget);
  });

  testWidgets('renders history entries and copies value if available', (
    tester,
  ) async {
    final entries = [
      MethodResultEntry(
        message: 'latest result',
        isError: false,
        timestamp: DateTime(2024, 1, 1),
        value: {'key': 'json_value', 'number': 42},
      ),
      MethodResultEntry(
        message: 'older result',
        isError: true,
        timestamp: DateTime(2023, 12, 31),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MethodResultHistory(entries: entries, initiallyExpanded: true),
        ),
      ),
    );

    expect(find.text('latest result'), findsOneWidget);
    expect(find.text('older result'), findsOneWidget);

    await tester.tap(find.byKey(const Key('method-history-copy')));
    await tester.pumpAndSettle();

    // Should copy JSON-encoded value, not message
    expect(clipboardText, contains('"key": "json_value"'));
    expect(clipboardText, contains('"number": 42'));
  });

  testWidgets('copies message when no value is available', (tester) async {
    final entries = [
      MethodResultEntry(
        message: 'message only',
        isError: false,
        timestamp: DateTime(2024, 1, 1),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MethodResultHistory(entries: entries, initiallyExpanded: true),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('method-history-copy')));
    await tester.pumpAndSettle();

    expect(clipboardText, 'message only');
  });

  testWidgets('copies selected history entry', (tester) async {
    final entries = [
      MethodResultEntry(
        message: 'first entry',
        isError: false,
        timestamp: DateTime(2024, 1, 1),
        value: 'first_value',
      ),
      MethodResultEntry(
        message: 'second entry',
        isError: true,
        timestamp: DateTime(2024, 1, 2),
        value: 'second_value',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MethodResultHistory(entries: entries, initiallyExpanded: true),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('method-history-entry-1')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('method-history-copy')));
    await tester.pumpAndSettle();

    // Should copy the JSON-encoded value "second_value"
    expect(clipboardText, '"second_value"');
  });

  testWidgets('initiallyExpanded=true shows entries immediately', (
    tester,
  ) async {
    final entries = [
      MethodResultEntry(
        message: 'test entry',
        isError: false,
        timestamp: DateTime(2024, 1, 1),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MethodResultHistory(entries: entries, initiallyExpanded: true),
        ),
      ),
    );

    // Entry should be visible immediately
    expect(find.byKey(const Key('method-history-entry-0')), findsOneWidget);
  });
}
