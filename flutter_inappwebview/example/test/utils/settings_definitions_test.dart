import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_example/models/setting_definition.dart';
import 'package:flutter_inappwebview_example/utils/settings_definitions.dart';

void main() {
  test('getSettingDefinitions returns expected categories', () {
    final definitions = getSettingDefinitions();

    expect(definitions, isNotEmpty);
    expect(definitions.keys, containsAll(['General', 'Security', 'Cache']));
  });

  test('definitions contain expected types', () {
    final definitions = getSettingDefinitions();
    final general = definitions['General'];

    expect(general, isNotNull);
    expect(general!.first.type, SettingType.boolean);
  });
}
