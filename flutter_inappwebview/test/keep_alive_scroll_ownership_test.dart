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
    testWidgets('${backend.key}: cancel pending kept-alive attachment', (
      tester,
    ) async {
      final native = _KeptAliveScrollView(messenger);
      addTearDown(native.dispose);
      var createdCallbacks = 0;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView.fromPlatform(
            platform: backend.value(
              PlatformInAppWebViewWidgetCreationParams(
                keepAlive: native.keepAlive,
                onScrollChanged: (_, x, y) {},
                onWebViewCreated: (_) => createdCallbacks++,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(native.creations, hasLength(1));
      final pendingGate = native.hasListener;
      await tester.pumpWidget(const SizedBox());
      final detachedGate = native.hasListener;
      native.creations.single.complete();
      await tester.pump();
      await tester.pump();

      expect(createdCallbacks, 0);
      expect(pendingGate, false, reason: 'No controller owns the subscription');
      expect(detachedGate, false);
      expect(native.hasListener, false);
      expect(
        native.updates,
        isEmpty,
        reason: 'No stale-owner cleanup is needed',
      );
    }, variant: TargetPlatformVariant({backend.key}));

    for (final olderCompletesFirst in [true, false]) {
      for (final newHasListener in [true, false]) {
        testWidgets('${backend.key}: replace pending kept-alive attachment, '
            'olderFirst=$olderCompletesFirst, listener=$newHasListener', (
          tester,
        ) async {
          final native = _KeptAliveScrollView(messenger);
          addTearDown(native.dispose);
          var oldCreated = 0;
          var newCreated = 0;
          final received = <String>[];

          Future<void> attach({required bool old}) async {
            await tester.pumpWidget(
              Directionality(
                textDirection: TextDirection.ltr,
                child: InAppWebView.fromPlatform(
                  platform: backend.value(
                    PlatformInAppWebViewWidgetCreationParams(
                      keepAlive: native.keepAlive,
                      onScrollChanged: old || newHasListener
                          ? (_, x, y) =>
                                received.add('${old ? 'old' : 'new'}:$y')
                          : null,
                      onWebViewCreated: (_) {
                        if (old) {
                          oldCreated++;
                        } else {
                          newCreated++;
                        }
                      },
                    ),
                  ),
                ),
              ),
            );
            await tester.pump();
          }

          await attach(old: true);
          await tester.pumpWidget(const SizedBox());
          await attach(old: false);
          expect(native.creations, hasLength(2));
          final pendingGate = native.hasListener;

          if (olderCompletesFirst) {
            native.creations.first.complete();
            await tester.pump();
            await tester.pump();
            expect(oldCreated, 0);
            expect(newCreated, 0);
            expect(native.updates, isEmpty);
          }
          native.creations.last.complete();
          await tester.pump();
          await tester.pump();
          await native.scroll(1);

          if (!olderCompletesFirst) {
            native.creations.first.complete();
            await tester.pump();
            await tester.pump();
          }
          await native.scroll(2);

          expect(pendingGate, false);
          expect(oldCreated, 0);
          expect(newCreated, 1);
          expect(native.hasListener, newHasListener);
          expect(native.updates, [newHasListener]);
          expect(received, newHasListener ? ['new:1', 'new:2'] : isEmpty);

          await tester.pumpWidget(const SizedBox());
          expect(native.hasListener, false);
        }, variant: TargetPlatformVariant({backend.key}));
      }
    }
  }
}

/// Models the native factories' synchronous gate update while deliberately
/// delaying the platform creation responses. Native keepAlive disposal retains
/// the view and its gate, so cancelling a pending widget cannot reset it for us.
class _KeptAliveScrollView {
  _KeptAliveScrollView(this.messenger) {
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'setScrollChangedListener') {
        hasListener = call.arguments['hasListener'] as bool;
        updates.add(hasListener);
      }
      return true;
    });
    messenger.setMockMethodCallHandler(SystemChannels.platform_views, (
      call,
    ) async {
      if (call.method == 'create') {
        final bytes = call.arguments['params'] as Uint8List;
        final params =
            const StandardMessageCodec().decodeMessage(
                  ByteData.sublistView(bytes),
                )
                as Map;
        expect(params['keepAliveId'], keepAlive.id);
        hasListener = params['hasScrollChangedListener'] as bool;
        final creation = Completer<void>();
        creations.add(creation);
        await creation.future;
      }
      return null;
    });
  }

  final TestDefaultBinaryMessenger messenger;
  final keepAlive = InAppWebViewKeepAlive();
  late final channel = MethodChannel(
    'com.pichillilorenzo/flutter_inappwebview_${keepAlive.id}',
  );
  final creations = <Completer<void>>[];
  final updates = <bool>[];
  bool hasListener = false;

  Future<void> scroll(int y) async {
    if (!hasListener) return;
    // Exercise the current registered channel handler, not a saved controller.
    await messenger.handlePlatformMessage(
      channel.name,
      const StandardMethodCodec().encodeMethodCall(
        MethodCall('onScrollChanged', {'x': 0, 'y': y}),
      ),
      (_) {},
    );
  }

  void dispose() {
    for (final creation in creations) {
      if (!creation.isCompleted) creation.complete();
    }
    messenger.setMockMethodCallHandler(channel, null);
    messenger.setMockMethodCallHandler(SystemChannels.platform_views, null);
  }
}
