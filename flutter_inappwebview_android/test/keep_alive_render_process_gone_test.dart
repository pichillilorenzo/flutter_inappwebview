import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

const _staticChannel = MethodChannel(
  'com.pichillilorenzo/flutter_inappwebview_manager',
);

TestDefaultBinaryMessenger get _messenger =>
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

/// A WebView shown by a widget and held by a keep alive, each counting the
/// render process deaths it is told about.
class _KeptAliveWebView {
  /// Whether a second widget takes the view over while the native side is
  /// still releasing it, as a screen reopened during the release does.
  bool anotherWidgetAttachesDuringRelease = false;
  final keepAliveDeaths = <RenderProcessGoneDetail>[];
  int otherWidgetDeaths = 0;
  int widgetDeaths = 0;

  late final keepAlive = InAppWebViewKeepAlive(
    onRenderProcessGone: keepAliveDeaths.add,
  );

  late final controller = AndroidInAppWebViewController(
    AndroidInAppWebViewControllerCreationParams(
      id: keepAlive.id,
      webviewParams: AndroidInAppWebViewWidgetCreationParams(
        keepAlive: keepAlive,
        onRenderProcessGone: (_, __) => widgetDeaths++,
      ),
    ),
  );

  /// A second widget taking the same kept-alive view over, as a route
  /// transition does while the first is still animating out.
  late final otherController = AndroidInAppWebViewController(
    AndroidInAppWebViewControllerCreationParams(
      id: keepAlive.id,
      webviewParams: AndroidInAppWebViewWidgetCreationParams(
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

  Future<void> nativeReportsRenderProcessGone({bool didCrash = true}) =>
      _messenger.handlePlatformMessage(
        'com.pichillilorenzo/flutter_inappwebview_${keepAlive.id}',
        const StandardMethodCodec().encodeMethodCall(
          MethodCall('onRenderProcessGone', {'didCrash': didCrash}),
        ),
        (_) {},
      );

  Future<void> widgetGoesAway() async => controller.dispose(isKeepAlive: true);

  /// Reading the field builds the controller, which is what attaching a
  /// widget does.
  Future<void> anotherWidgetTakesItOver() async => otherController;

  Future<void> keepAliveReleasesIt() =>
      AndroidInAppWebViewController.static().disposeKeepAlive(keepAlive);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() => _messenger.setMockMethodCallHandler(_staticChannel, null));

  group('A kept-alive WebView whose render process goes away', () {
    test(
      'tells its keep alive why, as well as the widget showing it',
      () async {
        final webView = _KeptAliveWebView();

        await webView.nativeReportsRenderProcessGone(didCrash: true);

        expect(webView.keepAliveDeaths.map((d) => d.didCrash), [true]);
        expect(webView.widgetDeaths, 1);
      },
    );

    test(
      'still tells its keep alive once its widget is gone, and the widget no longer',
      () async {
        final webView = _KeptAliveWebView();

        await webView.widgetGoesAway();
        await webView.nativeReportsRenderProcessGone(didCrash: false);

        expect(webView.keepAliveDeaths.map((d) => d.didCrash), [false]);
        expect(webView.widgetDeaths, 0);
      },
    );

    test(
      'tells the widget that took it over after its first widget was gone',
      () async {
        final webView = _KeptAliveWebView();

        await webView.widgetGoesAway();
        await webView.anotherWidgetTakesItOver();
        await webView.nativeReportsRenderProcessGone();

        expect(webView.keepAliveDeaths.map((d) => d.didCrash), [true]);
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
        await webView.nativeReportsRenderProcessGone();

        expect(webView.keepAliveDeaths.map((d) => d.didCrash), [true]);
        expect(webView.otherWidgetDeaths, 1);
        expect(webView.widgetDeaths, 0);
      },
    );

    test('tells nobody once the keep alive has released it', () async {
      final webView = _KeptAliveWebView();

      await webView.widgetGoesAway();
      await webView.keepAliveReleasesIt();
      await webView.nativeReportsRenderProcessGone();

      expect(webView.keepAliveDeaths, isEmpty);
      expect(webView.widgetDeaths, 0);
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

    test('tells nobody once its widget is disposed for good', () async {
      final webView = _KeptAliveWebView();

      webView.controller.dispose();
      await webView.nativeReportsRenderProcessGone();

      expect(webView.keepAliveDeaths, isEmpty);
      expect(webView.widgetDeaths, 0);
    });
  });

  group('A WebView created under a keep alive', () {
    /// The settings the widget hands the native side on creation.
    Future<Map<Object?, Object?>> initialSettingsOf(
      WidgetTester tester,
      InAppWebViewKeepAlive keepAlive,
    ) async {
      Map<Object?, Object?>? settings;

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform_views,
        (call) async {
          if (call.method == 'create') {
            final params =
                const StandardMessageCodec().decodeMessage(
                      ByteData.sublistView(
                        call.arguments['params'] as Uint8List,
                      ),
                    )
                    as Map;
            settings = params['initialSettings'] as Map;
          }
          return null;
        },
      );
      final widget = AndroidInAppWebViewWidget(
        AndroidInAppWebViewWidgetCreationParams(keepAlive: keepAlive),
      );
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(builder: widget.build),
        ),
      );
      await tester.pump();

      return settings ?? (throw StateError('no platform view was created'));
    }

    testWidgets(
      'that listens for its render process going is created reporting it, so Android does not kill the app instead',
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
