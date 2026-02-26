import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/models/setting_definition.dart';
import 'package:flutter_inappwebview_example/utils/environment_settings_definitions.dart';
import 'package:flutter_inappwebview_example/utils/settings_definitions.dart';

List<T> _enumValuesForPlatform<T>(
  TargetPlatform platform,
  Iterable<T> Function() getter,
) {
  final previousPlatform = debugDefaultTargetPlatformOverride;
  debugDefaultTargetPlatformOverride = platform;
  try {
    return getter().toList();
  } catch (_) {
    return <T>[];
  } finally {
    debugDefaultTargetPlatformOverride = previousPlatform;
  }
}

T _withPlatform<T>(TargetPlatform platform, T Function() body) {
  final previousPlatform = debugDefaultTargetPlatformOverride;
  debugDefaultTargetPlatformOverride = platform;
  try {
    return body();
  } finally {
    debugDefaultTargetPlatformOverride = previousPlatform;
  }
}

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

  test('enumValues fields are lists when provided', () {
    final definitions = getSettingDefinitions();

    for (final category in definitions.values) {
      for (final definition in category) {
        expect(definition.enumValues, anyOf(isNull, isA<List>()));
      }
    }

    final environmentDefinitions = getEnvironmentSettingDefinitions();
    for (final category in environmentDefinitions.values) {
      for (final definition in category) {
        expect(definition.enumValues, anyOf(isNull, isA<List>()));
      }
    }
  });

  test('enum-like environment setting definitions use enum values lists', () {
    final definitions = _withPlatform(
      TargetPlatform.windows,
      getEnvironmentSettingDefinitions,
    );
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
          definition.property ==
          WebViewEnvironmentSettingsProperty.scrollbarStyle,
    );
    final cacheModel = cache!.firstWhere(
      (definition) =>
          definition.property == WebViewEnvironmentSettingsProperty.cacheModel,
    );

    final expectedChannelKinds = _enumValuesForPlatform(
      TargetPlatform.windows,
      () => EnvironmentChannelSearchKind.values,
    );
    final expectedReleaseChannels = _enumValuesForPlatform(
      TargetPlatform.windows,
      () => EnvironmentReleaseChannels.values,
    );
    final expectedScrollbarStyles = _enumValuesForPlatform(
      TargetPlatform.windows,
      () => EnvironmentScrollbarStyle.values,
    );
    final expectedCacheModels = _enumValuesForPlatform(
      TargetPlatform.windows,
      () => CacheModel.values,
    );

    expect(channelSearchKind.enumValues, unorderedEquals(expectedChannelKinds));
    expect(
      releaseChannels.enumValues,
      unorderedEquals(expectedReleaseChannels),
    );
    expect(scrollbarStyle.enumValues, unorderedEquals(expectedScrollbarStyles));
    expect(cacheModel.enumValues, unorderedEquals(expectedCacheModels));
  });
}
