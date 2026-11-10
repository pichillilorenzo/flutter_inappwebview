import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_linux/src/in_app_webview/custom_platform_view.dart';
import 'package:flutter_test/flutter_test.dart';

const _managerChannel = MethodChannel(
  'com.pichillilorenzo/flutter_inappwebview_manager',
);
const _viewChannel = MethodChannel(
  'com.pichillilorenzo/custom_platform_view_7',
);
const _eventsChannel = MethodChannel(
  'com.pichillilorenzo/custom_platform_view_7_events',
);

/// A second view with its own id, standing in for another window.
class _SecondTestView extends TestFlutterView {
  _SecondTestView(TestFlutterView view)
    : super(
        view: view,
        platformDispatcher: view.platformDispatcher,
        display: TestDisplay(view.platformDispatcher, view.display),
      );

  @override
  final int viewId = 99;

  @override
  void render(Scene scene, {Size? size}) {}

  @override
  void updateSemantics(SemanticsUpdate update) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<MethodCall> managerCalls;
  late List<MethodCall> viewCalls;

  setUp(() {
    managerCalls = [];
    viewCalls = [];
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(_managerChannel, (call) async {
      managerCalls.add(call);
      if (call.method == 'createInAppWebView') {
        return 7;
      }
      return null;
    });
    messenger.setMockMethodCallHandler(_viewChannel, (call) async {
      viewCalls.add(call);
      return null;
    });
    messenger.setMockMethodCallHandler(_eventsChannel, (call) async => null);
  });

  tearDown(() {
    LinuxWebViewHostWindow.resolver = null;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(_managerChannel, null);
    messenger.setMockMethodCallHandler(_viewChannel, null);
    messenger.setMockMethodCallHandler(_eventsChannel, null);
  });

  Map<Object?, Object?> createArguments() {
    final call = managerCalls.singleWhere(
      (call) => call.method == 'createInAppWebView',
    );
    return call.arguments as Map<Object?, Object?>;
  }

  testWidgets(
    'a registered resolver adds the host handles to the create call',
    (tester) async {
      LinuxWebViewHostWindow.resolver = (viewId) =>
          (windowHandle: 1000 + viewId, flutterViewHandle: 2000 + viewId);

      await tester.pumpWidget(
        const MaterialApp(
          home: CustomPlatformView(creationParams: <String, dynamic>{}),
        ),
      );
      await tester.pump();

      final viewId = tester.view.viewId;
      final arguments = createArguments();
      expect(arguments['windowHandle'], 1000 + viewId);
      expect(arguments['flutterViewHandle'], 2000 + viewId);
    },
  );

