import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_linux/src/in_app_webview/custom_platform_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const manager = MethodChannel(
    'com.pichillilorenzo/flutter_inappwebview_manager',
  );
  const view = MethodChannel('com.pichillilorenzo/custom_platform_view_1');
  const events = MethodChannel(
    'com.pichillilorenzo/custom_platform_view_1_events',
  );
  late List<MethodCall> calls;

  setUp(() {
    calls = [];
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      manager,
      (call) async => call.method == 'createInAppWebView' ? 1 : null,
    );
    messenger.setMockMethodCallHandler(view, (call) async {
      calls.add(call);
      return null;
    });
    messenger.setMockMethodCallHandler(events, (call) async => null);
  });
  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final channel in [manager, view, events]) {
      messenger.setMockMethodCallHandler(channel, null);
    }
  });

  Future<Offset> mount(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox(width: 200, height: 100, child: CustomPlatformView()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    calls.clear();
    return tester.getCenter(find.byType(CustomPlatformView));
  }

  testWidgets('move bursts send the latest coordinate once per interval', (
    tester,
  ) async {
    final center = await mount(tester);
    final mouse = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(mouse.hover(center));
    for (var i = 1; i <= 5; i++) {
      await tester.sendEventToBinding(
        mouse.hover(center + Offset(i.toDouble(), 0)),
      );
    }
    expect(calls.where((call) => call.method == 'setCursorPos'), hasLength(1));
    await tester.pump(const Duration(milliseconds: 8));
    final moves = calls.where((call) => call.method == 'setCursorPos').toList();
    expect(moves, hasLength(2));
    expect(moves.last.arguments, [105.0, 50.0]);
    await tester.pumpWidget(const SizedBox());
  });

  for (final action in ['down', 'wheel', 'leave']) {
    testWidgets('pending position is flushed before $action', (tester) async {
      final center = await mount(tester);
      final mouse = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(mouse.hover(center));
      await tester.sendEventToBinding(mouse.hover(center + const Offset(7, 0)));
      calls.clear();
      switch (action) {
        case 'down':
          await tester.sendEventToBinding(
            mouse.down(center + const Offset(7, 0)),
          );
          break;
        case 'wheel':
          await tester.sendEventToBinding(mouse.scroll(const Offset(0, 120)));
          break;
        case 'leave':
          await tester.sendEventToBinding(mouse.removePointer());
          await tester.pump();
          break;
      }
      final input = calls
          .where(
            (call) => [
              'setCursorPos',
              'setPointerButton',
              'setScrollDelta',
            ].contains(call.method),
          )
          .toList();
      expect(input.first.method, 'setCursorPos');
      expect(input.first.arguments, [107.0, 50.0]);
      expect(
        input[1].method,
        action == 'wheel' ? 'setScrollDelta' : 'setPointerButton',
      );
      if (action == 'down') await tester.sendEventToBinding(mouse.up());
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('dispose cancels a pending move', (tester) async {
    final center = await mount(tester);
    final mouse = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(mouse.hover(center));
    await tester.sendEventToBinding(mouse.hover(center + const Offset(7, 0)));
    await tester.pumpWidget(const SizedBox());
    calls.clear();
    await tester.pump(const Duration(milliseconds: 16));
    expect(calls.where((call) => call.method == 'setCursorPos'), isEmpty);
  });
}
