import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
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
// A 1x1 PNG.
const String _kPreviewPng =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

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
    late Future<Object?> Function() previewResult;

    List<Object?> hiddenCalls() => viewCalls
        .where((call) => call.method == 'setHostWindowHidden')
        .map((call) => call.arguments)
        .toList();

    List<List<int>> clipCalls() => viewCalls
        .where((call) => call.method == 'setHostWindowClip')
        .map((call) => List<int>.of(call.arguments as Int32List))
        .toList();

    List<int> physical(WidgetTester tester, Rect rect) {
      final ratio = tester.view.devicePixelRatio;
      return [
        (rect.left * ratio).floor(),
        (rect.top * ratio).floor(),
        (rect.right * ratio).ceil(),
        (rect.bottom * ratio).ceil(),
      ];
    }

    setUp(() {
      viewCalls = <MethodCall>[];
      previewResult = () async => null;
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
        if (call.method == 'captureHostWindowPreview') return previewResult();
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

    testWidgets('an overlay entry covering part of the view cuts it out', (
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
          width: 40,
          height: 40,
          child: ColoredBox(color: Color(0xFF000000)),
        ),
      );

      overlay.insert(entry);
      await tester.pump();
      await tester.pump();
      expect(hiddenCalls(), [false]);
      // The view starts at (30, 20).
      expect(clipCalls(), [
        physical(tester, const Rect.fromLTWH(10, 10, 40, 40)),
      ]);

      entry.remove();
      entry.dispose();
      await tester.pump();
      await tester.pump();
      expect(hiddenCalls(), [false]);
      expect(clipCalls().last, isEmpty);
    });

    for (final scenario in <(String, Widget, bool)>[
      (
        'a one-pixel corner overlap',
        const Positioned(
          left: 29,
          top: 19,
          width: 2,
          height: 2,
          child: ColoredBox(color: Colors.black),
        ),
        true,
      ),
      (
        'a transformed overlay',
        Positioned(
          left: 0,
          top: 0,
          width: 10,
          height: 10,
          child: Transform.translate(
            offset: const Offset(40, 30),
            child: const ColoredBox(color: Colors.black),
          ),
        ),
        true,
      ),
      (
        'an overlay clipped outside the view',
        Positioned(
          left: 0,
          top: 0,
          width: 10,
          height: 10,
          child: ClipRect(
            child: Transform.translate(
              offset: const Offset(40, 30),
              child: const ColoredBox(color: Colors.black),
            ),
          ),
        ),
        false,
      ),
      (
        'an ignored tooltip',
        const Positioned(
          left: 40,
          top: 30,
          width: 40,
          height: 40,
          child: IgnorePointer(child: ColoredBox(color: Colors.black)),
        ),
        false,
      ),
      (
        'an absorbing overlay',
        const Positioned(
          left: 40,
          top: 30,
          width: 40,
          height: 40,
          child: AbsorbPointer(child: SizedBox.expand()),
        ),
        true,
      ),
      (
        'a translucent pointer overlay',
        const Positioned(
          left: 40,
          top: 30,
          width: 40,
          height: 40,
          child: Listener(behavior: HitTestBehavior.translucent),
        ),
        true,
      ),
      (
        'a non-absorbing empty overlay',
        const Positioned(
          left: 40,
          top: 30,
          width: 40,
          height: 40,
          child: AbsorbPointer(absorbing: false, child: SizedBox.expand()),
        ),
        false,
      ),
      (
        'an empty fullscreen overlay',
        const Positioned.fill(child: SizedBox.expand()),
        false,
      ),
      (
        'an offstage overlay',
        const Positioned.fill(
          child: Offstage(child: ColoredBox(color: Colors.black)),
        ),
        false,
      ),
    ]) {
      testWidgets('${scenario.$1} respects the HWND cut', (tester) async {
        await pumpView(tester);
        final overlay = Overlay.of(
          tester.element(find.byType(CustomPlatformView)),
        );
        final entry = OverlayEntry(builder: (_) => scenario.$2);
        overlay.insert(entry);
        await tester.pump();
        await tester.pump();
        expect(hiddenCalls(), [false]);
        expect(clipCalls(), hasLength(scenario.$3 ? 1 : 0));

        entry.remove();
        entry.dispose();
        await tester.pump();
        await tester.pump();
        expect(hiddenCalls(), [false]);
        expect(clipCalls(), scenario.$3 ? [isNotEmpty, isEmpty] : isEmpty);
      });
    }

    testWidgets(
      'moving a GlobalKey keeps the HWND visible and repositions it',
      (tester) async {
        final key = GlobalKey();
        Widget host(bool moved) => MaterialApp(
          home: Stack(
            children: [
              if (!moved)
                Positioned.fill(
                  child: KeyedSubtree(
                    key: key,
                    child: const CustomPlatformView(),
                  ),
                ),
              if (moved)
                Positioned(
                  left: 30,
                  top: 20,
                  right: 0,
                  bottom: 0,
                  child: KeyedSubtree(
                    key: key,
                    child: const CustomPlatformView(),
                  ),
                ),
            ],
          ),
        );
        await tester.pumpWidget(host(false));
        await tester.pump();
        await tester.pump();
        await tester.pumpWidget(host(true));
        await tester.pump();
        expect(hiddenCalls(), [false]);
        expect(
          viewCalls.lastWhere((call) => call.method == 'setPosition').arguments,
          [30.0, 20.0, tester.view.devicePixelRatio],
        );
      },
    );

    testWidgets('coverage skips a thousand render objects behind the view', (
      tester,
    ) async {
      var visited = 0;
      var hitTests = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Stack(
            children: [
              Positioned.fill(
                child: Wrap(
                  children: List.generate(
                    1000,
                    (_) => _TraversalProbe(
                      onVisit: () {
                        // Exclude Flutter's own layout and semantics walks.
                        if (SchedulerBinding.instance.schedulerPhase ==
                            SchedulerPhase.postFrameCallbacks) {
                          visited++;
                        }
                      },
                      child: const SizedBox(width: 1, height: 1),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: _TraversalProbe(
                  onVisit: () {},
                  onHitTest: () => hitTests++,
                  child: const CustomPlatformView(),
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      visited = 0;
      hitTests = 0;
      final callCount = viewCalls.length;
      tester.binding.scheduleFrame();
      await tester.pump();
      expect(visited, 0);
      expect(hitTests, 1);
      expect(viewCalls.length, callCount);

      final overlay = Overlay.of(
        tester.element(find.byType(CustomPlatformView)),
      );
      final entry = OverlayEntry(
        builder: (_) => const Positioned(
          left: 40,
          top: 30,
          width: 40,
          height: 40,
          child: ColoredBox(color: Colors.black),
        ),
      );
      overlay.insert(entry);
      await tester.pump();
      visited = 0;
      tester.binding.scheduleFrame();
      await tester.pump();
      expect(visited, 0);
      expect(clipCalls(), hasLength(1));
      entry.remove();
      entry.dispose();
      await tester.pump();
      expect(hiddenCalls(), [false]);
      expect(clipCalls().last, isEmpty);
    });

    testWidgets('a dialog shows a capture of the page while the window hides', (
      tester,
    ) async {
      previewResult = () async => _kPreviewPng;
      await pumpView(tester);
      final context = tester.element(find.byType(CustomPlatformView));

      showDialog<void>(
        context: context,
        builder: (_) => const AlertDialog(content: Text('over')),
      );
      await tester.pump();
      // Decoding the capture needs real async time.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();

      final methods = viewCalls.map((call) => call.method).toList();
      expect(
        methods.indexOf('captureHostWindowPreview'),
        lessThan(methods.lastIndexOf('setHostWindowHidden')),
      );
      expect(hiddenCalls(), [false, true]);
      expect(
        find.descendant(
          of: find.byType(CustomPlatformView),
          matching: find.byType(RawImage),
        ),
        findsOneWidget,
      );

      Navigator.of(context).pop();
      await tester.pumpAndSettle();
      expect(hiddenCalls(), [false, true, false]);
      expect(
        find.descendant(
          of: find.byType(CustomPlatformView),
          matching: find.byType(RawImage),
        ),
        findsNothing,
      );
    });

    testWidgets('a capture that never answers delays hiding only briefly', (
      tester,
    ) async {
      previewResult = () => Completer<Object?>().future;
      await pumpView(tester);
      final context = tester.element(find.byType(CustomPlatformView));

      showDialog<void>(
        context: context,
        builder: (_) => const AlertDialog(content: Text('over')),
      );
      await tester.pump();
      expect(hiddenCalls(), [false]);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      expect(hiddenCalls(), [false, true]);
      await tester.pumpAndSettle();
      expect(
        viewCalls.where((call) => call.method == 'captureHostWindowPreview'),
        hasLength(1),
      );
    });

    OverlayEntry cornerEntry() => OverlayEntry(
      builder: (_) => const Positioned(
        left: 40,
        top: 30,
        width: 40,
        height: 40,
        child: ColoredBox(color: Colors.black),
      ),
    );

    Finder snapshotImage() => find.descendant(
      of: find.byType(CustomPlatformView),
      matching: find.byType(RawImage),
    );

    Future<void> finishPreview(WidgetTester tester) async {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();
    }

    for (final size in [40.0, 200.0]) {
      testWidgets(
        'an unrelated transparent sibling of size $size does not enlarge the cut',
        (tester) async {
          await pumpView(tester);
          final overlay = Overlay.of(
            tester.element(find.byType(CustomPlatformView)),
          );
          // Both centers are over the button. At size 40 their bounds also
          // match, so caching a yes/no coverage result for the rect is wrong.
          final empty = OverlayEntry(
            builder: (_) => Positioned(
              left: 140 - size / 2,
              top: 130 - size / 2,
              width: size,
              height: size,
              child: const SizedBox.expand(),
            ),
          );
          final button = OverlayEntry(
            builder: (_) => const Positioned(
              left: 120,
              top: 110,
              width: 40,
              height: 40,
              child: ColoredBox(color: Colors.black),
            ),
          );
          overlay.insert(empty);
          overlay.insert(button);
          await tester.pump();
          await tester.pump();

          expect(hiddenCalls(), [false]);
          expect(clipCalls(), [
            physical(tester, const Rect.fromLTWH(90, 90, 40, 40)),
          ]);
          button.remove();
          button.dispose();
          empty.remove();
          empty.dispose();
          await tester.pump();
          expect(clipCalls().last, isEmpty);
        },
      );
    }

    testWidgets(
      'a persistent corner cover refreshes the preview for each dialog',
      (tester) async {
        previewResult = () async => _kPreviewPng;
        await pumpView(tester);
        final context = tester.element(find.byType(CustomPlatformView));
        final corner = cornerEntry();
        Overlay.of(context).insert(corner);
        await tester.pump();
        await finishPreview(tester);
        var previous = tester.widget<RawImage>(snapshotImage()).image!;
        expect(previous.debugDisposed, isFalse);

        for (var dialog = 0; dialog < 2; dialog++) {
          showDialog<void>(
            context: context,
            builder: (_) => const AlertDialog(content: Text('over')),
          );
          await tester.pump();
          await finishPreview(tester);
          expect(
            viewCalls.where(
              (call) => call.method == 'captureHostWindowPreview',
            ),
            hasLength(dialog + 2),
          );
          expect(previous.debugDisposed, isTrue);
          final current = tester.widget<RawImage>(snapshotImage()).image!;
          expect(current, isNot(same(previous)));
          expect(current.debugDisposed, isFalse);
          previous = current;
          tester.binding.scheduleFrame();
          await tester.pump();
          expect(
            viewCalls.where(
              (call) => call.method == 'captureHostWindowPreview',
            ),
            hasLength(dialog + 2),
          );
          Navigator.of(context).pop();
          await tester.pumpAndSettle();
        }
        expect(hiddenCalls(), [false, true, false, true, false]);
        corner.remove();
        corner.dispose();
        await tester.pumpAndSettle();
        expect(previous.debugDisposed, isTrue);
      },
    );

    testWidgets(
      'a modal refresh ignores a late capture from the corner cover',
      (tester) async {
        final captures = <Completer<Object?>>[];
        previewResult = () {
          final capture = Completer<Object?>();
          captures.add(capture);
          return capture.future;
        };
        await pumpView(tester);
        final context = tester.element(find.byType(CustomPlatformView));
        final corner = cornerEntry();
        Overlay.of(context).insert(corner);
        await tester.pump();
        showDialog<void>(
          context: context,
          builder: (_) => const AlertDialog(content: Text('over')),
        );
        await tester.pump();
        expect(captures, hasLength(2));
        captures.last.complete(_kPreviewPng);
        await finishPreview(tester);
        final current = tester.widget<RawImage>(snapshotImage()).image!;
        captures.first.complete(_kPreviewPng);
        await finishPreview(tester);
        expect(tester.widget<RawImage>(snapshotImage()).image, same(current));
        expect(current.debugDisposed, isFalse);
        expect(hiddenCalls(), [false, true]);
        Navigator.of(context).pop();
        corner.remove();
        corner.dispose();
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'one-use previews bypass the shared cache and release all handles',
      (tester) async {
        previewResult = () async => _kPreviewPng;
        await pumpView(tester);
        final overlay = Overlay.of(
          tester.element(find.byType(CustomPlatformView)),
        );
        final cache = PaintingBinding.instance.imageCache;
        final cachedBytes = cache.currentSizeBytes;
        final cachedImages = cache.currentSize;

        // Repeated captures must not accumulate decoded entries or image handles.
        for (var cover = 0; cover < 3; cover++) {
          final entry = cornerEntry();
          overlay.insert(entry);
          await tester.pump();
          await finishPreview(tester);
          final image = tester.widget<RawImage>(snapshotImage()).image!;
          final rendered = tester
              .renderObject<RenderImage>(snapshotImage())
              .image!;
          expect(image.debugDisposed, isFalse);
          expect(rendered.debugDisposed, isFalse);
          expect(cache.currentSizeBytes, cachedBytes);
          expect(cache.currentSize, cachedImages);
          entry.remove();
          entry.dispose();
          await tester.pumpAndSettle();
          expect(snapshotImage(), findsNothing);
          expect(image.debugDisposed, isTrue);
          expect(rendered.debugDisposed, isTrue);
          expect(cache.currentSizeBytes, cachedBytes);
          expect(cache.currentSize, cachedImages);
        }
      },
    );

    testWidgets('disposing a covered view releases the preview image handles', (
      tester,
    ) async {
      previewResult = () async => _kPreviewPng;
      await pumpView(tester);
      final entry = cornerEntry();
      Overlay.of(tester.element(find.byType(CustomPlatformView))).insert(entry);
      await tester.pump();
      await finishPreview(tester);
      final image = tester.widget<RawImage>(snapshotImage()).image!;
      final rendered = tester.renderObject<RenderImage>(snapshotImage()).image!;
      entry.remove();
      entry.dispose();
      await tester.pumpWidget(const SizedBox());
      expect(image.debugDisposed, isTrue);
      expect(rendered.debugDisposed, isTrue);
    });

    testWidgets('a capture arriving after its cover ends is not decoded', (
      tester,
    ) async {
      final capture = Completer<Object?>();
      previewResult = () => capture.future;
      await pumpView(tester);
      final entry = cornerEntry();
      Overlay.of(tester.element(find.byType(CustomPlatformView))).insert(entry);
      await tester.pump();
      entry.remove();
      entry.dispose();
      await tester.pump();
      final created = <ui.Image>[];
      final previousOnCreate = ui.Image.onCreate;
      ui.Image.onCreate = (image) {
        previousOnCreate?.call(image);
        created.add(image);
      };
      addTearDown(() => ui.Image.onCreate = previousOnCreate);
      capture.complete(_kPreviewPng);
      await finishPreview(tester);
      expect(created, isEmpty);
      expect(snapshotImage(), findsNothing);
      expect(clipCalls(), isEmpty);
    });

    testWidgets('a partial cover is cut only after the capture is shown', (
      tester,
    ) async {
      final capture = Completer<Object?>();
      previewResult = () => capture.future;
      await pumpView(tester);
      final overlay = Overlay.of(
        tester.element(find.byType(CustomPlatformView)),
      );
      final entry = cornerEntry();
      overlay.insert(entry);
      await tester.pump();
      await tester.pump();
      expect(clipCalls(), isEmpty);

      capture.complete(_kPreviewPng);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();
      await tester.pump();
      expect(clipCalls(), hasLength(1));
      expect(hiddenCalls(), [false]);
      expect(snapshotImage(), findsOneWidget);

      entry.remove();
      entry.dispose();
      await tester.pump();
      await tester.pump();
      expect(clipCalls().last, isEmpty);
      expect(snapshotImage(), findsNothing);
    });

    testWidgets('a pending capture does not delay hiding for a tab switch', (
      tester,
    ) async {
      previewResult = () => Completer<Object?>().future;
      final tickers = ValueNotifier(true);
      addTearDown(tickers.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValueListenableBuilder<bool>(
              valueListenable: tickers,
              builder: (_, enabled, child) =>
                  TickerMode(enabled: enabled, child: child!),
              child: const CustomPlatformView(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      final overlay = Overlay.of(
        tester.element(find.byType(CustomPlatformView)),
      );
      final entry = cornerEntry();
      overlay.insert(entry);
      await tester.pump();
      await tester.pump();
      expect(hiddenCalls(), [false]);

      tickers.value = false;
      await tester.pump();
      await tester.pump();
      expect(hiddenCalls(), [false, true]);

      entry.remove();
      entry.dispose();
      await tester.pump(const Duration(milliseconds: 400));
    });

    testWidgets('a stale capture does not act for a newer cover', (
      tester,
    ) async {
      final captures = <Completer<Object?>>[];
      previewResult = () {
        final capture = Completer<Object?>();
        captures.add(capture);
        return capture.future;
      };
      await pumpView(tester);
      final overlay = Overlay.of(
        tester.element(find.byType(CustomPlatformView)),
      );
      var entry = cornerEntry();
      overlay.insert(entry);
      await tester.pump();
      await tester.pump();
      entry.remove();
      entry.dispose();
      await tester.pump();
      await tester.pump();
      entry = cornerEntry();
      overlay.insert(entry);
      await tester.pump();
      await tester.pump();
      expect(captures, hasLength(2));

      captures.first.complete(null);
      await tester.pump();
      await tester.pump();
      expect(clipCalls(), isEmpty);

      captures.last.complete(null);
      await tester.pump();
      await tester.pump();
      expect(clipCalls(), hasLength(1));

      entry.remove();
      entry.dispose();
      await tester.pump();
    });

    testWidgets('a capture arriving after the limit is still shown', (
      tester,
    ) async {
      final capture = Completer<Object?>();
      previewResult = () => capture.future;
      await pumpView(tester);
      final context = tester.element(find.byType(CustomPlatformView));

      showDialog<void>(
        context: context,
        builder: (_) => const AlertDialog(content: Text('over')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      expect(hiddenCalls(), [false, true]);
      expect(snapshotImage(), findsNothing);

      capture.complete(_kPreviewPng);
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();
      await tester.pump();
      expect(snapshotImage(), findsOneWidget);

      Navigator.of(context).pop();
      await tester.pumpAndSettle();
      expect(hiddenCalls(), [false, true, false]);
      expect(snapshotImage(), findsNothing);
    });

    testWidgets('detaching a kept-alive HWND hides it before disposal', (
      tester,
    ) async {
      await pumpView(tester);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();

      expect(hiddenCalls(), [false, true]);
      await pumpView(tester);
      expect(hiddenCalls(), [false, true, false]);
    });

    testWidgets('disposing while creation is pending hides the HWND', (
      tester,
    ) async {
      final pending = Completer<Object?>();
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        IN_APP_WEBVIEW_STATIC_CHANNEL,
        (call) async =>
            call.method == 'createInAppWebView' ? pending.future : null,
      );
      await tester.pumpWidget(const MaterialApp(home: CustomPlatformView()));
      await tester.pumpWidget(const SizedBox());
      pending.complete(creationResult);
      await tester.pump();
      await tester.pump();

      expect(hiddenCalls(), [true]);
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

class _TraversalProbe extends SingleChildRenderObjectWidget {
  const _TraversalProbe({required this.onVisit, this.onHitTest, super.child});

  final VoidCallback onVisit;
  final VoidCallback? onHitTest;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _TraversalProbeBox(onVisit, onHitTest);
}

class _TraversalProbeBox extends RenderProxyBox {
  _TraversalProbeBox(this.onVisit, this.onHitTest);

  final VoidCallback onVisit;
  final VoidCallback? onHitTest;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    onHitTest?.call();
    return super.hitTest(result, position: position);
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    onVisit();
    super.visitChildren(visitor);
  }
}