  testWidgets('without a resolver the create call has no handles', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CustomPlatformView(creationParams: <String, dynamic>{}),
      ),
    );
    await tester.pump();

    final arguments = createArguments();
    expect(arguments.containsKey('windowHandle'), isFalse);
    expect(arguments.containsKey('flutterViewHandle'), isFalse);
  });

  testWidgets('moving to another view sends setHostView with its handles', (
    tester,
  ) async {
    LinuxWebViewHostWindow.resolver = (viewId) =>
        (windowHandle: 1000 + viewId, flutterViewHandle: 2000 + viewId);
    final webview = KeyedSubtree(
      key: GlobalKey(),
      child: const CustomPlatformView(creationParams: <String, dynamic>{}),
    );
    final secondView = _SecondTestView(tester.view);

    Widget tree({required bool inSecond}) => ViewCollection(
      views: [
        View(
          view: tester.view,
          child: inSecond ? const SizedBox.shrink() : webview,
        ),
        View(
          view: secondView,
          child: inSecond ? webview : const SizedBox.shrink(),
        ),
      ],
    );

    await tester.pumpWidget(wrapWithView: false, tree(inSecond: false));
    await tester.pump();
    expect(createArguments()['windowHandle'], 1000 + tester.view.viewId);
    expect(viewCalls.where((call) => call.method == 'setHostView'), isEmpty);

    await tester.pumpWidget(wrapWithView: false, tree(inSecond: true));
    await tester.pump();

    final setHostView = viewCalls.singleWhere(
      (call) => call.method == 'setHostView',
    );
    expect(setHostView.arguments, {
      'windowHandle': 1000 + secondView.viewId,
      'flutterViewHandle': 2000 + secondView.viewId,
    });
  });

  testWidgets(
    'moving back to a view the resolver leaves unmapped resets the host',
    (tester) async {
      final secondView = _SecondTestView(tester.view);
      // Like the main (implicit) view: only the second view is mapped.
      LinuxWebViewHostWindow.resolver = (viewId) => viewId == secondView.viewId
          ? (windowHandle: 1099, flutterViewHandle: 2099)
          : null;
      final webview = KeyedSubtree(
        key: GlobalKey(),
        child: const CustomPlatformView(creationParams: <String, dynamic>{}),
      );

      Widget tree({required bool inSecond}) => ViewCollection(
        views: [
          View(
            view: tester.view,
            child: inSecond ? const SizedBox.shrink() : webview,
          ),
          View(
            view: secondView,
            child: inSecond ? webview : const SizedBox.shrink(),
          ),
        ],
      );

      await tester.pumpWidget(wrapWithView: false, tree(inSecond: true));
      await tester.pump();
      expect(createArguments()['windowHandle'], 1099);

      await tester.pumpWidget(wrapWithView: false, tree(inSecond: false));
      await tester.pump();

      final setHostView = viewCalls.singleWhere(
        (call) => call.method == 'setHostView',
      );
      expect(setHostView.arguments, isEmpty);
    },
  );

  testWidgets('rehosting reapplies unchanged size and explicit scale', (
    tester,
  ) async {
    LinuxWebViewHostWindow.resolver = (viewId) =>
        (windowHandle: 1000 + viewId, flutterViewHandle: 2000 + viewId);
    final webview = KeyedSubtree(
      key: GlobalKey(),
      child: const CustomPlatformView(
        creationParams: <String, dynamic>{},
        scaleFactor: 1.5,
      ),
    );
    final secondView = _SecondTestView(tester.view);

    Widget tree({required bool inSecond}) => ViewCollection(
      views: [
        View(
          view: tester.view,
          child: inSecond ? const SizedBox.shrink() : webview,
        ),
        View(
          view: secondView,
          child: inSecond ? webview : const SizedBox.shrink(),
        ),
      ],
    );

    await tester.pumpWidget(wrapWithView: false, tree(inSecond: false));
    await tester.pump();
    expect(viewCalls.where((call) => call.method == 'setSize').last.arguments, [
      800.0,
      600.0,
      1.5,
    ]);
    viewCalls.clear();

    await tester.pumpWidget(wrapWithView: false, tree(inSecond: true));
    await tester.pump();
    await tester.pump();

    expect(
      viewCalls.where((call) => call.method == 'setHostView'),
      hasLength(1),
    );
    expect(
      viewCalls.where((call) => call.method == 'setSize').last.arguments,
      [800.0, 600.0, 1.5],
      reason:
          'Native setHostView resets scale; Flutter must reapply it even '
          'when the widget dimensions and explicit scale are unchanged.',
    );
    expect(
      viewCalls.where((call) => call.method == 'setTextureOffset'),
      isNotEmpty,
    );
  });

  testWidgets('rapid rehosting applies the latest unmapped host and geometry', (
    tester,
  ) async {
    LinuxWebViewHostWindow.resolver = (viewId) =>
        (windowHandle: 1000 + viewId, flutterViewHandle: 2000 + viewId);
    final firstHostCall = Completer<void>();
    var shouldHoldFirstHostCall = true;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(_viewChannel, (call) async {
      viewCalls.add(call);
      if (call.method == 'setHostView' && shouldHoldFirstHostCall) {
        shouldHoldFirstHostCall = false;
        await firstHostCall.future;
      }
      return null;
    });

    final webview = KeyedSubtree(
      key: GlobalKey(),
      child: const CustomPlatformView(
        creationParams: <String, dynamic>{},
        scaleFactor: 1.5,
      ),
    );
    final secondView = _SecondTestView(tester.view);

    Widget tree({required bool inSecond}) => ViewCollection(
      views: [
        View(
          view: tester.view,
          child: inSecond ? const SizedBox.shrink() : webview,
        ),
        View(
          view: secondView,
          child: inSecond ? webview : const SizedBox.shrink(),
        ),
      ],
    );

    await tester.pumpWidget(wrapWithView: false, tree(inSecond: false));
    await tester.pump();
    viewCalls.clear();

    await tester.pumpWidget(wrapWithView: false, tree(inSecond: true));
    await tester.pump();
    expect(
      viewCalls.where((call) => call.method == 'setHostView'),
      hasLength(1),
    );
    expect(
      viewCalls.where((call) => call.method == 'setHostView').single.arguments,
      {
        'windowHandle': 1000 + secondView.viewId,
        'flutterViewHandle': 2000 + secondView.viewId,
      },
    );

    // Move back while the first native rehost is still waiting for its reply.
    // With no resolver, the main view must explicitly reset to the default host.
    LinuxWebViewHostWindow.resolver = null;
    await tester.pumpWidget(wrapWithView: false, tree(inSecond: false));
    await tester.pump();
    expect(
      viewCalls.where((call) => call.method == 'setHostView'),
      hasLength(1),
    );

    firstHostCall.complete();
    await tester.pump();
    await tester.pump();
    await tester.pump();

    final hostCalls = viewCalls.where((call) => call.method == 'setHostView');
    expect(hostCalls.map((call) => call.arguments), [
      {
        'windowHandle': 1000 + secondView.viewId,
        'flutterViewHandle': 2000 + secondView.viewId,
      },
      <String, dynamic>{},
    ]);
    final lastHostCallIndex = viewCalls.lastIndexWhere(
      (call) => call.method == 'setHostView',
    );
    final sizeCalls = viewCalls
        .asMap()
        .entries
        .where((entry) => entry.value.method == 'setSize')
        .toList();
    expect(sizeCalls, hasLength(1));
    expect(sizeCalls.single.value.arguments, [800.0, 600.0, 1.5]);
    expect(sizeCalls.single.key, greaterThan(lastHostCallIndex));
    final offsetCallIndex = viewCalls.lastIndexWhere(
      (call) => call.method == 'setTextureOffset',
    );
    expect(offsetCallIndex, greaterThan(lastHostCallIndex));
  });

  testWidgets('pending creation must not reuse a destroyed intermediate host', (
    tester,
  ) async {
    final nativeCreate = Completer<int>();
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(_managerChannel, (call) async {
      managerCalls.add(call);
      if (call.method == 'createInAppWebView') return nativeCreate.future;
      return null;
    });
    final secondView = _SecondTestView(tester.view);
    var secondAlive = true;
    LinuxWebViewHostWindow.resolver = (viewId) =>
        viewId == secondView.viewId && secondAlive
        ? (windowHandle: 1099, flutterViewHandle: 2099)
        : null;
    final webview = KeyedSubtree(
      key: GlobalKey(),
      child: const CustomPlatformView(creationParams: <String, dynamic>{}),
    );
    Widget tree({required bool inSecond}) => ViewCollection(
      views: [
        View(
          view: tester.view,
          child: inSecond ? const SizedBox.shrink() : webview,
        ),
        View(
          view: secondView,
          child: inSecond ? webview : const SizedBox.shrink(),
        ),
      ],
    );
    await tester.pumpWidget(wrapWithView: false, tree(inSecond: false));
    await tester.pumpWidget(wrapWithView: false, tree(inSecond: true));
    await tester.pumpWidget(wrapWithView: false, tree(inSecond: false));
    secondAlive = false;
    await tester.pump();
    nativeCreate.complete(7);
    await tester.pump();
    final hosts = viewCalls
        .where((call) => call.method == 'setHostView')
        .map((call) => call.arguments)
        .toList();
    expect(
      hosts,
      everyElement(isNot(containsPair('windowHandle', 1099))),
      reason: 'secondary window has been destroyed before creation completed',
    );
  });

  for (final targetDestroyed in [true, false]) {
    testWidgets(
      targetDestroyed
          ? 'pending creation resolves a destroyed current host again'
          : 'pending creation resolves replacement handles for the same view',
      (tester) async {
        final nativeCreate = Completer<int>();
        final messenger =
            TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
        messenger.setMockMethodCallHandler(_managerChannel, (call) async {
          managerCalls.add(call);
          if (call.method == 'createInAppWebView') return nativeCreate.future;
          return null;
        });
        final secondView = _SecondTestView(tester.view);
        LinuxWebViewHostHandles? secondHost = (
          windowHandle: 1099,
          flutterViewHandle: 2099,
        );
        LinuxWebViewHostWindow.resolver = (viewId) =>
            viewId == secondView.viewId ? secondHost : null;
        final webview = KeyedSubtree(
          key: GlobalKey(),
          child: const CustomPlatformView(creationParams: <String, dynamic>{}),
        );
        Widget tree({required bool inSecond}) => ViewCollection(
          views: [
            View(
              view: tester.view,
              child: inSecond ? const SizedBox.shrink() : webview,
            ),
            View(
              view: secondView,
              child: inSecond ? webview : const SizedBox.shrink(),
            ),
          ],
        );
        await tester.pumpWidget(wrapWithView: false, tree(inSecond: false));
        await tester.pumpWidget(wrapWithView: false, tree(inSecond: true));
        // The Flutter view id stays the same while its native handles become
        // invalid or are replaced. The resolver is authoritative at dispatch.
        secondHost = targetDestroyed
            ? null
            : (windowHandle: 3099, flutterViewHandle: 4099);
        nativeCreate.complete(7);
        await tester.pump();
        await tester.pump();

        final hostCall = viewCalls.singleWhere(
          (call) => call.method == 'setHostView',
        );
        expect(
          hostCall.arguments,
          targetDestroyed
              ? <String, dynamic>{}
              : {'windowHandle': 3099, 'flutterViewHandle': 4099},
        );
      },
    );
  }

  testWidgets('queued rehosting resolves the current handles when dispatched', (
    tester,
  ) async {
    final secondView = _SecondTestView(tester.view);
    LinuxWebViewHostHandles? firstHost = (
      windowHandle: 1000,
      flutterViewHandle: 2000,
    );
    LinuxWebViewHostWindow.resolver = (viewId) => viewId == secondView.viewId
        ? (windowHandle: 1099, flutterViewHandle: 2099)
        : firstHost;
    final firstHostReply = Completer<void>();
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(_viewChannel, (call) async {
      viewCalls.add(call);
      if (call.method == 'setHostView' && !firstHostReply.isCompleted) {
        await firstHostReply.future;
      }
      return null;
    });
    final webview = KeyedSubtree(
      key: GlobalKey(),
      child: const CustomPlatformView(creationParams: <String, dynamic>{}),
    );
    Widget tree({required bool inSecond}) => ViewCollection(
      views: [
        View(
          view: tester.view,
          child: inSecond ? const SizedBox.shrink() : webview,
        ),
        View(
          view: secondView,
          child: inSecond ? webview : const SizedBox.shrink(),
        ),
      ],
    );
    await tester.pumpWidget(wrapWithView: false, tree(inSecond: false));
    await tester.pump();
    await tester.pumpWidget(wrapWithView: false, tree(inSecond: true));
    await tester.pump();
    await tester.pumpWidget(wrapWithView: false, tree(inSecond: false));
    expect(
      viewCalls.where((call) => call.method == 'setHostView'),
      hasLength(1),
    );
    firstHost = (windowHandle: 3000, flutterViewHandle: 4000);
    firstHostReply.complete();
    await tester.pump();
    await tester.pump();
    expect(
      viewCalls
          .where((call) => call.method == 'setHostView')
          .map((call) => call.arguments),
      [
        {'windowHandle': 1099, 'flutterViewHandle': 2099},
        {'windowHandle': 3000, 'flutterViewHandle': 4000},
      ],
    );
  });
}
