import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview_linux/flutter_inappwebview_linux.dart';
import 'package:flutter_inappwebview_windows/flutter_inappwebview_windows.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final backends =
      <
        String,
        PlatformInAppWebViewWidget Function(
          PlatformInAppWebViewWidgetCreationParams,
        )
      >{
        'Windows': WindowsInAppWebViewWidget.new,
        'Linux': LinuxInAppWebViewWidget.new,
      };
  for (final entry in backends.entries) {
    for (final delayed in [false, true]) {
      testWidgets(
        '${entry.key} console subscriptions across rebuild, delayed=$delayed',
        (tester) async {
          const channel = MethodChannel(
            'com.pichillilorenzo/flutter_inappwebview_42',
          );
          final calls = <MethodCall>[];
          final received = <String>[];
          messenger.setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            return null;
          });
          addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
          late BuildContext context;
          await tester.pumpWidget(
            Builder(
              builder: (value) {
                context = value;
                return const SizedBox();
              },
            ),
          );
          ChannelController? controller;
          var creations = 0;
          final delegate = entry.value(
            PlatformInAppWebViewWidgetCreationParams(
              onWebViewCreated: (value) {
                controller = value as ChannelController;
                creations++;
              },
            ),
          );
          // Only the platform-view creation completion is mocked. These are the
          // production delegate's build/updateParams/controller/dispose paths.
          final dynamic view = delegate.build(context);
          expect(view.creationParams['hasConsoleMessageListener'], false);
          if (!delayed) view.onPlatformViewCreated(42);
          delegate.updateParams(
            PlatformInAppWebViewWidgetCreationParams(
              onConsoleMessage: (_, message) =>
                  received.add('A:${message.message}'),
            ),
          );
          if (delayed) view.onPlatformViewCreated(42);
          await tester.pump();
          final original = controller;
          await controller!.handler!(
            const MethodCall('onConsoleMessageBatch', {
              'messages': [
                {'message': 'one', 'messageLevel': 1},
                {'message': 'two', 'messageLevel': 1},
              ],
            }),
          );
          final changesAfterA = calls.length;
          delegate.updateParams(
            PlatformInAppWebViewWidgetCreationParams(
              onConsoleMessage: (_, message) =>
                  received.add('B:${message.message}'),
            ),
          );
          await tester.pump();
          expect(calls, hasLength(changesAfterA));
          await controller!.handler!(
            const MethodCall('onConsoleMessage', {
              'message': 'three',
              'messageLevel': 1,
            }),
          );
          delegate.updateParams(PlatformInAppWebViewWidgetCreationParams());
          await tester.pump();
          await controller!.handler!(
            const MethodCall('onConsoleMessageBatch', {
              'messages': [
                {'message': 'after removal', 'messageLevel': 3},
              ],
            }),
          );
          expect(received, ['A:one', 'A:two', 'B:three']);
          expect(controller, same(original));
          expect(creations, 1);
          expect(
            calls
                .where((call) => call.method == 'setConsoleMessageListener')
                .map((call) => call.arguments['hasListener']),
            delayed ? [true, false] : [false, true, false],
          );
          expect(calls.where((call) => call.method == 'setSettings'), isEmpty);
          delegate.dispose();
          expect(controller!.disposed, true);
        },
      );
    }
    testWidgets(
      '${entry.key} late native creation cannot revive a disposed delegate',
      (tester) async {
        late BuildContext context;
        await tester.pumpWidget(
          Builder(
            builder: (value) {
              context = value;
              return const SizedBox();
            },
          ),
        );
        var callbacks = 0;
        final delegate = entry.value(
          PlatformInAppWebViewWidgetCreationParams(
            onWebViewCreated: (_) => callbacks++,
          ),
        );
        final dynamic view = delegate.build(context);
        delegate.dispose();
        view.onPlatformViewCreated(42);
        expect(callbacks, 0);
      },
    );
  }
}
