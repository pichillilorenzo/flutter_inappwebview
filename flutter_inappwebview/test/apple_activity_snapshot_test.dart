import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_ios/flutter_inappwebview_ios.dart' as ios;
import 'package:flutter_inappwebview_macos/flutter_inappwebview_macos.dart'
    as macos;
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

// Method-channel tests of the actual public wrapper and Apple Dart controllers.
// The native dictionaries below are fixtures, not native Apple observations.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  for (final platform in ['ios', 'macos']) {
    group(platform, () {
      const id = 'apple-snapshot-test';
      const channel = MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_$id',
      );
      late InAppWebViewController controller;
      late List<String> calls;
      late FutureOr<Object?> Function() respond;

      Map<String, dynamic> observation({bool attached = true}) => {
        'schemaVersion': 1,
        'availability': 'available',
        'platform': platform,
        'capturedAtMillisecondsSinceEpoch': 1700000000000,
        'windowAttached': attached,
        'viewIsHidden': false,
        'viewOrAncestorIsHidden': false,
        'applicationState': 'active',
        if (platform == 'macos') ...{
          'applicationIsHidden': false,
          if (attached) ...{
            'windowIsVisible': true,
            'windowIsMiniaturized': false,
            'windowIsOcclusionVisible': true,
          },
        },
        if (platform == 'ios' && attached) 'windowIsHidden': false,
        'inactiveSchedulingPolicyIsSupported': false,
      };

      InAppWebViewController create({dynamic controllerId = id}) {
        final params = PlatformInAppWebViewControllerCreationParams(
          id: controllerId,
        );
        return InAppWebViewController.fromPlatform(
          platform: platform == 'ios'
              ? ios.IOSInAppWebViewController(params)
              : macos.MacOSInAppWebViewController(params),
        );
      }

      setUp(() {
        calls = [];
        respond = () => observation();
        messenger.setMockMethodCallHandler(channel, (call) async {
          calls.add(call.method);
          if (call.method == 'getAppleWebViewActivitySnapshot') {
            expect(call.arguments, isNull);
            return await respond();
          }
          // Existing keepAlive callback teardown can update subscriptions.
          if (call.method == 'setScrollChangedListener' ||
              call.method == 'setConsoleMessageListener')
            return null;
          fail(
            'Unexpected method, including any JS evaluation: ${call.method}',
          );
        });
        controller = create();
      });
      tearDown(() {
        controller.dispose();
        messenger.setMockMethodCallHandler(channel, null);
      });

      test('wrapper makes one native call and preserves null/false', () async {
        final snapshot = await controller.getAppleWebViewActivitySnapshot();
        expect(calls, ['getAppleWebViewActivitySnapshot']);
        expect(
          snapshot.availability,
          AppleWebViewActivityAvailability.available,
        );
        expect(snapshot.windowAttached, true);
        expect(snapshot.viewIsHidden, false);
        expect(snapshot.inactiveSchedulingPolicyIsSupported, false);
        expect(snapshot.inactiveSchedulingPolicy, isNull);
      });
      test('every call observes a fresh response, not cached data', () async {
        final first = await controller.getAppleWebViewActivitySnapshot();
        respond = () =>
            observation(attached: false)
              ..['capturedAtMillisecondsSinceEpoch'] = 1700000001000;
        final second = await controller.getAppleWebViewActivitySnapshot();
        expect(first.windowAttached, true);
        expect(second.windowAttached, false);
        expect(second.windowIsVisible, isNull);
        expect(second.capturedAt!.isAfter(first.capturedAt!), true);
        expect(calls, List.filled(2, 'getAppleWebViewActivitySnapshot'));
      });
      test(
        'static controller reports noNativeView without contacting native',
        () async {
          final other = create(controllerId: null);
          final snapshot = await other.getAppleWebViewActivitySnapshot();
          expect(
            snapshot.availability,
            AppleWebViewActivityAvailability.noNativeView,
          );
          expect(snapshot.capturedAt, isNull);
          expect(calls, isEmpty);
          other.dispose();
        },
      );
      test('absent native view is not detached=false', () async {
        respond = () => {'availability': 'noNativeView'};
        final snapshot = await controller.getAppleWebViewActivitySnapshot();
        expect(
          snapshot.availability,
          AppleWebViewActivityAvailability.noNativeView,
        );
        expect(snapshot.windowAttached, isNull);
        expect(snapshot.capturedAt, isNull);
      });
      test('older or absent method is explicitly unavailable', () async {
        respond = () => throw MissingPluginException('older native plugin');
        final snapshot = await controller.getAppleWebViewActivitySnapshot();
        expect(
          snapshot.availability,
          AppleWebViewActivityAvailability.methodUnavailable,
        );
        expect(snapshot.windowAttached, isNull);
      });
      test('native failure propagates, with no JS fallback', () async {
        respond = () => throw PlatformException(code: 'snapshot-failure');
        await expectLater(
          controller.getAppleWebViewActivitySnapshot(),
          throwsA(
            isA<PlatformException>().having(
              (error) => error.code,
              'code',
              'snapshot-failure',
            ),
          ),
        );
        expect(calls, ['getAppleWebViewActivitySnapshot']);
      });
      for (final malformed in [
        null,
        false,
        <String, dynamic>{},
        {'availability': 'available', 'schemaVersion': 1},
      ]) {
        test('malformed response $malformed is not an observation', () async {
          respond = () => malformed;
          await expectLater(
            controller.getAppleWebViewActivitySnapshot(),
            throwsFormatException,
          );
        });
      }
      for (final keepAlive in [false, true]) {
        test(
          'disposed controller makes no call, keepAlive=$keepAlive',
          () async {
            controller.dispose(isKeepAlive: keepAlive);
            final snapshot = await controller.getAppleWebViewActivitySnapshot();
            expect(
              snapshot.availability,
              AppleWebViewActivityAvailability.disposed,
            );
            expect(snapshot.capturedAt, isNull);
            expect(
              calls.where((name) => name == 'getAppleWebViewActivitySnapshot'),
              isEmpty,
            );
            // Create a live replacement so tearDown does not exercise unrelated
            // repeated-dispose behavior of the pre-existing controller.
            controller = create();
          },
        );
        for (final failure in ['success', 'missing', 'error']) {
          test(
            'late $failure after detach is disposed, keepAlive=$keepAlive',
            () async {
              final arrived = Completer<void>();
              final reply = Completer<Object?>();
              respond = () {
                arrived.complete();
                return reply.future;
              };
              final pending = controller.getAppleWebViewActivitySnapshot();
              await arrived.future;
              controller.dispose(isKeepAlive: keepAlive);
              // A replacement on the same native id owns only its own reads.
              controller = create();
              respond = () => observation(attached: false);
              final replacement = await controller
                  .getAppleWebViewActivitySnapshot();
              expect(replacement.windowAttached, false);
              switch (failure) {
                case 'success':
                  reply.complete(observation());
                case 'missing':
                  reply.completeError(MissingPluginException());
                case 'error':
                  reply.completeError(PlatformException(code: 'late'));
              }
              final stale = await pending;
              expect(
                stale.availability,
                AppleWebViewActivityAvailability.disposed,
              );
              expect(stale.windowAttached, isNull);
              expect(stale.capturedAt, isNull);
              expect(
                replacement.availability,
                AppleWebViewActivityAvailability.available,
              );
            },
          );
        }
      }
    });
  }
}
