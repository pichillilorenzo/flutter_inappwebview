import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

typedef ConsoleCallback = void Function(
  dynamic controller,
  ConsoleMessage message,
);

// Exercise the real platform-channel handlers in every native Dart package.
void testConsoleMessageController(
  PlatformInAppWebViewController Function(ConsoleCallback? callback) create,
  Future<void> Function(PlatformInAppWebViewController, ConsoleCallback?)
  update,
  PlatformInAppWebViewController Function(PlatformInAppBrowserEvents)
  createBrowser,
) {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const codec = StandardMethodCodec();
  const channel = MethodChannel(
    'com.pichillilorenzo/flutter_inappwebview_console-batch',
  );
  late PlatformInAppWebViewController controller;
  late List<MethodCall> nativeCalls;
  final received = <String>[];

  Future<void> deliver(List<String> messages, {bool legacy = false}) async {
    final response = Completer<ByteData?>();
    final entries = messages
        .map((message) => {'message': message, 'messageLevel': 1})
        .toList();
    // ignore: deprecated_member_use
    binding.defaultBinaryMessenger.handlePlatformMessage(
      channel.name,
      codec.encodeMethodCall(
        MethodCall(
          legacy ? 'onConsoleMessage' : 'onConsoleMessageBatch',
          legacy ? entries.single : {'messages': entries},
        ),
      ),
      response.complete,
    );
    final envelope = await response.future;
    if (envelope != null) codec.decodeEnvelope(envelope);
  }

  setUp(() {
    received.clear();
    nativeCalls = [];
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      nativeCalls.add(call);
      return null;
    });
    controller = create((_, message) => received.add(message.message));
  });

  tearDown(() {
    if (!(controller as ChannelController).disposed) controller.dispose();
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('batch and legacy messages preserve every callback and order', () async {
    for (var start = 0; start < 10000; start += 64) {
      await deliver(
        List.generate((10000 - start).clamp(0, 64), (i) => '${start + i}'),
      );
    }
    await deliver(['legacy'], legacy: true);
    expect(received, [...List.generate(10000, (i) => '$i'), 'legacy']);
  });

  test(
    'callback failure is reported and later batch entries still arrive',
    () async {
      final errors = <FlutterErrorDetails>[];
      final previous = FlutterError.onError;
      FlutterError.onError = errors.add;
      try {
        await update(controller, (_, message) {
          received.add(message.message);
          if (message.message == 'first') throw StateError('consumer failed');
        });
        await deliver(['first', 'second', 'third']);
        expect(received, ['first', 'second', 'third']);
        expect(errors, hasLength(1));
        expect(errors.single.exception, isA<StateError>());
        expect(errors.single.stack, isNotNull);
      } finally {
        FlutterError.onError = previous;
      }
    },
  );

  test(
    'live callback replacement and removal apply during an in-flight batch',
    () async {
      await update(controller, (_, message) {
        received.add('A:${message.message}');
        unawaited(
          update(controller, (_, next) {
            received.add('B:${next.message}');
            unawaited(update(controller, null));
          }),
        );
      });
      await deliver(['one', 'two', 'three']);
      expect(received, ['A:one', 'B:two']);
      await deliver(['queued after unsubscribe']);
      expect(received, ['A:one', 'B:two']);
      expect(
        nativeCalls
            .where((call) => call.method == 'setConsoleMessageListener')
            .map((call) => call.arguments),
        [
          {'hasListener': false},
        ],
      );
      await update(
        controller,
        (_, message) => received.add('C:${message.message}'),
      );
      await deliver(['reattached']);
      expect(received.last, 'C:reattached');
      expect(nativeCalls.last.arguments, {'hasListener': true});
    },
  );

  test('dispose inside a callback stops the remainder of that batch', () async {
    await update(controller, (_, message) {
      received.add(message.message);
      controller.dispose();
    });
    await deliver(['before close', 'after close']);
    expect(received, ['before close']);
    await update(controller, (_, message) => received.add('stale'));
    expect(nativeCalls, isEmpty);
  });

  test(
    'InAppBrowser keeps its event handler without widget callbacks',
    () async {
      controller.dispose();
      controller = createBrowser(
        _ConsoleBrowserEvents((message) => received.add(message.message)),
      );
      await deliver(['browser one', 'browser two']);
      await deliver(['legacy browser'], legacy: true);
      expect(received, ['browser one', 'browser two', 'legacy browser']);
      expect(nativeCalls, isEmpty);
    },
  );

  test(
    'keep-alive detachment disables native forwarding before disposal',
    () async {
      controller.dispose(isKeepAlive: true);
      await Future<void>.value();
      expect(nativeCalls.single.method, 'setConsoleMessageListener');
      expect(nativeCalls.single.arguments, {'hasListener': false});
      await deliver(['detached']);
      expect(received, isEmpty);
    },
  );
}

class _ConsoleBrowserEvents extends PlatformInAppBrowserEvents {
  _ConsoleBrowserEvents(this.callback);
  final void Function(ConsoleMessage) callback;
  @override
  void onConsoleMessage(ConsoleMessage message) => callback(message);
}
