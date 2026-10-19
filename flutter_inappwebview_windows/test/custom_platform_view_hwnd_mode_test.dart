import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_inappwebview_windows/src/in_app_webview/_static_channel.dart';
import 'package:flutter_inappwebview_windows/src/in_app_webview/custom_platform_view.dart';
import 'package:flutter_inappwebview_windows/src/in_app_webview/webview_render_mode.dart';

const int _kViewId = 7;
const MethodChannel _viewChannel = MethodChannel(
  'com.pichillilorenzo/custom_platform_view_$_kViewId',
);
const EventChannel _viewEventChannel = EventChannel(
  'com.pichillilorenzo/custom_platform_view_${_kViewId}_events',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WindowsWebViewCreationResult.fromNative', () {
    test('a bare id from older native code means composition', () {
      final result = WindowsWebViewCreationResult.fromNative(3);
      expect(result.id, 3);
      expect(result.renderMode, WindowsWebViewRenderMode.composition);
      expect(result.fallbackStage, isNull);
    });

    test('a composition map has no fallback', () {
      final result = WindowsWebViewCreationResult.fromNative({
        'id': 4,
        'renderMode': 'composition',
      });
      expect(result.renderMode, WindowsWebViewRenderMode.composition);
      expect(result.fallbackStage, isNull);
      expect(result.fallbackHresult, isNull);
    });

    test('an HWND map carries the failed stage and an unsigned HRESULT', () {
      final result = WindowsWebViewCreationResult.fromNative({
        'id': 5,
        'renderMode': 'hwnd',
        'fallbackStage': 'CreateCoreWebView2CompositionController callback',
        // 0x8007139F as the signed value native code sends.
        'fallbackHresult': -2147019873,
      });
      expect(result.renderMode, WindowsWebViewRenderMode.hwnd);
      expect(
        result.fallbackStage,
        'CreateCoreWebView2CompositionController callback',
      );
      expect(result.fallbackHresult, 0x8007139F);
    });

    test('a missing result is an error', () {
      expect(
        () => WindowsWebViewCreationResult.fromNative(null),
        throwsArgumentError,
      );
    });
  });

  test('the fallback formats its HRESULT', () {
    const fallback = WindowsWebViewHwndFallback(
      stage: 'CreateCaptureSession',
      hresult: 0x80070005,
    );
    expect(fallback.hresultHex, '0x80070005');
    expect(const WindowsWebViewHwndFallback(stage: 'forced').hresultHex, null);
  });

  group('CustomPlatformView', () {
    late List<MethodCall> viewCalls;
    late Object? creationResult;

    List<Object?> hiddenCalls() => viewCalls
        .where((call) => call.method == 'setHostWindowHidden')
        .map((call) => call.arguments)
        .toList();

    setUp(() {
      viewCalls = <MethodCall>[];
      creationResult = {
        'id': _kViewId,
        'renderMode': 'hwnd',
        'fallbackStage': 'CreateCaptureSession',
        'fallbackHresult': 0x887A0004 - 0x100000000,
      };
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(IN_APP_WEBVIEW_STATIC_CHANNEL, (
        call,
      ) async {
        if (call.method == 'createInAppWebView') return creationResult;
        return null;
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

    Future<void> pumpView(WidgetTester tester, {Key? key}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.only(left: 30, top: 20),
              child: CustomPlatformView(creationKey: key),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
    }

    testWidgets('HWND mode reports the fallback once, with its key', (
      tester,
    ) async {
      final fallbacks = <WindowsWebViewHwndFallback>[];
      final subscription = WindowsWebViewHwndFallbacks.stream.listen(
        fallbacks.add,
      );
      addTearDown(subscription.cancel);
      const key = ValueKey('plugin-tab');

      await pumpView(tester, key: key);

      expect(fallbacks, hasLength(1));
      expect(fallbacks.single.stage, 'CreateCaptureSession');
      expect(fallbacks.single.hresultHex, '0x887A0004');
      expect(fallbacks.single.creationKey, key);
    });

    testWidgets('HWND mode draws no texture and forwards no input', (
      tester,
    ) async {
      await pumpView(tester);

      expect(find.byType(Texture), findsNothing);
      await tester.tapAt(const Offset(400, 300));
      await tester.pump();
      expect(
        viewCalls.map((call) => call.method),
        isNot(contains(anyOf('setPointerButton', 'setCursorPos'))),
      );
    });

    testWidgets('HWND mode places the window, then shows it', (tester) async {
      await pumpView(tester);

      final methods = viewCalls.map((call) => call.method).toList();
      expect(methods, containsAllInOrder(['setSize', 'setPosition']));
      final position = viewCalls.lastWhere(
        (call) => call.method == 'setPosition',
      );
      expect(position.arguments, [30.0, 20.0, tester.view.devicePixelRatio]);
      expect(
        methods.indexOf('setHostWindowHidden'),
        greaterThan(methods.lastIndexOf('setPosition')),
      );
      expect(hiddenCalls(), [false]);
    });

    testWidgets('a dialog over the view hides the window until it closes', (
      tester,
    ) async {
      await pumpView(tester);
      final context = tester.element(find.byType(CustomPlatformView));

      showDialog<void>(
        context: context,
        builder: (_) => const AlertDialog(content: Text('over')),
      );
      await tester.pumpAndSettle();
      expect(hiddenCalls(), [false, true]);

      Navigator.of(context).pop();
      await tester.pumpAndSettle();
      expect(hiddenCalls(), [false, true, false]);
    });

    testWidgets('an overlay entry covering part of the view hides it', (
      tester,
    ) async {
      await pumpView(tester);
      final overlay = Overlay.of(
        tester.element(find.byType(CustomPlatformView)),
      );
      final entry = OverlayEntry(
        builder: (_) => const Positioned(
          left: 40,
          top: 30,
          width: 200,
          height: 150,
          child: ColoredBox(color: Color(0xFF000000)),
        ),
      );

      overlay.insert(entry);
      await tester.pump();
      await tester.pump();
      expect(hiddenCalls(), [false, true]);

      entry.remove();
      entry.dispose();
      await tester.pump();
      await tester.pump();
      expect(hiddenCalls(), [false, true, false]);
    });

    testWidgets('a disabled TickerMode keeps the window hidden', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TickerMode(enabled: false, child: CustomPlatformView()),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(hiddenCalls(), [true]);
    });

    testWidgets('composition mode keeps the texture and sends no visibility', (
      tester,
    ) async {
      creationResult = {'id': _kViewId, 'renderMode': 'composition'};

      await pumpView(tester);

      expect(find.byType(Texture), findsOneWidget);
      expect(hiddenCalls(), isEmpty);
    });
  });
}
