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

  /// The `kind` of every `setPointerButton` call sent to the native side so
  /// far, in order. This is exactly what WebView2's `SendMouseInput` sees.
  List<InAppWebViewPointerEventKind> pointerKinds() => viewChannelCalls
      .where((call) => call.method == 'setPointerButton')
      .map(
        (call) =>
            InAppWebViewPointerEventKind.values[(call.arguments as Map)['kind']
                as int],
      )
      .toList();

  List<Offset> cursorPositions() => viewChannelCalls
      .where((call) => call.method == 'setCursorPos')
      .map(
        (call) => Offset(
          ((call.arguments as List)[0] as num).toDouble(),
          ((call.arguments as List)[1] as num).toDouble(),
        ),
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

  /// Lays the view out smaller than the test surface so there is real estate
  /// outside it to drag into, and returns its bounds.
  Future<Rect> pumpView(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              height: 300,
              child: CustomPlatformView(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Texture), findsOneWidget);
    return tester.getRect(find.byType(Texture));
  }

  group('drag past the edge of the view', () {
    testWidgets('does not tell the native side the pointer left', (
      tester,
    ) async {
      final view = await pumpView(tester);
      final mouse = TestPointer(1, PointerDeviceKind.mouse);

      await tester.sendEventToBinding(mouse.hover(view.center));
      await tester.pump();
      viewChannelCalls.clear();

      await tester.sendEventToBinding(mouse.down(view.center));
      await tester.pump();
      // Drag out through the bottom edge, the way a user extends a selection
      // past the last visible line.
      await tester.sendEventToBinding(
        mouse.move(Offset(view.center.dx, view.bottom + 60)),
      );
      await tester.pump();

      expect(
        pointerKinds(),
        [InAppWebViewPointerEventKind.down],
        reason:
            'a LEAVE here reaches Chromium as WM_MOUSELEAVE and ends the drag',
      );

      await tester.sendEventToBinding(mouse.up());
      await tester.pump();
    });

    testWidgets('keeps forwarding the cursor while it is outside', (
      tester,
    ) async {
      final view = await pumpView(tester);
      final mouse = TestPointer(1, PointerDeviceKind.mouse);

      await tester.sendEventToBinding(mouse.hover(view.center));
      await tester.pump();
      await tester.sendEventToBinding(mouse.down(view.center));
      await tester.pump();
      viewChannelCalls.clear();

      for (var i = 1; i <= 3; i++) {
        await tester.sendEventToBinding(
          mouse.move(Offset(view.center.dx, view.bottom + 30.0 * i)),
        );
        await tester.pump();
      }

      // Local coordinates below the view's own height: Chromium needs them to
      // keep extending the selection (and to auto-scroll) while the button is
      // held outside.
      final positions = cursorPositions();
      expect(positions, hasLength(3));
      for (final position in positions) {
        expect(position.dy, greaterThan(view.height));
      }

      await tester.sendEventToBinding(mouse.up());
      await tester.pump();
    });

    testWidgets('delivers the withheld leave once the button is released', (
      tester,
    ) async {
      final view = await pumpView(tester);
      final mouse = TestPointer(1, PointerDeviceKind.mouse);

      await tester.sendEventToBinding(mouse.hover(view.center));
      await tester.pump();
      viewChannelCalls.clear();

      await tester.sendEventToBinding(mouse.down(view.center));
      await tester.pump();
      await tester.sendEventToBinding(
        mouse.move(Offset(view.center.dx, view.bottom + 60)),
      );
      await tester.pump();
      await tester.sendEventToBinding(mouse.up());
      await tester.pump();

      // The leave is not dropped, only postponed: the cursor really is outside
      // now, so the native side must stop treating the view as hovered.
      expect(pointerKinds(), [
        InAppWebViewPointerEventKind.down,
        InAppWebViewPointerEventKind.up,
        InAppWebViewPointerEventKind.leave,
      ]);
    });

    testWidgets('releases the button and delivers the leave when cancelled', (
      tester,
    ) async {
      final view = await pumpView(tester);
      final mouse = TestPointer(1, PointerDeviceKind.mouse);

      await tester.sendEventToBinding(mouse.hover(view.center));
      await tester.pump();
      viewChannelCalls.clear();

      await tester.sendEventToBinding(mouse.down(view.center));
      await tester.pump();
      await tester.sendEventToBinding(
        mouse.move(Offset(view.center.dx, view.bottom + 60)),
      );
      await tester.pump();
      await tester.sendEventToBinding(mouse.cancel());
      await tester.pump();

      expect(pointerKinds(), [
        InAppWebViewPointerEventKind.down,
        // WebView2 has no mouse-cancel event, so cancellation is translated
        // to UP before the delayed LEAVE. This also clears native button state.
        InAppWebViewPointerEventKind.up,
        InAppWebViewPointerEventKind.leave,
      ]);
    });

    testWidgets('a drag that comes back inside produces no enter/leave pair', (
      tester,
    ) async {
      final view = await pumpView(tester);
      final mouse = TestPointer(1, PointerDeviceKind.mouse);

      await tester.sendEventToBinding(mouse.hover(view.center));
      await tester.pump();
      viewChannelCalls.clear();

      await tester.sendEventToBinding(mouse.down(view.center));
      await tester.pump();
      await tester.sendEventToBinding(
        mouse.move(Offset(view.center.dx, view.bottom + 60)),
      );
      await tester.pump();
      await tester.sendEventToBinding(mouse.move(view.center));
      await tester.pump();
      await tester.sendEventToBinding(mouse.up());
      await tester.pump();

      // WebView2 was never told the pointer left, so it must not be told it
      // came back either: an unpaired ENTER would leave the native hover state
      // out of step with reality.
      expect(pointerKinds(), [
        InAppWebViewPointerEventKind.down,
        InAppWebViewPointerEventKind.up,
      ]);
    });

    testWidgets('a right-button drag is withheld the same way', (tester) async {
      final view = await pumpView(tester);
      final mouse = TestPointer(1, PointerDeviceKind.mouse);

      await tester.sendEventToBinding(mouse.hover(view.center));
      await tester.pump();
      viewChannelCalls.clear();

      await tester.sendEventToBinding(
        mouse.down(view.center, buttons: kSecondaryMouseButton),
      );
      await tester.pump();
      await tester.sendEventToBinding(
        mouse.move(Offset(view.center.dx, view.bottom + 60)),
      );
      await tester.pump();

      expect(pointerKinds(), [InAppWebViewPointerEventKind.down]);

      await tester.sendEventToBinding(mouse.up());
      await tester.pump();
    });
  });

  group('hover leaving the view', () {
    testWidgets('still reports the leave immediately', (tester) async {
      final view = await pumpView(tester);
      final mouse = TestPointer(1, PointerDeviceKind.mouse);

      await tester.sendEventToBinding(mouse.hover(view.center));
      await tester.pump();
      viewChannelCalls.clear();

      await tester.sendEventToBinding(
        mouse.hover(Offset(view.center.dx, view.bottom + 60)),
      );
      await tester.pump();

      expect(pointerKinds(), [InAppWebViewPointerEventKind.leave]);
    });

    testWidgets('re-entering after a real leave reports the enter', (
      tester,
    ) async {
      final view = await pumpView(tester);
      final mouse = TestPointer(1, PointerDeviceKind.mouse);

      await tester.sendEventToBinding(mouse.hover(view.center));
      await tester.pump();
      await tester.sendEventToBinding(
        mouse.hover(Offset(view.center.dx, view.bottom + 60)),
      );
      await tester.pump();
      viewChannelCalls.clear();

      await tester.sendEventToBinding(mouse.hover(view.center));
      await tester.pump();

      expect(pointerKinds(), [InAppWebViewPointerEventKind.enter]);
    });
  });
}
