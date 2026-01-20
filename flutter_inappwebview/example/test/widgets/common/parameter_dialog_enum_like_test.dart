import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_example/widgets/common/parameter_dialog.dart';

class _TestEnumLike {
  final String _label;

  const _TestEnumLike._(this._label);

  String name() => _label;

  static const alpha = _TestEnumLike._('alpha');
  static const beta = _TestEnumLike._('beta');

  static const values = [alpha, beta];
}

void main() {
  group('ParameterDialog enum-like handling', () {
    testWidgets('uses name() for enum-like display', (tester) async {
      final parameters = <String, dynamic>{
        'mode': EnumParameterValueHint<_TestEnumLike>(
          _TestEnumLike.alpha,
          _TestEnumLike.values,
        ),
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ParameterDialog(title: 'Parameters', parameters: parameters),
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButtonFormField));
      await tester.pumpAndSettle();

      expect(find.text('alpha'), findsWidgets);
      expect(find.text('beta'), findsWidgets);
    });

    testWidgets('renders multi-select enum-like values', (tester) async {
      final parameters = <String, dynamic>{
        'flags': EnumParameterValueHint<_TestEnumLike>(
          <_TestEnumLike>[_TestEnumLike.alpha],
          _TestEnumLike.values,
          isMultiSelect: true,
        ),
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ParameterDialog(title: 'Parameters', parameters: parameters),
          ),
        ),
      );

      final alphaChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'alpha'),
      );
      final betaChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'beta'),
      );

      expect(alphaChip.selected, isTrue);
      expect(betaChip.selected, isFalse);

      await tester.tap(find.widgetWithText(FilterChip, 'beta'));
      await tester.pumpAndSettle();

      final updatedBetaChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'beta'),
      );
      expect(updatedBetaChip.selected, isTrue);
    });
  });
}
