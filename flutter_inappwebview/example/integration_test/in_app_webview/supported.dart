part of 'main.dart';

void supported() {
  skippableGroup('supported', () {
    skippableTestWidgets('basic', (WidgetTester tester) async {
      expect(InAppWebViewController.isClassSupported(), true);
      expect(
        InAppWebViewController.isPropertySupported(
          PlatformInAppWebViewControllerProperty.webStorage,
        ),
        true,
      );
      expect(
        InAppWebViewController.isMethodSupported(
          PlatformInAppWebViewControllerMethod.startSafeBrowsing,
        ),
        defaultTargetPlatform == TargetPlatform.android,
      );
      expect(
        InAppWebViewController.isMethodSupported(
          PlatformInAppWebViewControllerMethod.createPdf,
        ),
        [
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform),
      );
      expect(
        InAppWebViewController.isMethodSupported(
          PlatformInAppWebViewControllerMethod.clearSslPreferences,
        ),
        [
          TargetPlatform.android,
          TargetPlatform.windows,
        ].contains(defaultTargetPlatform),
      );
      expect(
        InAppWebViewController.isMethodSupported(
          PlatformInAppWebViewControllerMethod.openDevTools,
        ),
        defaultTargetPlatform == TargetPlatform.windows,
      );

      expect(InAppWebView.isClassSupported(), true);
      expect(
        InAppWebView.isPropertySupported(
          PlatformWebViewCreationParamsProperty.initialSettings,
        ),
        true,
      );
      expect(
        InAppWebView.isPropertySupported(
          PlatformWebViewCreationParamsProperty.windowId,
        ),
        true,
      );
      expect(
        InAppWebView.isPropertySupported(
          PlatformInAppWebViewWidgetCreationParamsProperty.preventGestureDelay,
        ),
        defaultTargetPlatform == TargetPlatform.iOS,
      );
      expect(
        InAppWebView.isPropertySupported(
          PlatformWebViewCreationParamsProperty.onWebContentProcessDidTerminate,
        ),
        [
          TargetPlatform.iOS,
          TargetPlatform.macOS,
          TargetPlatform.windows,
        ].contains(defaultTargetPlatform),
      );
      expect(
        InAppWebView.isPropertySupported(
          PlatformWebViewCreationParamsProperty.onAcceleratorKeyPressed,
        ),
        defaultTargetPlatform == TargetPlatform.windows,
      );

      expect(
        InAppWebViewSettings.isPropertySupported(
          InAppWebViewSettingsProperty.algorithmicDarkeningAllowed,
        ),
        defaultTargetPlatform == TargetPlatform.android,
      );
      expect(
        InAppWebViewSettings.isPropertySupported(
          InAppWebViewSettingsProperty.allowsBackForwardNavigationGestures,
        ),
        [
          TargetPlatform.iOS,
          TargetPlatform.macOS,
          TargetPlatform.windows,
        ].contains(defaultTargetPlatform),
      );
      expect(
        InAppWebViewSettings.isPropertySupported(
          InAppWebViewSettingsProperty.handleAcceleratorKeyPressed,
        ),
        defaultTargetPlatform == TargetPlatform.windows,
      );
    }, skip: false);
  }, skip: false);
}
