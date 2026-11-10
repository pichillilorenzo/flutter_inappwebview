import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_ios/flutter_inappwebview_ios.dart';
import 'package:flutter_inappwebview_macos/flutter_inappwebview_macos.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const platformChannel = SystemChannels.platform_views;
  final backends =
      <
        TargetPlatform,
        PlatformInAppWebViewWidget Function(
          PlatformInAppWebViewWidgetCreationParams,
        )
      >{
        TargetPlatform.android: AndroidInAppWebViewWidget.new,
        TargetPlatform.iOS: IOSInAppWebViewWidget.new,
        TargetPlatform.macOS: MacOSInAppWebViewWidget.new,
      };

  for (final backend in backends.entries) {
    testWidgets('${backend.key}: dispose during native creation', (
      tester,
    ) async {
      final creation = Completer<void>();
      var callbacks = 0;
      var nativeUpdates = 0;
      MethodChannel? viewChannel;
      messenger.setMockMethodCallHandler(platformChannel, (call) async {
        if (call.method == 'create') {
          viewChannel = MethodChannel(
            'com.pichillilorenzo/flutter_inappwebview_${call.arguments['id']}',
          );
          messenger.setMockMethodCallHandler(viewChannel!, (_) async {
            nativeUpdates++;
            return true;
          });
          await creation.future;
        }
        return null;
      });
      addTearDown(() {
        messenger.setMockMethodCallHandler(platformChannel, null);
        if (viewChannel != null) {
          messenger.setMockMethodCallHandler(viewChannel!, null);
        }
      });
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView.fromPlatform(
            platform: backend.value(
              PlatformInAppWebViewWidgetCreationParams(
                onScrollChanged: (_, x, y) {},
                onWebViewCreated: (_) => callbacks++,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpWidget(const SizedBox());
      creation.complete();
      await tester.pump();
      expect(callbacks, 0);
      expect(nativeUpdates, 0);
    }, variant: TargetPlatformVariant({backend.key}));

    testWidgets('${backend.key}: kept-alive detach and reattach', (
      tester,
    ) async {
      final keepAlive = InAppWebViewKeepAlive();
      final channel = MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_${keepAlive.id}',
      );
      final gates = <bool>[];
      final nativeIds = <Object?>[];
      final received = <int>[];
      final controllers = <ChannelController>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'setScrollChangedListener') {
          gates.add(call.arguments['hasListener'] as bool);
        }
        return true;
      });
      messenger.setMockMethodCallHandler(platformChannel, (call) async {
        if (call.method == 'create') {
          final bytes = call.arguments['params'] as Uint8List;
          final params =
              const StandardMessageCodec().decodeMessage(
                    ByteData.sublistView(bytes),
                  )
                  as Map;
          nativeIds.add(params['keepAliveId']);
          expect(params['hasScrollChangedListener'], false);
        }
        return null;
      });
      addTearDown(() {
        messenger.setMockMethodCallHandler(channel, null);
        messenger.setMockMethodCallHandler(platformChannel, null);
      });
      Future<void> attach() async {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: InAppWebView.fromPlatform(
              platform: backend.value(
                PlatformInAppWebViewWidgetCreationParams(
                  keepAlive: keepAlive,
                  onScrollChanged: (_, x, y) => received.add(y),
                  onWebViewCreated: (controller) =>
                      controllers.add(controller as ChannelController),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
      }

      await attach();
      await controllers.last.handler!(
        const MethodCall('onScrollChanged', {'x': 1, 'y': 2}),
      );
      await tester.pumpWidget(const SizedBox());
      expect(controllers.single.disposed, true);
      expect(gates, [true, false]);
      await attach();
      expect(controllers, hasLength(2));
      expect(identical(controllers.first, controllers.last), false);
      expect(nativeIds, [keepAlive.id, keepAlive.id]);
      await controllers.last.handler!(
        const MethodCall('onScrollChanged', {'x': 3, 'y': 4}),
      );
      expect(received, [2, 4]);
      expect(gates, [true, false, true]);
      await tester.pumpWidget(const SizedBox());
      expect(gates, [true, false, true, false]);
    }, variant: TargetPlatformVariant({backend.key}));

    for (final delayed in [false, true]) {
      testWidgets('${backend.key}: live scroll subscription, delayed=$delayed', (
        tester,
      ) async {
        final nativeCalls = <MethodCall>[];
        final views = <Map<Object?, Object?>>[];
        final creation = Completer<void>();
        MethodChannel? viewChannel;
        ChannelController? controller;
        var controllerCreations = 0;
        final received = <String>[];

        messenger.setMockMethodCallHandler(platformChannel, (call) async {
          if (call.method == 'create') {
            final args = (call.arguments as Map).cast<Object?, Object?>();
            views.add(args);
            viewChannel = MethodChannel(
              'com.pichillilorenzo/flutter_inappwebview_${args['id']}',
            );
            messenger.setMockMethodCallHandler(viewChannel!, (call) async {
              nativeCalls.add(call);
              return true;
            });
            if (delayed) await creation.future;
          }
          return null;
        });
        addTearDown(() {
          messenger.setMockMethodCallHandler(platformChannel, null);
          if (viewChannel != null) {
            messenger.setMockMethodCallHandler(viewChannel!, null);
          }
        });

        Future<void> pump(void Function(dynamic, int, int)? callback) async {
          await tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.ltr,
              child: InAppWebView.fromPlatform(
                platform: backend.value(
                  PlatformInAppWebViewWidgetCreationParams(
                    onScrollChanged: callback,
                    onWebViewCreated: (value) {
                      controller = value as ChannelController;
                      controllerCreations++;
                    },
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
        }

        await pump(null);
        expect(views, hasLength(1));
        final bytes = views.single['params'] as Uint8List;
        final params =
            const StandardMessageCodec().decodeMessage(
                  ByteData.sublistView(bytes),
                )
                as Map;
        expect(params['hasScrollChangedListener'], false);

        await pump((value, x, y) {
          expect(value, same(controller));
          received.add('A:$x,$y');
        });
        if (delayed) {
          expect(controller, isNull);
          creation.complete();
          await tester.pump();
        }
        final originalController = controller;
        expect(originalController, isNotNull);
        await controller!.handler!(
          const MethodCall('onScrollChanged', {'x': 3, 'y': 4}),
        );
        final changesAfterA = nativeCalls
            .where((call) => call.method == 'setScrollChangedListener')
            .length;

        await pump((value, x, y) {
          expect(value, same(originalController));
          received.add('B:$x,$y');
        });
        await controller!.handler!(
          const MethodCall('onScrollChanged', {'x': 5, 'y': 6}),
        );
        expect(
          nativeCalls
              .where((call) => call.method == 'setScrollChangedListener')
              .length,
          changesAfterA,
          reason:
              'A → B changes the Dart callback without toggling the native gate',
        );
        await pump(null);
        await controller!.handler!(
          const MethodCall('onScrollChanged', {'x': 7, 'y': 8}),
        );
        expect(received, ['A:3,4', 'B:5,6']);
        expect(views, hasLength(1));
        expect(controller, same(originalController));
        expect(controllerCreations, 1);
        final gates = nativeCalls
            .where((call) => call.method == 'setScrollChangedListener')
            .map((call) => call.arguments['hasListener']);
        expect(gates, delayed ? [true, false] : [false, true, false]);
        expect(
          nativeCalls.where((call) => call.method == 'setSettings'),
          isEmpty,
        );

        await tester.pumpWidget(const SizedBox());
        expect(controller!.disposed, true);
      }, variant: TargetPlatformVariant({backend.key}));
    }
  }

  for (final platform in ['android', 'ios', 'macos']) {
    test('$platform headless creation forwards listener presence', () async {
      const channel = MethodChannel(
        'com.pichillilorenzo/flutter_headless_inappwebview',
      );
      final runs = <Map>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'run') runs.add(call.arguments as Map);
        return true;
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
      for (final enabled in [false, true]) {
        final params = PlatformHeadlessInAppWebViewCreationParams(
          onScrollChanged: enabled ? (_, x, y) {} : null,
        );
        final PlatformHeadlessInAppWebView headless = switch (platform) {
          'android' => AndroidHeadlessInAppWebView(params),
          'ios' => IOSHeadlessInAppWebView(params),
          _ => MacOSHeadlessInAppWebView(params),
        };
        await headless.run();
        expect(runs.last['params']['hasScrollChangedListener'], enabled);
        final lifecycleChannel = MethodChannel(
          'com.pichillilorenzo/flutter_headless_inappwebview_${headless.id}',
        );
        messenger.setMockMethodCallHandler(lifecycleChannel, (_) async => true);
        await headless.dispose();
        messenger.setMockMethodCallHandler(lifecycleChannel, null);
      }
    });
  }
}
