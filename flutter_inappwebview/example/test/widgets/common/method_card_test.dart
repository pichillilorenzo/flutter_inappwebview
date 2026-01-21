import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_example/utils/support_checker.dart';
import 'package:flutter_inappwebview_example/widgets/common/method_card.dart';

void main() {
  testWidgets('test_method_card_compact_on_mobile', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(320, 800)),
          child: Scaffold(
            body: MethodCard(
              methodName: 'Test Method',
              description: 'Does something useful.',
              supportedPlatforms: const {SupportedPlatform.android},
              onRun: () {},
            ),
          ),
        ),
      ),
    );

    final buttonFinder = find.byKey(const Key('method-card-run-button'));
    expect(buttonFinder, findsOneWidget);

    final button = tester.widget<ElevatedButton>(buttonFinder);
    final style = button.style;
    final minSize = style?.minimumSize?.resolve(<MaterialState>{});
    final padding = style?.padding?.resolve(<MaterialState>{});

    expect(minSize?.height, 40);
    expect(padding, const EdgeInsets.symmetric(horizontal: 12, vertical: 8));
  });
}
