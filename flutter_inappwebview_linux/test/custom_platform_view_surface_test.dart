import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_linux/src/in_app_webview/custom_platform_view.dart';

const _managerChannel = MethodChannel(
  'com.pichillilorenzo/flutter_inappwebview_manager',
);
const _viewChannel = MethodChannel(
  'com.pichillilorenzo/custom_platform_view_7',
);
const _eventsChannel = MethodChannel(
  'com.pichillilorenzo/custom_platform_view_7_events',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<MethodCall> viewCalls;
  late List<MethodCall> managerCalls;
  Completer<int>? creation;
  Completer<void>? delayedOffsetReply;

  void installChannelMocks() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(_managerChannel, (call) async {
      managerCalls.add(call);
      if (call.method == 'createInAppWebView') {
        return creation == null ? 7 : creation!.future;
      }
      return null;
    });
    messenger.setMockMethodCallHandler(_viewChannel, (call) async {
      viewCalls.add(call);
      if (call.method == 'setTextureOffset' && delayedOffsetReply != null) {
        return delayedOffsetReply!.future.then((_) => null);
      }
      return null;
    });
    messenger.setMockMethodCallHandler(_eventsChannel, (call) async => null);
  }

  Widget buildView({
    double left = 20,
    double top = 15,
    double width = 100,
    double height = 60,
    double? scaleFactor,
    double? mediaQueryDpr,
  }) {
    Widget view = CustomPlatformView(scaleFactor: scaleFactor);
    if (mediaQueryDpr != null) {
      view = MediaQuery(
        data: MediaQueryData(devicePixelRatio: mediaQueryDpr),
        child: view,
      );
    }
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              width: width,
              height: height,
              child: view,
            ),
          ],
        ),
      ),
    );
  }

  List<MethodCall> callsFor(String method) =>
      viewCalls.where((call) => call.method == method).toList();

  setUp(() {
    viewCalls = <MethodCall>[];
    managerCalls = <MethodCall>[];
    creation = null;
    delayedOffsetReply = null;
  });

  tearDown(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(_managerChannel, null);
    messenger.setMockMethodCallHandler(_viewChannel, null);
    messenger.setMockMethodCallHandler(_eventsChannel, null);
  });

  testWidgets('pending layout bursts report the latest logical size once', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = const Size(1000, 800);
    creation = Completer<int>();
    installChannelMocks();

    await tester.pumpWidget(buildView(width: 100, height: 50));
    await tester.pump();
    await tester.pumpWidget(buildView(left: 30, width: 120, height: 70));
    await tester.pump();
    await tester.pumpWidget(buildView(left: 40, width: 150, height: 80));
    await tester.pump();
    expect(callsFor('setSize'), isEmpty);

    creation!.complete(7);
    await tester.pump();
    await tester.pump();

    final sizeCalls = callsFor('setSize');
    expect(sizeCalls, hasLength(1));
    expect(sizeCalls.single.arguments, [150.0, 80.0, 2.0]);
    expect(callsFor('setTextureOffset').single.arguments, [40.0, 15.0]);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets(
    'failed creation is observable and does not use an invalid channel',
    (tester) async {
      final creationErrors = <LinuxWebViewCreationFailure>[];
      final subscription = LinuxWebViewCreationDiagnostics.creationErrors
          .listen(creationErrors.add);
      addTearDown(subscription.cancel);
      creation = Completer<int>();
      installChannelMocks();

      await tester.pumpWidget(buildView());
      creation!.completeError(
        PlatformException(
          code: 'WEBVIEW_CREATION_FAILED',
          message: 'WPE display connection failed',
          details: <String, Object?>{
            'stage': 'wpe_display_connect',
            'nativeCode': 12,
            'nativeDomain': 'wpe-platform-error',
          },
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();
      final pointerPosition = tester.getCenter(find.byType(CustomPlatformView));
      await tester.sendEventToBinding(
        PointerDownEvent(
          pointer: 12,
          position: pointerPosition,
          buttons: kPrimaryButton,
        ),
      );
      await tester.sendEventToBinding(
        PointerUpEvent(pointer: 12, position: pointerPosition),
      );
      await tester.pump();
      await tester.pumpWidget(const SizedBox());

      expect(tester.takeException(), isNull);
      expect(creationErrors, hasLength(1));
      final platformError = creationErrors.single.error as PlatformException;
      expect(platformError.code, 'WEBVIEW_CREATION_FAILED');
      expect(platformError.details['stage'], 'wpe_display_connect');
      expect(viewCalls, isEmpty);
      expect(managerCalls.map((call) => call.method), ['createInAppWebView']);
    },
  );

  testWidgets(
    'ready layout bursts coalesce within a frame and pointer wakes it',
    (tester) async {
      tester.view.devicePixelRatio = 2;
      tester.view.physicalSize = const Size(1000, 800);
      installChannelMocks();

      var width = 100.0;
      var height = 60.0;
      var left = 20.0;
      var scaleFactor = 1.25;
      late StateSetter updateLayout;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                updateLayout = setState;
                return Stack(
                  children: [
                    Positioned(
                      left: left,
                      top: 15,
                      width: width,
                      height: height,
                      child: CustomPlatformView(scaleFactor: scaleFactor),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
      await tester.pump();
      viewCalls.clear();

      updateLayout(() {
        width = 180;
        height = 90;
        left = 50;
        scaleFactor = 1.75;
      });
      final notificationContext = tester.element(
        find.byType(SizeChangedLayoutNotifier),
      );
      for (var i = 0; i < 4; i++) {
        const SizeChangedLayoutNotification().dispatch(notificationContext);
      }
      expect(callsFor('setSize'), isEmpty);

      await tester.pump();
      expect(callsFor('setSize'), hasLength(1));
      expect(callsFor('setSize').single.arguments, [180.0, 90.0, 1.75]);
      expect(callsFor('setTextureOffset').last.arguments, [50.0, 15.0]);

      viewCalls.clear();
      expect(tester.binding.hasScheduledFrame, isFalse);
      tester.binding.handlePointerEvent(
        const PointerDownEvent(
          pointer: 2,
          position: Offset(60, 25),
          buttons: kPrimaryMouseButton,
          kind: PointerDeviceKind.mouse,
        ),
      );
      expect(tester.binding.hasScheduledFrame, isTrue);
      expect(callsFor('setSize'), isEmpty);
      await tester.pump();
      expect(callsFor('setSize'), hasLength(1));
      expect(callsFor('setSize').single.arguments, [180.0, 90.0, 1.75]);
      tester.binding.handlePointerEvent(
        const PointerUpEvent(
          pointer: 2,
          position: Offset(60, 25),
          kind: PointerDeviceKind.mouse,
        ),
      );

      await tester.pumpWidget(const SizedBox());
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    },
  );

  testWidgets('a device pixel ratio change reports unchanged logical size', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.5;
    tester.view.physicalSize = const Size(1000, 800);
    installChannelMocks();

    await tester.pumpWidget(buildView(width: 80, height: 40));
    await tester.pump();
    expect(callsFor('setSize').last.arguments, [80.0, 40.0, 1.5]);

    tester.view.devicePixelRatio = 2.5;
    await tester.pump();

    expect(callsFor('setSize').last.arguments, [80.0, 40.0, 2.5]);
    expect(callsFor('setSize'), hasLength(2));

    await tester.pumpWidget(const SizedBox());
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('default scale uses FlutterView DPR over MediaQuery override', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = const Size(1000, 800);
    installChannelMocks();

    await tester.pumpWidget(buildView(width: 80, height: 40, mediaQueryDpr: 7));
    await tester.pump();

    expect(callsFor('setSize').single.arguments, [80.0, 40.0, 2.0]);
    await tester.pumpWidget(const SizedBox());
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('an explicit scale override is preserved and can be updated', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = const Size(1000, 800);
    installChannelMocks();

    await tester.pumpWidget(
      buildView(width: 80, height: 40, scaleFactor: 1.25),
    );
    await tester.pump();
    expect(callsFor('setSize').last.arguments, [80.0, 40.0, 1.25]);

    tester.view.devicePixelRatio = 4;
    await tester.pumpWidget(
      buildView(width: 80, height: 40, scaleFactor: 1.25),
    );
    await tester.pump();
    expect(callsFor('setSize'), hasLength(1));

    await tester.pumpWidget(
      buildView(width: 80, height: 40, scaleFactor: 1.75),
    );
    await tester.pump();
    expect(callsFor('setSize').last.arguments, [80.0, 40.0, 1.75]);
    expect(callsFor('setSize'), hasLength(2));

    await tester.pumpWidget(const SizedBox());
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets(
    'position-only movement sends offset before rapid pointer input',
    (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      installChannelMocks();
      await tester.pumpWidget(buildView(left: 20, top: 15));
      await tester.pump();
      await tester.pumpWidget(buildView(left: 45, top: 35));
      await tester.pump();
      viewCalls.clear();
      delayedOffsetReply = Completer<void>();

      tester.binding.handlePointerEvent(
        const PointerDownEvent(
          pointer: 1,
          position: Offset(55, 45),
          buttons: kPrimaryMouseButton,
          kind: PointerDeviceKind.mouse,
        ),
      );
      await tester.pump();
      tester.binding.handlePointerEvent(
        const PointerUpEvent(
          pointer: 1,
          position: Offset(55, 45),
          kind: PointerDeviceKind.mouse,
        ),
      );
      await tester.pump();

      final names = viewCalls.map((call) => call.method).toList();
      final offsetIndex = names.indexOf('setTextureOffset');
      final pointerButtonCalls = callsFor('setPointerButton');
      final downIndex = viewCalls.indexOf(
        pointerButtonCalls.firstWhere(
          (call) => (call.arguments as Map)['kind'] == 1,
        ),
      );
      final upIndex = viewCalls.indexOf(
        pointerButtonCalls.firstWhere(
          (call) => (call.arguments as Map)['kind'] == 4,
        ),
      );
      expect(callsFor('setTextureOffset').single.arguments, [45.0, 35.0]);
      expect(offsetIndex, greaterThanOrEqualTo(0));
      expect(downIndex, greaterThan(offsetIndex));
      expect(upIndex, greaterThan(downIndex));

      delayedOffsetReply!.complete();
      await tester.pump();
      await tester.pumpWidget(const SizedBox());
      tester.view.resetPhysicalSize();
    },
  );

  testWidgets('disposal after readiness cancels a queued layout report', (
    tester,
  ) async {
    installChannelMocks();
    await tester.pumpWidget(buildView(width: 100, height: 50));
    await tester.pump();
    viewCalls.clear();

    final notificationContext = tester.element(
      find.byType(SizeChangedLayoutNotifier),
    );
    const SizeChangedLayoutNotification().dispatch(notificationContext);
    expect(callsFor('setSize'), isEmpty);

    await tester.pumpWidget(const SizedBox());
    expect(callsFor('setSize'), isEmpty);
    expect(callsFor('setTextureOffset'), isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'disposal during creation drops pending size and offset reports',
    (tester) async {
      creation = Completer<int>();
      installChannelMocks();

      await tester.pumpWidget(buildView(width: 100, height: 50));
      await tester.pump();
      await tester.pumpWidget(const SizedBox());
      creation!.complete(7);
      await tester.pump();
      await tester.pump();

      expect(callsFor('setSize'), isEmpty);
      expect(callsFor('setTextureOffset'), isEmpty);
      expect(tester.takeException(), isNull);
    },
  );
}
