import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_example/widgets/common/responsive_row.dart';

void main() {
  testWidgets('test_responsive_row_switches_to_column', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 500,
            child: ResponsiveRow(children: [Text('A'), Text('B')]),
          ),
        ),
      ),
    );

    final responsiveRowFinder = find.byType(ResponsiveRow);
    final columnFinder = find.descendant(
      of: responsiveRowFinder,
      matching: find.byType(Column),
    );
    final rowFinder = find.descendant(
      of: responsiveRowFinder,
      matching: find.byType(Row),
    );

    expect(columnFinder, findsOneWidget);
    expect(rowFinder, findsNothing);
  });

  testWidgets('test_responsive_row_switches_to_row', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 600,
            child: ResponsiveRow(children: [Text('A'), Text('B')]),
          ),
        ),
      ),
    );

    final responsiveRowFinder = find.byType(ResponsiveRow);
    final columnFinder = find.descendant(
      of: responsiveRowFinder,
      matching: find.byType(Column),
    );
    final rowFinder = find.descendant(
      of: responsiveRowFinder,
      matching: find.byType(Row),
    );

    expect(columnFinder, findsNothing);
    expect(rowFinder, findsOneWidget);
  });
}
