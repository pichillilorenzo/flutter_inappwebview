import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_inappwebview_windows/src/in_app_webview/_static_channel.dart';
import 'package:flutter_inappwebview_windows/src/in_app_webview/custom_platform_view.dart';

const int _kTextureId = 1;
const MethodChannel _viewChannel = MethodChannel(
  'com.pichillilorenzo/custom_platform_view_$_kTextureId',
);
const EventChannel _viewEventChannel = EventChannel(
  'com.pichillilorenzo/custom_platform_view_${_kTextureId}_events',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<MethodCall> viewChannelCalls;

  /// Returns the `[dx, dy]` arguments of every `setScrollDelta` call sent to
  /// the native side so far.
  List<List<double>> scrollDeltaCalls() => viewChannelCalls
      .where((call) => call.method == 'setScrollDelta')
      .map(
        (call) =>
            (call.arguments as List).map((e) => (e as num).toDouble()).toList(),
      )
      .toList();

  setUp(() {
    viewChannelCalls = <MethodCall>[];
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(IN_APP_WEBVIEW_STATIC_CHANNEL, (
      call,
    ) async {
      if (call.method == 'createInAppWebView') {
        return _kTextureId;
      }
      return null;
    });
    messenger.setMockMethodCallHandler(_viewChannel, (call) async {
      viewChannelCalls.add(call);
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

  Future<Offset> pumpView(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CustomPlatformView())),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Texture), findsOneWidget);
    return tester.getCenter(find.byType(Texture));
  }

  group('trackpad pan (PointerPanZoomUpdate)', () {
    testWidgets('sub-pixel deltas accumulate instead of being lost', (
      tester,
    ) async {
      final center = await pumpView(tester);

      final pointer = TestPointer(1, PointerDeviceKind.trackpad);
      await tester.sendEventToBinding(pointer.panZoomStart(center));
      // Four 0.4px updates cross one wheel unit after calibration.
      // Before accumulation, native short truncation lost each update.
      for (var i = 1; i <= 4; i++) {
        await tester.sendEventToBinding(
          pointer.panZoomUpdate(center, pan: Offset(0, -0.4 * i)),
        );
      }
      await tester.sendEventToBinding(pointer.panZoomEnd());
      await tester.pump();

      expect(scrollDeltaCalls(), [
        [0.0, -1.0],
      ]);
    });

    testWidgets('a long slow pan scrolls the full distance', (tester) async {
      final center = await pumpView(tester);

      final pointer = TestPointer(1, PointerDeviceKind.trackpad);
      await tester.sendEventToBinding(pointer.panZoomStart(center));
      // 60 updates of 0.25px = 15px finger travel.
      // With 120/100 calibration this becomes about 18 wheel units.
      for (var i = 1; i <= 60; i++) {
        await tester.sendEventToBinding(
          pointer.panZoomUpdate(center, pan: Offset(0, -0.25 * i)),
        );
      }
      await tester.sendEventToBinding(pointer.panZoomEnd());
      await tester.pump();

      final totalDy = scrollDeltaCalls().fold<double>(
        0,
        (sum, args) => sum + args[1],
      );
      // Up to one unit may stay accumulated as a fractional remainder.
      expect(totalDy, lessThanOrEqualTo(-17.0));
      expect(totalDy, greaterThanOrEqualTo(-18.0));
    });

    testWidgets('integral deltas are flushed each frame, unchanged', (
      tester,
    ) async {
      final center = await pumpView(tester);

      final pointer = TestPointer(1, PointerDeviceKind.trackpad);
      await tester.sendEventToBinding(pointer.panZoomStart(center));
      await tester.sendEventToBinding(
        pointer.panZoomUpdate(center, pan: const Offset(0, -5)),
      );
      await tester.pump();
      await tester.sendEventToBinding(
        pointer.panZoomUpdate(center, pan: const Offset(0, -15)),
      );
      await tester.pump();
      // Scroll back up (sign must be preserved in both directions).
      await tester.sendEventToBinding(
        pointer.panZoomUpdate(center, pan: const Offset(0, -10)),
      );
      await tester.sendEventToBinding(pointer.panZoomEnd());
      await tester.pump();

      // Pan pixels × 120/100: -5px → -6 units, -10px → -12, +5px → +6.
      expect(scrollDeltaCalls(), [
        [0.0, -6.0],
        [0.0, -12.0],
        [0.0, 6.0],
      ]);
    });

    testWidgets('multiple updates within one frame coalesce to one message', (
      tester,
    ) async {
      final center = await pumpView(tester);

      final pointer = TestPointer(1, PointerDeviceKind.trackpad);
      await tester.sendEventToBinding(pointer.panZoomStart(center));
      // A fast pan can deliver several pointer events between two frames;
      // they must reach the native side as a single batched wheel event.
      await tester.sendEventToBinding(
        pointer.panZoomUpdate(center, pan: const Offset(0, -4)),
      );
      await tester.sendEventToBinding(
        pointer.panZoomUpdate(center, pan: const Offset(0, -9)),
      );
      await tester.sendEventToBinding(
        pointer.panZoomUpdate(center, pan: const Offset(0, -10)),
      );
      await tester.sendEventToBinding(pointer.panZoomEnd());
      await tester.pump();

      // 10px of finger travel × 120/100 = 12 wheel units, one message.
      expect(scrollDeltaCalls(), [
        [0.0, -12.0],
      ]);
    });

    testWidgets('horizontal sub-pixel deltas accumulate too', (tester) async {
      final center = await pumpView(tester);

      final pointer = TestPointer(1, PointerDeviceKind.trackpad);
      await tester.sendEventToBinding(pointer.panZoomStart(center));
      for (var i = 1; i <= 3; i++) {
        await tester.sendEventToBinding(
          pointer.panZoomUpdate(center, pan: Offset(-0.5 * i, 0)),
        );
      }
      await tester.sendEventToBinding(pointer.panZoomEnd());
      await tester.pump();

      expect(scrollDeltaCalls(), [
        [-1.0, 0.0],
      ]);
    });

    testWidgets('fractional remainder is reset when a new gesture starts', (
      tester,
    ) async {
      final center = await pumpView(tester);

      final pointer = TestPointer(1, PointerDeviceKind.trackpad);
      await tester.sendEventToBinding(pointer.panZoomStart(center));
      await tester.sendEventToBinding(
        pointer.panZoomUpdate(center, pan: const Offset(0, -0.7)),
      );
      await tester.sendEventToBinding(pointer.panZoomEnd());

      await tester.sendEventToBinding(pointer.panZoomStart(center));
      await tester.sendEventToBinding(
        pointer.panZoomUpdate(center, pan: const Offset(0, -0.7)),
      );
      await tester.sendEventToBinding(pointer.panZoomEnd());
      await tester.pump();

      // 0.7 + 0.7 crosses 1.0, but the remainder must not leak across
      // separate gestures.
      expect(scrollDeltaCalls(), isEmpty);
    });
  });

  group('trackpad inertia (synthetic fling)', () {
    /// Sends a fast downward pan (high velocity) and lifts the fingers.
    Future<void> fastPan(WidgetTester tester, Offset center) async {
      final pointer = TestPointer(1, PointerDeviceKind.trackpad);
      await tester.sendEventToBinding(
        pointer.panZoomStart(center, timeStamp: Duration.zero),
      );
      // 10px per 8ms => 1250 px/s, well above kMinFlingVelocity.
      for (var i = 1; i <= 8; i++) {
        await tester.sendEventToBinding(
          pointer.panZoomUpdate(
            center,
            pan: Offset(0, -10.0 * i),
            timeStamp: Duration(milliseconds: 8 * i),
          ),
        );
      }
      await tester.sendEventToBinding(
        pointer.panZoomEnd(timeStamp: const Duration(milliseconds: 72)),
      );
      await tester.pump();
    }

    testWidgets('a fast pan keeps scrolling after the fingers lift', (
      tester,
    ) async {
      final center = await pumpView(tester);

      await fastPan(tester, center);
      final callsAtRelease = scrollDeltaCalls().length;

      // Let the fling ticker run for a while.
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      final calls = scrollDeltaCalls();
      expect(
        calls.length,
        greaterThan(callsAtRelease),
        reason: 'inertia must keep emitting scroll deltas after release',
      );
      // All inertia deltas continue in the gesture direction (down).
      for (final args in calls.skip(callsAtRelease)) {
        expect(args[1], lessThan(0));
      }

      // And the fling must decay and stop on its own.
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      final settledCount = scrollDeltaCalls().length;
      await tester.pump(const Duration(milliseconds: 200));
      expect(scrollDeltaCalls().length, settledCount);
    });

    testWidgets('a slow release does not trigger inertia', (tester) async {
      final center = await pumpView(tester);

      final pointer = TestPointer(1, PointerDeviceKind.trackpad);
      await tester.sendEventToBinding(
        pointer.panZoomStart(center, timeStamp: Duration.zero),
      );
      // 1px per 50ms => 20 px/s, below kMinFlingVelocity.
      for (var i = 1; i <= 6; i++) {
        await tester.sendEventToBinding(
          pointer.panZoomUpdate(
            center,
            pan: Offset(0, -1.0 * i),
            timeStamp: Duration(milliseconds: 50 * i),
          ),
        );
      }
      await tester.sendEventToBinding(
        pointer.panZoomEnd(timeStamp: const Duration(milliseconds: 300)),
      );
      await tester.pump();
      final callsAtRelease = scrollDeltaCalls().length;

      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(scrollDeltaCalls().length, callsAtRelease);
    });

    testWidgets('a new gesture stops the running fling', (tester) async {
      final center = await pumpView(tester);

      await fastPan(tester, center);
      await tester.pump(const Duration(milliseconds: 16));

      // Touch down again: putting the fingers back must halt the glide.
      final pointer = TestPointer(1, PointerDeviceKind.trackpad);
      await tester.sendEventToBinding(
        pointer.panZoomStart(
          center,
          timeStamp: const Duration(milliseconds: 200),
        ),
      );
      await tester.pump();
      final callsAfterStop = scrollDeltaCalls().length;

      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(scrollDeltaCalls().length, callsAfterStop);
      await tester.sendEventToBinding(
        pointer.panZoomEnd(timeStamp: const Duration(milliseconds: 600)),
      );
      await tester.pump();
    });

    testWidgets('a mouse wheel event stops the running fling', (tester) async {
      final center = await pumpView(tester);

      await fastPan(tester, center);
      await tester.pump(const Duration(milliseconds: 16));

      final mouse = TestPointer(2, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(mouse.hover(center));
      await tester.sendEventToBinding(mouse.scroll(const Offset(0, 120)));
      await tester.pump();
      final callsAfterWheel = scrollDeltaCalls().length;

      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(scrollDeltaCalls().length, callsAfterWheel);
    });
  });

  group('mouse wheel (PointerScrollEvent)', () {
    testWidgets('wheel deltas are still forwarded negated', (tester) async {
      final center = await pumpView(tester);

      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(pointer.hover(center));
      await tester.sendEventToBinding(pointer.scroll(const Offset(0, 120)));
      await tester.pump();
      await tester.sendEventToBinding(pointer.scroll(const Offset(0, -120)));
      await tester.pump();

      expect(scrollDeltaCalls(), [
        [0.0, -120.0],
        [0.0, 120.0],
      ]);
    });

    testWidgets('fractional wheel deltas (high-resolution wheels) accumulate', (
      tester,
    ) async {
      final center = await pumpView(tester);

      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(pointer.hover(center));
      for (var i = 0; i < 3; i++) {
        await tester.sendEventToBinding(pointer.scroll(const Offset(0, 0.5)));
      }
      await tester.pump();

      expect(scrollDeltaCalls(), [
        [0.0, -1.0],
      ]);
    });
  });
}
