import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_android/flutter_inappwebview_android.dart';
import 'package:flutter_inappwebview_ios/flutter_inappwebview_ios.dart';
import 'package:flutter_inappwebview_linux/flutter_inappwebview_linux.dart';
import 'package:flutter_inappwebview_macos/flutter_inappwebview_macos.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_inappwebview_windows/flutter_inappwebview_windows.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
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
        TargetPlatform.windows: WindowsInAppWebViewWidget.new,
        TargetPlatform.linux: LinuxInAppWebViewWidget.new,
      };

  for (final backend in backends.entries) {
    final cases = [
      (replaceOwner: false, oldCompletesFirst: false, hasListener: false),
      for (final oldCompletesFirst in [false, true])
        for (final hasListener in [false, true])
          (
            replaceOwner: true,
            oldCompletesFirst: oldCompletesFirst,
            hasListener: hasListener,
          ),
    ];
    for (final scenario in cases) {
      final replaceOwner = scenario.replaceOwner;
      testWidgets('${backend.key}: keepAlive pending creation $scenario', (
        tester,
      ) async {
        final messenger =
            TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
        final keepAlive = InAppWebViewKeepAlive();
        final channel = MethodChannel(
          'com.pichillilorenzo/flutter_inappwebview_${keepAlive.id}',
        );
        const manager = MethodChannel(
          'com.pichillilorenzo/flutter_inappwebview_manager',
        );
        final desktop =
            backend.key == TargetPlatform.windows ||
            backend.key == TargetPlatform.linux;
        final creations = <Completer<void>>[];
        final channels = <MethodChannel>[
          channel,
          manager,
          SystemChannels.platform_views,
        ];
        bool? nativeGate;
        final callbacks = <String>[];
        final received = <String>[];
        ChannelController? currentController;

        messenger.setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'setConsoleMessageListener') {
            nativeGate = call.arguments['hasListener'] as bool;
          }
          return true;
        });
        Future<Object?> create(MethodCall call) async {
          if (call.method != 'create' && call.method != 'createInAppWebView') {
            // Native disposal retains keepAlive views; it does not reset
            // their publisher or stand in for subscription cleanup here.
            return null;
          }
          final Map params;
          if (desktop) {
            params = call.arguments as Map;
          } else {
            final bytes = call.arguments['params'] as Uint8List;
            params =
                const StandardMessageCodec().decodeMessage(
                      ByteData.sublistView(bytes),
                    )
                    as Map;
          }
          expect(params['keepAliveId'], keepAlive.id);
          nativeGate = params['hasConsoleMessageListener'] as bool;
          final creation = Completer<void>();
          creations.add(creation);
          final id = 100 + creations.length;
          if (desktop) {
            for (final suffix in ['', '_events']) {
              final nativeChannel = MethodChannel(
                'com.pichillilorenzo/custom_platform_view_$id$suffix',
              );
              channels.add(nativeChannel);
              messenger.setMockMethodCallHandler(
                nativeChannel,
                (_) async => null,
              );
            }
          }
          await creation.future;
          return desktop ? id : null;
        }

        messenger.setMockMethodCallHandler(manager, create);
        messenger.setMockMethodCallHandler(
          SystemChannels.platform_views,
          create,
        );
        addTearDown(() {
          for (final registered in channels) {
            messenger.setMockMethodCallHandler(registered, null);
          }
        });

        Future<void> attach(String owner, {bool hasListener = true}) async {
          await tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.ltr,
              child: InAppWebView.fromPlatform(
                platform: backend.value(
                  PlatformInAppWebViewWidgetCreationParams(
                    keepAlive: keepAlive,
                    onConsoleMessage: hasListener
                        ? (_, message) =>
                              received.add('$owner:${message.message}')
                        : null,
                    onWebViewCreated: (controller) {
                      callbacks.add(owner);
                      currentController = controller as ChannelController;
                    },
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
        }

        await attach('old');
        expect(creations, hasLength(1));
        await tester.pumpWidget(const SizedBox());

        if (replaceOwner) {
          await attach('new', hasListener: scenario.hasListener);
          expect(creations, hasLength(2));
          if (scenario.oldCompletesFirst) {
            creations.first.complete();
            await tester.pump();
            await tester.pump();
            expect(callbacks, isEmpty);
            expect(nativeGate, false);
          }
          creations.last.complete();
          await tester.pump();
          await tester.pump();
          expect(callbacks, ['new']);
          expect(nativeGate, scenario.hasListener);
        }

        if (!creations.first.isCompleted) creations.first.complete();
        await tester.pump();
        await tester.pump();
        expect(callbacks, replaceOwner ? ['new'] : isEmpty);
        expect(
          nativeGate,
          replaceOwner && scenario.hasListener,
          reason: replaceOwner
              ? 'Stale creation must not disable a newer owner'
              : 'A retained view without a Dart owner must not forward logs',
        );
        if (replaceOwner) {
          await currentController!.handler!(
            const MethodCall('onConsoleMessageBatch', {
              'messages': [
                {'message': 'still attached', 'messageLevel': 3},
              ],
            }),
          );
          expect(
            received,
            scenario.hasListener ? ['new:still attached'] : isEmpty,
          );
          await tester.pumpWidget(const SizedBox());
          await tester.pump();
          expect(nativeGate, false);
        }
      }, variant: TargetPlatformVariant({backend.key}));
    }
  }
}
