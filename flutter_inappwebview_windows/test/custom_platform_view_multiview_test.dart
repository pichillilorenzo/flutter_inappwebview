import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_inappwebview_windows/src/in_app_webview/_static_channel.dart';
import 'package:flutter_inappwebview_windows/src/in_app_webview/custom_platform_view.dart';

/// Multi-window: the native host window must be parented under the view that
/// shows the widget, and follow it when the widget moves to another view.
const int _kTextureId = 3;
const MethodChannel _viewChannel = MethodChannel(
  'com.pichillilorenzo/custom_platform_view_$_kTextureId',
);
const EventChannel _viewEventChannel = EventChannel(
  'com.pichillilorenzo/custom_platform_view_${_kTextureId}_events',
);

/// A second view backed by the test view, with its own id and scale.
class _SecondaryTestView extends TestFlutterView {
  _SecondaryTestView(TestFlutterView base)
    : super(
        view: base,
        platformDispatcher: base.platformDispatcher,
        display: base.display,
      );

  @override
  int get viewId => 7;

  @override
  double get devicePixelRatio => 1.5;

  @override
  void render(ui.Scene scene, {Size? size}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<MethodCall> pluginCalls;
  late List<MethodCall> viewCalls;

  setUp(() {
    pluginCalls = <MethodCall>[];
    viewCalls = <MethodCall>[];
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(IN_APP_WEBVIEW_STATIC_CHANNEL, (
      call,
    ) async {
      pluginCalls.add(call);
      return call.method == 'createInAppWebView' ? _kTextureId : null;
    });
    messenger.setMockMethodCallHandler(_viewChannel, (call) async {
      viewCalls.add(call);
      return null;
    });
    messenger.setMockStreamHandler(
      _viewEventChannel,
      MockStreamHandler.inline(onListen: (arguments, events) {}),
    );
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(IN_APP_WEBVIEW_STATIC_CHANNEL, null);
    messenger.setMockMethodCallHandler(_viewChannel, null);
    messenger.setMockStreamHandler(_viewEventChannel, null);
  });

  testWidgets('creation in the implicit view sends no view id', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: CustomPlatformView(
          creationParams: <String, dynamic>{'initialSettings': {}},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final create = pluginCalls.singleWhere(
      (call) => call.method == 'createInAppWebView',
    );
    final arguments = create.arguments as Map;
    expect(arguments.containsKey('flutterViewId'), isFalse);
    expect(arguments['initialSettings'], isA<Map>());
  });

  testWidgets('creation in a secondary view carries its id', (tester) async {
    final secondary = _SecondaryTestView(tester.view);
    await tester.pumpWidget(
      ViewCollection(
        views: [
          View(view: tester.view, child: const SizedBox()),
          View(
            view: secondary,
            child: const Directionality(
              textDirection: TextDirection.ltr,
              child: CustomPlatformView(creationParams: <String, dynamic>{}),
            ),
          ),
        ],
      ),
      wrapWithView: false,
    );
    await tester.pumpAndSettle();

    final create = pluginCalls.singleWhere(
      (call) => call.method == 'createInAppWebView',
    );
    expect((create.arguments as Map)['flutterViewId'], 7);
  });

  testWidgets('moving to another view reparents with that view scale', (
    tester,
  ) async {
    final secondary = _SecondaryTestView(tester.view);
    final webViewKey = GlobalKey();
    Widget host({required bool inSecondary}) {
      final webView = KeyedSubtree(
        key: webViewKey,
        child: const CustomPlatformView(creationParams: <String, dynamic>{}),
      );
      return ViewCollection(
        views: [
          View(
            view: tester.view,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: inSecondary ? const SizedBox() : webView,
            ),
          ),
          View(
            view: secondary,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: inSecondary ? webView : const SizedBox(),
            ),
          ),
        ],
      );
    }

    await tester.pumpWidget(host(inSecondary: false), wrapWithView: false);
    await tester.pumpAndSettle();
    viewCalls.clear();

    await tester.pumpWidget(host(inSecondary: true), wrapWithView: false);
    await tester.pumpAndSettle();

    expect(
      viewCalls
          .where((call) => call.method == 'setFlutterViewId')
          .single
          .arguments,
      7,
    );
    final setSize = viewCalls.lastWhere((call) => call.method == 'setSize');
    expect((setSize.arguments as List).last, 1.5);
    expect(
      pluginCalls.where((call) => call.method == 'createInAppWebView'),
      hasLength(1),
    );
  });

  for (final hwndMode in [false, true]) {
    testWidgets(
      'pending ${hwndMode ? 'HWND' : 'composition'} creation follows its closed source view',
      (tester) async {
        final creation = Completer<dynamic>();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(IN_APP_WEBVIEW_STATIC_CHANNEL, (
              call,
            ) async {
              pluginCalls.add(call);
              return call.method == 'createInAppWebView'
                  ? creation.future
                  : null;
            });
        final key = GlobalKey();
        final webView = Directionality(
          key: key,
          textDirection: TextDirection.ltr,
          child: const CustomPlatformView(creationParams: <String, dynamic>{}),
        );
        final source = _SecondaryTestView(tester.view);
        await tester.pumpWidget(
          ViewCollection(
            views: [
              View(view: tester.view, child: const SizedBox()),
              View(view: source, child: webView),
            ],
          ),
          wrapWithView: false,
        );
        await tester.pump();
        await tester.pumpWidget(
          View(view: tester.view, child: webView),
          wrapWithView: false,
        );
        expect(
          viewCalls.where((call) => call.method == 'setFlutterViewId'),
          isEmpty,
        );

        creation.complete(
          hwndMode ? {'id': _kTextureId, 'renderMode': 'hwnd'} : _kTextureId,
        );
        await tester.pumpAndSettle();

        expect(
          pluginCalls.where((call) => call.method == 'createInAppWebView'),
          hasLength(1),
        );
        expect(
          viewCalls
              .where((call) => call.method == 'setFlutterViewId')
              .single
              .arguments,
          tester.view.viewId,
        );
        expect(find.byType(Texture), hwndMode ? findsNothing : findsOneWidget);
        if (hwndMode) {
          expect(
            viewCalls
                .lastWhere((call) => call.method == 'setHostWindowHidden')
                .arguments,
            false,
          );
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('a scale change in the same view reports the new surface scale', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: CustomPlatformView(creationParams: <String, dynamic>{}),
      ),
    );
    await tester.pumpAndSettle();
    viewCalls.clear();

    tester.view.devicePixelRatio = 1.5;
    tester.view.physicalSize = const Size(1200, 900);
    await tester.pumpAndSettle();

    final size = viewCalls.lastWhere((call) => call.method == 'setSize');
    expect((size.arguments as List).last, 1.5);
    final position = viewCalls.lastWhere(
      (call) => call.method == 'setPosition',
    );
    expect((position.arguments as List).last, 1.5);
    expect(
      viewCalls.where((call) => call.method == 'setFlutterViewId'),
      isEmpty,
    );
  });
}
