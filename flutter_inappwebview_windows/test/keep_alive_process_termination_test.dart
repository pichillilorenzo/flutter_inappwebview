import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_inappwebview_windows/flutter_inappwebview_windows.dart';
import 'package:flutter_test/flutter_test.dart';

const _staticChannel = MethodChannel(
  'com.pichillilorenzo/flutter_inappwebview_manager',
);

TestDefaultBinaryMessenger get _messenger =>
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

/// A WebView2 shown by a widget and held by a keep alive, each counting the
/// process deaths it is told about. WebView2 reports a browser process exit
/// as a render process gone and a render process exit as a content process
/// termination.
class _KeptAliveWebView {
  /// Whether a second widget takes the view over while the native side is
  /// still releasing it, as a screen reopened during the release does.
  bool anotherWidgetAttachesDuringRelease = false;
  int keepAliveContentDeaths = 0;
  final keepAliveRenderDeaths = <RenderProcessGoneDetail>[];
  int otherWidgetDeaths = 0;
  int widgetContentDeaths = 0;
  int widgetRenderDeaths = 0;

  late final keepAlive = InAppWebViewKeepAlive(
    onRenderProcessGone: keepAliveRenderDeaths.add,
    onWebContentProcessDidTerminate: () => keepAliveContentDeaths++,
  );

  late final controller = WindowsInAppWebViewController(
    WindowsInAppWebViewControllerCreationParams(
      id: keepAlive.id,
      webviewParams: WindowsInAppWebViewWidgetCreationParams(
        keepAlive: keepAlive,
        onRenderProcessGone: (_, __) => widgetRenderDeaths++,
        onWebContentProcessDidTerminate: (_) => widgetContentDeaths++,
      ),
    ),
  );

