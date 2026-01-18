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

  testWidgets('renders history entries and copies latest by default',
      (tester) async {
    final entries = [
      MethodResultEntry(
        message: 'latest result',
        isError: false,
        timestamp: DateTime(2024, 1, 1),
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
          body: MethodResultHistory(entries: entries),
        ),
      ),
    );

    expect(find.text('latest result'), findsOneWidget);
    expect(find.text('older result'), findsOneWidget);

    await tester.tap(find.byKey(const Key('method-history-copy')));
    await tester.pump();

    expect(clipboardText, 'latest result');
  });

  testWidgets('copies selected history entry', (tester) async {
    final entries = [
      MethodResultEntry(
        message: 'first entry',
        isError: false,
        timestamp: DateTime(2024, 1, 1),
      ),
      MethodResultEntry(
        message: 'second entry',
        isError: true,
        timestamp: DateTime(2024, 1, 2),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MethodResultHistory(entries: entries),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('method-history-entry-1')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('method-history-copy')));
    await tester.pump();

    expect(clipboardText, 'second entry');
  });
}
