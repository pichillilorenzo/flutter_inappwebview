import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_inappwebview_windows/src/in_app_webview/_static_channel.dart';
import 'package:flutter_inappwebview_windows/src/in_app_webview/custom_platform_view.dart';

/// Regression tests for the native focus bridge.
///
/// Bridging Flutter's `Focus.onFocusChange` to native `MoveFocus`/`blur` broke
/// typing with a mouse: the click already focused the element natively, and the
/// `MoveFocus` that followed toggled that focus away (upstream #2736). A blur on
/// every Flutter-side focus loss made it worse — any host widget requesting
/// focus wiped the caret out of the page.
///
/// Only a touch tap needs the native grab, because `SendPointerInput` (unlike
/// `SendMouseInput`) does not focus the renderer on its own.
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

  List<String> focusCalls() => viewChannelCalls
      .map((call) => call.method)
      .where((m) => m == 'requestFocus' || m == 'clearFocus')
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

  /// Mounts the view next to a sibling that can take focus away from it.
  Future<(Offset, FocusNode)> pumpViewWithSibling(WidgetTester tester) async {
    final sibling = FocusNode(debugLabel: 'host-widget');
    addTearDown(sibling.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Focus(focusNode: sibling, child: const SizedBox(height: 10)),
              const Expanded(child: CustomPlatformView()),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Texture), findsOneWidget);
    return (tester.getCenter(find.byType(Texture)), sibling);
  }

  testWidgets('regaining Flutter focus does not call native MoveFocus', (
    tester,
  ) async {
    final (_, sibling) = await pumpViewWithSibling(tester);

    sibling.requestFocus();
    await tester.pumpAndSettle();

    // Focus returning to the view — e.g. Tab navigation — must not re-issue
    // MoveFocus, which would toggle the focused input away inside the page.
    final viewFocus = Focus.of(
      tester.element(find.byType(Texture)),
      scopeOk: true,
    );
    viewFocus.requestFocus();
    await tester.pumpAndSettle();

    expect(focusCalls(), isEmpty);
  });

  testWidgets('losing Flutter focus does not blur the page', (tester) async {
    final (_, sibling) = await pumpViewWithSibling(tester);

    // A host widget taking focus — e.g. a screen focus restorer — must not
    // wipe the caret out of the input the user is typing in.
    sibling.requestFocus();
    await tester.pumpAndSettle();

    expect(focusCalls(), isEmpty);
  });

  testWidgets('a mouse click does not trigger a native focus call', (
    tester,
  ) async {
    final (center, sibling) = await pumpViewWithSibling(tester);

    // Focus starts outside the view, so the click makes Flutter focus it —
    // exactly the sequence whose MoveFocus stole the caret from the field.
    sibling.requestFocus();
    await tester.pumpAndSettle();

    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(pointer.down(center));
    await tester.sendEventToBinding(pointer.up());
    await tester.pumpAndSettle();

    expect(focusCalls(), isEmpty);
  });

  testWidgets('a touch tap still grabs native focus after a delay', (
    tester,
  ) async {
    final (center, _) = await pumpViewWithSibling(tester);

    final pointer = TestPointer(1, PointerDeviceKind.touch);
    await tester.sendEventToBinding(pointer.down(center));
    await tester.sendEventToBinding(pointer.up());
    await tester.pump();

    // The grab is delayed so it lands after Chromium processed the tap.
    expect(focusCalls(), isEmpty);
    await tester.pump(const Duration(milliseconds: 150));

    expect(focusCalls(), ['requestFocus']);
  });

  testWidgets('a touch scroll does not grab focus', (tester) async {
    final (center, _) = await pumpViewWithSibling(tester);

    final pointer = TestPointer(1, PointerDeviceKind.touch);
    await tester.sendEventToBinding(pointer.down(center));
    await tester.sendEventToBinding(pointer.move(center + const Offset(0, 60)));
    await tester.sendEventToBinding(pointer.up());
    await tester.pump(const Duration(milliseconds: 150));

    expect(focusCalls(), isEmpty);
  });

  testWidgets('focus leaving before the tap timer fires cancels the grab', (
    tester,
  ) async {
    final (center, sibling) = await pumpViewWithSibling(tester);

    final pointer = TestPointer(1, PointerDeviceKind.touch);
    await tester.sendEventToBinding(pointer.down(center));
    await tester.sendEventToBinding(pointer.up());
    await tester.pump();

    // Something else takes focus within the delay window — the pending grab
    // must not pull it back into the WebView.
    sibling.requestFocus();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 150));

    expect(focusCalls(), isEmpty);
  });
}
