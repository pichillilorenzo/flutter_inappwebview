import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'
    hide AndroidInAppWebViewController;
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_inappwebview_windows/flutter_inappwebview_windows.dart';
import 'package:flutter_inappwebview_windows/src/in_app_webview/_static_channel.dart';
import 'package:flutter_test/flutter_test.dart';

// Exercise the real public widget, Android delegate and Flutter platform-view
// controllers. Only the native method-channel endpoint is simulated.
class _NativeViews {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final creations = <Map<dynamic, dynamic>>[];
  final disposals = <int>[];
  final channels = <MethodChannel>[];
  Completer<void>? nextCreation;

  void install() {
    messenger.setMockMethodCallHandler(SystemChannels.platform_views, (
      call,
    ) async {
      if (call.method == 'create') {
        final args = call.arguments as Map;
        creations.add(args);
        final channel = MethodChannel(
          'com.pichillilorenzo/flutter_inappwebview_${args['id']}',
        );
        channels.add(channel);
        messenger.setMockMethodCallHandler(channel, (_) async => true);
        final pending = nextCreation;
        nextCreation = null;
        if (pending != null) await pending.future;
        return args['hybrid'] == true ? null : 1000 + (args['id'] as int);
      }
      if (call.method == 'dispose') {
        final args = call.arguments;
        disposals.add(args is int ? args : args['id'] as int);
      }
      if (call.method == 'resize') {
        final args = call.arguments as Map;
        return {
          'width': (args['width'] as num).toDouble(),
          'height': (args['height'] as num).toDouble(),
        };
      }
      return null;
    });
  }

  void uninstall() {
    messenger.setMockMethodCallHandler(SystemChannels.platform_views, null);
    for (final channel in channels) {
      messenger.setMockMethodCallHandler(channel, null);
    }
  }
}

class _DirectDelegateOwner extends StatefulWidget {
  const _DirectDelegateOwner({required this.delegate});

  final AndroidInAppWebViewWidget delegate;

  @override
  State<_DirectDelegateOwner> createState() => _DirectDelegateOwnerState();
}

class _DirectDelegateOwnerState extends State<_DirectDelegateOwner> {
  @override
  Widget build(BuildContext context) => widget.delegate.build(context);

