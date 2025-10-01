part of 'main.dart';

void supported() {
  skippableGroup('supported', () {
    skippableTestWidgets('basic', (WidgetTester tester) async {
      expect(HeadlessInAppWebView.isClassSupported(), true);
      expect(
          HeadlessInAppWebView.isPropertySupported(
              PlatformHeadlessInAppWebViewCreationParamsProperty.initialSize),
          true);
      expect(
          HeadlessInAppWebView.isPropertySupported(
              PlatformHeadlessInAppWebViewCreationParamsProperty
                  .webViewEnvironment),
          defaultTargetPlatform == TargetPlatform.windows);
      expect(
          HeadlessInAppWebView.isMethodSupported(
              PlatformHeadlessInAppWebViewMethod.run),
          true);
      expect(
          HeadlessInAppWebView.isMethodSupported(
              PlatformHeadlessInAppWebViewMethod.dispose),
          true);
    }, skip: false);
  }, skip: false);
}
