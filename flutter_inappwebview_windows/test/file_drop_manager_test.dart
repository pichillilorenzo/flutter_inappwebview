import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_windows/flutter_inappwebview_windows.dart';

const MethodChannel _channel = MethodChannel(
  'com.pichillilorenzo/flutter_inappwebview_filedrop',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final codec = const StandardMethodCodec();

  Future<void> sendNativeCall(MethodCall call) {
    final completer = Completer<void>();
    messenger.handlePlatformMessage(
      _channel.name,
      codec.encodeMethodCall(call),
      (_) => completer.complete(),
    );
    return completer.future;
  }

  tearDown(() async {
    await WindowsFileDropManager.instance.stop();
    messenger.setMockMethodCallHandler(_channel, null);
  });

  testWidgets('enables native delivery and sends drag acceptance', (_) async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(_channel, (call) async {
      calls.add(call);
      return null;
    });
    WindowsFileDropEvent? dropped;

    await WindowsFileDropManager.instance.start(
      onDrag: (event) => event.x == 12.5 && event.paths.single == r'C:\x.otz',
      onDrop: (event) => dropped = event,
    );
    await sendNativeCall(
      const MethodCall('onFileDrop', <String, Object>{
        'event': 'enter',
        'paths': <String>[r'C:\x.otz'],
        'x': 12.5,
        'y': 40.0,
      }),
    );
    await sendNativeCall(
      const MethodCall('onFileDrop', <String, Object>{
        'event': 'drop',
        'paths': <String>[r'C:\x.otz'],
        'x': 12.5,
        'y': 40.0,
      }),
    );

    expect(calls.map((call) => call.method), <String>[
      'setEnabled',
      'setAccepted',
    ]);
    expect(calls[0].arguments, <String, bool>{'enabled': true});
    expect(calls[1].arguments, <String, bool>{'accepted': true});
    expect(dropped?.paths, <String>[r'C:\x.otz']);
  });

  testWidgets('fails closed when the drag handler throws', (_) async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(_channel, (call) async {
      calls.add(call);
      return null;
    });
    await WindowsFileDropManager.instance.start(
      onDrag: (_) => throw StateError('bad drop region'),
      onDrop: (_) {},
    );

    await sendNativeCall(
      const MethodCall('onFileDrop', <String, Object>{
        'event': 'over',
        'paths': <String>[],
        'x': 1.0,
        'y': 2.0,
      }),
    );

    expect(calls.last.arguments, <String, bool>{'accepted': false});
  });
}