  @override
  void dispose() {
    widget.delegate.dispose();
    super.dispose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  InAppWebViewPlatform? previousPlatform;
  late _NativeViews native;

  setUp(() {
    previousPlatform = InAppWebViewPlatform.instance;
    AndroidInAppWebViewPlatform.registerWith();
    native = _NativeViews()..install();
  });

  tearDown(() {
    native.uninstall();
    if (previousPlatform != null) {
      InAppWebViewPlatform.instance = previousPlatform;
    }
  });

  Future<void> mount(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      Directionality(textDirection: TextDirection.ltr, child: child),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  }

  Future<void> detach(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(tester.takeException(), isNull);
  }

  AndroidInAppWebViewController android(InAppWebViewController controller) =>
      controller.platform as AndroidInAppWebViewController;

  for (final hybrid in [true, false]) {
    group('hybrid=$hybrid', () {
      InAppWebViewSettings settings() =>
          InAppWebViewSettings(useHybridComposition: hybrid);

      void expectComposition() {
        expect(native.creations, isNotEmpty);
        for (final creation in native.creations) {
          expect(creation['hybrid'] == true, hybrid);
        }
      }

      testWidgets(
        'public GlobalKey retains its owner across rebuild and move',
        (tester) async {
          final key = GlobalKey();
          final controllers = <AndroidInAppWebViewController>[];
          final events = <String>[];
          Future<void> pump({
            bool right = false,
            String listener = 'first',
          }) async {
            final view = InAppWebView(
              key: key,
              initialSettings: settings(),
              onWebViewCreated: (controller) =>
                  controllers.add(android(controller)),
              onScrollChanged: (_, x, y) => events.add('$listener:$x,$y'),
            );
            expect(view.platform.params.key, same(key));
            await mount(
              tester,
              Row(
                children: [
                  Expanded(
                    key: const ValueKey('left'),
                    child: right ? const SizedBox() : view,
                  ),
                  Expanded(
                    key: const ValueKey('right'),
                    child: right ? view : const SizedBox(),
                  ),
                ],
              ),
            );
            expect(key.currentWidget, same(view));
          }

          await pump();
          final state = key.currentState;
          expect(state, isNotNull);
          expect(controllers, hasLength(1));
          final controller = controllers.single;
          await pump(listener: 'rebuilt');
          await controller.handler!(
            const MethodCall('onScrollChanged', {'x': 1, 'y': 2}),
          );
          await pump(right: true, listener: 'moved');
          await controller.handler!(
            const MethodCall('onScrollChanged', {'x': 3, 'y': 4}),
          );
          expect(events, ['rebuilt:1,2', 'moved:3,4']);
          expect(key.currentState, same(state));
          expect(controllers, [controller]);
          expect(native.creations, hasLength(1));
          expect(native.disposals, isEmpty);
          expectComposition();
          await detach(tester);
          expect(key.currentContext, isNull);
          expect(controller.disposed, isTrue);
          expect(native.disposals, [native.creations.single['id']]);
        },
        variant: TargetPlatformVariant.only(TargetPlatform.android),
      );

      testWidgets(
        'replacing the outer GlobalKey replaces and disposes its view',
        (tester) async {
          final firstKey = GlobalKey();
          final secondKey = GlobalKey();
          final controllers = <AndroidInAppWebViewController>[];
          Future<void> pump(Key key) => mount(
            tester,
            InAppWebView(
              key: key,
              initialSettings: settings(),
              onWebViewCreated: (controller) =>
                  controllers.add(android(controller)),
            ),
          );
          await pump(firstKey);
          final firstState = firstKey.currentState;
          await pump(secondKey);
          expect(firstKey.currentContext, isNull);
          expect(secondKey.currentState, isNot(same(firstState)));
          expect(controllers, hasLength(2));
          expect(controllers.first.disposed, isTrue);
          expect(controllers.last.disposed, isFalse);
          expect(native.creations, hasLength(2));
          expect(native.disposals, [native.creations.first['id']]);
          expectComposition();
          await detach(tester);
          expect(controllers.last.disposed, isTrue);
          expect(
            native.disposals,
            native.creations.map((value) => value['id']),
          );
        },
        variant: TargetPlatformVariant.only(TargetPlatform.android),
      );

      testWidgets('two public GlobalKeys survive sibling reordering', (
        tester,
      ) async {
        final keys = [GlobalKey(), GlobalKey()];
        final controllers = <GlobalKey, AndroidInAppWebViewController>{};
        var callbacks = 0;
        Future<void> pump(Iterable<GlobalKey> order) => mount(
          tester,
          Row(
            children: [
              for (final key in order)
                Expanded(
                  child: InAppWebView(
                    key: key,
                    initialSettings: settings(),
                    onWebViewCreated: (controller) {
                      callbacks++;
                      controllers[key] = android(controller);
                    },
                  ),
                ),
            ],
          ),
        );
        await pump(keys);
        final states = keys.map((key) => key.currentState).toList();
        final original = Map.of(controllers);
        await pump(keys.reversed);
        expect(callbacks, 2);
        expect(controllers, original);
        expect(keys.map((key) => key.currentState), states);
        expect(native.creations, hasLength(2));
        expect(native.disposals, isEmpty);
        expectComposition();
        await detach(tester);
        expect(controllers.values.every((value) => value.disposed), isTrue);
        expect(
          native.disposals,
          unorderedEquals(native.creations.map((value) => value['id'])),
        );
      }, variant: TargetPlatformVariant.only(TargetPlatform.android));

      testWidgets(
        'LocalKey equality, forwarding and replacement are preserved',
        (tester) async {
          final controllers = <AndroidInAppWebViewController>[];
          Future<void> pump(Key key) => mount(
            tester,
            InAppWebView(
              key: key,
              initialSettings: settings(),
              onWebViewCreated: (controller) =>
                  controllers.add(android(controller)),
            ),
          );
          await pump(const ValueKey('first'));
          final state = tester.state(find.byType(InAppWebView));
          await pump(ValueKey(String.fromCharCodes('first'.codeUnits)));
          expect(tester.state(find.byType(InAppWebView)), same(state));
          expect(controllers, hasLength(1));
          expect(
            tester.widget<PlatformViewLink>(find.byType(PlatformViewLink)).key,
            const ValueKey('first'),
          );
          await pump(const ValueKey('second'));
          expect(controllers, hasLength(2));
          expect(controllers.first.disposed, isTrue);
          expectComposition();
          await detach(tester);
          expect(
            native.disposals,
            native.creations.map((value) => value['id']),
          );
        },
        variant: TargetPlatformVariant.only(TargetPlatform.android),
      );

      testWidgets('equal GlobalObjectKeys refer to one outer owner', (
        tester,
      ) async {
        final identity = Object();
        final outerKey = GlobalObjectKey(identity);
        final paramsKey = GlobalObjectKey(identity);
        expect(outerKey, equals(paramsKey));
        expect(identical(outerKey, paramsKey), isFalse);
        final params = PlatformInAppWebViewWidgetCreationParams(
          key: paramsKey,
          initialSettings: settings(),
        );
        final view = InAppWebView.fromPlatformCreationParams(
          key: outerKey,
          params: params,
        );
        await mount(tester, view);
        expect(outerKey.currentWidget, same(view));
        expect(paramsKey.currentWidget, same(view));
        expect(view.platform.params.key, same(paramsKey));
        expect(native.creations, hasLength(1));
        expectComposition();
        await detach(tester);
      }, variant: TargetPlatformVariant.only(TargetPlatform.android));

      testWidgets(
        'a separate inner GlobalKey still identifies the platform view',
        (tester) async {
          final outerKey = GlobalKey();
          final innerKey = GlobalKey();
          final view = InAppWebView.fromPlatformCreationParams(
            key: outerKey,
            params: PlatformInAppWebViewWidgetCreationParams(
              key: innerKey,
              initialSettings: settings(),
            ),
          );
          await mount(tester, view);
          expect(outerKey.currentWidget, same(view));
          expect(innerKey.currentWidget, isA<PlatformViewLink>());
          expect(innerKey.currentState, isNot(same(outerKey.currentState)));
          expect(native.creations, hasLength(1));
          expectComposition();
          await detach(tester);
          expect(innerKey.currentContext, isNull);
        },
        variant: TargetPlatformVariant.only(TargetPlatform.android),
      );

      testWidgets('a direct delegate retains its own GlobalKey', (
        tester,
      ) async {
        final innerKey = GlobalKey();
        AndroidInAppWebViewController? controller;
        final delegate = AndroidInAppWebViewWidget(
          PlatformInAppWebViewWidgetCreationParams(
            key: innerKey,
            initialSettings: settings(),
            onWebViewCreated: (value) =>
                controller = value as AndroidInAppWebViewController,
          ),
        );
        await mount(tester, _DirectDelegateOwner(delegate: delegate));
        expect(innerKey.currentWidget, isA<PlatformViewLink>());
        expect(controller, isNotNull);
        expectComposition();
        await detach(tester);
        expect(controller!.disposed, isTrue);
        expect(innerKey.currentContext, isNull);
        expect(native.disposals, [native.creations.single['id']]);
      }, variant: TargetPlatformVariant.only(TargetPlatform.android));

      testWidgets('a disposed keyed owner cannot receive late creation', (
        tester,
      ) async {
        final key = GlobalKey();
        final pending = Completer<void>();
        native.nextCreation = pending;
        final controllers = <AndroidInAppWebViewController>[];
        Future<void> pump() => mount(
          tester,
          InAppWebView(
            key: key,
            initialSettings: settings(),
            onWebViewCreated: (controller) =>
                controllers.add(android(controller)),
          ),
        );
        await pump();
        expect(native.creations, hasLength(1));
        expect(controllers, isEmpty);
        await detach(tester);
        pending.complete();
        await tester.pump();
        expect(controllers, isEmpty);
        expect(native.disposals, [native.creations.single['id']]);
        await pump();
        expect(controllers, hasLength(1));
        expect(key.currentWidget, isA<InAppWebView>());
        expect(native.creations, hasLength(2));
        expectComposition();
        await detach(tester);
        expect(controllers.single.disposed, isTrue);
        expect(native.disposals, native.creations.map((value) => value['id']));
      }, variant: TargetPlatformVariant.only(TargetPlatform.android));
    });
  }

  testWidgets(
    'Windows creation failures retain the original public GlobalKeys',
    (tester) async {
      WindowsInAppWebViewPlatform.registerWith();
      final keys = [GlobalKey(), GlobalKey()];
      final failures = <WindowsWebViewCreationFailure>[];
      final subscription = WindowsWebViewCreationFailures.stream.listen(
        failures.add,
      );
      addTearDown(subscription.cancel);
      native.messenger.setMockMethodCallHandler(IN_APP_WEBVIEW_STATIC_CHANNEL, (
        call,
      ) async {
        if (call.method == 'createInAppWebView') {
          throw PlatformException(
            code: 'creation_failed',
            message: 'test failure',
          );
        }
        return null;
      });
      addTearDown(
        () => native.messenger.setMockMethodCallHandler(
          IN_APP_WEBVIEW_STATIC_CHANNEL,
          null,
        ),
      );
      await mount(
        tester,
        Row(
          children: [
            for (final key in keys)
              Expanded(
                child: InAppWebView(
                  key: key,
                  initialUrlRequest: URLRequest(
                    url: WebUri('file:///same.html'),
                  ),
                ),
              ),
          ],
        ),
      );
      await tester.pump();
      expect(failures, hasLength(2));
      expect(failures.map((value) => value.creationKey), unorderedEquals(keys));
      expect(
        failures.map((value) => value.requestedUrl),
        everyElement('file:///same.html'),
      );
      expect(keys.every((key) => key.currentWidget is InAppWebView), isTrue);
      await detach(tester);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.windows),
  );
}
