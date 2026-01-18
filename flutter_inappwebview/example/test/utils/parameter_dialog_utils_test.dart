import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_example/utils/parameter_dialog_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ParameterDialogUtils', () {
    test('deepCloneMap creates new nested copies', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final original = <String, dynamic>{
        'name': 'value',
        'list': [
          1,
          2,
          {'inner': 'ok'},
        ],
        'bytes': bytes,
        'color': Colors.red,
      };

      final clone = ParameterDialogUtils.deepCloneMap(original);

      expect(clone, isNot(same(original)));
      expect(clone['list'], isNot(same(original['list'])));
      expect(clone['bytes'], isNot(same(original['bytes'])));
      expect(clone['color'], isA<Color>());

      (clone['list'] as List)[2]['inner'] = 'changed';
      expect(original['list'][2]['inner'], 'ok');
    });

    test('parseNumber returns null for invalid values', () {
      expect(ParameterDialogUtils.parseNumber('abc'), isNull);
      expect(ParameterDialogUtils.parseNumber(''), isNull);
      expect(ParameterDialogUtils.parseNumber('12.5'), 12.5);
    });

    test('parseBytes decodes base64 when prefixed', () {
      final data = Uint8List.fromList([10, 20, 30]);
      final encoded = base64.encode(data);

      final parsed = ParameterDialogUtils.parseBytes('base64:$encoded');

      expect(parsed, isNotNull);
      expect(parsed, data);
    });

    test('parseBytes decodes data URI base64 payloads', () {
      final data = Uint8List.fromList([3, 4, 5, 6]);
      final encoded = base64.encode(data);

      final parsed = ParameterDialogUtils.parseBytes(
        'data:application/octet-stream;base64,$encoded',
      );

      expect(parsed, isNotNull);
      expect(parsed, data);
    });

    test('parseBytes returns null on invalid base64 input with prefix', () {
      final parsed = ParameterDialogUtils.parseBytes('base64:====');
      expect(parsed, isNull);
    });

    test('parseBytes falls back to utf8 for non-base64', () {
      final parsed = ParameterDialogUtils.parseBytes('hello');
      expect(parsed, Uint8List.fromList(utf8.encode('hello')));
    });

    test('parseBytes treats base64-like text as utf8 without prefix', () {
      final parsed = ParameterDialogUtils.parseBytes('dGVzdA==');
      expect(parsed, Uint8List.fromList(utf8.encode('dGVzdA==')));
    });

    test('getValueAtPath and setValueAtPath work for nested structures', () {
      final data = <String, dynamic>{
        'root': {
          'items': [
            {'value': 1},
          ],
        },
      };

      ParameterDialogUtils.setValueAtPath(data, [
        'root',
        'items',
        0,
        'value',
      ], 42);

      final result = ParameterDialogUtils.getValueAtPath(data, [
        'root',
        'items',
        0,
        'value',
      ]);

      expect(result, 42);
    });
  });
}