  /// A second widget taking the same kept-alive view over, as a route
  /// transition does while the first is still animating out.
  late final otherController = WindowsInAppWebViewController(
    WindowsInAppWebViewControllerCreationParams(
      id: keepAlive.id,
      webviewParams: WindowsInAppWebViewWidgetCreationParams(
        keepAlive: keepAlive,
        onRenderProcessGone: (_, __) => otherWidgetDeaths++,
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

  Future<void> _nativeReports(MethodCall call) =>
      _messenger.handlePlatformMessage(
        'com.pichillilorenzo/flutter_inappwebview_${keepAlive.id}',
        const StandardMethodCodec().encodeMethodCall(call),
        (_) {},
      );

  Future<void> nativeReportsRenderProcessGone({bool didCrash = true}) =>
      _nativeReports(MethodCall('onRenderProcessGone', {'didCrash': didCrash}));

  Future<void> nativeReportsContentProcessTerminated() =>
      _nativeReports(const MethodCall('onWebContentProcessDidTerminate'));

  Future<void> widgetGoesAway() async => controller.dispose(isKeepAlive: true);

  /// Reading the field builds the controller, which is what attaching a
  /// widget does.
  Future<void> anotherWidgetTakesItOver() async => otherController;

  Future<void> keepAliveReleasesIt() =>
      WindowsInAppWebViewController.static().disposeKeepAlive(keepAlive);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() => _messenger.setMockMethodCallHandler(_staticChannel, null));

  group('A kept-alive WebView2 whose browser process exits', () {
    test(
      'tells its keep alive why, as well as the widget showing it',
      () async {
        final webView = _KeptAliveWebView();

        await webView.nativeReportsRenderProcessGone(didCrash: true);

        expect(webView.keepAliveRenderDeaths.map((d) => d.didCrash), [true]);
        expect(webView.widgetRenderDeaths, 1);
      },
    );

    test(
      'still tells its keep alive once its widget is gone, and the widget no longer',
      () async {
        final webView = _KeptAliveWebView();

        await webView.widgetGoesAway();
        await webView.nativeReportsRenderProcessGone(didCrash: false);

        expect(webView.keepAliveRenderDeaths.map((d) => d.didCrash), [false]);
        expect(webView.widgetRenderDeaths, 0);
      },
    );

    test(
      'tells the widget that took it over after its first widget was gone',
      () async {
        final webView = _KeptAliveWebView();

        await webView.widgetGoesAway();
        await webView.anotherWidgetTakesItOver();
        await webView.nativeReportsRenderProcessGone();

        expect(webView.keepAliveRenderDeaths.map((d) => d.didCrash), [true]);
        expect(webView.otherWidgetDeaths, 1);
        expect(webView.widgetRenderDeaths, 0);
      },
    );

    test('tells nobody once the keep alive has released it', () async {
      final webView = _KeptAliveWebView();

      await webView.widgetGoesAway();
      await webView.keepAliveReleasesIt();
      await webView.nativeReportsRenderProcessGone();

      expect(webView.keepAliveRenderDeaths, isEmpty);
      expect(webView.widgetRenderDeaths, 0);
    });

    test(
      'keeps telling a widget that took it over while the keep alive was still releasing it',
      () async {
        final webView = _KeptAliveWebView()
          ..anotherWidgetAttachesDuringRelease = true;

        await webView.widgetGoesAway();
        await webView.keepAliveReleasesIt();
        await webView.nativeReportsRenderProcessGone();

        expect(webView.otherWidgetDeaths, 1);
      },
    );
  });

  group('A kept-alive WebView2 whose render process exits', () {
    test('tells its keep alive, as well as the widget showing it', () async {
      final webView = _KeptAliveWebView();

      await webView.nativeReportsContentProcessTerminated();

      expect(webView.keepAliveContentDeaths, 1);
      expect(webView.widgetContentDeaths, 1);
    });

    test(
      'still tells its keep alive once its widget is gone, and the widget no longer',
      () async {
        final webView = _KeptAliveWebView();

        await webView.widgetGoesAway();
        await webView.nativeReportsContentProcessTerminated();

        expect(webView.keepAliveContentDeaths, 1);
        expect(webView.widgetContentDeaths, 0);
      },
    );

    test('tells nobody once the keep alive has released it', () async {
      final webView = _KeptAliveWebView();

      await webView.widgetGoesAway();
      await webView.keepAliveReleasesIt();
      await webView.nativeReportsContentProcessTerminated();

      expect(webView.keepAliveContentDeaths, 0);
      expect(webView.widgetContentDeaths, 0);
    });
  });

  group('A WebView2 created under a keep alive', () {
    /// The settings the widget hands the native side on creation. Creation is
    /// left pending on purpose: once it completes, the view subscribes to
    /// channels nothing answers here.
    Future<Map<Object?, Object?>> initialSettingsOf(
      WidgetTester tester,
      InAppWebViewKeepAlive keepAlive,
    ) async {
      Map<Object?, Object?>? settings;

      _messenger.setMockMethodCallHandler(_staticChannel, (call) {
        if (call.method == 'createInAppWebView') {
          settings = (call.arguments as Map)['initialSettings'] as Map;
        }
        return Completer<Object?>().future;
      });
      final widget = WindowsInAppWebViewWidget(
        WindowsInAppWebViewWidgetCreationParams(keepAlive: keepAlive),
      );
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(builder: widget.build),
        ),
      );
      await tester.pump();

      return settings ?? (throw StateError('no native view was created'));
    }

    testWidgets(
      'that listens for its render process going is created reporting it',
      (tester) async {
        final settings = await initialSettingsOf(
          tester,
          InAppWebViewKeepAlive(onRenderProcessGone: (_) {}),
        );

        expect(settings['useOnRenderProcessGone'], isTrue);
      },
    );

    testWidgets('that does not listen leaves the default in place', (
      tester,
    ) async {
      final settings = await initialSettingsOf(tester, InAppWebViewKeepAlive());

      expect(settings['useOnRenderProcessGone'], isNot(true));
    });
  });
}
