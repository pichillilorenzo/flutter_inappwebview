import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_macos/flutter_inappwebview_macos.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

const _staticChannel = MethodChannel(
  'com.pichillilorenzo/flutter_inappwebview_manager',
);

TestDefaultBinaryMessenger get _messenger =>
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

/// A WebView shown by a widget and held by a keep alive, each counting the
/// content process deaths it is told about.
class _KeptAliveWebView {
  /// Whether a second widget takes the view over while the native side is
  /// still releasing it, as a screen reopened during the release does.
  bool anotherWidgetAttachesDuringRelease = false;
  int keepAliveDeaths = 0;
  int otherWidgetDeaths = 0;
  int widgetDeaths = 0;

  late final keepAlive = InAppWebViewKeepAlive(
    onWebContentProcessDidTerminate: () => keepAliveDeaths++,
  );

  late final controller = MacOSInAppWebViewController(
    MacOSInAppWebViewControllerCreationParams(
      id: keepAlive.id,
      webviewParams: MacOSInAppWebViewWidgetCreationParams(
        keepAlive: keepAlive,
        onWebContentProcessDidTerminate: (_) => widgetDeaths++,
      ),
    ),
  );

  /// A second widget taking the same kept-alive view over, as a route
  /// transition does while the first is still animating out.
  late final otherController = MacOSInAppWebViewController(
    MacOSInAppWebViewControllerCreationParams(
      id: keepAlive.id,
      webviewParams: MacOSInAppWebViewWidgetCreationParams(
        keepAlive: keepAlive,
        onWebContentProcessDidTerminate: (_) => otherWidgetDeaths++,
      ),
    ),
  );

  _KeptAliveWebView() {
    // Listening starts when the controller exists, as it does under a widget.
    controller;
    _messenger.setMockMethodCallHandler(_staticChannel, (call) async {
      if (call.method == 'disposeKeepAlive' &&
          anotherWidgetAttachesDuringRelease) {
        otherController;
      }
      return null;
    });
  }

  Future<void> nativeReportsContentProcessTerminated() =>
      _messenger.handlePlatformMessage(
        'com.pichillilorenzo/flutter_inappwebview_${keepAlive.id}',
        const StandardMethodCodec().encodeMethodCall(
          const MethodCall('onWebContentProcessDidTerminate'),
        ),
        (_) {},
      );

  Future<void> widgetGoesAway() async => controller.dispose(isKeepAlive: true);

  /// Reading the field builds the controller, which is what attaching a
  /// widget does.
  Future<void> anotherWidgetTakesItOver() async => otherController;

  Future<void> keepAliveReleasesIt() =>
      MacOSInAppWebViewController.static().disposeKeepAlive(keepAlive);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() => _messenger.setMockMethodCallHandler(_staticChannel, null));

  group('A kept-alive WebView whose content process is terminated', () {
    test('tells its keep alive, as well as the widget showing it', () async {
      final webView = _KeptAliveWebView();

      await webView.nativeReportsContentProcessTerminated();

      expect(webView.keepAliveDeaths, 1);
      expect(webView.widgetDeaths, 1);
    });

    test(
      'still tells its keep alive once its widget is gone, and the widget no longer',
      () async {
        final webView = _KeptAliveWebView();

        await webView.widgetGoesAway();
        await webView.nativeReportsContentProcessTerminated();

        expect(webView.keepAliveDeaths, 1);
        expect(webView.widgetDeaths, 0);
      },
    );

    test(
      'tells the widget that took it over after its first widget was gone',
      () async {
        final webView = _KeptAliveWebView();

        await webView.widgetGoesAway();
        await webView.anotherWidgetTakesItOver();
        await webView.nativeReportsContentProcessTerminated();

        expect(webView.keepAliveDeaths, 1);
        expect(webView.otherWidgetDeaths, 1);
        expect(webView.widgetDeaths, 0);
      },
    );

    test(
      'keeps telling the widget that took it over when the first widget goes away afterwards',
      () async {
        final webView = _KeptAliveWebView();

        await webView.anotherWidgetTakesItOver();
        await webView.widgetGoesAway();
        await webView.nativeReportsContentProcessTerminated();

        expect(webView.keepAliveDeaths, 1);
        expect(webView.otherWidgetDeaths, 1);
        expect(webView.widgetDeaths, 0);
      },
    );

    test('tells nobody once the keep alive has released it', () async {
      final webView = _KeptAliveWebView();

      await webView.widgetGoesAway();
      await webView.keepAliveReleasesIt();
      await webView.nativeReportsContentProcessTerminated();

      expect(webView.keepAliveDeaths, 0);
      expect(webView.widgetDeaths, 0);
    });

    test(
      'keeps telling a widget that took it over while the keep alive was still releasing it',
      () async {
        final webView = _KeptAliveWebView()
          ..anotherWidgetAttachesDuringRelease = true;

        await webView.widgetGoesAway();
        await webView.keepAliveReleasesIt();
        await webView.nativeReportsContentProcessTerminated();

        expect(webView.otherWidgetDeaths, 1);
      },
    );

    test('tells nobody once its widget is disposed for good', () async {
      final webView = _KeptAliveWebView();

      webView.controller.dispose();
      await webView.nativeReportsContentProcessTerminated();

      expect(webView.keepAliveDeaths, 0);
      expect(webView.widgetDeaths, 0);
    });
  });
}
