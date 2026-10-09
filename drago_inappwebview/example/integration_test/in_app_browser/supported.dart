part of 'main.dart';

void supported() {
  skippableGroup('supported', () {
    skippableTestWidgets('basic', (WidgetTester tester) async {
      expect(InAppBrowser.isClassSupported(), true);
      expect(
        InAppBrowser.isPropertySupported(PlatformInAppBrowserProperty.windowId),
        true,
      );
      expect(
        InAppBrowser.isMethodSupported(
          PlatformInAppBrowserMethod.openUrlRequest,
        ),
        true,
      );
      expect(
        InAppBrowser.isMethodSupported(PlatformInAppBrowserMethod.close),
        true,
      );
      expect(
        InAppBrowser.isMethodSupported(PlatformInAppBrowserMethod.hide),
        true,
      );
      expect(
        InAppBrowser.isMethodSupported(PlatformInAppBrowserMethod.show),
        true,
      );
      expect(
        InAppBrowser.isEventMethodSupported(
          PlatformInAppBrowserEventsMethod.onWebContentProcessDidTerminate,
        ),
        [
          TargetPlatform.iOS,
          TargetPlatform.macOS,
          TargetPlatform.windows,
        ].contains(defaultTargetPlatform),
      );
      expect(
        InAppBrowser.isEventMethodSupported(
          PlatformInAppBrowserEventsMethod.onAcceleratorKeyPressed,
        ),
        defaultTargetPlatform == TargetPlatform.windows,
      );

      expect(
        InAppBrowserSettings.isPropertySupported(
          InAppBrowserSettingsProperty.toolbarBottomTintColor,
        ),
        defaultTargetPlatform == TargetPlatform.iOS,
      );
      expect(
        InAppBrowserSettings.isPropertySupported(
          InAppBrowserSettingsProperty.hidden,
        ),
        true,
      );
      expect(
        InAppBrowserSettings.isPropertySupported(
          InAppBrowserSettingsProperty.closeOnCannotGoBack,
        ),
        defaultTargetPlatform == TargetPlatform.android,
      );
    }, skip: false);
  }, skip: false);
}
