import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_inappwebview_windows/flutter_inappwebview_windows.dart';
import 'package:flutter_inappwebview_windows/src/in_app_webview/_static_channel.dart';
import 'package:flutter_inappwebview_windows/src/in_app_webview/custom_platform_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final channels = <String>{};
  final eventChannels = <String>{};
  InAppWebViewPlatform? previousPlatform;
  late FutureOr<Object?> Function(Map<dynamic, dynamic>) create;
  late List<MethodCall> managerCalls;
  late List<String> transportCalls;
  var completedCreations = 0;

  void mockControllerChannel(dynamic id) {
    final name = 'com.pichillilorenzo/flutter_inappwebview_$id';
    channels.add(name);
    messenger.setMockMethodCallHandler(MethodChannel(name), (_) async => null);
  }

  setUp(() {
    previousPlatform = InAppWebViewPlatform.instance;
    WindowsInAppWebViewPlatform.registerWith();
    managerCalls = [];
    transportCalls = [];
    completedCreations = 0;
    create = (_) => {'id': 7, 'renderMode': 'composition'};
    messenger.setMockMethodCallHandler(IN_APP_WEBVIEW_STATIC_CHANNEL, (
      call,
    ) async {
      managerCalls.add(call);
      transportCalls.add('manager.${call.method}');
      if (call.method != 'createInAppWebView') return null;
      final params = call.arguments as Map;
      final result = await create(params);
      final id = result is Map ? result['id'] : result;
      if (id is int) {
        completedCreations++;
        final name = 'com.pichillilorenzo/custom_platform_view_$id';
        channels.add(name);
        messenger.setMockMethodCallHandler(MethodChannel(name), (call) async {
          transportCalls.add('view$id.${call.method}');
          return null;
        });
        eventChannels.add('${name}_events');
        messenger.setMockStreamHandler(
          EventChannel('${name}_events'),
          MockStreamHandler.inline(
            onListen: (_, _) => transportCalls.add('view$id.listen'),
            onCancel: (_) => transportCalls.add('view$id.cancel'),
          ),
        );
        mockControllerChannel(
          params['keepAliveId'] ?? params['headlessWebViewId'] ?? id,
        );
      }
      return result;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(IN_APP_WEBVIEW_STATIC_CHANNEL, null);
    for (final name in channels) {
      messenger.setMockMethodCallHandler(MethodChannel(name), null);
    }
    for (final name in eventChannels) {
      messenger.setMockStreamHandler(EventChannel(name), null);
    }
    channels.clear();
    eventChannels.clear();
    if (previousPlatform != null) {
      InAppWebViewPlatform.instance = previousPlatform;
    }
  });

  Future<void> mount(WidgetTester tester, Widget view) async {
    await tester.pumpWidget(MaterialApp(home: SizedBox.expand(child: view)));
    await tester.pump();
    await tester.pump();
  }

  Future<void> drainDisposals(WidgetTester tester) async {
    // Hiding the HWND and cancelling its event subscription finish after the
    // creation reply. Await actual disposal, not an assumed number of frames.
    for (var i = 0; i < 10; i++) {
      if (managerCalls.where((call) => call.method == 'dispose').length ==
          completedCreations) {
        return;
      }
      await tester.pump();
      // Stream cancellation can complete outside the fake frame clock.
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    }
    expect(
      managerCalls.where((call) => call.method == 'dispose'),
      hasLength(completedCreations),
      reason: transportCalls.join(', '),
    );
  }

  Future<void> detach(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await drainDisposals(tester);
  }

  WindowsInAppWebViewController windows(InAppWebViewController controller) =>
      controller.platform as WindowsInAppWebViewController;

  for (final mode in WindowsWebViewRenderMode.values) {
    testWidgets('normal onWebViewCreated can observe ${mode.name}', (
      tester,
    ) async {
      create = (_) => {
        'id': 7,
        'renderMode': mode.name,
        if (mode == WindowsWebViewRenderMode.hwnd) ...{
          'fallbackStage': 'CreateCaptureSession',
          'fallbackHresult': -2147019873,
        },
      };
      InAppWebViewController? received;
      WindowsWebViewCreationDetails? observedInCallback;
      await mount(
        tester,
        InAppWebView(
          onWebViewCreated: (controller) {
            received = controller;
            observedInCallback = windows(controller).creationDetails;
          },
        ),
      );
      final details = observedInCallback!;
      expect(details.nativeViewId, 7);
      expect(details.renderMode, mode);
      expect(details.isRenderModeVerified, isTrue);
      expect(windows(received!).creationDetails, same(details));
      if (mode == WindowsWebViewRenderMode.hwnd) {
        expect(details.fallbackStage, 'CreateCaptureSession');
        expect(details.fallbackHresult, 0x8007139F);
        expect(details.isFallbackReasonAvailable, isTrue);
      }
      await detach(tester);
      expect(windows(received!).creationDetails, isNull);
      expect(
        details.renderMode,
        mode,
      ); // Retained immutable historical snapshot.
    });
  }

  for (final result in <Object>[
    7,
    {'id': 7},
    {'id': 7, 'renderMode': 'unknown'},
  ]) {
    testWidgets('$result stays unverified through the normal widget', (
      tester,
    ) async {
      create = (_) => result;
      InAppWebViewController? received;
      await mount(
        tester,
        InAppWebView(onWebViewCreated: (value) => received = value),
      );
      final details = windows(received!).creationDetails!;
      expect(details.nativeViewId, 7);
      expect(details.renderMode, isNull);
      expect(details.isRenderModeVerified, isFalse);
      expect(find.byType(Texture), findsOneWidget);
      await detach(tester);
    });
  }

  testWidgets('observation exists before every controller wrapper call', (
    tester,
  ) async {
    final platforms = <WindowsInAppWebViewController>[];
    final observations = <WindowsWebViewCreationDetails?>[];
    InAppWebViewController? received;
    await mount(
      tester,
      InAppWebView.fromPlatform(
        platform: WindowsInAppWebViewWidget(
          WindowsInAppWebViewWidgetCreationParams(
            controllerFromPlatform: (platform) {
              final controller = platform as WindowsInAppWebViewController;
              platforms.add(controller);
              observations.add(controller.creationDetails);
              return InAppWebViewController.fromPlatform(platform: platform);
            },
            onWebViewCreated: (value) =>
                received = value as InAppWebViewController,
          ),
        ),
      ),
    );
    expect(platforms, isNotEmpty);
    expect(
      platforms.every((value) => identical(value, received!.platform)),
      isTrue,
    );
    expect(observations.every((value) => value != null), isTrue);
    expect(
      observations.every((value) => identical(value, observations.first)),
      isTrue,
    );
    await detach(tester);
  });

  testWidgets(
    'rebuilding preserves the observation on the existing controller',
    (tester) async {
      InAppWebViewController? received;
      await mount(
        tester,
        InAppWebView(onWebViewCreated: (value) => received = value),
      );
      final original = windows(received!);
      final observation = original.creationDetails;
      var unexpectedCreations = 0;
      await mount(
        tester,
        InAppWebView(onWebViewCreated: (_) => unexpectedCreations++),
      );
      expect(original.creationDetails, same(observation));
      expect(unexpectedCreations, 0);
      expect(
        managerCalls.where((call) => call.method == 'createInAppWebView'),
        hasLength(1),
      );
      await detach(tester);
    },
  );

  for (final abandonAt in [1, 2]) {
    testWidgets('controller wrapper $abandonAt can detach before publication', (
      tester,
    ) async {
      late WindowsInAppWebViewWidget delegate;
      final observed = <WindowsInAppWebViewController>[];
      var publications = 0;
      delegate = WindowsInAppWebViewWidget(
        WindowsInAppWebViewWidgetCreationParams(
          controllerFromPlatform: (platform) {
            final controller = platform as WindowsInAppWebViewController;
            expect(controller.creationDetails, isNotNull);
            observed.add(controller);
            if (observed.length == abandonAt) delegate.dispose();
            return InAppWebViewController.fromPlatform(platform: platform);
          },
          onWebViewCreated: (_) => publications++,
        ),
      );
      await mount(tester, InAppWebView.fromPlatform(platform: delegate));
      expect(publications, 0);
      expect(observed, hasLength(abandonAt));
      expect(
        observed.every((controller) => controller.creationDetails == null),
        isTrue,
      );
      await detach(tester);
    });
  }

  for (final failureAt in [1, 2, 3]) {
    testWidgets(
      'throwing wrapper/public callback $failureAt releases its owner',
      (tester) async {
        final captured = <WindowsInAppWebViewController>[];
        final observations = <WindowsWebViewCreationDetails?>[];
        var wrappers = 0;
        var publications = 0;
        var lateLoads = 0;
        final delegate = WindowsInAppWebViewWidget(
          WindowsInAppWebViewWidgetCreationParams(
            controllerFromPlatform: (platform) {
              final controller = platform as WindowsInAppWebViewController;
              captured.add(controller);
              observations.add(controller.creationDetails);
              wrappers++;
              if (wrappers == failureAt) throw StateError('wrapper-$failureAt');
              return InAppWebViewController.fromPlatform(platform: controller);
            },
            onWebViewCreated: (_) {
              publications++;
              if (failureAt == 3) throw StateError('public-callback');
            },
            onLoadStart: (_, _) => lateLoads++,
          ),
        );
        await mount(tester, InAppWebView.fromPlatform(platform: delegate));
        expect(captured, hasLength(failureAt == 1 ? 1 : 2));
        expect(observations.every((details) => details != null), isTrue);
        expect(publications, failureAt == 3 ? 1 : 0);
        await detach(tester);
        await messenger.handlePlatformMessage(
          'com.pichillilorenzo/flutter_inappwebview_7',
          const StandardMethodCodec().encodeMethodCall(
            const MethodCall('onLoadStart', {
              'url': 'https://example.invalid/late',
            }),
          ),
          null,
        );
        expect(
          captured.every((controller) => controller.creationDetails == null),
          isTrue,
        );
        expect(lateLoads, 0);
        expect(
          managerCalls.where((call) => call.method == 'dispose'),
          hasLength(1),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'pending creation exposes no controller until native completion',
    (tester) async {
      final pending = Completer<Object?>();
      create = (_) => pending.future;
      InAppWebViewController? received;
      await mount(
        tester,
        InAppWebView(onWebViewCreated: (value) => received = value),
      );
      expect(received, isNull);
      pending.complete({'id': 7, 'renderMode': 'hwnd'});
      await tester.pump();
      await tester.pump();
      expect(
        windows(received!).creationDetails!.renderMode,
        WindowsWebViewRenderMode.hwnd,
      );
      expect(
        windows(received!).creationDetails!.isFallbackReasonAvailable,
        isFalse,
      );
      await detach(tester);
    },
  );

  testWidgets('failed creation never publishes a controller or metadata', (
    tester,
  ) async {
    create = (_) => throw PlatformException(code: 'creation-failed');
    var publications = 0;
    final failures = <WindowsWebViewCreationFailure>[];
    final subscription = WindowsWebViewCreationFailures.stream.listen(
      failures.add,
    );
    addTearDown(subscription.cancel);
    await mount(tester, InAppWebView(onWebViewCreated: (_) => publications++));
    expect(failures, hasLength(1));
    expect(publications, 0);
    expect(tester.takeException(), isNull);
    await detach(tester);
  });

  testWidgets('late native success cannot publish an abandoned widget', (
    tester,
  ) async {
    final pending = Completer<Object?>();
    var publications = 0;
    create = (_) => pending.future;
    await mount(tester, InAppWebView(onWebViewCreated: (_) => publications++));
    await detach(tester);
    pending.complete({'id': 7, 'renderMode': 'hwnd'});
    await tester.pump();
    await drainDisposals(tester);
    expect(publications, 0);
    expect(
      managerCalls.where((call) => call.method == 'dispose'),
      hasLength(1),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'cancellation between details and id cannot create a controller',
    (tester) async {
      var wrappers = 0;
      var publications = 0;
      final delegate = WindowsInAppWebViewWidget(
        WindowsInAppWebViewWidgetCreationParams(
          controllerFromPlatform: (controller) {
            wrappers++;
            return controller;
          },
          onWebViewCreated: (_) => publications++,
        ),
      );
      var observations = 0;
      await mount(
        tester,
        Builder(
          builder: (context) {
            final view = delegate.build(context) as CustomPlatformView;
            return CustomPlatformView(
              creationParams: view.creationParams,
              onPlatformViewCreationDetails: (details) {
                observations++;
                view.onPlatformViewCreationDetails!(details);
                delegate.dispose();
              },
              onPlatformViewCreated: view.onPlatformViewCreated,
            );
          },
        ),
      );
      expect(observations, 1);
      expect(wrappers, 0);
      expect(publications, 0);
      await detach(tester);
    },
  );

  testWidgets('keepAlive reattachment owns fresh mode and unavailable reason', (
    tester,
  ) async {
    final keepAlive = InAppWebViewKeepAlive();
    final owners = <WindowsInAppWebViewController>[];
    create = (_) => {
      'id': 7,
      'renderMode': 'hwnd',
      'fallbackStage': 'forced',
      'fallbackHresult': 0,
    };
    Future<void> attach() => mount(
      tester,
      InAppWebView(
        keepAlive: keepAlive,
        onWebViewCreated: (value) => owners.add(windows(value)),
      ),
    );
    await attach();
    final first = owners.single.creationDetails!;
    expect(owners.single.getViewId(), keepAlive.id);
    expect(first.isFallbackReasonAvailable, isTrue);
    await detach(tester);
    expect(owners.single.creationDetails, isNull);

    create = (_) => {'id': 8, 'renderMode': 'hwnd'};
    await attach();
    final current = owners.last.creationDetails!;
    expect(owners.last.getViewId(), keepAlive.id);
    expect(current.nativeViewId, 8);
    expect(current.renderMode, WindowsWebViewRenderMode.hwnd);
    expect(current.isFallbackReasonAvailable, isFalse);
    expect(current.fallbackStage, isNull);
    expect(owners.first.creationDetails, isNull);
    expect(first.nativeViewId, 7);
    expect(first.fallbackStage, 'forced');
    await detach(tester);
    await WindowsInAppWebViewController.static().disposeKeepAlive(keepAlive);
  });

  testWidgets('a reused native id cannot change a retained old observation', (
    tester,
  ) async {
    final owners = <WindowsInAppWebViewController>[];
    Future<void> attach() => mount(
      tester,
      InAppWebView(onWebViewCreated: (value) => owners.add(windows(value))),
    );
    create = (_) => {'id': 7, 'renderMode': 'hwnd'};
    await attach();
    final first = owners.single.creationDetails!;
    await detach(tester);
    create = (_) => {'id': 7, 'renderMode': 'composition'};
    await attach();
    expect(owners.first.creationDetails, isNull);
    expect(
      owners.last.creationDetails!.renderMode,
      WindowsWebViewRenderMode.composition,
    );
    expect(first.renderMode, WindowsWebViewRenderMode.hwnd);
    expect(identical(first, owners.last.creationDetails), isFalse);
    await detach(tester);
  });

  for (final abandonedCompletesFirst in [false, true]) {
    testWidgets(
      'pending keepAlive owners are isolated, old first=$abandonedCompletesFirst',
      (tester) async {
        final keepAlive = InAppWebViewKeepAlive();
        final first = Completer<Object?>();
        final second = Completer<Object?>();
        var creation = 0;
        var abandonedPublications = 0;
        create = (_) => ++creation == 1 ? first.future : second.future;
        await mount(
          tester,
          InAppWebView(
            key: const ValueKey('old'),
            keepAlive: keepAlive,
            onWebViewCreated: (_) => abandonedPublications++,
          ),
        );
        await detach(tester);
        WindowsInAppWebViewController? current;
        await mount(
          tester,
          InAppWebView(
            key: const ValueKey('new'),
            keepAlive: keepAlive,
            onWebViewCreated: (value) => current = windows(value),
          ),
        );
        if (abandonedCompletesFirst) {
          first.complete({'id': 7, 'renderMode': 'hwnd'});
          await tester.pump();
        }
        second.complete({'id': 8, 'renderMode': 'composition'});
        await tester.pump();
        await tester.pump();
        final currentObservation = current!.creationDetails!;
        if (!abandonedCompletesFirst) {
          first.complete({'id': 7, 'renderMode': 'hwnd'});
          await tester.pump();
          await tester.pump();
        }
        expect(current!.creationDetails, same(currentObservation));
        expect(abandonedPublications, 0);
        expect(currentObservation.nativeViewId, 8);
        expect(
          currentObservation.renderMode,
          WindowsWebViewRenderMode.composition,
        );
        expect(tester.takeException(), isNull);
        await detach(tester);
        await WindowsInAppWebViewController.static().disposeKeepAlive(
          keepAlive,
        );
      },
    );
  }

  testWidgets(
    'headless conversion gets widget metadata without retrofitting the old controller',
    (tester) async {
      const manager = MethodChannel(
        'com.pichillilorenzo/flutter_headless_inappwebview',
      );
      channels.add(manager.name);
      messenger.setMockMethodCallHandler(manager, (_) async => null);
      final headless = HeadlessInAppWebView();
      await headless.run();
      final original = windows(headless.webViewController!);
      expect(original.creationDetails, isNull);
      create = (params) {
        expect(params['headlessWebViewId'], headless.id);
        return {'id': 9, 'renderMode': 'hwnd'};
      };
      WindowsInAppWebViewController? current;
      await mount(
        tester,
        InAppWebView(
          headlessWebView: headless,
          onWebViewCreated: (value) => current = windows(value),
        ),
      );
      expect(current!.getViewId(), headless.id);
      expect(current!.creationDetails!.nativeViewId, 9);
      expect(
        current!.creationDetails!.renderMode,
        WindowsWebViewRenderMode.hwnd,
      );
      expect(current!.creationDetails!.isFallbackReasonAvailable, isFalse);
      expect(original.creationDetails, isNull);
      expect(headless.isRunning(), isFalse);
      await detach(tester);
    },
  );
}
