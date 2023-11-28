part of 'main.dart';

void apply() {
  final shouldSkip = kIsWeb
      ? true
      : ![
          TargetPlatform.android,
        ].contains(defaultTargetPlatform);

  skippableTestWidgets('apply', (WidgetTester tester) async {
    await expectLater(
        ProcessGlobalConfig.instance().apply(
            settings: ProcessGlobalConfigSettings(
                dataDirectorySuffix:
                    (await WebViewFeature.isStartupFeatureSupported(
                            WebViewFeature
                                .STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX))
                        ? 'suffix_inappwebviewexample'
                        : null,
                directoryBasePaths:
                    (await WebViewFeature.isStartupFeatureSupported(
                            WebViewFeature
                                .STARTUP_FEATURE_SET_DIRECTORY_BASE_PATHS))
                        ? ProcessGlobalConfigDirectoryBasePaths(
                            cacheDirectoryBasePath:
                                (await getApplicationDocumentsDirectory())
                                        .absolute
                                        .path +
                                    '/inappwebviewexample/cache',
                            dataDirectoryBasePath:
                                (await getApplicationDocumentsDirectory())
                                        .absolute
                                        .path +
                                    '/inappwebviewexample/data')
                        : null)),
        completes);
  }, skip: shouldSkip);
}
