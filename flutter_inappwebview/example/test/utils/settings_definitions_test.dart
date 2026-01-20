import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/models/setting_definition.dart';
import 'package:flutter_inappwebview_example/utils/environment_settings_definitions.dart';
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

  test('enum-like setting definitions use enum values lists', () {
    final definitions = getSettingDefinitions();
    final security = definitions['Security'];
    final cache = definitions['Cache'];

    expect(security, isNotNull);
    expect(cache, isNotNull);

    final mixedContent = security!.firstWhere(
      (definition) =>
          definition.property == InAppWebViewSettingsProperty.mixedContentMode,
    );
    final cacheMode = cache!.firstWhere(
      (definition) =>
          definition.property == InAppWebViewSettingsProperty.cacheMode,
    );

    expect(mixedContent.enumValues, unorderedEquals(MixedContentMode.values));
    expect(cacheMode.enumValues, unorderedEquals(CacheMode.values));
  });

  test('enum-like environment setting definitions use enum values lists', () {
    final definitions = getEnvironmentSettingDefinitions();
    final releaseChannel = definitions['Release Channel'];
    final appearance = definitions['Appearance'];
    final cache = definitions['Cache'];

    expect(releaseChannel, isNotNull);
    expect(appearance, isNotNull);
    expect(cache, isNotNull);

    final channelSearchKind = releaseChannel!.firstWhere(
      (definition) =>
          definition.property ==
          WebViewEnvironmentSettingsProperty.channelSearchKind,
    );
    final releaseChannels = releaseChannel.firstWhere(
      (definition) =>
          definition.property ==
          WebViewEnvironmentSettingsProperty.releaseChannels,
    );
    final scrollbarStyle = appearance!.firstWhere(
      (definition) =>
          definition.property == WebViewEnvironmentSettingsProperty.scrollbarStyle,
    );
    final cacheModel = cache!.firstWhere(
      (definition) =>
          definition.property == WebViewEnvironmentSettingsProperty.cacheModel,
    );

    expect(
      channelSearchKind.enumValues,
      unorderedEquals(EnvironmentChannelSearchKind.values),
    );
    expect(
      releaseChannels.enumValues,
      unorderedEquals(EnvironmentReleaseChannels.values),
    );
    expect(
      scrollbarStyle.enumValues,
      unorderedEquals(EnvironmentScrollbarStyle.values),
    );
    expect(cacheModel.enumValues, unorderedEquals(CacheModel.values));
  });
}
