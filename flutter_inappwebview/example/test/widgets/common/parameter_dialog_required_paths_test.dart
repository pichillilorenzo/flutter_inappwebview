import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_example/widgets/common/parameter_dialog.dart';

void main() {
  group('ParameterDialog required paths', () {
    testWidgets(
      'shows required errors for non-text fields and accepts false boolean',
      (tester) async {
        final parameters = <String, dynamic>{
          'bytesValue': Uint8List(0),
          'dateValue': const ParameterValueHint<DateTime?>(
            null,
            ParameterValueType.date,
          ),
          'colorValue': const ParameterValueHint<Color?>(
            null,
            ParameterValueType.color,
          ),
          'listValue': <dynamic>[],
          'mapValue': <String, dynamic>{},
          'boolValue': false,
        };

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ParameterDialog(
                title: 'Parameters',
                parameters: parameters,
                requiredPaths: const [
                  'bytesValue',
                  'dateValue',
                  'colorValue',
                  'listValue',
                  'mapValue',
                  'boolValue',
                ],
              ),
            ),
          ),
        );

        await tester.tap(find.text('Apply'));
        await tester.pumpAndSettle();

        expect(find.text('Required'), findsNWidgets(5));

        final boolTile = tester.widget<SwitchListTile>(
          find.widgetWithText(SwitchListTile, 'boolValue'),
        );
        expect(boolTile.value, isFalse);
      },
    );
  });
}
