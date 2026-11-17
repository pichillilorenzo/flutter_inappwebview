import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

const _channel = MethodChannel('com.pichillilorenzo/flutter_inappwebview_test');

class _Controller with ChannelController {
  final heard = <String>[];

  _Controller() {
    channel = _channel;
    handler = (call) async => heard.add(call.method);
    initMethodCallHandler();
  }

  @override
  void dispose() {}
}

Future<void> _nativeSends(String method) => TestDefaultBinaryMessengerBinding
    .instance
    .defaultBinaryMessenger
    .handlePlatformMessage(
      _channel.name,
      const StandardMethodCodec().encodeMethodCall(MethodCall(method)),
      (_) {},
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('A channel controller disposed while its native side lives on', () {
    test(
      'leaves the detached handler to hear what the native side sends',
      () async {
        final controller = _Controller();
        final heardDetached = <String>[];

        controller.disposeChannel(
          removeMethodCallHandler: false,
          detachedHandler: (call) async => heardDetached.add(call.method),
        );
        await _nativeSends('onRenderProcessGone');

        expect(heardDetached, ['onRenderProcessGone']);
        expect(controller.heard, isEmpty);
      },
    );

    test(
      'keeps the previous handler silent when no detached handler is given',
      () async {
        final controller = _Controller();

        controller.disposeChannel(removeMethodCallHandler: false);
        await _nativeSends('onRenderProcessGone');

        expect(controller.heard, isEmpty);
      },
    );

    test(
      'leaves the channel to the controller that took it over in the meantime',
      () async {
        final first = _Controller();
        final second = _Controller();

        first.disposeChannel(
          removeMethodCallHandler: false,
          detachedHandler: (call) async =>
              fail('the replaced handler was called'),
        );
        await _nativeSends('onLoadStop');

        expect(second.heard, ['onLoadStop']);
        expect(first.heard, isEmpty);
      },
    );

    test('hears nothing once disposed for good', () async {
      final controller = _Controller();

      controller.disposeChannel(
        detachedHandler: (call) async => fail('a removed handler was called'),
      );
      await _nativeSends('onRenderProcessGone');

      expect(controller.heard, isEmpty);
    });
  });
}
